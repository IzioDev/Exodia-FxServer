ComponentList = {}
local random = math.random
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end


function CreateComponent(_id, ParentComponent, HTMLComponent)
  if HTMLComponent == nil then
    HTMLComponent = ParentComponent
    ParentComponent = _id
    _id = uuid()
  end
  if cssRules == nil then
    cssRules = ""
  end

  ComponentList[_id] = {
    id = _id,
    parent = ParentComponent,
    html = HTMLComponent,
    jS = "#" .. _id,
    text = '', -- value will be updated on show() and on change
    value = '',-- value will be updated on show() and on change
    isVisible = false,

    show = function()
      print(_id)

      showComponent({ComponentList[_id]}, nil)
      isVisible = true
    end,

    hide = function()
      hideComponent({ComponentList[_id]}, nil)
      isVisible = false
    end,

    setAttribute = function(attr, value)
      SetComponentAttribute(_id, attr, value)
    end,

    getAttribute = function(attr)
      return GetComponentAttribute(_id, attr)
    end,

    remove = function()
      if isVisible == true then
        hide()
      end
      ComponentList[_id] = nil
    end

  }
  return ComponentList[_id]
end



function SetComponentAttribute(componentID, attr, value) -- love kanerpss idea
  if attr == "clickCB" then
    -- may be one day
  elseif attr == "change_cb" then
    -- may be one day
  else
    SendNUIMessage({type = "SetComponentAttribute", id = componentID, attributeName = attr, attributeValue = value})
    if ComponentList[componentID].OnRender == nil then
      ComponentList[componentID].OnRender = {}
    end
    ComponentList[componentID].OnRender[#ComponentList[componentID].OnRender + 1] = function()

      SendNUIMessage({type = "SetComponentAttribute", id = componentID, attributeName = attr, attributeValue = value})
    end
  end
  ComponentList[componentID][attr] = value
end

function GetComponentAttribute(id, attr)
  return ComponentList[id].attr
end

function GetComponentById(id)
  if ComponentList[id] == nil then
    return false
  else
    return ComponentList[id]
  end
end

function showComponent(componentList, focus)  -- focus = {true, true} for a mouse control
  for _,v in pairs(componentList) do
    SendNUIMessage({type = "createComponent", id = v.id, html = v.html, parent = v.parent})
    if v.OnRender == nil then
      v.OnRender = {}
    else
      for __, func in pairs(v.OnRender) do
        func()
      end
    end
  end
  if focus ~= nil then
    SetNuiFocus(focus[1],focus[2])
  end
end


function hideComponent(componentList, focus)  -- focus = {true, true} for a mouse control
  for i,v in pairs(componentList) do
    SendNUIMessage({type= "deleteComponent", id = v.id})
  end
  if focus ~= nil then
    SetNuiFocus(focus[1],focus[2])
  end
end

RegisterNUICallback('click', function(data, cb)
  if ComponentList[data.id] == nil then
    return false
  end
  if ComponentList[data.id].clickCB ~= nil then
    ComponentList[data.id].clickCB()
  end
  cb('ok')
end)
RegisterNUICallback('change', function(data, cb)
  if ComponentList[data.id] == nil then
    cb('ok')
    return false
  end
  ComponentList[data.id].text  = data.content

  ComponentList[data.id].value  = data.value
  cb('ok')
end)
-- SetTimeout(1500, function()
--   buttonList = {}
--   for i = 1, 10 do
--     buttonList[i] = createComponent("button", "body", "this is the button:"..i, " ", "color= 'white'")
--     SetComponentAttribute(buttonList[i].id, "clickCB", function()
--       Citizen.Trace("Daaam this api is just awesome. btn id (" .. i .. ")")
--     end)
--   end
--   ShowComponent(buttonList, {true, true})
--   SetTimeout(6000, function()
--     cleanPage(buttonList, {false, false})
--   end)
-- end)
