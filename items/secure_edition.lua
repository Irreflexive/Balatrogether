local loc_def = {
  name = "Secure",
  label = "Secure",
  text = {
      "{C:attention}Opponents{} cannot",
      "view or take this",
      "card from you"
  }
}

SMODS.Shader{
  key = "secure",
  path = "secure.fs",
}

SMODS.Sound{
  key = "secure",
  path = "secure.ogg",
}

SMODS.Edition{
  key = "secure",
  shader = "secure",
  loc_txt = loc_def,
  config = {},
  discovered = false,
  weight = 14,
  extra_cost = 3,
  -- TODO: Switch when SMODS Sound API is ready
  -- sound = { sound = "secure", per = 1, vol = 0.4 },
  sound = { sound = "holo1", per = 1.2 * 1.58, vol = 0.4 },
  get_weight = function(self, card, context)
    if G.FUNCS.is_versus_game() then
      return G.GAME.edition_rate * self.weight
    end
    return 0
  end,
}