local run_setup_ref = G.UIDEF.run_setup
function G.UIDEF.run_setup(from_game_over)
  if not G.STEAM then return run_setup_ref(from_game_over) end
  G.run_setup_seed = nil
  local _challenge_chosen = from_game_over == 'challenge_list'
  from_game_over = from_game_over and not (from_game_over == 'challenge_list')

  local _can_continue = G.MAIN_MENU_UI and G.FUNCS.can_continue({config = {func = true}})
  G.FUNCS.false_ret = function() return false end
  local t =   create_UIBox_generic_options({no_back = from_game_over, no_esc = from_game_over, contents ={
      {n=G.UIT.R, config={align = "cm", padding = 0, draw_layer = 1}, nodes={
        create_tabs(
        {tabs = {
            {
              label = localize('b_new_run'),
              chosen = (not _challenge_chosen) and (not _can_continue),
              tab_definition_function = G.UIDEF.run_setup_option,
              tab_definition_function_args = 'New Run'
            },
            G.STAGE == G.STAGES.MAIN_MENU and {
              label = localize('b_continue'),
              chosen = (not _challenge_chosen) and _can_continue,
              tab_definition_function = G.UIDEF.run_setup_option,
              tab_definition_function_args = 'Continue',
              func = 'can_continue'
            } or {
              label = localize('b_challenges'),
              tab_definition_function = G.UIDEF.challenges,
              tab_definition_function_args = from_game_over,
              chosen = _challenge_chosen
            },
            G.STAGE == G.STAGES.MAIN_MENU and {
              label = localize('b_challenges'),
              tab_definition_function = G.UIDEF.challenges,
              tab_definition_function_args = from_game_over,
              chosen = _challenge_chosen
            } or nil,
            {
              label = localize('b_balatrogether'),
              tab_definition_function = G.UIDEF.multiplayer_join,
            }
        },
        snap_to_nav = true}),
      }},
  }})
  return t
end

