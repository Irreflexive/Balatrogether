local socket = require("socket")

local tcp = {
  enabled = false,
  thread = nil,
  send_channel = nil,
  receive_channel = nil,
}

G.FUNCS.tcp_connect = function()
  if tcp.enabled then return end
  tcp.enabled = true
  tcp.thread = love.thread.newThread(NFS.read(Balatrogether.file_path .. "tcp_thread.lua"))
  tcp.send_channel = love.thread.newChannel()
  tcp.receive_channel = love.thread.newChannel()
  tcp.thread:start(Balatrogether.server.address, tcp.send_channel, tcp.receive_channel, true)
  if Balatrogether.debug then sendDebugMessage("TCP connection opened") end
end

local function receive_and_parse()
  local res = nil
  local popped = tcp.receive_channel:pop()
  if not popped or popped.debug then
    if popped and popped.debug then sendDebugMessage(popped.debug) end
    return { success = true }
  end
  local s, status, partial = popped.s, popped.status, popped.partial
  if status == "timeout" or status == "wantread" or status == "wantwrite" then
    res = { success = true }
  elseif status == "closed" or s == nil then
    res = { success = false, error = "Connection closed" }
  else
    local success, json = pcall(G.JSON.decode, s)
    if success then
      res = json
    elseif type(s) == "table" then
      res = s
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
    if res.game_state then
      Balatrogether.server.game_state = res.game_state
    end
    local funcs = Balatrogether.actions[res.cmd]
    if funcs then
      for _, func in ipairs(funcs) do
        func(res.data)
      end
    elseif res.cmd ~= "NODATA" then
      if Balatrogether.debug then sendDebugMessage("Unknown action: " .. res.cmd) end
    end
  else
    if Balatrogether.debug then sendDebugMessage("Failed to receive data: " .. (res.error or "Unknown error")) end
    G.FUNCS.tcp_close()
  end
end

G.FUNCS.tcp_close = function()
  if not tcp.enabled then return end
  tcp.send_channel:push("KILL")
  tcp.enabled = false
  Balatrogether.server.enabled = false
  Balatrogether.server.players = {}
  Balatrogether.server.leaderboard_blind = false
  Balatrogether.server.leaderboard = nil
  if G.STAGE == G.STAGES.MAIN_MENU then
    if G.OVERLAY_MENU then
      if G.OVERLAY_MENU:get_UIE_by_ID('connection_status') then
        G.FUNCS.set_connection_status("b_disconnected")
      else
        G.FUNCS.exit_overlay_menu()
      end
    end
  else
    G.FUNCS.set_connection_status("")
    remove_save()
    G.FUNCS.go_to_menu()
  end
  if Balatrogether.debug then sendDebugMessage("TCP connection closed") end
end

G.FUNCS.tcp_send = function(data)
  if data.cmd == "JOIN" then
    data.steam_id = tostring(G.STEAM.user.getSteamID())
    data.unlock_hash = G.FUNCS.compute_unlock_hash()
  end
  local encoded = G.JSON.encode(data)
  if Balatrogether.debug then sendDebugMessage("Sending data: " .. encoded) end
  tcp.send_channel:push(encoded)
end

G.FUNCS.tcp_update = function(dt)
  G.FUNCS.tcp_receive()
end

G.FUNCS.tcp_listen = function(event, callback)
  if not Balatrogether.actions[event] then
    Balatrogether.actions[event] = {}
  end
  table.insert(Balatrogether.actions[event], callback)
end

----------------------------------------------
------------MOD CODE END----------------------