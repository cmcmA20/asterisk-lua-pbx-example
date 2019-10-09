dofile("/etc/asterisk/include/common/branch.lua") -- do not touch this line

-- it's just me, myself and I
self_branch_name = "Novosibirsk"
self_ssw_name = "nsk-privacy-enhanced-name"

self_branch = find_br(branch_table, self_branch_name) -- do not touch this line
self_ssw = find_sw(self_branch, self_ssw_name) -- do not touch this line

-- your SIP providers
provider_ssws = { SoftSwitch("sip-provider1" , { "_XXXXXXX"
                                               , "_8XXXXXXXXXX"
                                               }
                            )
                }

-- legacy hardware (with SIP support)
local_legacy_sws = { SoftSwitch("legacy-pbx", { "_6100"
                                              }
                               )
--                   , SoftSwitch("kvgw-i1", { "_6199"
--                                           , "_6198"
--                                           , "_6197"
--                                           , "_6196"
--                                           , "_6195"
--                                           , "_6194"
--                                           , "_6193"
--                                           , "_6192"
--                                           }
--                               )
                   }

