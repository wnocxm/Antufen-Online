NEW_FORM_PLAYER= { }
NEW_FORM_PLAYER.Main = function( m )
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
NEW_FORM_PLAYER.C50103_OnLoad = function( m )
m.modify = false
m.age = ""
m.country = ""
m.tel = ""
m.mail = ""
m.sigh = ""
m.lookMode = 0
m.draw = false
m.input = false
m.mode = true
m.moved = false
end
local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_CANCEL)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local UserConfirm = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_OK)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local DrawEquip = function(m)
	local img, nSN = m:DrawEquipImage(0)
	UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_93, img, 0, 0, false, nSN)
	img, nSN = m:DrawEquipImage(1)
	UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_96, img, 0, 0, false, nSN)
	img, nSN = m:DrawEquipImage(2)
	UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_95, img, 0, 0, false, nSN)
	img, nSN = m:DrawEquipImage(3)
	UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_94, img, 0, 0, false, nSN)
	img, nSN = m:DrawEquipImage(4)
	UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_98, img, 0, 0, false, nSN)
	img, nSN = m:DrawEquipImage(5)
	UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_97, img, 0, 0, false, nSN)
	img, nSN = m:DrawEquipImage(6)
	UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_100, img, 0, 0, false, nSN)
	img, nSN = m:DrawEquipImage(7)
	UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_99, img, 0, 0, false, nSN)
end

local HideMenu = function(m, mode)
	for i = 0, 6 do
		local id = UI2_COMPOSIT_105 + i
		UI_Engine.SetVisible(m.formIndex, id, mode)
	end
end

local DoMenu = function(m, index)
	local type = m:GetMenuType(index)
	if nil == type then
		return
	end
	UI_Engine.SetStateNull(m.formIndex)
	--HideMenu(m, false)
	if type == PLAYER.MENU_REPLACE then
		local curSel = m:ChangeEquip()
		if nil ~= curSel then
			m.equipPack = NewSelectBag(m, 0, 1, curSel, -1)
			DBGPRINTF("Equip Mode")
			if nil == m.equipPack then
				return
			end
			DBGPRINTF("MODE 1")
			m.equipPack:SetEquipMode(true)
			DBGPRINTF("MODE 2")
			m.equipPack:WaitUserInput(m)
			DelSelectBag(m.equipPack)
		end
	elseif type == PLAYER.MENU_FULLINFO then
		local name, ptr = m:GetInfoPtr()
		m.info = NewInfo(m, name, ptr)
	elseif type == PLAYER.MENU_TAKEOFF then
		m:TakeOff_L()
	end
end

local GetCurImgID = function(m) 
	if m.human == 1 and m.male == 1 then
		return 0
	elseif m.human == 1 and m.male == 0 then
		return 1
	elseif m.human == 0 and m.male == 1 then
		return 2
	elseif m.human == 0 and m.male == 0 then
		return 3
	end
end

local SetHeadImg = function(m)
	local imgID = GetCurImgID(m)
	m.headImg = NewHeadImg(m, imgID)
	if m.human == 1 and m.male == 1 then
		m.headImg.ret = m.headImg:LoadHeadImg(m, 0)
	elseif m.human == 1 and m.male == 0 then
		m.headImg.ret = m.headImg:LoadHeadImg(m, 1)
	elseif m.human == 0 and m.male == 1 then
		m.headImg.ret = m.headImg:LoadHeadImg(m, 2)
	else
		m.headImg.ret = m.headImg:LoadHeadImg(m, 3)
	end
	m.headImg:WaitUserInput(m)
	m.subImg = m.headImg:GetResult()
	local idx = m.headImg:GetImgIndex()
	DelHeadImg(m.headImg)
	local ptr = m:GetHeadImg(m.subImg)
	UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_122, ptr)
	m:SetCmntPortrait(idx)
end

local UpdateText = function(m, id, offset)
	local str = m:GetInfoString( m.offset + offset )
	if str == nil then
		str = ""
	end
	UI_Engine.SetText(m.formIndex, id, str)
