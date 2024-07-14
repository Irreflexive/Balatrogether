local socket = require("socket")

G.FUNCS.tcp_connect = function()
  if G.MULTIPLAYER.tcp then return end
  local tcp = assert(socket.tcp())
  G.MULTIPLAYER.tcp = tcp
  tcp:connect(G.MULTIPLAYER.address, 7063)
  tcp:settimeout(0)
  if G.MULTIPLAYER.debug then sendDebugMessage("TCP connection opened") end
end

G.FUNCS.tcp_listen = function()
  if not G.MULTIPLAYER.tcp then return end
  local res = G.FUNCS.tcp_receive()
  if res.success then
    if not res.data then return end
    local func = G.MULTIPLAYER.actions[res.cmd]
    if func then
      func(res.data)
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
  if G.STAGE == G.STAGES.MAIN_MENU then
    G.FUNCS.exit_overlay_menu()
  else
    G.FUNCS.go_to_menu()
  end
  if G.MULTIPLAYER.debug then sendDebugMessage("TCP connection closed") end
end

G.FUNCS.tcp_send = function(data)
  if data.cmd == "JOIN" then
    data.steam_id = tostring(G.STEAM.user.getSteamID())
  end
  if G.MULTIPLAYER.debug then sendDebugMessage("Sending data: " .. G.JSON.encode(data)) end
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

G.FUNCS.is_host = function(e)
  if e.config.func then
    local _is_host = tostring(G.STEAM.user.getSteamID()) == G.MULTIPLAYER.players[1]
    if not _is_host then
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
    end
    e.config.func = nil
    return _is_host
  end
end

----------------------------------------------
------------MOD CODE END----------------------