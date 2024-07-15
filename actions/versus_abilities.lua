G.MULTIPLAYER.actions.THE_CUP = function(data)
  ease_dollars(data.eliminated * 8)
end

G.MULTIPLAYER.actions.ANNIE_AND_HALLIE = function(data)
  local jokers = {}
  for k, v in pairs(G.jokers.cards) do
    table.insert(jokers, {
      joker = v.key,
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
        local card = add_joker(v.joker, v.edition, _first_materialize)
        self.ability = v.ability
      end
      return true end }))
end