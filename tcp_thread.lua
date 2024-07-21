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
    receive_channel:push({
      s = s,
      status = status,
      partial = partial,
    })
  end
end