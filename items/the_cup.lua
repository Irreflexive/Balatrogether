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

SMODS.ConsumableTypes["Tarot"].collection_rows = {6, 6}