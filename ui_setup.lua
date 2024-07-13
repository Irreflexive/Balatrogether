--- STEAMODDED HEADER
--- SECONDARY MOD FILE

----------------------------------------------
------------MOD CODE--------------------------

function G.UIDEF.run_setup(from_game_over)
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
              label = "Host",
              tab_definition_function = G.UIDEF.run_setup_host,
              chosen = false,
            }
        },
        snap_to_nav = true}),
      }},
  }})
  return t
end

function G.UIDEF.run_setup_host()
  local t = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR, minh = 3, minw = 6}, nodes={
    {n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={
        {n=G.UIT.C, config={align = "cm", minw = 2.4, id = 'host_versus_mode'}, nodes={
          create_toggle{col = true, label = 'Versus', label_scale = 0.5, w = 0, scale = 0.7, ref_table = G, ref_value = 'host_versus_mode', func = 'false_ret'}
        }},
      }
    },
    {n=G.UIT.R, config={align = "cm", minh = 0.5}, nodes={}},
    {n=G.UIT.R, config={align = "cm", padding = 0.05, minh = 0.9}, nodes={
        {n=G.UIT.C, config={align = "cm", minw = 4, minh = 0.8, padding = 0.2, r = 0.1, hover = true, colour = G.C.GREEN, button = "start_server", shadow = true}, nodes={
          {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
            {n=G.UIT.T, config={text = 'HOST', scale = 0.8, colour = G.C.UI.TEXT_LIGHT, func = 'set_button_pip', focus_args = {button = 'x',set_button_pip = true}}}
          }}
        }}
      }
    }}
  }
  return t
end

----------------------------------------------
------------MOD CODE END----------------------