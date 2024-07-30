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
  config = {},
  discovered = false,
  weight = 14,
  extra_cost = 3,
  in_shop = true,
  sound = { sound = createCollectionId(nil, 'secure'), per = 1, vol = 0.4 },
  get_weight = function(self, card, context)
    if G.FUNCS.is_versus_game() then
      return G.GAME.edition_rate * self.weight
    end
    return 0
  end,
}

SMODS.Consumable:take_ownership("wheel_of_fortune", {
  loc_vars = function(self, info_queue)
    local secure = createCollectionId('e', 'secure')
    info_queue[#info_queue+1] = G.P_CENTERS[secure]
    return {}
  end,
})

SMODS.Consumable:take_ownership("aura", {
  loc_vars = function(self, info_queue)
    local secure = createCollectionId('e', 'secure')
    info_queue[#info_queue+1] = G.P_CENTERS[secure]
    return {}
  end,
})

local poll_edition_ref = poll_edition
function poll_edition(_key, _mod, _no_neg, _guaranteed, _options)
  if (_key == "wheel_of_fortune" or _key == "aura") and G.FUNCS.is_versus_game() then
    local secure = createCollectionId('e', 'secure')
    _options = { 'e_negative', 'e_polychrome', 'e_holo', 'e_foil', secure }
  end
  return poll_edition_ref(_key, _mod, _no_neg, _guaranteed, _options)
end