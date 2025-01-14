G.FUNCS.select_blind = function(...)
  local boss_blind = G.GAME.round_resets.blind_choices.Boss
  local matchesDuel = (boss_blind == createCollectionId('bl', 'the_duel') or boss_blind == createCollectionId('bl', 'final_showdown'))
  sendDebugMessage("Is a boss blind: " .. tostring(G.GAME.blind_on_deck == "Boss"), "Balatrogether")
  sendDebugMessage("Is boss a duel blind: " .. tostring(matchesDuel), "Balatrogether")
  if G.FUNCS.is_coop_game() then
    G.FUNCS.tcp_send({ cmd = "SELECT_BLIND" })
  elseif G.FUNCS.is_versus_game() and G.GAME.blind_on_deck == "Boss" and matchesDuel then
    G.FUNCS.tcp_send({ cmd = "READY_FOR_BOSS" })
  else
    G.SINGLEPLAYER_FUNCS.select_blind(...)
  end
end

G.FUNCS.skip_blind = function(...)
  if G.FUNCS.is_coop_game() then
    G.FUNCS.tcp_send({ cmd = "SKIP_BLIND" })
  else
    G.SINGLEPLAYER_FUNCS.skip_blind(...)
  end
end

G.FUNCS.tcp_listen("SELECT_BLIND", function(data)
  if G.STATE ~= G.STATES.BLIND_SELECT then return end
  local e = findDescendantOfElementByConfig(G.blind_select:get_UIE_by_ID(G.GAME.blind_on_deck), "button", "select_blind")
  if e then G.SINGLEPLAYER_FUNCS.select_blind(e) end
end)

G.FUNCS.tcp_listen("SKIP_BLIND", function(data)
  if G.STATE ~= G.STATES.BLIND_SELECT then return end
  local e = findDescendantOfElementByConfig(G.blind_select:get_UIE_by_ID(G.GAME.blind_on_deck), "button", "skip_blind")
  if e then G.SINGLEPLAYER_FUNCS.skip_blind() end
end)

G.FUNCS.tcp_listen("START_BOSS", function(data)
  if G.STATE ~= G.STATES.BLIND_SELECT then return end
  local e = findDescendantOfElementByConfig(G.blind_select:get_UIE_by_ID(G.GAME.blind_on_deck), "button", "select_blind")
  if e then G.SINGLEPLAYER_FUNCS.select_blind(e) end
end)