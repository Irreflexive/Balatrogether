G.FUNCS.get_unsecure_jokers = function()
  local jokers = {}
  for k, v in pairs(G.jokers.cards) do
    if not v.edition or v.edition.type ~= createCollectionId(nil, 'secure') then
      table.insert(jokers, v)
    end
  end
  return jokers
end

G.FUNCS.serialize_joker = function(joker)
  local ability = {}
  for k,v in pairs(joker.ability) do
    if v ~= 0 then ability[k] = v end
  end
  return {
    k = joker.config.center.key,
    a = ability,
    ed = joker.edition,
    et = joker.eternal or nil
  }
end

G.FUNCS.serialize_jokers = function(jokers)
  local serialized = {}
  for k, v in pairs(jokers) do
    table.insert(serialized, G.FUNCS.serialize_joker(v))
  end
  return serialized
end

local function getEnhancementKey(abilityName)
  for k,v in pairs(G.P_CENTERS) do
    if v.name == abilityName and k:match("^m_") then
      return k
    end
  end
  return nil
end

G.FUNCS.get_serialized_deck = function()
  local serialized = {}
  for k, v in pairs(G.deck.cards) do
    if not v.edition or v.edition.type ~= createCollectionId(nil, 'secure') then
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
      local enhancement = getEnhancementKey(v.ability and v.ability.name)
      local bonus = v.ability and v.ability.perma_bonus or nil
      table.insert(serialized, {
        k = suit .. val,
        ed = v.edition,
        en = enhancement,
        s = v.seal,
        c = bonus ~= 0 and bonus or nil
      })
    end
  end
  return serialized
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
  if data.request_id then
    G.FUNCS.tcp_send({ cmd = "SWAP_JOKERS", jokers = G.FUNCS.serialize_jokers(jokers), request_id = data.request_id })
  end
  local _first_materialize = nil
  G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.4, func = function()
      for k, v in pairs(data.jokers) do
        local card = add_joker(v.k, v.ed, _first_materialize, v.et)
        if v.a then card:set_ability(v.a) end
      end
      return true end }))
end)

G.FUNCS.tcp_listen("GET_CARDS_AND_JOKERS", function(data)
  if data.request_id then
    local jokers = G.FUNCS.serialize_jokers(G.FUNCS.get_unsecure_jokers())
    local cards = G.FUNCS.get_serialized_deck()
    local randomCardSelection = {}
    table.sort(cards, function(a, b) return math.random() > 0.5 end)
    for i = 1, 20 do
      if not cards[i] then break end
      table.insert(randomCardSelection, cards[i])
    end
    G.FUNCS.tcp_send({ cmd = "GET_CARDS_AND_JOKERS", jokers = jokers, cards = randomCardSelection, request_id = data.request_id })
  else
    Balatrogether.server.network_pack = {
      jokers = #data.jokers > 0 and data.jokers or {{k = 'j_joker'}},
      cards = #data.cards > 0 and data.cards or {}
    }
  end
end)