-- helper functions
function message_extract_data()
  return channel.MESSAGE("from"):get(), channel.MESSAGE("to"):get(), channel.MESSAGE("body"):get()
end

function message_info()
  local msg_from, msg_to, msg_body = message_extract_data()
  app.Verbose("Message sender: " .. msg_from)
  app.Verbose("Message recipient: " .. msg_to)
  -- Sanitize before use
  --app.Verbose("Message body: " .. msg_body)
end


-- messaging functions
function msg(ext)
  local msg_from, _, _ = message_extract_data()
  message_info()
  app.MessageSend("sip:" .. ext, msg_from)
end

