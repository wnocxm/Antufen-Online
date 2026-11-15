NEW_FORM_SKILLTREE= { }
NEW_FORM_SKILLTREE.Main = function( m )
  while true do
      m.DoEvt = nil
      m.arg = nil
      m.result = nil
      m:WaitEvt()
      if m.DoEvt~=nil then
          m:DoEvt()
      end
    end
end
NEW_FORM_SKILLTREE.C50418_OnLoad = function( m )
m.menushow = false
m.id = 0
end
local QueryUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_OK)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local HideMenu = function(m, mode)
	local reverse = false
	if mode == true then
		reverse = false
	else
		reverse = true
	end
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_410, mode)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_411, mode)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_412, mode)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_401, mode)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_414, mode)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_430, reverse)
end

local Click = function(m, id, index)
	if m.menushow == false then
		m.menushow = true
		UI_Engine.MoveWindow(m.formIndex, -126, 0)
		HideMenu(m, true)
	end
	m:OnClick(index)
end

local ClickGift = function(m, index)
	m:OnClick(index)
	local img, str, info, sn = m:GetItemInfo()
	m.info = NewItemInfo(m, img, str, info, sn)
	m.info:WaitUserInput(m)
	DelItemInfo(m.info)
end
local DoMenu = function(m, index)
	local type = m:GetMenuType(index)
	if type == SkillTree.MENU_UPSKILLLEVEL then
		m:SendModifySkillInfo()
	elseif type == SkillTree.MENU_SETUPSHORTCUTKEY then
		if true == m:CanShortCut() then
		m.userDragItem = m:GetShortCutSelectItem()
		m.setShortcut = NewSetShortcut(m, m.userDragItem)
		m.setShortcut:WaitUserInput(m)
		DelSetShortcut(m.setShortcut)
		end
	elseif type == SkillTree.MENU_INFO then
		local img, str, info, sn = m:GetItemInfo()
		m.info = NewItemInfo(m, img, str, info, sn)
		m.info:WaitUserInput(m)
		DelItemInfo(m.info)
	end
end
NEW_FORM_SKILLTREE.C50417_OnClick = function( m )
ClickGift(m, 1)
end
NEW_FORM_SKILLTREE.C50415_OnClick = function( m )
ClickGift(m, 0)
end
NEW_FORM_SKILLTREE.C50414_OnClick = function( m )
UI_Engine.MoveWindow(m.formIndex, 126, 0)
HideMenu(m, false)
m.menushow = false
end
NEW_FORM_SKILLTREE.C50413_OnClick = function( m )
m:InputFinished()
DelSkillTree(m)
end
NEW_FORM_SKILLTREE.C50412_OnClick = function( m )
DoMenu(m,2)
end
NEW_FORM_SKILLTREE.C50411_OnClick = function( m )
DoMenu(m,1)
end
NEW_FORM_SKILLTREE.C50410_OnClick = function( m )
DoMenu(m,0)
end
NEW_FORM_SKILLTREE.C50430_OnClick = function( m )
local str = m:ClearSkillAffirm()
if MsgBox.ECODE_YES == QueryUser(m, str ) then
	m:ClearSkillForIphone()
end
end
NEW_FORM_SKILLTREE.C50407_OnClick = function( m )
Click(m, UI2_COMPOSIT_407, 5)
end
NEW_FORM_SKILLTREE.C50407_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(5)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_SKILLTREE.C50406_OnClick = function( m )
Click(m, UI2_COMPOSIT_406, 4)
end
NEW_FORM_SKILLTREE.C50406_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(4)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_SKILLTREE.C50405_OnClick = function( m )
Click(m, UI2_COMPOSIT_405, 3)
end
NEW_FORM_SKILLTREE.C50405_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(3)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_SKILLTREE.C50404_OnClick = function( m )
Click(m, UI2_COMPOSIT_404, 2)
end
NEW_FORM_SKILLTREE.C50404_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(2)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_SKILLTREE.C50403_OnClick = function( m )
Click(m, UI2_COMPOSIT_403, 1)
end
NEW_FORM_SKILLTREE.C50403_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(1)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_SKILLTREE.C50402_OnClick = function( m )
Click(m, UI2_COMPOSIT_402, 0)
end
NEW_FORM_SKILLTREE.C50402_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(0)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_SKILLTREE.C50396_OnClick = function( m )
m:OnClickTab(0)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_402)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_415)
end
NEW_FORM_SKILLTREE.C50397_OnClick = function( m )
m:OnClickTab(1)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_402)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_415)
end
NEW_FORM_SKILLTREE.C50398_OnClick = function( m )
m:OnClickTab(2)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_402)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_415)
end
NEW_FORM_SKILLTREE.C50399_OnClick = function( m )
m:OnClickTab(3)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_402)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_415)
end
NEW_FORM_SKILLTREE.C50400_OnClick = function( m )
m:OnClickTab(4)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_402)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_415)
end
NEW_FORM_SKILLTREE.C50872_OnClick = function( m )
m.liveskill = NewLiveSkill(m)
local tabname,tabnum = m:GetTabName()
m.liveskill:SetTabName(tabname,tabnum)
m.liveskill:WaitUserInput(m)
local nResult = m.liveskill :GetResult()
if nResult < 0 then
	DelLiveSkill(m.liveskill)
	m:InputFinished()
	DelSkillTree(m)
else
	DelLiveSkill(m.liveskill)
	m:OnClickTab(nResult)
	UI_Engine.SetState(m.formIndex,UI2_COMPOSIT_872,0)
	UI_Engine.SetState(m.formIndex,UI2_COMPOSIT_396+nResult,1)
	UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_402)
	UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_415)
end

end
NEW_FORM_SKILLTREE.C50394_OnLoad = function( m )
HideMenu(m, false)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_402)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_415)
UI_Engine.SetLevel(m.formIndex, 2)
local tx, ty, bx, by = UI_Engine.GetClientRect(m.formIndex, UI2_COMPOSIT_764)
UI_Engine.SetContainerRect(m.formIndex, UI2_COMPOSIT_402, tx, ty, bx, by)
UI_Engine.SetEnableMove(m.formIndex, UI2_COMPOSIT_402, false)
end
NEW_FORM_SKILLTREE.C50394_OnDraw = function( m )
local point = m:OnDrawSkillPoint()
UI_Engine.SetText(m.formIndex,UI2_COMPOSIT_429,point,0)
end
