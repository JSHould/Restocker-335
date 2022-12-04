local _TOCNAME, _ADDONPRIVATE = ... ---@type RestockerAddon
local RS = RS_ADDON ---@type RestockerAddon

---@class RsMainFrameModule
local mainFrameModule = RsModule.mainFrameModule ---@type RsMainFrameModule
local restockerModule = RsModule.restockerModule ---@type RsRestockerModule

RS.hiddenFrame = CreateFrame("Frame", nil, UIParent)
RS.hiddenFrame:Hide()

function mainFrameModule:CreateMenu()
  --[[
    FRAME
  ]]
  local settings = restockerModule.settings

  local addonFrame = CreateFrame("Frame", "RestockerMainFrame", UIParent, "BasicFrameTemplate");
  addonFrame.width = 300
  addonFrame.height = 400
  addonFrame:SetSize(addonFrame.width, addonFrame.height);
  addonFrame:SetPoint(settings.framePos.point or "RIGHT",
      UIParent, settings.framePos.relativePoint or "RIGHT",
      settings.framePos.xOfs or -5,
      settings.framePos.yOfs or 0);
  addonFrame:SetFrameStrata("FULLSCREEN");
  addonFrame:SetMovable(true)
  addonFrame:EnableMouse(true)
  addonFrame:RegisterForDrag("LeftButton")
  addonFrame:SetScript("OnDragStart", addonFrame.StartMoving)
  addonFrame:SetScript("OnDragStop", addonFrame.StopMovingOrSizing)

  --[[
    INSET
  ]]
  local listInset = CreateFrame("Frame", nil, addonFrame, "InsetFrameTemplate3");
  listInset.width = addonFrame.width - 6
  listInset.height = addonFrame.height - 76
  listInset:SetSize(listInset.width, listInset.height);
  listInset:SetPoint("TOPLEFT", addonFrame, "TOPLEFT", 2, -22);
  addonFrame.listInset = listInset

  --[[
    SCROLL FRAME
  ]]
  local scrollFrame = CreateFrame("ScrollFrame", nil, addonFrame, "UIPanelScrollFrameTemplate")
  scrollFrame.width = addonFrame.listInset.width - 4
  scrollFrame.height = addonFrame.listInset.height - 32
  scrollFrame:SetSize(scrollFrame.width - 30, scrollFrame.height);
  scrollFrame:SetPoint("TOPLEFT", listInset, "TOPLEFT", 8, -6);
  addonFrame.scrollFrame = scrollFrame

  --[[
    SCROLL CHILD
  ]]
  local scrollChild = CreateFrame("Frame", nil, ScrollFrame)
  scrollChild.width = scrollFrame:GetWidth()
  scrollChild.height = scrollFrame:GetHeight()
  scrollChild:SetWidth(scrollChild.width)
  scrollChild:SetHeight(scrollChild.height - 10)
  addonFrame.scrollChild = scrollChild

  scrollFrame:SetScrollChild(scrollChild)




  --[[
    TITLE
  ]]
  local title = addonFrame:CreateFontString(nil, "OVERLAY");
  title:SetFontObject("GameFontHighlightLarge");
  title:SetPoint("CENTER", addonFrame.TitleBg, "CENTER", 0, 0);
  title:SetText("Restocker");
  addonFrame.title = title


  --[[
    EDITBOX & ADD BUTTON GROUP
  ]]
  local addGrp = CreateFrame("Frame", nil, addonFrame);
  addGrp:SetPoint("BOTTOM", addonFrame.listInset, "BOTTOM", 0, 2);
  addGrp:SetSize(listInset.width - 5, 25);
  addonFrame.addGrp = addGrp




  -- Add button
  local addBtn = CreateFrame("Button", nil, addonFrame.addGrp, "GameMenuButtonTemplate");
  addBtn:SetPoint("BOTTOMRIGHT", addonFrame.addGrp, "BOTTOMRIGHT");
  addBtn:SetSize(60, 25);
  addBtn:SetText("Add");
  addBtn:SetNormalFontObject("GameFontNormal");
  addBtn:SetHighlightFontObject("GameFontHighlight");
  addBtn:SetScript("OnClick", function(self, button, down)
    local editBox = self:GetParent():GetParent().editBox
    local text = editBox:GetText()

    RS:addItem(text);

    editBox:SetText("")
    editBox:ClearFocus()
  end);


  -- Text field
  local editBox = CreateFrame("EditBox", nil, addonFrame.addGrp, "InputBoxTemplate");
  editBox:SetPoint("RIGHT", addBtn, "LEFT", 3);
  editBox:SetAutoFocus(false);
  editBox:SetSize(addonFrame.addGrp:GetWidth() - addBtn:GetWidth() - 5, 25);
  editBox:SetScript("OnEnterPressed", function(self)
    local text = self:GetText()
    RS:addItem(text)
    self:SetText("")
    self:ClearFocus()
  end)
  editBox:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
      local infoType, _, info2 = GetCursorInfo()
      if infoType == "item" then
        RS:addItem(info2)
        ClearCursor()
      end
    end
  end)
  editBox:SetScript("OnReceiveDrag", function(self)
    local infoType, _, info2 = GetCursorInfo()
    if infoType == "item" then
      RS:addItem(info2)
      ClearCursor()
    end
  end)
  editBox:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(RS.FormatTexture(RS.BAG_ICON) .. " Add an item")
    GameTooltip:AddLine("Drop an item from your bag, or type a numeric item ID")
    GameTooltip:Show()
  end)
  editBox:SetScript("OnLeave", function(self, motion)
    GameTooltip:Hide()
  end)

  addonFrame.editBox = editBox
  addonFrame.addBtn = addBtn

  -- END OF GROUP



  --[[
    AUTOBUY CHECKBOX
  ]]

  -- Checkbox for autobuy
  local checkbox = CreateFrame("CheckButton", nil, addonFrame, "UICheckButtonTemplate");
  checkbox:SetPoint("TOPLEFT", addonFrame.listInset, "BOTTOMLEFT", 2, -1)
  checkbox:SetSize(25, 25)
  checkbox:SetChecked(settings.autoBuy);
  checkbox:SetScript("OnClick", function(self, button, down)
    settings.autoBuy = checkbox:GetChecked()
  end);
  addonFrame.checkbox = checkbox

  -- Auto buy text
  local checkboxText = addonFrame:CreateFontString(nil, "OVERLAY");
  checkboxText:SetFontObject("GameFontHighlight");
  checkboxText:SetPoint("LEFT", checkbox, "RIGHT", 1, 1);
  checkboxText:SetText("Auto buy items");
  addonFrame.checkboxText = checkboxText
  -- // AUTOBUY


  --[[
    AUTO RESTOCK FROM BANK
  ]]
  -- Checkbox for auto restock from bank
  local checkboxBank = CreateFrame("CheckButton", nil, addonFrame, "UICheckButtonTemplate");
  checkboxBank:SetPoint("LEFT", addonFrame.checkbox, "RIGHT", 100, 0)
  checkboxBank:SetSize(25, 25)
  checkboxBank:SetChecked(settings.restockFromBank);
  checkboxBank:SetScript("OnClick", function(self, button, down)
    settings.restockFromBank = checkboxBank:GetChecked()
  end);
  addonFrame.checkboxBank = checkboxBank

  -- Auto restock from bank text
  local checkboxBankText = addonFrame:CreateFontString(nil, "OVERLAY");
  checkboxBankText:SetFontObject("GameFontHighlight");
  checkboxBankText:SetPoint("LEFT", checkboxBank, "RIGHT", 1, 1);
  checkboxBankText:SetText("Restock from bank");
  addonFrame.checkboxBank = checkboxBankText
  -- // AUTOBUY






  --[[
    PROFILES
  ]]
  local profileText = addonFrame:CreateFontString(nil, "OVERLAY")
  profileText:SetPoint("BOTTOMLEFT", addonFrame, "BOTTOMLEFT", 10, 12)
  profileText:SetFontObject("GameFontNormal")
  profileText:SetText("Profile:")

  local Restocker_ProfileDropDownMenu = CreateFrame("Frame", "Restocker_ProfileDropDownMenu", addonFrame, "UIDropDownMenuTemplate")
  Restocker_ProfileDropDownMenu:SetPoint("LEFT", profileText, "LEFT", 80, 0)
  --Restocker_ProfileDropDownMenu.displayMode = "MENU"
  UIDropDownMenu_SetWidth(Restocker_ProfileDropDownMenu, 120, 500)
  UIDropDownMenu_SetButtonWidth(Restocker_ProfileDropDownMenu, 140)
  UIDropDownMenu_SetText(Restocker_ProfileDropDownMenu, settings.currentProfile)

  Restocker_ProfileDropDownMenu.initialize = function(self, level)
    if not level then
      return
    end

    for profileName, _ in pairs(settings.profiles) do
      local info = UIDropDownMenu_CreateInfo()

      info.text = profileName
      info.arg1 = profileName
      info.func = RS.DropDownMenuSelectProfile
      info.checked = profileName == settings.currentProfile

      UIDropDownMenu_AddButton(info, 1)
    end
  end

  addonFrame.profileDropDownMenu = Restocker_ProfileDropDownMenu

  table.insert(UISpecialFrames, "RestockerMainFrame")
  addonFrame:Hide()

  RS.MainFrame = addonFrame
  return RS.MainFrame
