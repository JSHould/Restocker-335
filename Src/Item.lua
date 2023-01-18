--local _TOCNAME, _ADDONPRIVATE = ... ---@type RestockerAddon
--local RS = RS_ADDON ---@type RestockerAddon

---@class RsItemModule
local itemModule = RsModule.itemModule

---@class RsItem
---@field id number
---@field englishName string Name as it appears in English
---@field localizedName string Name in current client language

local itemClass = {}
itemClass.__index = itemClass

---@param id number
---@param englishName string
---@return RsItem
function itemModule:Create(id, englishName)
  local fields = --[[---@type RsItem]] {}
  fields.id = id
  fields.englishName = englishName

  setmetatable(fields, itemClass)

  return fields
end

---@param gii GIICacheItem
---@return RsItem
function itemModule:FromCachedItem(gii)
  local fields = --[[---@type RsItem]] {}
  fields.id = gii.itemId
  fields.englishName = gii.itemName

  setmetatable(fields, itemClass)

  return fields
end

---@class RsContainerItemInfo
---@field bag number Bag number where the item is found
---@field slot number Slot number in the bag
---@field icon string
---@field count number
---@field itemId number
---@field locked boolean
---@field link string
---@field name string Extracted from item link, localized name

---@return RsContainerItemInfo
function itemModule:GetContainerItemInfo(bag, slot)
  local icon, slotCount, slotLocked, _, _, _, slotItemLink, _, _, slotItemId = C_Container.GetContainerItemInfo(bag, slot)
  local itemName = slotItemLink and string.match(slotItemLink, "%[(.*)%]")

  local i = --[[---@type RsContainerItemInfo]] {}
  i.bag = bag
  i.slot = slot
  i.icon = icon
  i.count = slotCount
  i.locked = slotLocked
  i.link = slotItemLink
  i.itemId = slotItemId
  i.name = --[[---@type string]] itemName
  return i
end

---Compare whether a is less than b
---For use in table.sort(table, itemModule.CompareByStacksizeAscending) to sort by stack size
function itemModule.CompareByStacksizeAscending(a, b)
  return a.count < b.count
end
