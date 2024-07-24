G.FUNCS.get_unsecure_jokers = function()
  local jokers = {}
  for k, v in pairs(G.jokers.cards) do
    if not v.edition or v.edition.type ~= Balatrogether.prefix .. "_secure" then
      table.insert(jokers, v)
    end
  end
  return jokers
end

G.FUNCS.serialize_joker = function(joker)
  return {
    joker = v.config.center.key,
    ability = v.ability,
    edition = v.edition,
  }
end

G.FUNCS.serialize_jokers = function(jokers)
  local serialized = {}
  for k, v in pairs(jokers) do
    table.insert(serialized, G.FUNCS.serialize_joker(v))
  end
  return serialized
end

G.FUNCS.get_serialized_deck = function()
  local serialized = {}
  for k, v in pairs(G.deck.cards) do
    if not v.edition or v.edition.type ~= Balatrogether.prefix .. "_secure" then
      local suit = (v.base.suit == 'Diamonds' and 'D_') or
      (v.base.suit == 'Spades' and 'S_') or
      (v.base.suit == 'Clubs' and 'C_') or
      (v.base.suit == 'Hearts' and 'H_')
      local val = (v.base.value == 'Ace' and 'A') or
      (v.base.value == 'King' and 'K') or
      (v.base.value == 'Queen' and 'Q') or
      (v.base.value == 'Jack' and 'J') or
      (v.base.value == '10' and 'T') or 
      (v.base.value)
      table.insert(serialized, {
        key = suit .. val,
        edition = v.edition,
        ability = v.ability,
        seal = v.seal,
      })
    end
  end
end

G.FUNCS.tcp_listen("MONEY", function(data)
  ease_dollars(data.money)
end)

G.FUNCS.tcp_listen("HAND_SIZE", function(data)
  G.hand:change_size(data.hand_size)
end)

G.FUNCS.tcp_listen("SWAP_JOKERS", function(data)
  local jokers = G.FUNCS.get_unsecure_jokers()
  local _first_dissolve = nil
  G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.75, func = function()
      for k, v in pairs(jokers) do
          v:start_dissolve(nil, _first_dissolve)
          _first_dissolve = true
      end
      return true end }))
  if data.user then
    G.FUNCS.tcp_send({ cmd = "SWAP_JOKERS", jokers = G.FUNCS.serialize_jokers(jokers), player = data.user, responding = true })
  end
  local _first_materialize = nil
  G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.4, func = function()
      for k, v in pairs(data.jokers) do
        local card = add_joker(v.joker, v.edition, _first_materialize)
        card.ability = v.ability
      end
      return true end }))
end)

G.FUNCS.tcp_listen("GET_CARDS_AND_JOKERS", function(data)
  local jokers = G.FUNCS.serialize_jokers(G.FUNCS.get_unsecure_jokers())
  local cards = G.FUNCS.get_serialized_deck()
  G.FUNCS.tcp_send({ cmd = "CARDS_AND_JOKERS", jokers = jokers, cards = cards })
end)