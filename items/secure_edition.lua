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
  in_shop = true,
  sound = { sound = SMODS.current_mod.prefix .. "_secure", per = 1, vol = 0.4 },
  get_weight = function(self, card, context)
    if G.FUNCS.is_versus_game() then
      return G.GAME.edition_rate * self.weight
    end
    return 0
  end,
}

SMODS.Consumable:take_ownership("wheel_of_fortune", {
  loc_txt = {
    name = "The Wheel of Fortune",
    text = {
        "{C:green}#1# in #2#{} chance to add {C:dark_edition}Foil{},",
        "{C:dark_edition}Holographic{}, {C:dark_edition}Polychrome{},",
        "or {C:dark_edition}Secure{} edition to",
        "a random {C:attention}Joker"
    }
  },
})

SMODS.Consumable:take_ownership("aura", {
  loc_txt = {
    name = "Aura",
    text = {
      "Add {C:dark_edition}Foil{}, {C:dark_edition}Holographic{},",
      "{C:dark_edition}Polychrome{}, or {C:dark_edition}Secure{} effect",
      "to {C:attention}1{} selected card in hand"
    }
  },
})

local poll_edition_ref = poll_edition
function poll_edition(_key, _mod, _no_neg, _guaranteed, _options)
  if _key == "wheel_of_fortune" or _key == "aura" then
    local secure = 'e_' .. SMODS.current_mod.prefix .. '_secure'
    _options = { 'e_negative', 'e_polychrome', 'e_holo', 'e_foil', secure }
  end
  return poll_edition_ref(_key, _mod, _no_neg, _guaranteed, _options)
end