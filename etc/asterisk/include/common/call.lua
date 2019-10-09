dofile("/etc/asterisk/include/local/config.lua")

-- helper functions
function call_extract_cid()
  return channel.CALLERID("name"):get(), channel.CALLERID("num"):get()
end

function call_info(ext)
  local cid_name, cid_num = call_extract_cid()
  app.Verbose("Caller ID: " .. cid_name .. "<" .. cid_num .. ">")
  app.Verbose("Caller type: " .. number_type(cid_num))
  app.Verbose("Callee extension: " .. ext)
  app.Verbose("Callee type: " .. number_type(ext))
end

-- number classification
function number_belongs_to_sw(number, sw)
  local exists = false
  for _,np in pairs(sw(number_patterns)) do
    if match_number(np, number) then
      exists = true
      break
    end
  end
  return exists
end

function number_is_local_legacy(number)
  local exists = false
  local sn = nil
  for _,sw in pairs(local_legacy_sws) do
    exists = number_belongs_to_sw(number, sw)
    if exists then
      sn = sw(sw_name)
      break
    end
  end
  return sn
end

function number_is_local_sip(number)
  local exists = false
  local sn = nil
  for _,sw in pairs(self_branch(gateways)) do
    exists = number_belongs_to_sw(number, sw)
    if exists then
      sn = sw(sw_name)
      break
    end
  end
  return sn
end

function number_is_local(number)
  local sn = nil
  sn = number_is_local_legacy(number)
  if not sn then
    sn = number_is_local_sip(number)
  end
  return sn
end

function number_is_interbranch(number)
  local sn = nil
  local cn = nil
  local exists = false
  for _,br in pairs(branch_table) do
    if exists then
      break
    end
    if br(city_name) ~= self_branch_name then
      for _,sw in pairs(br(gateways)) do
        exists = number_belongs_to_sw(number, sw)
        if exists then
          sn = sw(sw_name)
          cn = br(city_name)
          break
        end
      end
    end
  end
  return sn, cn
end

function number_is_public(number)
  return number_type(number) == "public"
end

function number_type(number)
  local legacy_sn = number_is_local_legacy(number)
  if legacy_sn then
    return "local legacy (" .. legacy_sn .. ")"
  end
  local local_sn = number_is_local_sip(number)
  if local_sn then
    return "local SIP (" .. local_sn .. ")"
  end
  local ib_sn, ib_cn = number_is_interbranch(number)
  if ib_sn and ib_cn then
    return "branch " .. ib_cn .. " (" .. ib_sn .. ")"
  end
  if not t then
    return "public"
  end
end


-- dialing functions
function dial_error()
  app.Verbose("Something's terribly wrong")
  app.Hangup()
end

function dial_local_sip(ext)
  local cid_name, cid_num = call_extract_cid()
  local from_sn = number_is_local_sip(cid_num)
  local to_sn = number_is_local_sip(ext)

  call_info(ext)
  if not to_sn then
    dial_error()
  end

  if from_sn == to_sn or self_ssw_name == to_sn then
    ds = "SIP/" .. ext
  else
    ds = "SIP/" .. to_sn .. "/" .. ext
  end
  app.Dial(ds)
end

function dial_local_legacy(ext)
  local cid_name, cid_num = call_extract_cid()
  local from_lsn = number_is_local_legacy(cid_num)
  local to_lsn = number_is_local_legacy(ext)

  call_info(ext)
  if from_lsn == to_lsn then
    --app.Verbose("A legacy switch subscribers should call each other directly, hanging up")
    --app.Hangup()
  end

  if to_lsn then
    ds = "SIP/" .. to_lsn .. "/" .. ext
    if from_lsn == to_lsn then
      ds = "SIP/" .. ext
    end
    app.Dial(ds)
  else
    dial_error()
  end
end

function dial_local(ext)
  local to_sn = number_is_local_legacy(ext)
  if to_sn then
    dial_local_legacy(ext)
  else
    dial_local_sip(ext)
  end
end

function dial_interbranch(ext)
  local cid_name, cid_num = call_extract_cid()
  local to_sn,_ = number_is_interbranch(ext)

  call_info(ext)
  if to_sn then
    ds = "SIP/" .. to_sn .. "/" .. ext
    app.Dial(ds)
  else
    if number_type(ext) == "public" then
      -- TODO interbranch peering
      app.Verbose("Attempting to place a public call through another branch")
      dial_error()
    else
      dial_error()
    end
  end
end

function dial_public(ext)
  local cid_name, cid_num = call_extract_cid()
  call_info(ext)
  if number_type(cid_num) == "public" then
    app.Verbose("I see what you did there")
    dial_error()
  end
  local from_sn,_ = number_is_interbranch(cid_num)
  if from_sn then
    -- TODO interbranch peering
    app.Verbose("Another branch is trying to place a public call through us")
    dial_error()
  end
  from_sn = number_is_local(cid_num)
  if from_sn then
    local pswn = provider_ssws[1](sw_name) -- TODO multiple uplinks
    -- set to your cid (get it from your provider)
    app.Set("CALLERID(all)=3831234567")
    ds = "SIP/" .. pswn .. "/" .. ext
    app.Dial(ds)
  else
    dial_error()
  end
end

function dial_out(ext)
  local to_sw = number_is_local(ext)
  if to_sw then
    dial_local(ext)
    return
  end
  to_sw = number_is_interbranch(ext)
  if to_sw then
    dial_interbranch(ext)
    return
  end
  if number_is_public(ext) then
    dial_public(ext)
    return
  end
end
