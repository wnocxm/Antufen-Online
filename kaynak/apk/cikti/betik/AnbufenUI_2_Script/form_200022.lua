NEW_FORM_UNION_MAIN= { }
NEW_FORM_UNION_MAIN.Main = function( m )
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
NEW_FORM_UNION_MAIN.C50616_OnLoad = function( m )
m.tab = 0
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
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_OK)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local UpdateText = function(m, offset, ctlID)    -- 控件更新中调用此接口
	offset = m.offset + offset
	local name, job, level, online = m:GetMemberInfo(offset)
	UI_Engine.SetText(m.formIndex, ctlID, name, 0)
	UI_Engine.SetText(m.formIndex, ctlID, job, 1)
	UI_Engine.SetText(m.formIndex, ctlID, level, 2)
	UI_Engine.SetText(m.formIndex, ctlID, online, 3)
end

local SetCountrybute = function(m, nID, offset)
	local name, duty, bute = m:GetMemberCountrybute(offset + m.offset)
	UI_Engine.SetText(m.formIndex, nID, name, 0)
	UI_Engine.SetText(m.formIndex, nID, duty, 1)
	UI_Engine.SetText(m.formIndex, nID, bute, 2)
end

local UpdateApply = function(m, offset, nID)
	local name, job, level = m:GetApplyInfo( offset + m.offset )
	if nil ~= name then
		UI_Engine.SetText(m.formIndex, nID, name, 0)
		UI_Engine.SetText(m.formIndex, nID, job, 1)
		UI_Engine.SetText(m.formIndex, nID, level, 2)
	else
		UI_Engine.SetText(m.formIndex, nID, "", 0)
		UI_Engine.SetText(m.formIndex, nID, "", 1)
		UI_Engine.SetText(m.formIndex, nID, "", 2)
	end
end

local HideMenu = function(m, mode)
	for i = 0, 10 do
		local id = UI2_COMPOSIT_604 + i
		UI_Engine.SetVisible(m.formIndex, id, mode)
	end
end

local ClickList = function(m)
	if false == m:SetMoved() then
		HideMenu(m, true)
		UI_Engine.MoveWindow(m.formIndex, -126, 0)
		m:GetMoved(true)
	end
	local ret = m:GetUserSel(m.userSelectItem)
end

local Donate = function(m)
	local ptrPack, ptr2 = m:GetFuncFilter()
	m.Pack = NewSelectBag(m, ptrPack, ptr2)
	if nil == m.Pack then
		WarnUser(m, STR_NO_DONATE_ITEM)
		return
	else
		m.Pack:WaitUserInput(m)
		local item = m.Pack:GetSelectItem()
		local nSn,nNum= m.Pack:GetSelectSimpleItem()
		local code = m.Pack:GetExitCode()
		if code == 0 then 
			DelSelectBag(m.Pack)
			return
		end
		if item ~= nil then
			local max = m:GetSelNum( item )
			m.num = NewNumSel( m, STR_COMBINE_NUMBER,max, 1, max )
			m.num:WaitUserInput(m)
			local num = m.num:GetResult()
			DelNumSel(m.num)
			m:Donate(item, num)
			DelSelectBag(m.Pack)
			return
		else
			if nSn==0 then
				DBGPRINTF("locate SN == 0")
				DelSelectBag(m.Pack)
			else
				local max = m:GetSelNum( nSn, nNum )
				m.num = NewNumSel( m, STR_COMBINE_NUMBER,max, 1, max )
				m.num:WaitUserInput(m)
				local num = m.num:GetResult()
				DelNumSel(m.num)
				m:Donate(nSn, num)
				DelSelectBag(m.Pack)
			end
		end
	end
