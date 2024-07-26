local loc_def = {
  name = "Network Pack",
  group_name = "Network Pack",
  text = {
      "Choose {C:attention}#1#{} of up to",
      "{C:attention}#2#{} Playing or Joker",
      "cards from {C:attention}opponents{}",
  }
}

local function create_network_card(self, card)
  local cardType = pseudorandom_element({"Joker", "Base"}, pseudoseed('networktype'..G.GAME.round_resets.ante))
  if #Balatrogether.server.network_pack.cards == 0 then cardType = "Joker" end
  local card = nil
  if cardType == "Joker" then
    local selected = pseudorandom_element(Balatrogether.server.network_pack.jokers, pseudoseed('netjoker'..G.GAME.round_resets.ante))
    card = create_card(cardType, G.pack_cards, nil, nil, true, true, selected.joker)
    if selected.edition then card:set_edition({[selected.edition] = true}) end
    if selected.ability then card.ability = selected.ability end
  else
    local selected = pseudorandom_element(Balatrogether.server.network_pack.cards, pseudoseed('netcard'..G.GAME.round_resets.ante))
    card = create_card(cardType, G.pack_cards, nil, nil, true, true, selected.key)
    if selected.edition then card:set_edition({[selected.edition] = true}) end
    if selected.ability then card.ability = selected.ability end
    if selected.seal then card:set_seal(selected.seal) end
  end
  return card
end

SMODS.Booster{
  name = "Network Pack",
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
  name = "Network Pack",
  key = "network_2",
  pos = {x = 2, y = 1},
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