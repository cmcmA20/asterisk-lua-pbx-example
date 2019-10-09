-- [Naive] Asterisk Number Pattern Matching
-- it parses a weaker language btw

-- helper functions
function char_to_digit(input)
  local c = string.sub(input, 1, 1)
  local r = string.byte(c) - string.byte("0")
  if 0 <= r and r <= 9 then
    return r
  else
    return nil
  end
end

-- ANP data types
function ANPRange(_digit_start, _digit_end)
  if not (_digit_start and _digit_end) then
    return nil
  end

  if _digit_start <= _digit_end then
    return function(fn) return fn(_digit_start, _digit_end) end
  else
    return nil
  end
end
function digit_start(_digit_start, _digit_end) return _digit_start end
function digit_end(_digit_start, _digit_end) return _digit_end end

function ANPDigit(_digit)
  if not _digit then
    return nil
  end

  if 0 <= _digit and _digit <= 9 then
    return ANPRange(_digit, _digit)
  else
    return nil
  end
end


-- ANP parsing
function parse_ANPDigit(input)
  if string.len(input) == 0 then
    return nil
  end

  return ANPDigit(char_to_digit(input)), string.sub(input, 2)
end

function parse_ANPRange(input)
  if string.len(input) == 0 then
    return nil
  end

  local c = string.sub(input, 1, 1)
  if c == "X" then
    return ANPRange(0, 9), string.sub(input, 2)
  end
  if c == "Z" then
    return ANPRange(1, 9), string.sub(input, 2)
  end
  if c == "N" then
    return ANPRange(2, 9), string.sub(input, 2)
  end

  if c ~= "[" then
    return nil, string.sub(input, 2)
  end
  local ds  = char_to_digit(string.sub(input, 2))
  local csep = string.sub(input, 3, 3)
  if csep ~= "-" then
    return nil, string.sub(input, 4)
  end
  local de  = char_to_digit(string.sub(input, 4))
  local cend  = string.sub(input, 5, 5)
  if cend ~= "]" then
    return nil, string.sub(input, 6)
  end
  return ANPRange(ds, de), string.sub(input, 6)
end

function parse_ANPAny(input)
  if string.len(input) == 0 then
    return nil
  end

  local anpr, new_input = parse_ANPRange(input)
  if not anpr then
    anpr, new_input = parse_ANPDigit(input)
  end
  return anpr, new_input
end

function parse_ANP(input)
  if string.len(input) == 0 then
    return nil
  end
  local c = string.sub(input, 1, 1)
  if c ~= "_" then
    return nil
  else
    input = string.sub(input, 2)
  end

  local i = 1
  local result = {}
  local anpr, new_input = parse_ANPAny(input)
  while anpr do
    result[i] = anpr
    input = new_input
    anpr, new_input = parse_ANPAny(input)
    i = i + 1
  end

  if i == 1 then
    return nil
  end
  return result
end


-- ANP matching
function match_ANPRange_digit(anpr, digit)
  return anpr(digit_start) <= digit and digit <= anpr(digit_end)
end

function match_ANP_number(anp_array, number)
  local anp_length = 0
  for _ in pairs(anp_array) do
    anp_length = anp_length + 1
  end
  if anp_length ~= string.len(number) then
    return false
  end

  local i = 1
  while i <= anp_length do
    if not match_ANPRange_digit(anp_array[i], char_to_digit(string.sub(number, i, i))) then
      return false
    end
    i = i + 1
  end
  return true
end


-- string matching
function match_number(anp_string, number)
  local anp_array = parse_ANP(anp_string)
  return match_ANP_number(anp_array, number)
end
