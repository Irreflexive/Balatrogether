Balatrogether.mod.config_tab = function()
  return {n = G.UIT.ROOT, config = {r = 0.1, minw = 5, align = "cm", padding = 0.2, colour = G.C.BLACK}, nodes = {
    create_toggle({
      label = localize('b_debug_mode'), 
      w = 0,
      ref_table = Balatrogether.mod.config, 
      ref_value = 'debug', 
      callback = function() SMODS.save_mod_config(Balatrogether.mod) end
    }),
  }}
end

local create_UIBox_main_menu_buttons_ref = create_UIBox_main_menu_buttons
function create_UIBox_main_menu_buttons()
  local t = create_UIBox_main_menu_buttons_ref()
  local playButton = findDescendantOfNodeTreeByConfig(t, "button", "setup_run")
  if playButton and G.STEAM then
    playButton.config.button = "choose_game_mode"
  end
  return t
end

G.FUNCS.choose_game_mode = function(e)
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.choose_game_mode(),
  }
end

function G.UIDEF.choose_game_mode()
  G.run_setup_seed = nil
  G.FUNCS.false_ret = function() return false end
  local t = create_UIBox_generic_options({contents = {
    UIBox_button{label = {localize('b_singleplayer')}, button = "setup_run", minw = 5},
    UIBox_button{label = {localize('b_multiplayer')}, button = "setup_join_server", minw = 5},
  }})
  return t
end

G.FUNCS.setup_join_server = function(e)
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.multiplayer_mode(),
  }
end

function G.UIDEF.multiplayer_mode()
  local t = create_UIBox_generic_options({contents ={
    {n=G.UIT.R, config={align = "cm", padding = 0, draw_layer = 1}, nodes={
      create_tabs(
      {tabs = {
        {
          label = localize('b_balatrogether'),
          chosen = true,
          tab_definition_function = G.UIDEF.multiplayer_join,
        },
      },
      snap_to_nav = true}),
    }},
  }})
  
  return t
end

function G.UIDEF.multiplayer_join()
  G.E_MANAGER:add_event(Event({func = (function()
    G.FUNCS.set_connection_status("")
  return true end)}))

  local t = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR, minh = 5, minw = 8}, nodes={
    {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
      {n=G.UIT.T, config={text = localize('b_new_server'), scale = 0.5, colour = G.C.WHITE}},
    }},
    {n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={
      {n=G.UIT.C, config={align = "cm", minw = 1}, nodes={
        create_text_input({ref_table = Balatrogether, extended_corpus = true, max_length = 255, keep_zeroes = true, ref_value = 'address_input', prompt_text = localize('b_hostname')}),
        {n=G.UIT.C, config={align = "cm", minw = 0.1}, nodes={}},
        UIBox_button({label = {localize('b_paste')}, minw = 1, minh = 0.6, button = 'paste_address', colour = G.C.BLUE, scale = 0.3, col = true})
      }},
    }},
    {n=G.UIT.R, config={align = "cm", padding = 0.3, minh = 1.4}, nodes={
      {n=G.UIT.C, config={align = "cm", minw = 4, minh = 0.8, padding = 0.2, r = 0.1, hover = true, colour = G.C.BLUE, button = "join_server", one_press = true, shadow = true}, nodes={
        {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
          {n=G.UIT.T, config={text = localize('b_join'), scale = 0.8, colour = G.C.UI.TEXT_LIGHT, func = 'set_button_pip', focus_args = {button = 'x',set_button_pip = true}}}
        }}
      }}
    }},
    G.UIDEF.saved_servers(),
    {n=G.UIT.R, config={align = "cm", minh = 0.9}, nodes={ 
      {n=G.UIT.O, config={id = 'connection_status', object = Moveable()}},
    }},
  }}
  return t
end

function G.UIDEF.connection_status()
  local text = Balatrogether.connection_status or ""
  local t = {n=G.UIT.ROOT, config={align = "cm", minh = 0.7, minw = 0.7, padding = 0.2, colour = text == "" and G.C.CLEAR or G.C.BLACK, r = 0.1}, nodes={ 
    {n=G.UIT.T, config={text = text, scale = 0.5, colour = G.C.WHITE}}
  }}
  return t
end

