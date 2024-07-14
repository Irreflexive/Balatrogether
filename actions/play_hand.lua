G.FUNCS.play_cards_from_highlighted = function(...)
  if G.MULTIPLAYER.enabled then
    G.FUNCS.tcp_send({ cmd = "PLAY_HAND" })
  else
    G.SINGLEPLAYER_FUNCS.play_hand(...)
  end
end

G.MULTIPLAYER.actions.PLAY_HAND = function(data)
  G.SINGLEPLAYER_FUNCS.play_hand()
end