end
local DoMenu = function(m, index)
	m:DoMenu(index)
	local ret = m:GetMenuID()
	if ret == UNIONMAIN.MENU_MEMBER_ITEM_QUIT_UNION then
		local str = m:GetLeftString()
		if MsgBox.ECODE_YES == QueryUser(m, str) then
			m:LeaveUnion()
		end
	elseif ret == UNIONMAIN.MENU_ITEM_BUILDING_CONTRIBUTE then
		m.input = NewInputBox(m, STR_CONTRIBUTE_MONEY, 0, "1", 999999)
		m.input:WaitUserInput(m)
		local num,run = m.input:GetInput()
		DelInputBox(m.input)
		if run == 1 then
			m:SendBuildMessage(num)
		end
	elseif ret == UNIONMAIN.MENU_ITEM_MEMBER_QUIT_UNION then
		local str = m:GetLeftString()
		if MsgBox.ECODE_YES == QueryUser(m, str) then
			m:LeaveUnion()
			m:InputFinished()
		end
	elseif ret == UNIONMAIN.MENU_ITEM_MEMBER_TRANSFOR_CHAIRMAN then
		if MsgBox.ECODE_YES == QueryUser(m, STR_TRANSFOR_CHAIRMAN_NOTICE) then
			m:SetChairman()
		end
	end
end

local UpdateSkill = function(m, id, offset)
	local img, level = m:GetSkillInfo(m.offset + offset)
	if img ~= nil then
		UI_Engine.SetSurfaceImg( m.formIndex, id, img )
		UI_Engine.SetText(m.formIndex, id, level, 1)
	end
end

local ClickSkill = function(m)
	local img, str, vect, sn = m:OnClickSkill(m.userSelectItem)
	m.itemInfo = NewItemInfo(m, img, str, vect, sn)
	m.itemInfo:WaitUserInput(m)
	local ret = m.itemInfo:GetResult()
	DelItemInfo(m.itemInfo)
	
	if ret == 1 then
		if true == m:CanShortCut() then
			m.userDragItem = m:GetShortCutSelectItem()
			m.setShortcut = NewSetShortcut(m, m.userDragItem)
			m.setShortcut:WaitUserInput(m)
			DelSetShortcut(m.setShortcut)
		end
	end

	if ret == 2 then
		local str = m:IsCanSkillUp(m.userSelectItem)
		if 0 == str then
			m:UpSkill(m.userSelectItem)
		else
			WarnUser(m, str)
		end
	end
end

local GetInput = function(m)		-- 创建输入框
	local str = m:GetNotice()
	m.InputBox = OpenInputBox(m,str,70)
	m.InputBox :WaitUserInput(m)
	local result = m.InputBox :GetResult()
	return result
end
NEW_FORM_UNION_MAIN.C50615_OnClick = function( m )
if m:GetTab() == 6 then
	UI_Engine.SetFormTab(m.formIndex, 1)
	m:SetTab(1)
	m.tab = 1
	m:GetMoved(false)
	UI_Engine.MoveWindow(m.formIndex, 126, 0)
elseif m:GetTab() == 7 then
	UI_Engine.SetFormTab(m.formIndex, 1)
	m:SetTab(1)
	m.tab = 1
	m:GetMoved(false)
	UI_Engine.MoveWindow(m.formIndex, 126, 0)
else
	m:SaveShortCutData()
	m:InputFinished()
end
end
NEW_FORM_UNION_MAIN.C50626_OnClick = function( m )
m:OnRefuse()
end
NEW_FORM_UNION_MAIN.C50625_OnClick = function( m )
m:luaLog()
end
NEW_FORM_UNION_MAIN.C50765_OnClick = function( m )
Donate(m)
end
NEW_FORM_UNION_MAIN.C50624_OnClick = function( m )
local notice = GetInput(m)
m:ModifyNotice(notice)
end
NEW_FORM_UNION_MAIN.C50618_OnClick = function( m )
ClickSkill(m)
end
NEW_FORM_UNION_MAIN.C50618_OnUpdate = function( m )
UpdateSkill(m, UI2_COMPOSIT_618, 0)
end
NEW_FORM_UNION_MAIN.C50619_OnClick = function( m )
ClickSkill(m)
end
NEW_FORM_UNION_MAIN.C50619_OnUpdate = function( m )
UpdateSkill(m, UI2_COMPOSIT_619, 1)
end
NEW_FORM_UNION_MAIN.C50620_OnClick = function( m )
ClickSkill(m)
end
NEW_FORM_UNION_MAIN.C50620_OnUpdate = function( m )
UpdateSkill(m, UI2_COMPOSIT_620, 2)
end
NEW_FORM_UNION_MAIN.C50621_OnClick = function( m )
ClickSkill(m)
end
NEW_FORM_UNION_MAIN.C50621_OnUpdate = function( m )
UpdateSkill(m, UI2_COMPOSIT_621, 3)
end
NEW_FORM_UNION_MAIN.C50622_OnClick = function( m )
ClickSkill(m)
end
NEW_FORM_UNION_MAIN.C50622_OnUpdate = function( m )
UpdateSkill(m, UI2_COMPOSIT_622, 4)
end
NEW_FORM_UNION_MAIN.C50614_OnClick = function( m )
if true == m:SetMoved() then
	m:GetMoved(false)
	HideMenu(m, false)
	UI_Engine.MoveWindow(m.formIndex, 126, 0)
