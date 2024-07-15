G.MULTIPLAYER.actions.THE_CUP = function(data)
  ease_dollars(data.eliminated * 8)
end

G.MULTIPLAYER.actions.ANNIE_AND_HALLIE = function(data)
  local jokers = {}
  for k, v in pairs(G.jokers.cards) do
      table.insert(jokers, v)
  end
  local _first_dissolve = nil
  G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.75, func = function()
      for k, v in pairs(G.jokers.cards) do
          v:start_dissolve(nil, _first_dissolve)
          _first_dissolve = true
      end
      return true end }))
  G.FUNCS.tcp_send({ cmd = "GIVE_JOKERS", jokers = jokers, player = data.user })
  G.MULTIPLAYER.actions.GIVE_JOKERS({ jokers = data.jokers })
end

G.MULTIPLAYER.actions.GIVE_JOKERS = function(data)
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