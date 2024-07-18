local loc_def = {
  name = "Network Pack",
  group_name = "Network Pack",
  text = {
      "Choose {C:attention}#1#{} of up to",
      "{C:attention}#2#{} Playing or Joker",
      "cards from {C:attention}opponents{}",
  }
}

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
  create_card = function(self, card)
    local cardType = pseudorandom_element({"Joker", "Base"}, pseudoseed('networktype'..G.GAME.round_resets.ante))
    return create_card(cardType, G.pack_cards, nil, nil, true, true, nil, 'net')
  end
}