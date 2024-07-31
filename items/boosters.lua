local function create_network_card(self, card)
  local cardType = pseudorandom_element({"Joker", "Base"}, pseudoseed('networktype'..G.GAME.round_resets.ante))
  if #Balatrogether.server.network_pack.cards == 0 then cardType = "Joker" end
  local card = nil
  if cardType == "Joker" then
    local selected = pseudorandom_element(Balatrogether.server.network_pack.jokers, pseudoseed('netjoker'..G.GAME.round_resets.ante))
    card = create_card(cardType, G.pack_cards, nil, nil, true, true, selected.k)
    if selected.ed then card:set_edition({[selected.ed] = true}) end
    if selected.a then card.ability = selected.a end
    if selected.et then card:set_eternal(selected.et) end
  else
    local selected = pseudorandom_element(Balatrogether.server.network_pack.cards, pseudoseed('netcard'..G.GAME.round_resets.ante))
    card = create_card(cardType, G.pack_cards, nil, nil, true, true, selected.k)
    if selected.ed then card:set_edition({[selected.edition] = true}) end
    if selected.en then card:set_ability(G.P_CENTERS[selected.en]) end
    if selected.s then card:set_seal(selected.s) end
    if selected.c then card.ability.perma_bonus = selected.c end
  end
  return card
end

SMODS.Booster{
  key = "network",
  pos = {x = 1, y = 1},
  discovered = false,
  loc_txt = loc_def,
  weight = 1,
  cost = 6,
  config = {extra = 4, choose = 1},
  atlas = "Balatrogether_cards",
  in_pool = function(self)
    return G.FUNCS.is_versus_game()
  end,
  create_card = create_network_card
}

SMODS.Booster{
  key = "network_2",
  pos = {x = 2, y = 1},
  discovered = false,
  weight = 1,
  cost = 6,
  config = {extra = 4, choose = 1},
  atlas = "Balatrogether_cards",
  in_pool = function(self)
    return G.FUNCS.is_versus_game()
  end,
  create_card = create_network_card
}