function G.UIDEF.multiplayer_join()
  G.E_MANAGER:add_event(Event({func = (function()
    G.FUNCS.update_connection_status()
  return true end)}))

  local t = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR, minh = 5, minw = 6}, nodes={
    G.UIDEF.saved_servers(),
    {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
      {n=G.UIT.T, config={text = localize('b_new_server'), scale = 0.5, colour = G.C.WHITE}},
    }},
    {n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={
      {n=G.UIT.C, config={align = "cm", minw = 1}, nodes={
        create_text_input({ref_table = Balatrogether, extended_corpus = true, keep_zeroes = true, ref_value = 'address_input', prompt_text = localize('b_ip_address')}),
        {n=G.UIT.C, config={align = "cm", minw = 0.1}, nodes={}},
        UIBox_button({label = {localize('b_paste')}, minw = 1, minh = 0.6, button = 'paste_address', colour = G.C.BLUE, scale = 0.3, col = true})
      }},
    }},
    {n=G.UIT.R, config={align = "cm", minh = 1.3}, nodes={ 
      {n=G.UIT.O, config={id = 'connection_status', object = Moveable()}},
    }},
    {n=G.UIT.R, config={align = "cm", padding = 0.05, minh = 0.9}, nodes={
        {n=G.UIT.C, config={align = "cm", minw = 4, minh = 0.8, padding = 0.2, r = 0.1, hover = true, colour = G.C.GREEN, button = "join_server", one_press = true, shadow = true}, nodes={
          {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
            {n=G.UIT.T, config={text = localize('b_join'), scale = 0.8, colour = G.C.UI.TEXT_LIGHT, func = 'set_button_pip', focus_args = {button = 'x',set_button_pip = true}}}
          }}
        }}
      }
    }}
  }
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
  local t =   create_UIBox_generic_options({no_esc = not in_game or no_escape, no_back = no_escape, back_func = not in_game and "tcp_close" or nil, contents ={
      {n=G.UIT.R, config={align = "cm", padding = 0, draw_layer = 1}, nodes={
        create_tabs(
        {tabs = {
            {
              label = localize('b_players'),
              chosen = true,
              tab_definition_function = G.UIDEF.player_list,
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
  }})
  return t
end

function G.UIDEF.run_setup_multiplayer()
  local t = G.UIDEF.run_setup_option('Multiplayer Run')
  table.insert(t.nodes, 1, create_toggle({
    label = localize('b_versus_mode'),
    ref_table = Balatrogether.new_run_config,
    ref_value = "versus",
    callback = function(_set_toggle)
      Balatrogether.new_run_config.versus = _set_toggle
    end,
  }))
  return t
end

function G.UIDEF.server_address()
  local t = {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
    {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
      {n=G.UIT.T, config={text = localize('b_ip_address'), scale = 0.5, colour = G.C.WHITE}},
    }},
    {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
      UIBox_button({id = 'server_code', col = true, label = {Balatrogether.server.address}, button = 'nil', colour = G.C.BLUE, scale = 0.5, minw = 3, minh = 0.6, shadow = true}),
    }},
    {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
      UIBox_button({id = 'copy_code', col = true, label = {localize('b_copy')}, button = 'copy_server_code', colour = G.C.BLUE, scale = 0.5, minw = 2, minh = 0.6}),
      UIBox_button({id = 'save_server', col = true, label = {localize('b_save_address')}, button = 'save_server', colour = G.C.BLUE, scale = 0.5, minw = 2, minh = 0.6}),
    }},
  }}
  return t
end

function create_UIBox_options()  
  local current_seed = nil
  local restart = nil
  local main_menu = nil
  local your_collection = nil
  local credits = nil

  G.E_MANAGER:add_event(Event({
    blockable = false,
    func = function()
      G.REFRESH_ALERTS = true
    return true
    end
  }))

  if G.STAGE == G.STAGES.RUN then
    if Balatrogether.server.enabled then
      restart = UIBox_button{id = 'server_settings_button', label = {localize('b_server_settings')}, button = "setup_run_multiplayer", minw = 5}
    else
      restart = UIBox_button{id = 'restart_button', label = {localize('b_start_new_run')}, button = "setup_run", minw = 5}
    end
    if Balatrogether.server.enabled then
      main_menu = UIBox_button{ label = {localize('b_leave_server')}, button = "tcp_close", minw = 5}
    else
      main_menu = UIBox_button{ label = {localize('b_main_menu')}, button = "go_to_menu", minw = 5}
    end
    your_collection = UIBox_button{ label = {localize('b_collection')}, button = "your_collection", minw = 5, id = 'your_collection'}
    current_seed = {n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0}, nodes={
        {n=G.UIT.T, config={text = localize('b_seed')..": ", scale = 0.4, colour = G.C.WHITE}}
      }},
      {n=G.UIT.C, config={align = "cm", padding = 0, minh = 0.8}, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0, minh = 0.8}, nodes={
          {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.GAME.seeded and G.C.RED or G.C.BLACK, minw = 1.8, minh = 0.5, padding = 0.1, emboss = 0.05}, nodes={
            {n=G.UIT.C, config={align = "cm"}, nodes={
              {n=G.UIT.T, config={ text = tostring(G.GAME.pseudorandom.seed), scale = 0.43, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
            }}
          }}
        }}
      }},
      UIBox_button({col = true, button = 'copy_seed', label = {localize('b_copy')}, colour = G.C.BLUE, scale = 0.3, minw = 1.3, minh = 0.5,}),
    }}
  end
  if G.STAGE == G.STAGES.MAIN_MENU then
    credits = UIBox_button{ label = {localize('b_credits')}, button = "show_credits", minw = 5}
  end

  local settings = UIBox_button({button = 'settings', label = {localize('b_settings')}, minw = 5, focus_args = {snap_to = true}})
  local high_scores = UIBox_button{ label = {localize('b_stats')}, button = "high_scores", minw = 5}

  local t = create_UIBox_generic_options({ contents = {
      settings,
      (G.GAME.seeded and not Balatrogether.server.enabled) and current_seed or nil,
      restart,
      main_menu,
      high_scores,
      your_collection,
      credits
    }})
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
    UIBox_button({id = v, col = true, label = {v or ""}, button = v and 'join_saved_server' or 'nil', colour = v and G.C.BLUE or G.C.GREY, minw = 4, scale = 0.4, minh = 0.6, one_press = true, focus_args = {snap_to = not snapped}}),
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
      colour = (v and v.open) and G.C.BLUE or G.C.GREY, 
      minw = 4, 
      scale = 0.4, 
      minh = 0.6, 
      focus_args = {snap_to = not snapped}, 
      shadow = true
    }),
  }
