local emplace_ref = CardArea.emplace
function CardArea:emplace(card, location, stay_flipped)
  if G.FUNCS.is_coop_game() and getCardAreaType(self) then
    local id = Balatrogether.server.card_id + 1
    Balatrogether.server.card_id = id
    card.Multiplayer_ID = id
    if Balatrogether.debug then sendDebugMessage("Tagged card with multiplayer ID " .. tostring(card.Multiplayer_ID)) end
  end
  emplace_ref(self, card, location, stay_flipped)
end