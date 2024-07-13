--- STEAMODDED HEADER
--- MOD_NAME: Balatrogether
--- MOD_ID: Balatrogether
--- MOD_AUTHOR: [Irreflexive]
--- MOD_DESCRIPTION: Play co-op Balatro with your friends!
--- BADGE_COLOUR: 00FF64

----------------------------------------------
------------MOD CODE -------------------------

function SMODS.INIT.Balatrogether()
	local mod = SMODS.findModByID("Balatrogether")
  sendDebugMessage("Launching Balatrogether!")
	assert(load(NFS.read(mod.path .. "json.lua")))()
	assert(load(NFS.read(mod.path .. "util.lua")))()
	assert(load(NFS.read(mod.path .. "UI_definitions.lua")))()
	assert(load(NFS.read(mod.path .. "connection.lua")))()
	assert(load(NFS.read(mod.path .. "actions.lua")))()
end

G.MULTIPLAYER = {
  enabled = false,
  -- address = "",
  address = "192.9.250.154",
  players = {},
  tcp = nil,
}

local old_update = love.update
function love.update(dt)
  old_update(dt)
  G.FUNCS.tcp_listen()
end

G.FUNCS.join_server = function()
  sendDebugMessage("Joining server!")
  G.FUNCS.tcp_connect()
  G.FUNCS.tcp_send({ cmd = "JOIN" })
end

G.FUNCS.change_player_list_page = function(args)
  if not args or not args.cycle_config then return end
  if G.OVERLAY_MENU then
    local pl_list = G.OVERLAY_MENU:get_UIE_by_ID('server_player_list')
    if pl_list then 
      if pl_list.config.object then 
        pl_list.config.object:remove() 
      end
      pl_list.config.object = UIBox{
        definition =  G.UIDEF.player_list_page(args.cycle_config.current_option-1),
        config = {offset = {x=0,y=0}, align = 'cm', parent = pl_list}
      }
    end
  end
end

G.FUNCS.copy_server_code = function(e)
  if G.F_LOCAL_CLIPBOARD then
    G.CLIPBOARD = G.MULTIPLAYER.address
  else
    love.system.setClipboardText(G.MULTIPLAYER.address)
  end 
end

G.FUNCS.start_setup_run = function(e)
  if G.OVERLAY_MENU then G.FUNCS.exit_overlay_menu() end
  if G.SETTINGS.current_setup == 'New Run' then 
    if not G.GAME or (not G.GAME.won and not G.GAME.seeded) then
      if G.SAVED_GAME ~= nil then
        if not G.SAVED_GAME.GAME.won then 
          G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt = 0
        end
        G:save_settings()
      end
    end
    local _seed = G.run_setup_seed and G.setup_seed or G.forced_seed or nil
    local _challenge = G.challenge_tab or nil
    local _stake = G.forced_stake or G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
    G.FUNCS.start_run(e, {stake = _stake, seed = _seed, challenge = _challenge})
  
  elseif G.SETTINGS.current_setup == 'Multiplayer Run' then
    local _stake = G.forced_stake or G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
    G.FUNCS.tcp_send({cmd = "START", stake = _stake, seed = generate_starting_seed(), challenge = nil, deck = G.GAME.selected_back.name})

  elseif G.SETTINGS.current_setup == 'Continue' then
    if G.SAVED_GAME ~= nil then
      G.FUNCS.start_run(nil, {savetext = G.SAVED_GAME})
    end
  end
end

G.FUNCS.setup_run_multiplayer = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.server_config(),
  }
  if (e.config.id == 'from_game_over' or e.config.id == 'from_game_won') then G.OVERLAY_MENU.config.no_esc =true end
end

local go_to_menu = G.FUNCS.go_to_menu
G.FUNCS.go_to_menu = function(e)
  if G.MULTIPLAYER.enabled then
    G.FUNCS.tcp_close()
  end
  go_to_menu(e)
end

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
          or nil
        if self.highlighted ~= true then 
            if G.MULTIPLAYER.enabled and areaType then
              G.FUNCS.tcp_send({ cmd = "HIGHLIGHT", index = index, type = areaType })
            end
            self.area:add_to_highlighted(self)
        else
            if G.MULTIPLAYER.enabled and areaType then
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

local old_card_open = Card.open
function Card:open()
  if self.ability.set == "Booster" then
    if G.MULTIPLAYER.enabled then
      G.FUNCS.tcp_send({ cmd = "BUY", index = self.index })
    else
      old_card_open(self)
    end
  end
end

function Controller:queue_R_cursor_press(x, y)
  if self.locks.frame then return end
  if not G.SETTINGS.paused and G.hand and G.hand.highlighted[1] then 
      if (G.play and #G.play.cards > 0) or
      (self.locked) or 
      (self.locks.frame) or
      (G.GAME.STOP_USE and G.GAME.STOP_USE > 0) then return end
      if G.MULTIPLAYER.enabled then
        G.FUNCS.tcp_send({ cmd = "UNHIGHLIGHT_ALL" })
      end
      G.hand:unhighlight_all()
  end
end

function Controller:key_hold_update(key, dt)
  if ((self.locked) and not G.SETTINGS.paused) or (self.locks.frame) or (self.frame_buttonpress) then return end
  --self.frame_buttonpress = true
  if self.held_key_times[key] then
      if key == "r" and not G.SETTINGS.paused then
          if self.held_key_times[key] > 0.7 then
              if not G.GAME.won and not G.GAME.seeded and not G.GAME.challenge then 
                  G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt = 0
              end
              G:save_settings()
              self.held_key_times[key] = nil
              if G.MULTIPLAYER.enabled then
                G.SETTINGS.current_setup = 'Multiplayer Run'
              else
                G.SETTINGS.current_setup = 'New Run'
              end
              G.GAME.viewed_back = nil
              G.run_setup_seed = G.GAME.seeded
              G.challenge_tab = G.GAME and G.GAME.challenge and G.GAME.challenge_tab or nil
              G.forced_seed, G.setup_seed = nil, nil
              if G.GAME.seeded then G.forced_seed = G.GAME.pseudorandom.seed end
              G.forced_stake = G.GAME.stake
              if G.STAGE == G.STAGES.RUN then G.FUNCS.start_setup_run() end
              G.forced_stake = nil
              G.challenge_tab = nil
              G.forced_seed = nil
          else
              self.held_key_times[key] = self.held_key_times[key] + dt
          end
      end
  end
end

----------------------------------------------
------------MOD CODE END----------------------