end)

function G.UIDEF.lobby_list()
  local t = create_UIBox_generic_options({ contents = {
    {n=G.UIT.R, config={id = 'balatrogether_lobby_list', align = "cm", colour = G.C.CLEAR, minh = 7, minw = 4.2}, nodes={
      {n=G.UIT.R, config={align = "cm", padding = 0.0}, nodes={
        G.UIDEF.server_address(),
        {n=G.UIT.R, config={align = "cm", padding = 0.3}, nodes={}},
        {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
          {n=G.UIT.T, config={text = localize('b_lobby_list'), scale = 0.5, colour = G.C.WHITE}},
        }},
        G.UIDEF[lobby_list_id](),
        {n=G.UIT.R, config={align = "cm", padding = 0.05, minh = 0.7}, nodes={
          {n=G.UIT.C, config={align = "cm", minw = 3, minh = 0.6, padding = 0.1, r = 0.1, hover = true, colour = G.C.BLUE, button = "refresh_lobbies", shadow = true}, nodes={
            {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
              {n=G.UIT.T, config={text = localize('b_refresh'), scale = 0.4, colour = G.C.UI.TEXT_LIGHT, func = 'set_button_pip', focus_args = {button = 'x',set_button_pip = true}}}
            }}
          }}
        }},
      }},
    }}
  }})
  return t
end

local leaderboard_list_id = createUIListFunctions('boss_leaderboard', function() return Balatrogether.server.leaderboard end, 8, function(k, v)
  local stake_sprite = get_stake_sprite(G.GAME.stake or 1, 0.5)
  return v and {
    {n=G.UIT.C, config={align = "cm", minw = 7.5, minh = 0.6, r = 0.1, colour = (row.score and k <= survive_count) and G.C.BLUE or G.C.GREY}, nodes = {
      {n=G.UIT.C, config={align = "cl", minw = 4, minh = 0.6, padding = 0.1}, nodes={
        {n=G.UIT.T, config={text = G.FUNCS.get_player_name(v.player), scale = 0.4, colour = G.C.WHITE, shadow = true}},
      }},
      {n=G.UIT.C, config={align = "cr", minw = 3.5, minh = 0.6, padding = 0.1}, nodes=row.score and {
        {n=G.UIT.T, config={text = number_format(row.score), lang = G.LANGUAGES['en-us'], scale = 0.4, colour = G.C.WHITE, shadow = true}},
        {n=G.UIT.O, config={w=0.4,h=0.4, object = stake_sprite, hover = true, can_collide = false}},
      } or {
        {n=G.UIT.T, config={text = localize('b_eliminated'), scale = 0.4, colour = G.C.WHITE, shadow = true}},
      }},
    }},
  } or {
    {n=G.UIT.C, config={align = "cm", minw = 7.5, minh = 0.6, r = 0.1, colour = G.C.GREY}, nodes = {}},
  }
end)

function G.UIDEF.boss_leaderboard(leaderboard)
  local list = {}
  local survive_count = G.FUNCS.get_duel_threshold()
  local survived = false
  for k = 1, Balatrogether.server.max_players do
    local row = leaderboard[k]
    if row and tostring(G.STEAM.user.getSteamID()) == row.player and row.score and k <= survive_count then
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