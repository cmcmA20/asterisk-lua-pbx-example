dofile("/etc/asterisk/include/common/anpm.lua")
dofile("/etc/asterisk/include/common/call.lua")
dofile("/etc/asterisk/include/common/message.lua")

legacy_out_prefix = "49" -- kinda wonky

e = {}

e.default = {}
e.default.include = { "local_legacy_in"
                    , "local_legacy_out"
                    , "local_sip_in"
                    , "interbranch"
                    , "in_"
                    , "out"
                    , "messages"
                    , "features"
                    }

e.features = {}
e.features["_*43*XXXX"] = function(ctx, ext)
  app.Verbose("Not yet implemented")
end


e.messages = {}
for _,sw in pairs(self_branch(gateways)) do
  for _,np in pairs(sw(number_patterns)) do
    e.messages[np] = function(ctx, ext)
      msg(ext)
    end
  end
end


e.local_legacy_in = {}
for _,sw in pairs(local_legacy_sws) do
  for _,np in pairs(sw(number_patterns)) do
    e.local_legacy_in[np] = function(ctx, ext)
      dial_local_legacy(ext)
    end
  end
end

function legacy_out(ctx, ext)
  local real_ext = string.sub(ext, 3)
  app.Verbose("Dirty hack for legacy lines")
  dial_out(real_ext)
end
e.local_legacy_out = {}
for _,np in pairs(self_ssw(number_patterns)) do
  local new_np = "_" .. legacy_out_prefix .. string.sub(np, 2)
  e.local_legacy_out[new_np] = legacy_out
end
-- TODO multiple uplinks
for _,np in pairs(provider_ssws[1](number_patterns)) do
  local new_np = "_" .. legacy_out_prefix .. string.sub(np, 2)
  e.local_legacy_out[new_np] = legacy_out
end

e.local_sip_in = {}
for _,sw in pairs(self_branch(gateways)) do
  for _,np in pairs(sw(number_patterns)) do
    e.local_sip_in[np] = function(ctx, ext)
      dial_local_sip(ext)
    end
  end
end

e.interbranch = {}
for _,br in pairs(branch_table) do
  for _,sw in pairs(br(gateways)) do
    for _,np in pairs(sw(number_patterns)) do
      e.interbranch[np] = function(ctx, ext)
        dial_interbranch(ext)
      end
    end
  end
end

function handle_incoming_calls(ctx, ext)
  local cid_num = channel.CALLERID("num"):get()
  if number_is_public(cid_num) then
    cid_num = "8" .. cid_num
    channel.CALLERID("num"):set(cid_num)
  end

  -- for my gf
  -- if cid_num == "89131234567" then
  --  dial_local_sip("6123")
  --end

  app.Answer(150)
  app.Read("input", "custom/hello1", 4, "s", 1, 10)
  local input = channel.input:get()
  app.Verbose("Input: " .. input)

  -- DISREGARD THAT I HAVE GOT THE NEATEST CHICK
  -- Katya I<3U
--  if cid_num == "89131234567" and input == "6123" then
--    local pswn = provider_ssws[1](sw_name) -- TODO multiple uplinks
--    app.Set("CALLERID(all)=38331234567")
--    ds = "SIP/" .. pswn .. "/" .. "89130000000"
--    app.Dial(ds)
--  end
--

  if number_is_local(input) or number_is_interbranch(input) then
    dial_out(input)
  end

  -- fun stuff begin
  if input == "420" then
    app.Playback("custom/smokeweed")
  end
  if input == "421" then
    app.Playback("custom/gangster")
  end
  if input == "422" then
    app.Playback("custom/cygo")
  end
  -- fun stuff end

  app.Queue("secretary", "t", nil, nil, 10)
  app.Queue("project_support", "t", nil, nil, 20)
  --app.Wait(15)
end

e.in_ = {}
e.in_["_31234567"] = handle_incoming_calls

e.out = {}
-- TODO multiple uplinks
for _,np in pairs(provider_ssws[1](number_patterns)) do
  e.out[np] = function(ctx, ext)
    dial_out(ext)
  end
end

-- extension table
extensions = e
