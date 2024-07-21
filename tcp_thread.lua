local socket = require("socket")

local address = ...
local tcp = assert(socket.tcp())
tcp:connect(address, 7063)
tcp:settimeout(0)

while true do
  local s, status, partial = tcp:receive()
  if status ~= "timeout" then
    love.thread.getChannel("balatrogether_receive"):push({
      s = s,
      status = status,
      partial = partial,
    })
  end
  local data = love.thread.getChannel("balatrogether_send"):pop()
  if data then
    if data == "KILL" then
      tcp:close()
      break
    else
      tcp:send(data)
    end
  end
end