end


-- Handle shiftclicks of items
local origChatEdit_InsertLink = ChatEdit_InsertLink;
ChatEdit_InsertLink = function(link)
  if RS.MainFrame.editBox:IsVisible() and RS.MainFrame.editBox:HasFocus() then
    return RS:addItem(link)
  end
  return origChatEdit_InsertLink(link);
end

function RS.DropDownMenuSelectProfile(self, arg1, arg2, checked)
  RS:ChangeProfile(arg1)
end

---@param text string|number
function RS:addItem(text)
  local settings = restockerModule.settings
  local currentProfile = settings.profiles[settings.currentProfile]

  if tonumber(text) then
    text = --[[---@not nil]] tonumber(text)
  end

  --local itemName, itemLink = GetItemInfo(text)
  local itemInfo = RS.GetItemInfo(text)
  if itemInfo == nil then
    RS.addItemWait[text] = true
    return
  else
    for _, item in ipairs(currentProfile) do
      if item.itemName:lower() == (--[[---@not nil]] itemInfo).itemName:lower() then
        return
      end
    end
  end

  local buyItem = --[[---@type RsBuyCommand]] {}

  buyItem.itemName = (--[[---@not nil]] itemInfo).itemName
  buyItem.itemLink = (--[[---@not nil]] itemInfo).itemLink
  buyItem.itemID = (--[[---@not nil]] itemInfo).itemId
  buyItem.amount = 1

  table.insert(settings.profiles[settings.currentProfile], buyItem)

  RS:Update()
end
