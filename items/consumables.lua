local loc_def = {
  name = "The Cup",
  text = {
      "Earn {C:money}$8{} for each",
      "opponent that has",
      "been {C:attention}eliminated{}"
  }
}

SMODS.Tarot{
  name = "The Cup", 
  key = "cup", 
  config = {}, 
  pos = {x = 0, y = 1}, 
  loc_txt = loc_def, 
  unlocked = true, 
  discovered = false, 
  atlas = "Balatrogether_cards",
  use = function(self)
    if G.FUNCS.is_versus_game() then
      G.FUNCS.tcp_send({ cmd = "THE_CUP" })
    end
  end,
  can_use = function(self)
    return G.FUNCS.is_versus_game()
  end,
  in_pool = function(self)
    return G.FUNCS.is_versus_game()
  end
}

local loc_def2 = {
  name = "Siphon",
  text = {
      "Add a {C:green}Green Seal{}",
      "to {C:attention}#1#{} selected",
      "card in your hand"
  }
}

local sealId = createCollectionId('s', 'green')
SMODS.Spectral{
  name = "Siphon", 
  key = "siphon", 
  config = {
    mod_conv = sealId .. '_seal',
    seal = { money = 1 },
    max_highlighted = 1,
  }, 
  pos = {x = 0, y = 2}, 
  loc_txt = loc_def2, 
  unlocked = true, 
  discovered = false, 
  atlas = "Balatrogether_cards",
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = {
      set = "Other",
      key = sealId .. '_seal',
      specific_vars = {self.config.seal.money},
    }
    return {vars = {card.ability.max_highlighted}}
  end,
  use = function(self, card)
    if G.FUNCS.is_versus_game() then
      for i = 1, card.ability.max_highlighted do
        local highlighted = G.hand.highlighted[i]
        if highlighted then
          highlighted:set_seal(sealId)
        else
          break
        end
      end
      return true
    end
  end,
  in_pool = function(self)
    return G.FUNCS.is_versus_game()
  end
}

SMODS.ConsumableTypes["Tarot"].collection_rows = {6, 6}
SMODS.ConsumableTypes["Spectral"].collection_rows = {5, 5}