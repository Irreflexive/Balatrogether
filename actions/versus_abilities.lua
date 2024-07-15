G.MULTIPLAYER.actions.THE_CUP = function(data)
  ease_dollars(data.eliminated * 8)
end

G.MULTIPLAYER.actions.ANNIE_AND_HALLIE = function(data)
  local jokers = {}
  for k, v in pairs(G.jokers.cards) do
    table.insert(jokers, {
      T = {x = v.T.x, y = v.T.y},
      config = {center = v.config.center, card = v.config.card},
      ability = v.ability,
      edition = v.edition,
    })
  end
  local _first_dissolve = nil
  G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.75, func = function()
      for k, v in pairs(G.jokers.cards) do
          v:start_dissolve(nil, _first_dissolve)
          _first_dissolve = true
      end
      return true end }))
  if data.user then
    G.FUNCS.tcp_send({ cmd = "ANNIE_AND_HELLIE", jokers = jokers, player = data.user })
  end
  local _first_materialize = nil
  G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.4, func = function()
      for k, v in pairs(data.jokers) do
        local card = copy_card(v)
        card:start_materialize(nil, _first_materialize)
        _first_materialize = true
        card:add_to_deck()
        G.jokers:emplace(card)
      end
      return true end }))
end