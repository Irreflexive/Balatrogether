function Card:click() 
  if self.area and self.area:can_highlight(self) then
      if (self.area == G.hand) and (G.STATE == G.STATES.HAND_PLAYED) then return end
      local index = 1
      for k,v in ipairs(self.area.cards) do
        if v.ID == self.ID then index = k end
      end
      local areaType = self.area == G.hand and "hand" 
        or self.area == G.jokers and "jokers" 
        or self.area == G.consumeables and "consumeables" 
        or self.area == G.shop_jokers and "shop_jokers"
        or self.area == G.shop_booster and "shop_booster"
        or self.area == G.shop_vouchers and "shop_vouchers"
        or self.area == G.pack_cards and "pack_cards"
        or nil
      if self.highlighted ~= true then 
          if G.FUNCS.is_coop_game() and areaType then
            G.FUNCS.tcp_send({ cmd = "HIGHLIGHT", index = index, type = areaType })
          end
          self.area:add_to_highlighted(self)
      else
          if G.FUNCS.is_coop_game() and areaType then
            G.FUNCS.tcp_send({ cmd = "UNHIGHLIGHT", index = index, type = areaType })
          end
          self.area:remove_from_highlighted(self)
          play_sound('cardSlide2', nil, 0.3)
      end
  end
  if self.area and self.area == G.deck and self.area.cards[1] == self then 
      G.FUNCS.deck_info()
  end
end

G.MULTIPLAYER.actions.HIGHLIGHT = function(data)
  G[data.type]:add_to_highlighted(G[data.type].cards[data.index])
end

G.MULTIPLAYER.actions.UNHIGHLIGHT = function(data)
  G[data.type]:remove_from_highlighted(G[data.type].cards[data.index])
end

G.MULTIPLAYER.actions.UNHIGHLIGHT_ALL = function(data)
  G.hand:unhighlight_all()
end