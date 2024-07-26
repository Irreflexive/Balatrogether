local socket = require("socket")

local address, send_channel, receive_channel = ...
local tcp = assert(socket.tcp())
tcp:connect(address, 7063)
tcp:settimeout(0)

while true do
  local data = send_channel:pop()
  if data then
    if data == "KILL" then
      tcp:close()
      break
    else
      tcp:send(data)
    end
  end
  local s, status, partial = tcp:receive()
  if status ~= "timeout" then
    if s then
      local messages = {}
      local first = nil
      local num_open = 0
      for i = 1, #s do
        local char = s:sub(i, i)
        if char == "{" or char == "[" then
          if not first then first = i end
          num_open = num_open + 1
        end

        if first and (char == "}" or char == "]") then
          num_open = num_open - 1
          if num_open == 0 then
            table.insert(messages, s:sub(first, i))
            first = nil
          end
        end
      end
      for _,msg in ipairs(messages) do 
        receive_channel:push({
          s = msg,
          status = status,
          partial = partial,
        })
      end
    else
      receive_channel:push({
        s = s,
        status = status,
        partial = partial,
      })
    end
  end
end