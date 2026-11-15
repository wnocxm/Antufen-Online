NEW_FORM_BAG_2= { }
NEW_FORM_BAG_2.Main = function( m )
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
NEW_FORM_BAG_2.C50046_OnLoad = function( m )
m.describe = true
m.pageNum = 0
DBGPRINTF("loading... m.pageNum = "..m.pageNum)
m.mode = 0
m.money = 0
m.szMoney = ""
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

local DrawCap = function(m)
	local cap = m:DrawCap()
	UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_44, cap)
end

local SetDescribe = function(m, nID)
	if false == m.describe then
		local null = UI_Engine.GetNullString()
		UI_Engine.SetSlipperText(m.formIndex, nID, null)
	else
		local text = m:GetDescribe()
		UI_Engine.SetSlipperText(m.formIndex, nID, text)
	end
end

local FeedHorse = function(m)
	m.horse = NewSelectBag(m, 0,1, 9)
	if nil == m.horse then
		m:OnOpenFailed()
		WarnUser(m, R_STRING_NO_HORSE)
		return nil
	end
	m.horse:WaitUserInput(m)
	local ret = m.horse:GetSelectItem()
	DelPackage(m.horse)
	return ret
end

local InitMenu = function(m, b, load)
	DBGPRINTF("=================Move window")
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_32, false)
	--UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_48, false)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_33, false)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_34, false)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_29, false)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_523, false)
	for i = 0, 6 do
		local id = UI2_COMPOSIT_35 + i
		UI_Engine.SetVisible(m.formIndex, id, false)
	end
	if b == true then   -- 右移
		if load == false then
			UI_Engine.MoveWindow(m.formIndex, 126, 0)
		end
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_523, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_29, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_44, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_45, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_47, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_43, true)
	else	-- 左移
		if load == false then
			UI_Engine.MoveWindow(m.formIndex, -126, 0)
		end
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_523, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_29, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_44, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_45, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_47, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_43, false)
	end
end

local MoveWindow = function(m,b)
	if b == true then	--左移
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_3, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_4, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_5, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_6, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_0, false)
		UI_Engine.MoveWindow(m.formIndex, -126, 0)
	end
end

local ChangePage = function(m)
	for i = 0, 10 do
		local id = UI2_COMPOSIT_32 + i
		UI_Engine.SetVisible(m.formIndex, id, false)
	end
	if m.moved == false then
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_627, false)
	else
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_627, true)
	end
end

local HideMenu = function(m, mode)
--[[
	local reverse = false
	if mode == true then
		reverse = false
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_627, false)
	else
		reverse = true
	end
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_523, mode)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_29, mode)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_32, mode)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_33, mode)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_34, mode)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_48, mode)
	for i = 0, 6 do
		local id = UI2_COMPOSIT_35 + i
		UI_Engine.SetVisible(m.formIndex, id, mode)
	end
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_43, reverse)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_44, reverse)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_45, reverse)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_47, reverse)
	--]]
end

local ChangePage = function(m)
	for i = 0, 9 do
		local id = UI2_COMPOSIT_32 + i
		UI_Engine.SetVisible(m.formIndex, id, false)
	end
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_48, false)
	if m.moved == false then
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_627, false)
	else
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_627, true)
	end
end

local ClickGrid = function(m, i)
	m.describe = true
	UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_8)
	m.userSelectItem = m:GetPage() * 20 + i
	m:SelectItem(m.userSelectItem)
	HideMenu(m, true)
	m:OnClickGrid()
	SetDescribe(m, UI2_COMPOSIT_523)
	--InitMenu(m, false, false)
	--MoveWindow(m, true)
end

