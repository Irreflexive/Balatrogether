G.FUNCS.discard_cards_from_highlighted = function(e, hook)
  if G.FUNCS.is_coop_game() and not hook then
    G.FUNCS.tcp_send({ cmd = "DISCARD_HAND" })
  else
    G.SINGLEPLAYER_FUNCS.discard_hand(e, hook)
  end
end

G.FUNCS.tcp_listen("DISCARD_HAND", function(data)
  G.SINGLEPLAYER_FUNCS.discard_hand()
end)