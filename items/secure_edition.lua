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

SMODS.Edition{
  key = "secure",
  shader = "secure",
  loc_txt = loc_def,
  config = {},
  discovered = true,
  weight = 14,
  get_weight = function(self, card, context)
    if G.FUNCS.is_versus_game() then
      return G.GAME.edition_rate * self.weight
    end
    return 0
  end,
}