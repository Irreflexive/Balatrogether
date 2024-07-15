local drag_card = Card.drag
local current_card_dragging = nil
local old_card_index = nil
function Card:drag()
  if self.area and (self.area == G.hand or self.area == G.jokers or self.area == G.consumeables) and current_card_dragging ~= self.ID then
    for k,card in ipairs(self.area.cards) do
      if card.ID == self.ID then
        old_card_index = k
      end
    end
    current_card_dragging = self.ID
  end
  drag_card(self)
end

function Card:stop_drag()
  Node.stop_drag(self)
  if self.area and self.area == G.hand or self.area == G.jokers or self.area == G.consumeables then
    local new_card_index = nil
    for k,card in ipairs(self.area.cards) do
      if card.ID == self.ID then
        new_card_index = k
      end
    end

    local orderChanged = new_card_index ~= old_card_index
    if G.FUNCS.is_coop_game() and orderChanged then
      local areaType = self.area == G.hand and "hand" 
        or self.area == G.jokers and "jokers" 
        or self.area == G.consumeables and "consumeables" 
        or nil
      G.FUNCS.tcp_send({ cmd = "REORDER", type = areaType, from = old_card_index, to = new_card_index })
    end
  end
  current_card_dragging = nil
end

G.FUNCS.sort_hand_suit = function(...)
  if G.FUNCS.is_coop_game() then
    G.FUNCS.tcp_send({ cmd = "SORT_HAND", type = "suit" })
  else
    G.FUNCS.SINGLEPLAYER_FUNCS.sort_by_suit(...)
  end
end

G.FUNCS.sort_hand_value = function(...)
  if G.FUNCS.is_coop_game() then
    G.FUNCS.tcp_send({ cmd = "SORT_HAND", type = "value" })
  else
    G.FUNCS.SINGLEPLAYER_FUNCS.sort_by_value(...)
  end
end

G.MULTIPLAYER.actions.REORDER = function(data)
  local card = G[data.type].cards[data.from]
  table.remove(G[data.type].cards, data.from)
  table.insert(G[data.type].cards, data.to, card)
end

G.MULTIPLAYER.actions.SORT_HAND = function(data)
  if data.type == "suit" then
    G.SINGLEPLAYER_FUNCS.sort_by_suit()
  elseif data.type == "value" then
    G.SINGLEPLAYER_FUNCS.sort_by_value()
  end
end