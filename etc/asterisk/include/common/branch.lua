dofile("/etc/asterisk/include/common/general.lua")

-- branch table
branch_table = { Branch("Moscow", { SoftSwitch("switch-1", {"_1[0-5]XX", "_173[13]"})
                                  , SoftSwitch("switch-2", {"_1[6-9]XX"}) })
               , Branch("Saint-Petersburg", { SoftSwitch("switch-d9", {"_2[0-8]XX"}) })
               , Branch("New York", { SoftSwitch("switch-51", {"_3XXX"}) })
               , Branch("London", { SoftSwitch("switch-93", {"_4[0-7]XX"}) })
               , Branch("San Francisco", { SoftSwitch("switch-13", {"_5XXX"}) })
               , Branch("Novosibirsk", { SoftSwitch("switch-05", {"_6XXX"}) })
               , Branch("Vienna", { SoftSwitch("switch-50", {"_7XXX"}) })
               , Branch("Kaliningrad", { SoftSwitch("switch-77", {"_29XX"}) })
               , Branch("Brussels", { SoftSwitch("switch-huitch", {"_48XX"}) })
               }

function find_br(bt, cn)
  local real_b = nil
  for _,b in pairs(bt) do
    if b(city_name) == cn then
      real_b = b
      break
    end
  end
  return real_b
end

function find_sw(br, swn)
  local real_sw = nil
  for _,sw in pairs(br(gateways)) do
    if sw(sw_name) == swn then
      real_sw = sw
      break
    end
  end
  return real_sw
end

