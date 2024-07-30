G.FUNCS.play_cards_from_highlighted = function(...)
  if G.FUNCS.is_coop_game() then
    G.FUNCS.tcp_send({ cmd = "PLAY_HAND" })
  else
    G.SINGLEPLAYER_FUNCS.play_hand(...)
  end
end

G.FUNCS.discard_cards_from_highlighted = function(e, hook)
  if G.FUNCS.is_coop_game() and not hook then
    G.FUNCS.tcp_send({ cmd = "DISCARD_HAND" })
  else
    G.SINGLEPLAYER_FUNCS.discard_hand(e, hook)
  end
end

G.FUNCS.tcp_listen("PLAY_HAND", function(data)
  if G.STATE ~= G.STATES.SELECTING_HAND then return end
  G.SINGLEPLAYER_FUNCS.play_hand()
end)

G.FUNCS.tcp_listen("DISCARD_HAND", function(data)
  if G.STATE ~= G.STATES.SELECTING_HAND then return end
  G.SINGLEPLAYER_FUNCS.discard_hand()
end)