end
end
NEW_FORM_UNION_MAIN.C50613_OnClick = function( m )
DoMenu(m, 6)
end
NEW_FORM_UNION_MAIN.C50612_OnClick = function( m )
DoMenu(m,5 )
end
NEW_FORM_UNION_MAIN.C50611_OnClick = function( m )
DoMenu(m, 4)
end
NEW_FORM_UNION_MAIN.C50610_OnClick = function( m )
DoMenu(m, 3)
end
NEW_FORM_UNION_MAIN.C50609_OnClick = function( m )
DoMenu(m,2 )
end
NEW_FORM_UNION_MAIN.C50608_OnClick = function( m )
DoMenu(m, 1)
end
NEW_FORM_UNION_MAIN.C50607_OnClick = function( m )
DoMenu(m, 0)
end
NEW_FORM_UNION_MAIN.C50606_OnClick = function( m )
m:ClickArrow(true)
end
NEW_FORM_UNION_MAIN.C50605_OnClick = function( m )
m:ClickArrow(false)
end
NEW_FORM_UNION_MAIN.C50597_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50597_OnUpdate = function( m )
UpdateApply(m, 0, UI2_COMPOSIT_597)
end
NEW_FORM_UNION_MAIN.C50598_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50598_OnUpdate = function( m )
UpdateApply(m, 1, UI2_COMPOSIT_598)
end
NEW_FORM_UNION_MAIN.C50599_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50599_OnUpdate = function( m )
UpdateApply(m, 2, UI2_COMPOSIT_599)
end
NEW_FORM_UNION_MAIN.C50600_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50600_OnUpdate = function( m )
UpdateApply(m, 3, UI2_COMPOSIT_600)
end
NEW_FORM_UNION_MAIN.C50601_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50601_OnUpdate = function( m )
UpdateApply(m, 4, UI2_COMPOSIT_601)
end
NEW_FORM_UNION_MAIN.C50602_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50602_OnUpdate = function( m )
UpdateApply(m, 5, UI2_COMPOSIT_602)
end
NEW_FORM_UNION_MAIN.C50603_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50603_OnUpdate = function( m )
UpdateApply(m, 6, UI2_COMPOSIT_603)
end
NEW_FORM_UNION_MAIN.C50588_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50588_OnUpdate = function( m )
SetCountrybute(m, UI2_COMPOSIT_588, 0)
end
NEW_FORM_UNION_MAIN.C50589_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50589_OnUpdate = function( m )
SetCountrybute(m, UI2_COMPOSIT_589, 1)
end
NEW_FORM_UNION_MAIN.C50590_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50590_OnUpdate = function( m )
SetCountrybute(m, UI2_COMPOSIT_590, 2)
end
NEW_FORM_UNION_MAIN.C50591_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50591_OnUpdate = function( m )
SetCountrybute(m, UI2_COMPOSIT_591, 3)
end
NEW_FORM_UNION_MAIN.C50592_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50592_OnUpdate = function( m )
SetCountrybute(m, UI2_COMPOSIT_592, 4)
end
NEW_FORM_UNION_MAIN.C50593_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50593_OnUpdate = function( m )
SetCountrybute(m, UI2_COMPOSIT_593, 5)
end
NEW_FORM_UNION_MAIN.C50594_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50594_OnUpdate = function( m )
SetCountrybute(m, UI2_COMPOSIT_594, 6)
end
NEW_FORM_UNION_MAIN.C50582_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50583_OnClick = function( m )
m.curBuild = 0
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50583_OnUpdate = function( m )
local name = m:GetBuildingString(0)
local lv = m:GetLevel(0)
local total = m:GetTotalBuild(0)

UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_583, name, 0)
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_583, lv, 1)
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_583, total, 2)
local str = m:GetMoney()
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_566, str, 0)
end
NEW_FORM_UNION_MAIN.C50584_OnClick = function( m )
m.curBuild = 1
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50584_OnUpdate = function( m )
local name = m:GetBuildingString(1)
local lv = m:GetLevel(1)
local total = m:GetTotalBuild(1)

UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_584, name, 0)
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_584, lv, 1)
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_584, total, 2)
end
NEW_FORM_UNION_MAIN.C50585_OnClick = function( m )
m.curBuild = 2
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50585_OnUpdate = function( m )
local name = m:GetBuildingString(2)
local lv = m:GetLevel(2)
local total = m:GetTotalBuild(2)

UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_585, name, 0)
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_585, lv, 1)
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_585, total, 2)
end
NEW_FORM_UNION_MAIN.C50586_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50574_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50574_OnUpdate = function( m )
UpdateText(m, 0, UI2_COMPOSIT_574) 
end
NEW_FORM_UNION_MAIN.C50575_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50575_OnUpdate = function( m )
UpdateText(m, 1, UI2_COMPOSIT_575) 
end
NEW_FORM_UNION_MAIN.C50576_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50576_OnUpdate = function( m )
UpdateText(m, 2, UI2_COMPOSIT_576) 
end
NEW_FORM_UNION_MAIN.C50577_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50577_OnUpdate = function( m )
UpdateText(m, 3, UI2_COMPOSIT_577) 
end
NEW_FORM_UNION_MAIN.C50578_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50578_OnUpdate = function( m )
UpdateText(m, 4, UI2_COMPOSIT_578) 
end
NEW_FORM_UNION_MAIN.C50579_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50579_OnUpdate = function( m )
UpdateText(m, 5, UI2_COMPOSIT_579) 
end
NEW_FORM_UNION_MAIN.C50580_OnClick = function( m )
ClickList(m)
end
NEW_FORM_UNION_MAIN.C50580_OnUpdate = function( m )
UpdateText(m, 6, UI2_COMPOSIT_580) 
end
NEW_FORM_UNION_MAIN.C50567_OnClick = function( m )
m:GetFormType(0)
m:SetTab(0)
m.tab = 0
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_579)
local str = m:GetMaxMember()
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_566, str, 0)
end
NEW_FORM_UNION_MAIN.C50568_OnClick = function( m )
m:GetFormType(1)
m:SetTab(1)
m.tab = 1
UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_585)
local str = m:GetMoney()
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_566, str, 0)
end
NEW_FORM_UNION_MAIN.C50569_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 2)
m:SetTab(2)
m.tab = 2
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_593)
local str = m:GetMoney()
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_566, str, 0)
end
NEW_FORM_UNION_MAIN.C50570_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 3)
m:SetTab(3)
m.tab = 3
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_566, "", 0)
end
NEW_FORM_UNION_MAIN.C50571_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 4)
m:SetTab(4)
m.tab = 4
local str = m:GetUnionName()
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_566, str, 0)
end
NEW_FORM_UNION_MAIN.C50572_OnClick = function( m )
if m:HideMenu() then
	return
else
UI_Engine.SetFormTab(m.formIndex, 5)
m:SetTab(5)
m.tab = 5
m:SetTableApply()
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_566, "", 0)
m:OnOpenList()
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_602)
end
end
NEW_FORM_UNION_MAIN.C50565_OnLoad = function( m )
HideMenu(m, false)
UI_Engine.SetLevel(m.formIndex, 3)
local str = m:GetMaxMember()
UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_566, str, 0)
end