function G.UIDEF.server_config(e)
  local in_game = G.STAGE ~= G.STAGES.MAIN_MENU
  local no_escape = e and (e.config.id == 'from_game_over' or e.config.id == 'from_game_won')
  local t = create_UIBox_generic_options({
    no_esc = not in_game or no_escape, 
    no_back = no_escape, 
    back_func = not in_game and "tcp_close" or nil, 
    back_label = not in_game and localize('b_leave_server') or nil,
    contents = {
      {n=G.UIT.R, config={align = "cm", padding = 0, draw_layer = 1}, nodes={
        create_tabs(
        {tabs = {
          {
            label = localize('b_players'),
            chosen = true,
            tab_definition_function = G.UIDEF.player_list,
          },
          {
            label = localize('b_settings'),
            chosen = false,
            tab_definition_function = G.UIDEF.multiplayer_settings,
            func = 'can_setup_multiplayer_run'
          },
          {
            label = localize('b_multiplayer_run'),
            chosen = false,
            tab_definition_function = G.UIDEF.run_setup_multiplayer,
            func = 'can_setup_multiplayer_run'
          },
        },
        snap_to_nav = true}),
      }},
    }
  })
  return t
end

G.FUNCS.change_showdown_ante = function(args)
  Balatrogether.new_run_config.showdown_ante = args.to_val
end

function G.UIDEF.multiplayer_settings()
  local t = {n=G.UIT.ROOT, config={id = 'balatrogether_run_settings', align = "cm", colour = G.C.CLEAR, minh = 3, minw = 4.2}, nodes={
    {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
      Balatrogether.mod.config.debug and create_toggle({
        label = localize('b_debug_mode'),
        w = 0,
        ref_table = Balatrogether.new_run_config,
        ref_value = "debug",
        callback = function(_set_toggle)
          Balatrogether.new_run_config.debug = _set_toggle
        end,
      }) or nil,
      create_toggle({
        label = localize('b_versus_mode'),
        w = 0,
        ref_table = Balatrogether.new_run_config,
        ref_value = "versus",
        callback = function(_set_toggle)
          Balatrogether.new_run_config.versus = _set_toggle
        end,
      }),
      create_option_cycle({
        label = localize('b_showdown_ante'), 
        options = Balatrogether.mod.config.debug and {1, 4, 8, 12, 16}, {4, 8, 12, 16}, 
        opt_callback = 'change_showdown_ante', 
        current_option = math.ceil(Balatrogether.new_run_config.showdown_ante / 4), 
        colour = G.C.RED, 
        w = 2, 
        scale = 0.8
      })
    }}
  }}
  return t
end

function G.UIDEF.run_setup_multiplayer()
  local t = G.UIDEF.run_setup_option('Multiplayer Run')
  G.viewed_stake = G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
  G.FUNCS.change_stake({to_key = G.viewed_stake})
  return t
end

function G.UIDEF.server_address()
  local t = {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
    {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
      {n=G.UIT.T, config={text = localize('b_hostname') .. ': ' .. Balatrogether.server.address, scale = 0.5, colour = G.C.WHITE}},
    }},
    {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
      UIBox_button({id = 'copy_code', col = true, label = {localize('b_copy')}, button = 'copy_server_code', colour = G.C.BLUE, scale = 0.5, minw = 2, minh = 0.6}),
      UIBox_button({id = 'save_server', col = true, label = {localize('b_save_address')}, button = 'save_server', colour = G.C.BLUE, scale = 0.5, minw = 2, minh = 0.6}),
    }},
  }}
  return t
end

local create_UIBox_options_ref = create_UIBox_options
function create_UIBox_options()  
  local t = create_UIBox_options_ref()
  if G.STAGE == G.STAGES.RUN and Balatrogether.server.enabled then
    local contents = t.nodes[1].nodes[1].nodes[1]
    contents.nodes[2] = nil
    contents.nodes[3] = UIBox_button{id = 'server_settings_button', label = {localize('b_server_settings')}, button = "setup_run_multiplayer", minw = 5}
    contents.nodes[4] = UIBox_button{label = {localize('b_leave_server')}, button = "tcp_close", minw = 5}
  end
  return t
end

