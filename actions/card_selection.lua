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

function Controller:queue_R_cursor_press(x, y)
  if self.locks.frame then return end
  if not G.SETTINGS.paused and G.hand and G.hand.highlighted[1] then 
      if (G.play and #G.play.cards > 0) or
      (self.locked) or 
      (self.locks.frame) or
      (G.GAME.STOP_USE and G.GAME.STOP_USE > 0) then return end
      if G.FUNCS.is_coop_game() then
        G.FUNCS.tcp_send({ cmd = "UNHIGHLIGHT_ALL" })
      end
      G.hand:unhighlight_all()
  end
end

G.FUNCS.tcp_listen("HIGHLIGHT", function(data)
  G[data.type]:add_to_highlighted(G[data.type].cards[data.index])
end)

G.FUNCS.tcp_listen("UNHIGHLIGHT", function(data)
  G[data.type]:remove_from_highlighted(G[data.type].cards[data.index])
end)

G.FUNCS.tcp_listen("UNHIGHLIGHT_ALL", function(data)
  G.hand:unhighlight_all()
end)