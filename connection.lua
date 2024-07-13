--- STEAMODDED HEADER
--- SECONDARY MOD FILE

----------------------------------------------
------------MOD CODE--------------------------

local socket = require("socket")

G.FUNCS.tcp_connect = function()
  if G.MULTIPLAYER.tcp then return end
  local tcp = assert(socket.tcp())
  G.MULTIPLAYER.tcp = tcp
  tcp:connect(G.MULTIPLAYER.address, 7063)
  tcp:settimeout(0)
  sendDebugMessage("TCP connection opened")
end

G.FUNCS.tcp_listen = function()
  if not G.MULTIPLAYER.tcp then return end
  local res = G.FUNCS.tcp_receive()
  if res.success then
    if not res.data then return end
    sendDebugMessage("Received data: " .. G.JSON.encode(res))
    if res.cmd == "JOIN" then
      G.FUNCS.room_join(res.data)
    elseif res.cmd == "START" then
      local key = 1
      for k, v in ipairs(G.P_CENTER_POOLS.Back) do
        if v.name == res.data.deck then
          key = k
          break
        end
      end
      G.GAME.viewed_back:change_to(G.P_CENTER_POOLS.Back[key])
      G.FUNCS.start_run(nil, { seed = res.data.seed, stake = res.data.stake })
    end
  else
    sendDebugMessage("Failed to receive data: " .. (res.error or "Unknown error"))
    G.FUNCS.tcp_close()
  end
end

G.FUNCS.tcp_close = function()
  if not G.MULTIPLAYER.tcp then return end
  G.MULTIPLAYER.tcp:close()
  G.MULTIPLAYER.tcp = nil
  G.MULTIPLAYER.enabled = false
  sendDebugMessage("TCP connection closed")
end

G.FUNCS.tcp_send = function(data)
  data.steam_id = tostring(G.STEAM.user.getSteamID())
  sendDebugMessage("Sending data: " .. G.JSON.encode(data))
  G.MULTIPLAYER.tcp:send(G.JSON.encode(data) .. "\n")
end

G.FUNCS.tcp_receive = function()
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

G.FUNCS.room_join = function(data)
  G.MULTIPLAYER.enabled = true
  G.MULTIPLAYER.versus = false
  G.MULTIPLAYER.players = data.players
  -- Load UI
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.server_config(tostring(G.STEAM.user.getSteamID()) == data.players[1]),
  }
  G.OVERLAY_MENU.config.no_esc = true
end

G.FUNCS.room_leave = function()
  G.FUNCS.tcp_close()
  G.MULTIPLAYER.versus = false
  G.MULTIPLAYER.players = {}
  G.SETTINGS.paused = false
  G.FUNCS:exit_overlay_menu()
end

----------------------------------------------
------------MOD CODE END----------------------