local create_UIBox_win_ref = create_UIBox_win
function create_UIBox_win()
  local t = create_UIBox_win_ref()

  if Balatrogether.server.enabled then
    local new_run_button = findDescendantOfNodeTreeByConfig(t, 'id', 'from_game_won')
    if new_run_button then
      new_run_button.config.button = 'setup_run_multiplayer'
    end

    local main_menu_button = findDescendantOfNodeTreeByConfig(t, 'button', 'go_to_menu')
    if main_menu_button then
      main_menu_button.config.button = 'tcp_close'
    end

    local endless_button = findDescendantOfNodeTreeByConfig(t, 'button', 'exit_overlay_menu')
    if endless_button then
      if G.FUNCS.is_versus_game() then
        endless_button.config.colour = G.C.UI.BACKGROUND_INACTIVE
        endless_button.config.button = nil
      else
        endless_button.config.button = 'endless_multiplayer'
      end
    end
  end

  return t
end

local create_UIBox_game_over_ref = create_UIBox_game_over
function create_UIBox_game_over()
  local t = create_UIBox_game_over_ref()

  if Balatrogether.server.enabled then
    if G.FUNCS.is_versus_game() then
      G.FUNCS.tcp_send({cmd = "ELIMINATED"})
    end

    local new_run_button = findDescendantOfNodeTreeByConfig(t, 'id', 'from_game_over')
    if new_run_button then
      new_run_button.config.button = 'setup_run_multiplayer'
    end

    local main_menu_button = findDescendantOfNodeTreeByConfig(t, 'button', 'go_to_menu')
    if main_menu_button then
      main_menu_button.config.button = 'tcp_close'
    end
  end

  return t
end

local saved_server_id = createUIListFunctions('saved_servers', function() return Balatrogether.mod.config.saved_servers end, 4, function(k, v)
  return {
    UIBox_button({id = v, col = true, label = {v or ""}, button = v and 'join_saved_server' or 'nil', colour = v and G.C.RED or G.C.GREY, minw = 5, scale = 0.4, minh = 0.6, one_press = false, focus_args = {snap_to = not snapped}}),
    {n=G.UIT.C, config={align = 'cm', minw = 0.1}, nodes = {}},
    UIBox_button({id = v and 'remove_'..v or nil, col = true, label = {'X'}, button = v and 'remove_server' or 'nil', colour = v and G.C.RED or G.C.GREY, scale = 0.4, minw = 0.6, minh = 0.6, one_press = true, focus_args = {snap_to = not snapped}}),
  }
end)

function G.UIDEF.saved_servers()
  local t = {n=G.UIT.R, config={align = "cm", colour = G.C.CLEAR}, nodes={
    {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
      {n=G.UIT.T, config={text = localize('b_saved_servers'), scale = 0.5, colour = G.C.WHITE}},
    }},
    G.UIDEF[saved_server_id](),
  }}

  return t
end

local player_list_id = createUIListFunctions('lobby_players', function() return Balatrogether.server.players end, 4, function(k, v)
  return {
    UIBox_button({
      id = k, 
      col = true, 
      label = {G.FUNCS.get_player_name(v)}, 
      button = 'nil', 
      colour = v and (tostring(G.STEAM.user.getSteamID()) == v.id and G.C.IMPORTANT or G.C.RED) or G.C.GREY, 
      minw = 4, 
      scale = 0.4, 
      minh = 0.6, 
      focus_args = {snap_to = not snapped}, 
      shadow = true
    }),
  }
end)

function G.UIDEF.player_list()
  local t = {n=G.UIT.ROOT, config={id = 'balatrogether_player_list', align = "cm", colour = G.C.CLEAR, minh = 7, minw = 4.2}, nodes={
    {n=G.UIT.R, config={align = "cm", padding = 0.0}, nodes={
      G.UIDEF.server_address(),
      {n=G.UIT.R, config={align = "cm", padding = 0.3}, nodes={}},
      {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
        {n=G.UIT.T, config={text = localize('b_player_list'), scale = 0.5, colour = G.C.WHITE}},
      }},
      G.UIDEF[player_list_id](),
    }},
  }}
  return t
end

