local socket = require("socket")

local tcp = {
  enabled = false,
  thread = nil,
  send_channel = nil,
  receive_channel = nil,
  send_queue = {},
}

G.FUNCS.tcp_connect = function()
  if tcp.enabled then return end
  tcp.enabled = true
  tcp.thread = love.thread.newThread(NFS.read(SMODS.current_mod.path .. "tcp_thread.lua"))
  tcp.send_channel = love.thread.newChannel()
  tcp.receive_channel = love.thread.newChannel()
  tcp.send_queue = {}
  tcp.thread:start(G.MULTIPLAYER.address, tcp.send_channel, tcp.receive_channel)
  if G.MULTIPLAYER.debug then sendDebugMessage("TCP connection opened") end
end

local function receive_and_parse()
  local res = nil
  local popped = tcp.receive_channel:pop()
  if not popped then
    return { success = true }
  end
  local s, status, partial = popped.s, popped.status, popped.partial
  if status == "timeout" then
    res = { success = true }
  elseif status == "closed" or s == nil then
    res = { success = false, error = "Connection closed" }
  else
    local success, json = pcall(G.JSON.decode, s)
    if success then
      res = json
    else
      res = { success = false, error = "Failed to parse packet" }
    end
  end
  return res
end

G.FUNCS.tcp_receive = function()
  if not tcp.enabled then return end
  local res = receive_and_parse()
  if res.success then
    if not res.data then return end
    local funcs = G.MULTIPLAYER.actions[res.cmd]
    if funcs then
      for _, func in ipairs(funcs) do
        func(res.data)
      end
    else
      if G.MULTIPLAYER.debug then sendDebugMessage("Unknown action: " .. res.cmd) end
    end
  else
    if G.MULTIPLAYER.debug then sendDebugMessage("Failed to receive data: " .. (res.error or "Unknown error")) end
    G.FUNCS.tcp_close()
  end
end

G.FUNCS.tcp_close = function()
  if not tcp.enabled then return end
  tcp.send_channel:push("KILL")
  tcp.enabled = false
  G.MULTIPLAYER.enabled = false
  G.MULTIPLAYER.players = {}
  G.MULTIPLAYER.leaderboard_blind = false
  G.MULTIPLAYER.leaderboard = nil
  if G.STAGE == G.STAGES.MAIN_MENU then
    G.FUNCS.exit_overlay_menu()
  else
    remove_save()
    G.FUNCS.go_to_menu()
  end
  if G.MULTIPLAYER.debug then sendDebugMessage("TCP connection closed") end
end

G.FUNCS.tcp_send = function(data)
  if data.cmd == "JOIN" then
    data.steam_id = tostring(G.STEAM.user.getSteamID())
  end
  table.insert(tcp.send_queue, G.JSON.encode(data))
end

local time_since_last_send = 0
G.FUNCS.tcp_update = function(dt)
  G.FUNCS.tcp_receive()
  if not tcp.enabled then return end
  time_since_last_send = time_since_last_send + dt
  if #tcp.send_queue == 0 or time_since_last_send < 0.1 then return end
  time_since_last_send = 0
  local data = tcp.send_queue[1]
  table.remove(tcp.send_queue, 1)
  if G.MULTIPLAYER.debug then sendDebugMessage("Sending data: " .. data) end
  tcp.send_channel:push(data)
end

G.FUNCS.tcp_listen = function(event, callback)
  if not G.MULTIPLAYER.actions[event] then
    G.MULTIPLAYER.actions[event] = {}
  end
  table.insert(G.MULTIPLAYER.actions[event], callback)
end

----------------------------------------------
------------MOD CODE END----------------------