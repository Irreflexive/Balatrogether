function findDescendantOfElementByConfig(element, property, value) 
  if not element or not element.children then return nil end
  for k, child in pairs(element.children) do
    if child.config[property] == value or (child.definition and child.definition.config[property] == value) then
      return child.definition or child
    else
      local result = findDescendantOfElementByConfig(child, property, value)
      if result then
        return result
      end
    end
  end
  return nil
end

function findDescendantOfNodeTreeByConfig(t, property, value)
  if not t or not t.nodes then return nil end
  for k, child in pairs(t.nodes) do
    if child.config[property] == value then
      return child
    else
      local result = findDescendantOfNodeTreeByConfig(child, property, value)
      if result then 
        return result 
      end
    end
  end
  return nil
end

function createCollectionId(prefix, id)
  return (prefix and prefix .. "_" or "") .. Balatrogether.prefix .. "_" .. id
end

function getCardAreaType(area, allowedAreas)
  if allowedAreas then
    local allowed = false
    for _,allowedArea in pairs(allowedAreas) do
      if area == allowedArea then
        allowed = true
        break
      end
    end
    if not allowed then return nil end
  end
  if not area then return nil end
  if area == G.hand then return "hand" end
  if area == G.jokers then return "jokers" end
  if area == G.consumeables then return "consumeables" end
  if area == G.shop_jokers then return "shop_jokers" end
  if area == G.shop_booster then return "shop_booster" end
  if area == G.shop_vouchers then return "shop_vouchers" end
  if area == G.pack_cards then return "pack_cards" end
  return nil
end

function getCardFromMultiplayerID(area, id)
  for _,card in pairs(area.cards) do
    if card.Multiplayer_ID == id then return card end
  end
  return nil
end

function createUIListFunctions(name, get_list, page_size, element_func, config)
  local ui_list_id = Balatrogether.prefix .. '_' .. name .. '_list'
  local ui_page_id = ui_list_id .. '_page'
  local change_page_id = 'change_' .. ui_page_id

  G.UIDEF[ui_list_id] = function()
    local pages = {}
    for i = 1, math.ceil(#get_list()/page_size) do
      table.insert(pages, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#get_list()/page_size)))
    end
    if #pages == 0 then pages = {localize('k_page')..' 1/0'} end
    G.E_MANAGER:add_event(Event({func = (function()
      G.FUNCS[change_page_id]{cycle_config = {current_option = 1}}
    return true end)}))
  
    local t = {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
      {n=G.UIT.R, config={align = "cm", padding = 0.1, minh = config and config.minh or 0.7*page_size, minw = config and config.minw or 4.2}, nodes={
        {n=G.UIT.O, config={id = ui_list_id, object = Moveable()}},
      }},
      {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
        create_option_cycle({
          id = ui_page_id, 
          scale = 0.9, 
          h = 0.3, 
          w = 3.5, 
          options = pages, 
          cycle_shoulders = true, 
          opt_callback = change_page_id, 
          current_option = 1, 
          colour = G.C.RED, 
          no_pips = true, 
          focus_args = {snap_to = true}
        })
      }},
    }}
    return t
  end

  G.UIDEF[ui_page_id] = function(_page)
    local snapped = false
    local list_ui = {}
    for k = page_size*(_page or 0) + 1, page_size*((_page or 0) + 1) do
      v = get_list()[k]
      if G.CONTROLLER.focused.target and G.CONTROLLER.focused.target.config.id == ui_page_id then snapped = true end
  
      list_ui[#list_ui+1] = 
      {n=G.UIT.R, config={align = "cm"}, nodes={
        {n=G.UIT.C, config={align = 'cl', minw = 0.8}, nodes = {
          {n=G.UIT.T, config={text = k..'', scale = 0.4, colour = G.C.WHITE}},
        }},
        unpack(element_func(k, v)),
      }}
      snapped = true
    end
  
    return {n=G.UIT.R, config={align = "cm", padding = 0.1, colour = G.C.CLEAR}, nodes=list_ui}
  end

  local last_selected_page = 1
  G.FUNCS[change_page_id] = function(args)
    if not args then args = {} end
    if not args.cycle_config then args.cycle_config = {} end
    if not args.cycle_config.current_option then args.cycle_config.current_option = last_selected_page end
    last_selected_page = args.cycle_config.current_option
    if G.OVERLAY_MENU then
      local ui_list = G.OVERLAY_MENU:get_UIE_by_ID(ui_list_id)
      if ui_list then 
        if ui_list.config.object then 
          ui_list.config.object:remove() 
        end
        ui_list.config.object = UIBox{
          definition = G.UIDEF[ui_page_id](args.cycle_config.current_option-1),
          config = {offset = {x=0,y=0}, align = 'cm', parent = ui_list}
        }
      end
    end
  end

  return ui_list_id
end

function computeUnlockHash()
  local content = {}
  for k,v in pairs(G.P_CENTERS) do
    if v.unlocked and v.set ~= "Back" then
      table.insert(content, k)
    end
  end
  table.sort(content)
  return love.data.encode("string", "base64", love.data.hash("sha512", table.concat(content, ",")))
end