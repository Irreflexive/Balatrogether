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
    for _,allowedArea in ipairs(allowedAreas) do
      if allowedArea and area == allowedArea then
        allowed = true
        break
      end
    end
    if not allowed then return nil end
  end
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