local UpdateItem = function ( m, control )
	local img, nSN  = m:OnUpdateItem( m.ItemCount )
	local lock = m:GetLockImg()
	UI_Engine.SetClientEmpty(m.formIndex, control)
	local nNewItemIconRectID = UI3_COMPOSIT_914 - m.ItemCount
	UI_Engine.SetClientEmpty(m.formIndex, nNewItemIconRectID)
	if img ~= nil then
		UI_Engine.SetVisible( m.formIndex, control, true )
		UI_Engine.SetVisible( m.formIndex, nNewItemIconRectID, true )
		if 0 ~= nSN then
			if m:IsLocked(m.ItemCount) then
				UI_Engine.SetSurfaceImg( m.formIndex, control, img, 0, 0, false,  nSN, true)
			else
				UI_Engine.SetSurfaceImg( m.formIndex, control, img, 0, 0, false,  nSN)
			end
			local newimg = m:IsNewItem(m.ItemCount)
			
			UI_Engine.SetSurfaceImg( m.formIndex, nNewItemIconRectID, newimg, 0, 0, false, 0)
		else
			UI_Engine.SetClientEmpty(m.formIndex, control)
			UI_Engine.SetClientEmpty(m.formIndex, nNewItemIconRectID)
		end
	else
		UI_Engine.SetVisible( m.formIndex, control, false )
		UI_Engine.SetVisible( m.formIndex, nNewItemIconRectID, false )
	end
	m.ItemCount = m.ItemCount + 1
end

local RefreshBag = function ( m )
	m:UpdateItemList()
	m.ItemCount = 0
	for i = 0, 19 do
		local id = UI2_COMPOSIT_7 + i
		UpdateItem( m, id)
	end
end

local SetPageMode = function(m)
	if m:GetPage() == 0 then
		DBGPRINTF("left false")
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_27, false)
	else
		DBGPRINTF("left true")
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_27, true)
	end

	if m.pageNum > m:GetPage() then
		DBGPRINTF("r true")
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_28, true)
	else
		DBGPRINTF("r false")
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_28, false)
	end
end

local DrawIcon = function(m, nID, nIndex)
	local img,nSN  = m:OnUpdateItem( nIndex )
	local lock = m:GetLockImg()
	local nNewItemIconRectID = UI3_COMPOSIT_914 - nIndex
	if img ~= nil then
		UI_Engine.SetVisible( m.formIndex, nNewItemIconRectID, true )
		UI_Engine.SetVisible( m.formIndex, nID, true )
		if m:IsLocked(nIndex) then
			UI_Engine.SetSurfaceImg( m.formIndex, nID, img, 0, 0, false,  nSN, true)
		else
			UI_Engine.SetSurfaceImg( m.formIndex, nID, img, 0, 0, false,  nSN)
		end
		local newimg = m:IsNewItem(nIndex)
		UI_Engine.SetSurfaceImg( m.formIndex, nNewItemIconRectID, newimg, 0, 0, false, 0)
	else
		UI_Engine.SetVisible( m.formIndex, nNewItemIconRectID , false )
		UI_Engine.SetVisible( m.formIndex, nID, false )
	end
end

local ReClick = function(m)
	m:OnClickGrid()
end

local SetMoney = function(m)
	m.money, m.szMoney = m:GetGolden()
	UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_47, m.szMoney)
end

local OnDestroy = function(m)
	local num = m:GetSelNum()
	if 0 == num then
		DBGPRINTF("num = 0")
		return false
	end

	if 1 == num then
		DBGPRINTF("num = 1")
		m:DeleteItem(1)
		RefreshBag(m)
		return true
	else
		m.NumSel = NewNumSel(m, STR_SELECTNUMBER_TYPE_DESTROY, num, 1, num)
		m.NumSel:WaitUserInput(m)
		local ret = m.NumSel:GetResult()
		DelNumSel(m.NumSel)
		if -1 == ret then
			return false
		end
		m:DeleteItem(ret)
		RefreshBag(m)
		return true
	end
	RefreshBag(m)
end

local SaveStore = function(m)
	local num = m:GetSelNum()
	if num == 0 then
		return false
	elseif 1 == num then
		m:luaSaveToStore(1)
	else
		m.NumSel = NewNumSel(m, STR_COMBINE_NUMBER, num, 1, num)
		m.NumSel:WaitUserInput(m)
		local ret = m.NumSel:GetResult()
		DelNumSel(m.NumSel)
		m:luaSaveToStore(ret)
	end
		RefreshBag(m)
		return true
end

