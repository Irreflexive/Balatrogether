local socket = require("socket")

local tcp_thread
G.FUNCS.tcp_connect = function()
  if tcp_thread then return end
  tcp_thread = love.thread.newThread(NFS.read(SMODS.current_mod.path .. "tcp_thread.lua"))
  tcp_thread:start(G.MULTIPLAYER.address)
  if G.MULTIPLAYER.debug then sendDebugMessage("TCP connection opened") end
end

local function receive_and_parse()
  local res = nil
  local popped = love.thread.getChannel("balatrogether_receive"):pop()
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
  if not tcp_thread then return end
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

local receive_requests = false
G.FUNCS.tcp_close = function()
  if not tcp_thread then return end
  love.thread.getChannel("balatrogether_send"):push("KILL")
  tcp_thread:release()
  tcp_thread = nil
  G.MULTIPLAYER.enabled = false
  receive_requests = false
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
    receive_requests = true
  end
  table.insert(G.MULTIPLAYER.send_queue, G.JSON.encode(data))
end

local time_since_last_send = 0
G.FUNCS.tcp_update = function(dt)
  if receive_requests then
    G.FUNCS.tcp_receive()
  end 
  if not tcp_thread then return end
  time_since_last_send = time_since_last_send + dt
  if #G.MULTIPLAYER.send_queue == 0 or time_since_last_send < 0.1 then return end
  time_since_last_send = 0
  local data = G.MULTIPLAYER.send_queue[1]
  table.remove(G.MULTIPLAYER.send_queue, 1)
  if G.MULTIPLAYER.debug then sendDebugMessage("Sending data: " .. data) end
  love.thread.getChannel("balatrogether_send"):push(data)
end

G.FUNCS.tcp_listen = function(event, callback)
  if not G.MULTIPLAYER.actions[event] then
    G.MULTIPLAYER.actions[event] = {}
  end
  table.insert(G.MULTIPLAYER.actions[event], callback)
end

----------------------------------------------
------------MOD CODE END----------------------