--- STEAMODDED HEADER
--- SECONDARY MOD FILE

----------------------------------------------
------------MOD CODE--------------------------

local socket = require("socket")

G.FUNCS.tcp_connect = function()
  if G.MULTIPLAYER.tcp then return end
  local tcp = assert(socket.tcp())
  G.MULTIPLAYER.tcp = tcp
  tcp:connect("127.0.0.1", 7063)
  tcp:settimeout(0)
  sendDebugMessage("TCP connection opened")
end

G.FUNCS.tcp_listen = function()
  if not G.MULTIPLAYER.tcp then return end
  local res = G.FUNCS.tcp_receive()
  if res.success then
    if not res.data then return end
    sendDebugMessage("Received data: " .. G.JSON.encode(res))
    if res.cmd == "CREATE" then
      G.FUNCS.room_created(res.data)
    elseif res.cmd == "JOIN" then
      G.FUNCS.room_join(res.data)
    elseif res.cmd == "LEAVE" then
      G.FUNCS.room_leave()
    end
  else
    sendDebugMessage("Failed to receive data: " .. res.error)
    G.FUNCS.tcp_close()
  end
end

G.FUNCS.tcp_close = function()
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
  if status == "closed" then
    res = { success = false, error = "Connection closed" }
  elseif status == "timeout" then
    res = { success = true }
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

G.FUNCS.room_created = function(data)
  G.MULTIPLAYER.enabled = true
  G.MULTIPLAYER.versus = data.versus
  G.MULTIPLAYER.code = data.code
  G.MULTIPLAYER.players = data.players
  G.MULTIPLAYER.id = 1
  -- Load UI
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.server_config(true),
  }
  G.OVERLAY_MENU.config.no_esc = true
end

G.FUNCS.room_join = function(data)
  G.MULTIPLAYER.enabled = true
  G.MULTIPLAYER.versus = data.versus
  G.MULTIPLAYER.code = data.code
  G.MULTIPLAYER.players = data.players
  G.MULTIPLAYER.id = #data.players
  -- Load UI
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.server_config(false),
  }
  G.OVERLAY_MENU.config.no_esc = true
end

G.FUNCS.room_leave = function()
  G.MULTIPLAYER.enabled = false
  G.MULTIPLAYER.versus = false
  G.MULTIPLAYER.code = ""
  G.MULTIPLAYER.players = {}
  G.MULTIPLAYER.id = 0
  G.SETTINGS.paused = false
  G.FUNCS.overlay_menu_close()
end

----------------------------------------------
------------MOD CODE END----------------------