local lobby_list_id = createUIListFunctions('server_lobbies', function() return Balatrogether.server.lobbies end, 4, function(k, v)
  return {
    UIBox_button({
      id = k, 
      col = true, 
      label = {v and (tostring(v.players)..'/'..tostring(v.max) .. ' ' .. localize('b_players')) or ''}, 
      button = (v and v.open) and 'join_lobby' or 'nil', 
      colour = (v and v.open) and G.C.RED or G.C.GREY, 
      minw = 4, 
      scale = 0.4, 
      minh = 0.6, 
      focus_args = {snap_to = not snapped}, 
      shadow = true
    }),
  }
end)

function G.UIDEF.lobby_list()
  local t = create_UIBox_generic_options({back_func = 'setup_join_server', contents = {
    {n=G.UIT.R, config={id = 'balatrogether_lobby_list', align = "cm", colour = G.C.CLEAR, minh = 7, minw = 4.2}, nodes={
      {n=G.UIT.R, config={align = "cm", padding = 0.0}, nodes={
        G.UIDEF.server_address(),
        {n=G.UIT.R, config={align = "cm", padding = 0.3}, nodes={}},
        {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
          {n=G.UIT.T, config={text = localize('b_lobby_list'), scale = 0.5, colour = G.C.WHITE}},
        }},
        G.UIDEF[lobby_list_id](),
      }},
      {n=G.UIT.R, config={align = "cm", padding = 0.0}, nodes={
        {n=G.UIT.C, config={align = "cm", minw = 3, padding = 0.1, r = 0.1, hover = true, colour = G.C.BLUE, button = "refresh_lobbies", shadow = true}, nodes={
          {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
            {n=G.UIT.T, config={text = localize('b_refresh'), scale = 0.5, colour = G.C.UI.TEXT_LIGHT, func = 'set_button_pip', focus_args = {button = 'x',set_button_pip = true}}}
          }}
        }},
      }},
    }},
  }})
  return t
end

local leaderboard_list_id = createUIListFunctions('boss_leaderboard', function() return Balatrogether.server.leaderboard end, 8, function(k, v)
  local stake_sprite = get_stake_sprite(G.GAME.stake or 1, 0.5)
  return v and {
    {n=G.UIT.C, config={align = "cm", minw = 7.5, minh = 0.6, r = 0.1, colour = (v.score and k <= G.FUNCS.get_duel_threshold()) and G.C.BLUE or G.C.GREY}, nodes = {
      {n=G.UIT.C, config={align = "cl", minw = 4, minh = 0.6, padding = 0.1}, nodes={
        {n=G.UIT.T, config={text = G.FUNCS.get_player_name(v.player), scale = 0.4, colour = G.C.WHITE, shadow = true}},
      }},
      {n=G.UIT.C, config={align = "cr", minw = 3.5, minh = 0.6, padding = 0.1}, nodes=v.score and {
        {n=G.UIT.T, config={text = number_format(v.score), lang = G.LANGUAGES['en-us'], scale = 0.4, colour = G.C.WHITE, shadow = true}},
        {n=G.UIT.O, config={w=0.4,h=0.4, object = stake_sprite, hover = true, can_collide = false}},
      } or {
        {n=G.UIT.T, config={text = localize('b_eliminated'), scale = 0.4, colour = G.C.WHITE, shadow = true}},
      }},
    }},
  } or {
    {n=G.UIT.C, config={align = "cm", minw = 7.5, minh = 0.6, r = 0.1, colour = G.C.GREY}, nodes = {}},
  }
end, {minw = 9})

function G.UIDEF.boss_leaderboard()
  local list = {}
  local survived = false
  for k = 1, G.FUNCS.get_duel_threshold() do
    local row = Balatrogether.server.leaderboard[k]
    if row and tostring(G.STEAM.user.getSteamID()) == row.player then
      survived = true
      break
    end
  end

  local t = create_UIBox_generic_options({ back_label = localize('b_continue'), back_func = survived and 'close_leaderboard' or 'lose_duel_versus', contents = {
      {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
        {n=G.UIT.T, config={text = localize('b_boss_leaderboard'), scale = 0.5, colour = G.C.WHITE}},
      }},
      {
        n = G.UIT.R,
        config = {
          emboss = 0.05,
          r = 0.1,
          minw = 8,
          align = "cm",
          padding = 0.2,
          colour = G.C.BLACK
        },
        nodes = {G.UIDEF[leaderboard_list_id]()}
      },
    }})
  return t
end