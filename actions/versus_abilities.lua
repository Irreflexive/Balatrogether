G.FUNCS.tcp_listen("MONEY", function(data)
  ease_dollars(data.money)
end)

G.FUNCS.tcp_listen("HAND_SIZE", function(data)
  G.hand:change_size(data.hand_size)
end)

G.FUNCS.tcp_listen("SWAP_JOKERS", function(data)
  local jokers = {}
  for k, v in pairs(G.jokers.cards) do
    if not v.edition or v.edition.type ~= Balatrogether.prefix .. "_secure" then
      table.insert(jokers, {
        joker = v.config.center.key,
        ability = v.ability,
        edition = v.edition,
      })
    end
  end
  local _first_dissolve = nil
  G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.75, func = function()
      for k, v in pairs(G.jokers.cards) do
          if not v.edition or v.edition.type ~= Balatrogether.prefix .. "_secure" then
            v:start_dissolve(nil, _first_dissolve)
            _first_dissolve = true
          end
      end
      return true end }))
  if data.user then
    G.FUNCS.tcp_send({ cmd = "SWAP_JOKERS", jokers = jokers, player = data.user, responding = true })
  end
  local _first_materialize = nil
  G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.4, func = function()
      for k, v in pairs(data.jokers) do
        local card = add_joker(v.joker, v.edition, _first_materialize)
        card.ability = v.ability
      end
      return true end }))
end)