end
NEW_FORM_PLAYER.C50100_OnClick = function( m )
local str = m:OnClickEquip(6)
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_92, str, 0)
end
NEW_FORM_PLAYER.C50099_OnClick = function( m )
local str = m:OnClickEquip(7)
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_92, str, 0)
end
NEW_FORM_PLAYER.C50098_OnClick = function( m )
local str = m:OnClickEquip(4)
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_92, str, 0)
end
NEW_FORM_PLAYER.C50097_OnClick = function( m )
local str = m:OnClickEquip(5)
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_92, str, 0)
end
NEW_FORM_PLAYER.C50096_OnClick = function( m )
local str = m:OnClickEquip(1)
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_92, str, 0)
end
NEW_FORM_PLAYER.C50095_OnClick = function( m )
local str = m:OnClickEquip(2)
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_92, str, 0)
end
NEW_FORM_PLAYER.C50094_OnClick = function( m )
local str = m:OnClickEquip(3)
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_92, str, 0)
end
NEW_FORM_PLAYER.C50093_OnClick = function( m )
local str = m:OnClickEquip(0)
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_92, str, 0)
end
NEW_FORM_PLAYER.C50104_OnClick = function( m )
DelPlayerInfo(m)
end
NEW_FORM_PLAYER.C50091_OnClick = function( m )
if false == m:GetCurType() then
	local ptr = m:GetPointer()
	NewTitle(m, ptr)
end
end
NEW_FORM_PLAYER.C50112_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_112,0 )
end
NEW_FORM_PLAYER.C50113_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_113,1 )
end
NEW_FORM_PLAYER.C50114_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_114, 2)
end
NEW_FORM_PLAYER.C50115_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_115, 3)
end
NEW_FORM_PLAYER.C50116_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_116, 4)
end
NEW_FORM_PLAYER.C50117_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_117, 5)
end
NEW_FORM_PLAYER.C50118_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_118, 6)
end
NEW_FORM_PLAYER.C50119_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_119, 7)
end
NEW_FORM_PLAYER.C50120_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_120, 8)
end
NEW_FORM_PLAYER.C50925_OnClick = function( m )
if true == m:PotentialState() then
	m:OnClickPotential()
else
	if MsgBox.ECODE_YES == QueryUser(m, m:PotentialHelpString()) then
		m:OnClickPotential()
	end
end
end
NEW_FORM_PLAYER.C50122_OnClick = function( m )
if false == m:GetCurType() then
	SetHeadImg(m)
end
end
NEW_FORM_PLAYER.C50084_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 0)
m:ChangeTab(0)
m.draw = false
end
NEW_FORM_PLAYER.C50085_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 1)
m:ChangeTab(1)
m.draw = false
local str = m:EquipInitString()
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_92, str, 0)
end
NEW_FORM_PLAYER.C50913_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 4)
m:ChangeTab(4)
end
NEW_FORM_PLAYER.C50087_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 3)
m:ChangeTab(3)
m.draw = false
m:SendAchievementList()
end
NEW_FORM_PLAYER.C50086_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 2)
m:ChangeTab(2)
m.draw = true
end
NEW_FORM_PLAYER.C50912_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 2)
m:ChangeTab(2)
m.draw = true
end
NEW_FORM_PLAYER.C50110_OnClick = function( m )
m:GetMenuType(100)
end
NEW_FORM_PLAYER.C50108_OnClick = function( m )
DoMenu(m, 2)
end
NEW_FORM_PLAYER.C50107_OnClick = function( m )
DoMenu(m, 1)
end
NEW_FORM_PLAYER.C50106_OnClick = function( m )
DoMenu(m, 0)
end
NEW_FORM_PLAYER.C50083_OnLoad = function( m )
m.mode = m:GetOpenMode()
HideMenu(m, false)
UI_Engine.SetLevel(m.formIndex, 2)

if m.mode == true then
	m.male, m.human = m:GetHeadInfo(m)
	local curTitle = m:GetCurTitle()
	UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_91, curTitle)
	local name, id = m:GetNickName()
	UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_89,name)
	UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_90,id)
end

end
NEW_FORM_PLAYER.C50083_OnDraw = function( m )
if false == m:GetCurType() then
	DrawEquip(m)
end
end
