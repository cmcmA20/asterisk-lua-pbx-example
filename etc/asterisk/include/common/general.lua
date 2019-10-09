function SoftSwitch(_sw_name, _number_patterns)
  return function(fn) return fn(_sw_name, _number_patterns) end
end
function sw_name(_sw_name, _number_patterns) return _sw_name end
function number_patterns(_sw_name, _number_patterns) return _number_patterns end

function Branch(_city_name, _gateways)
  return function(fn) return fn(_city_name, _gateways) end
end
function city_name(_city_name, _gateways) return _city_name end
function gateways(_city_name, _gateways) return _gateways end

