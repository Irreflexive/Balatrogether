local socket = require("socket")

G.FUNCS.tcp_connect = function()
  if G.MULTIPLAYER.tcp then return end
  local tcp = assert(socket.tcp())
  G.MULTIPLAYER.tcp = tcp
  tcp:connect(G.MULTIPLAYER.address, 7063)
  tcp:settimeout(0)
  if G.MULTIPLAYER.debug then sendDebugMessage("TCP connection opened") end
end

local function receive_and_parse()
  local res = nil
  local s, status, partial = G.MULTIPLAYER.tcp:receive()
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
  if not G.MULTIPLAYER.tcp then return end
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
  if not G.MULTIPLAYER.tcp then return end
  G.MULTIPLAYER.tcp:close()
  G.MULTIPLAYER.tcp = nil
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
  if G.MULTIPLAYER.debug then sendDebugMessage("Sending data: " .. G.JSON.encode(data)) end
  G.MULTIPLAYER.tcp:send(G.JSON.encode(data))
end

G.FUNCS.tcp_listen = function(event, callback)
  if not G.MULTIPLAYER.actions[event] then
    G.MULTIPLAYER.actions[event] = {}
  end
  table.insert(G.MULTIPLAYER.actions[event], callback)
end

----------------------------------------------
------------MOD CODE END----------------------