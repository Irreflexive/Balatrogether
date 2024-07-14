G.FUNCS.select_blind = function(...)
  if G.MULTIPLAYER.enabled then
    G.FUNCS.tcp_send({ cmd = "SELECT_BLIND" })
  else
    G.SINGLEPLAYER_FUNCS.select_blind(...)
  end
end

G.FUNCS.skip_blind = function(...)
  if G.MULTIPLAYER.enabled then
    G.FUNCS.tcp_send({ cmd = "SKIP_BLIND" })
  else
    G.SINGLEPLAYER_FUNCS.skip_blind(...)
  end
end

G.MULTIPLAYER.actions.SELECT_BLIND = function(data)
  local e = findDescendantOfElementByConfig(G.blind_select:get_UIE_by_ID(G.GAME.blind_on_deck), "button", "select_blind")
  if e then G.SINGLEPLAYER_FUNCS.select_blind(e) end
end

G.MULTIPLAYER.actions.SKIP_BLIND = function(data)
  local e = findDescendantOfElementByConfig(G.blind_select:get_UIE_by_ID(G.GAME.blind_on_deck), "button", "skip_blind")
  if e then G.SINGLEPLAYER_FUNCS.skip_blind() end
end