local lDonate = function(m)
	DBGPRINTF("lua_info:Begin donate")
	local num = m:GetSelNum()
	if num == 0 then
		return false
	elseif 1 == num then
		m:luaDonate(1)
	else
		m.NumSel = NewNumSel(m, STR_COMBINE_NUMBER, num, 1, num)
		m.NumSel:WaitUserInput(m)
		local ret = m.NumSel:GetResult()
		DelNumSel(m.NumSel)
		m:luaDonate(ret)
	end
		RefreshBag(m)
		return true
end

local DoMenu = function(m, index)
	local type = m:GetMenuType(index)
	if type == nil then
		return
	end
	HideMenu(m, false)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_627, true)
	UI_Engine.SetStateNull(m.formIndex)
	if type == PackageUseType.MENU_USE then		-- 使用
		local num, str = m:luaModeExamineProp()
			if num ~= nil then
				if num == 0 then
					if MsgBox.ECODE_YES == QueryUser(m, str) then
						m:Use()
						RefreshBag(m)
					end
				elseif num == 1 then
					WarnUser(m, str)
				elseif num == 2 then
					WarnUser(m, R_STRING_HELP_TO_PET_TAB)
				elseif 3 == num then
					local ret = FeedHorse(m) 
					if nil ~= ret then
						m:FeedHorse(ret)
					end
				end
			end
		local needclose = m:NeedClose()
		if needclose then
			m:InputFinished()
			m:Close()
			return
		end
	elseif type == PackageUseType.MENU_TAKEON then --装备
		local str = m:luaModeExamineEquip()
		if str ~= nil then
			DBGPRINTF(str)
			local result = QueryUser(m, str)
			if MsgBox.ECODE_YES == result then
				m:TakeOn()
				UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_8)
			end
		end
	elseif type == PackageUseType.MENU_TAKEOFF then -- 除下
		local str = m:luaModeExamineEquip()
	elseif type == PackageUseType.MENU_SHORTCUT then
		if true == m:CanShortCut() then
			m.userDragItem = m:GetShortCutSelectItem()
			m.setShortcut = NewSetShortcut(m, m.userDragItem)
			m.setShortcut:WaitUserInput(m)
			DelSetShortcut(m.setShortcut)
		end
	elseif type == PackageUseType.MENU_FULLINFO then -- 详细信息
		local name, ptr = m:GetInfoPtr()
		if nil == ptr then
			return false
		else
			m.info = NewInfo(m, name, ptr)
			return true
		end
	elseif type == PackageUseType.MENU_DESTROY then -- 销毁
		local str = m:GetDesString()
		if MsgBox.ECODE_YES == QueryUser(m, str) then
			OnDestroy(m)
			UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_8)
		end
	elseif type == PackageUseType.MENU_HATCH then-- 孵化
		local num, str = m:luaModeExamineProp()
			if num ~= nil then
				if num == 0 then
					if MsgBox.ECODE_YES == QueryUser(m, str) then
						m:Use()
						RefreshBag(m)
					end
				elseif num == 1 then
					WarnUser(m, str)
				elseif num == 2 then
					FoodPet(m)
				elseif 3 == num then
					local ret = FeedHorse(m) 
					if nil ~= ret then
						m:FeedHorse(ret)
					end
				end
			end
	elseif type == PackageUseType.MENU_GETON then --上马
		local str = m:luaModeExamineEquip()
		if str ~= nil then
			DBGPRINTF(str)
			local result = QueryUser(m, str)
			if MsgBox.ECODE_YES == result then
				m:TakeOn()
			end
		end
	elseif type == PackageUseType.MENU_GETOFF then -- 下马
		local str = m:luaModeExamineEquip()
		if str ~= nil then
			DBGPRINTF(str)
			local result = QueryUser(m, str)
			if MsgBox.ECODE_YES == result then
				m:TakeOn()
			end
		end
	elseif type == PackageUseType.MENU_AUTOHPSETTING then -- 自动吃血
		local szTitle, szDef = m:GetAutoString(0)
		m.input = NewInputBox(m, szTitle, 0, szDef, 100)
		m.input:WaitUserInput(m)
		local num = m.input:GetInput()
		DelInputBox(m.input)
		m:SetAutoIni(0, num)
	elseif type == PackageUseType.MENU_AUTOMPSETTING then -- 自动吃蓝
		local szTitle, szDef = m:GetAutoString(1)
		m.input = NewInputBox(m, szTitle, 0, szDef, 100)
		m.input:WaitUserInput(m)
		local num = m.input:GetInput()
		DelInputBox(m.input)
		m:SetAutoIni(1, num)
	elseif type == PackageUseType.MENU_AUTOPETHPSETTING then -- 宠自动吃血
		local szTitle, szDef = m:GetAutoString(2)
		m.input = NewInputBox(m, szTitle, 0, szDef, 100)
		m.input:WaitUserInput(m)
		local num = m.input:GetInput()
		DelInputBox(m.input)
		m:SetAutoIni(2, num)
	elseif type == PackageUseType.MENU_AUTOPETMPSETTING then -- 宠自动吃蓝
		local szTitle, szDef = m:GetAutoString(3)
		m.input = NewInputBox(m, szTitle, 0, szDef, 100)
		m.input:WaitUserInput(m)
		local num = m.input:GetInput()
		DelInputBox(m.input)
		m:SetAutoIni(3, num)
	elseif type == PackageUseType.MENU_FEED then
		while true do
			local ptr1, ptr2 = m:GetFoodPtr()
			m.bag = NewSelectBag(m, ptr1, ptr2)
			if nil == m.bag then
				WarnUser(m, R_STRING_NO_PET_FOOD)
				break
			else
				m.bag:WaitUserInput(m)
				local item = m.bag:GetSelectItem()
				local sn, num = m.bag:GetSelectSimpleItem()
				local code = m.bag:GetExitCode()
				if code == 0 then
					DelSelectBag(m.bag)
					break
				end
				if item ~= nil then
					m:FeedPet(item)
					DelSelectBag(m.bag)
				else
					if sn ~= 0 then
						m:FeedPet(sn, num)
						DelSelectBag(m.bag)
					end
				end
			end
			DBGPRINTF("loop#@&$^*&#@^$*&")
		end
	elseif type == PackageUseType.MENU_SAVETOSTORE then --存到仓库
		SaveStore(m)
	elseif type == PackageUseType.MENU_SAVEMONEY then -- 存钱
		m.NumSel = NewNumSel(m, STR_INPUT_MONEY_PRMOPT, m.money, 1, m.money)
		m.NumSel:WaitUserInput(m)
		local ret = m.NumSel:GetResult()
		DelNumSel(m.NumSel)
		m:luaSaveMoney(ret)
		SetMoney(m)
	elseif type == PackageUseType.MENU_CHANGETOSTORE then--切换仓库
	elseif type == PackageUseType.MENU_DONATE then--捐献
		lDonate(m)
	elseif type == PackageUseType.MENU_LOCK then
		if MsgBox.ECODE_YES == QueryUser(m, STR_CONFIRM_LCOK) then
			m:Lock()
		end
	elseif type == PackageUseType.MENU_UNLOCK then
		m:UnLock()
	elseif type == PackageUseType.MENU_LOOKUP then
		m:HandlePet(PackageUseType.MENU_LOOKUP)
	elseif type == PackageUseType.MENU_CALLUP then
		m:HandlePet(PackageUseType.MENU_CALLUP)
	elseif type == PackageUseType.MENU_CALLBACK then
		m:HandlePet(PackageUseType.MENU_CALLBACK)
	elseif type == PackageUseType.MENU_TRAIN then
		m:HandlePet(PackageUseType.MENU_TRAIN)
	elseif type == PackageUseType.MENU_FREE then
		local str = m:HandlePet(PackageUseType.MENU_FREE)
		if MsgBox.ECODE_YES == QueryUser(m, str) then
			m:Free()
		end
	elseif type == PackageUseType.MENU_PETEQUIP then
		m:HandlePet(PackageUseType.MENU_PETEQUIP)
	elseif type == PackageUseType.MENU_SETSHORTCUTICON then
		if true == m:CanShortCut() then
			m.userDragItem = m:GetShortCutSelectItem()
			m.setShortcut = NewSetShortcut(m, m.userDragItem)
			m.setShortcut:WaitUserInput(m)
			DelSetShortcut(m.setShortcut)
		end
	end
	RefreshBag(m)
	UI_Engine.UpdateList( m.formIndex, UI2_COMPOSIT_8 )
