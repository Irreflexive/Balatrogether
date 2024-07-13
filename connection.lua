--- STEAMODDED HEADER
--- SECONDARY MOD FILE

----------------------------------------------
------------MOD CODE--------------------------

local socket = require("socket")

G.FUNCS.tcp_connect = function()
  local tcp = assert(socket.tcp())
  tcp:connect("127.0.0.1", 7063);
  G.MULTIPLAYER.tcp = tcp
  G.FUNCS.tcp_listen()
end

G.FUNCS.tcp_close = function()
  G.MULTIPLAYER.tcp:close()
  G.MULTIPLAYER.tcp = nil
  G.MULTIPLAYER.enabled = false
end

G.FUNCS.tcp_send = function(data)
  data.steam_id = tostring(G.STEAM.user.getSteamID())
  G.MULTIPLAYER.tcp:send(G.JSON.encode(data) .. "\n");
end

G.FUNCS.tcp_receive = function()
  local res = nil
  local s, status, partial = G.MULTIPLAYER.tcp:receive()
  if status == "closed" then
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

G.FUNCS.room_created = function(data)
  local data = res.data
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
  local data = res.data
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

G.FUNCS.tcp_listen = function()
  while G.MULTIPLAYER.tcp do
    local res = G.FUNCS.tcp_receive()
    if res.success then
      if res.dtype == "room_create" then
        G.FUNCS.room_created(res.data)
      end
    else
      sendDebugMessage("Failed to process packet: " .. res.error)
      G.FUNCS.tcp_close()
    end
  end
end

----------------------------------------------
------------MOD CODE END----------------------