end
NEW_FORM_BAG_2.C50003_OnClick = function( m )
m:ChangeTab(PackageTab.BAG_TAB_EQUIP)
m.expand = 0
DrawCap(m)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_8)
m.pageNum = m:GetTabNum()
UI_Engine.SetStateNull(m.formIndex)
RefreshBag( m )
end
NEW_FORM_BAG_2.C50004_OnClick = function( m )
m:ChangeTab(PackageTab.BAG_TAB_CONSUME)
m.expand = 1
DrawCap(m)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_8)
m.pageNum = m:GetTabNum()
UI_Engine.SetStateNull(m.formIndex)
RefreshBag( m )
end
NEW_FORM_BAG_2.C50005_OnClick = function( m )
m:ChangeTab(PackageTab.BAG_TAB_NORMAL)
m.expand = 2
DrawCap(m)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_8)
m.pageNum = m:GetTabNum()
UI_Engine.SetStateNull(m.formIndex)
RefreshBag( m )
end
NEW_FORM_BAG_2.C50006_OnClick = function( m )
m:ChangeTab(PackageTab.BAG_TAB_TASK )
m.expand = 3
DrawCap(m)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_8)
m.pageNum = m:GetTabNum()
UI_Engine.SetStateNull(m.formIndex)
RefreshBag( m )
end
NEW_FORM_BAG_2.C50049_OnClick = function( m )
m:ChangeTab(4)
m.expand = 5
DrawCap(m)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_8)
m.pageNum = m:GetTabNum()
UI_Engine.SetStateNull(m.formIndex)
RefreshBag( m )
end
NEW_FORM_BAG_2.C50030_OnClick = function( m )
m:SaveShortCutData()
m:InputFinished()
m:Close()
end
NEW_FORM_BAG_2.C50048_OnClick = function( m )
--InitMenu(m, true, false)
--[[HideMenu(m, false)
if m.moved == true then
	UI_Engine.MoveWindow(m.formIndex, 126, 0)
	m.moved = false
end
--]]
m:GetMenuType(100)
end
NEW_FORM_BAG_2.C50041_OnClick = function( m )
DoMenu(m, 6)
end
NEW_FORM_BAG_2.C50040_OnClick = function( m )
DoMenu(m, 5)
end
NEW_FORM_BAG_2.C50039_OnClick = function( m )
DoMenu(m, 4)
end
NEW_FORM_BAG_2.C50038_OnClick = function( m )
DoMenu(m, 3)
end
NEW_FORM_BAG_2.C50037_OnClick = function( m )
DoMenu(m, 2)
end
NEW_FORM_BAG_2.C50036_OnClick = function( m )
DoMenu(m, 1)
end
NEW_FORM_BAG_2.C50035_OnClick = function( m )
DoMenu(m, 0)
end
NEW_FORM_BAG_2.C50034_OnClick = function( m )
m:ChangeMenuGroup( false )
end
NEW_FORM_BAG_2.C50033_OnClick = function( m )
m:ChangeMenuGroup( true )
end
NEW_FORM_BAG_2.C50043_OnClick = function( m )
m:OnExpand(m.expand)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_8)
end
NEW_FORM_BAG_2.C50028_OnClick = function( m )
m:ClickArrow(true)
ChangePage(m)
local null = UI_Engine.GetNullString()
RefreshBag(m)
UI_Engine.SetSlipperText(m.formIndex, nID, null)
end
NEW_FORM_BAG_2.C50027_OnClick = function( m )
m:ClickArrow(false)
ChangePage(m)
local null = UI_Engine.GetNullString()
RefreshBag(m)
UI_Engine.SetSlipperText(m.formIndex, nID, null)
end
NEW_FORM_BAG_2.C50026_OnClick = function( m )
ClickGrid(m, 19)
end
NEW_FORM_BAG_2.C50026_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_26, 19)
local ret = m:GetNum(m:GetPage() * 20 + 19)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50025_OnClick = function( m )
ClickGrid(m, 18)
end
NEW_FORM_BAG_2.C50025_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_25, 18)
local ret = m:GetNum(m:GetPage() * 20 + 18)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50024_OnClick = function( m )
ClickGrid(m, 17)
end
NEW_FORM_BAG_2.C50024_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_24, 17)
local ret = m:GetNum(m:GetPage() * 20 + 17)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50023_OnClick = function( m )
ClickGrid(m, 16)
end
NEW_FORM_BAG_2.C50023_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_23, 16)
local ret = m:GetNum(m:GetPage() * 20 + 16)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50022_OnClick = function( m )
ClickGrid(m, 15)
end
NEW_FORM_BAG_2.C50022_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_22, 15)
local ret = m:GetNum(m:GetPage() * 20 + 15)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50021_OnClick = function( m )
ClickGrid(m, 14)
end
NEW_FORM_BAG_2.C50021_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_21, 14)
local ret = m:GetNum(m:GetPage() * 20 + 14)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50020_OnClick = function( m )
ClickGrid(m, 13)
end
NEW_FORM_BAG_2.C50020_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_20, 13)
local ret = m:GetNum(m:GetPage() * 20 + 13)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50019_OnClick = function( m )
ClickGrid(m, 12)
end
NEW_FORM_BAG_2.C50019_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_19, 12)
local ret = m:GetNum(m:GetPage() * 20 + 12)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50018_OnClick = function( m )
ClickGrid(m, 11)
end
NEW_FORM_BAG_2.C50018_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_18, 11)
local ret = m:GetNum(m:GetPage() * 20 + 11)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50017_OnClick = function( m )
ClickGrid(m, 10)
end
NEW_FORM_BAG_2.C50017_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_17, 10)
local ret = m:GetNum(m:GetPage() * 20 + 10)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50016_OnClick = function( m )
ClickGrid(m, 9)
end
NEW_FORM_BAG_2.C50016_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_16, 9)
local ret = m:GetNum(m:GetPage() * 20 + 9)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50015_OnClick = function( m )
ClickGrid(m, 8)
end
NEW_FORM_BAG_2.C50015_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_15, 8)
local ret = m:GetNum(m:GetPage() * 20 + 8)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50014_OnClick = function( m )
ClickGrid(m, 7)
end
NEW_FORM_BAG_2.C50014_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_14, 7)
local ret = m:GetNum(m:GetPage() * 20 + 7)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50013_OnClick = function( m )
ClickGrid(m, 6)
end
NEW_FORM_BAG_2.C50013_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_13, 6)
local ret = m:GetNum(m:GetPage() * 20 + 6)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50012_OnClick = function( m )
ClickGrid(m, 5)
end
NEW_FORM_BAG_2.C50012_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_12, 5)
local ret = m:GetNum(m:GetPage() * 20 + 5)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50011_OnClick = function( m )
ClickGrid(m, 4)
end
NEW_FORM_BAG_2.C50011_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_11, 4)
local ret = m:GetNum(m:GetPage() * 20 + 4)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50010_OnClick = function( m )
ClickGrid(m, 3)
end
NEW_FORM_BAG_2.C50010_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_10, 3)
local ret = m:GetNum(m:GetPage() * 20 + 3)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50009_OnClick = function( m )
ClickGrid(m, 2)
end
NEW_FORM_BAG_2.C50009_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_9, 2)
local ret = m:GetNum(m:GetPage() * 20 + 2)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50008_OnClick = function( m )
ClickGrid(m, 1)
end
NEW_FORM_BAG_2.C50008_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_8, 1)
SetMoney(m)
local ret = m:GetNum(m:GetPage() * 20 + 1)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
DrawCap(m)
m.pageNum = m:GetTabNum()
m:SetArrow()
end
NEW_FORM_BAG_2.C50007_OnClick = function( m )
ClickGrid(m, 0)
end
NEW_FORM_BAG_2.C50007_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_7, 0)
local ret = m:GetNum(m:GetPage() * 20 + 0)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
NEW_FORM_BAG_2.C50002_OnLoad = function( m )
m:ChangeTab(PackageTab.BAG_TAB_EQUIP)
m.expand = 0
DrawCap(m)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_8)
m.pageNum = m:GetTabNum()
RefreshBag( m )
HideMenu(m, false)
--InitMenu(m, false, true)
UI_Engine.SetLevel(m.formIndex, 2)

end
