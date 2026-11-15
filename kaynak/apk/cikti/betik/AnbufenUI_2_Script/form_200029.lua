NEW_FORM_UNIONSTORE= { }
NEW_FORM_UNIONSTORE.Main = function( m )
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

local OpenSelectPack = function(m)
	local ptrPack,pack2 = m:GetFuncFilter()
	m.Pack = NewSelectBag(m, ptrPack,pack2)

	if nil == m.Pack then
		WarnUser(m, STR_SAVE_STORE_NOITEM)
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
			local itemCount = m.Pack:GetItemCount(item)
			if itemCount == 0 then
				DelSelectBag(m.Pack)
				return
			elseif 1 == itemCount then
				m.Pack:SaveUnionStore(1)
			else
				m.NumSel = NewNumSel(m, STR_COMBINE_NUMBER, itemCount, 1, itemCount)
				m.NumSel:WaitUserInput(m)
				local ret = m.NumSel:GetResult()
				DelNumSel(m.NumSel)
				m.Pack:SaveUnionStore(ret)
			end
		elseif nNum ~= 0 then
			if nNum == 1 then
				m.Pack:SaveUnionStore(1)
			else
				m.NumSel = NewNumSel(m, STR_COMBINE_NUMBER, nNum , 1, nNum )
				m.NumSel:WaitUserInput(m)
				local ret = m.NumSel:GetResult()
				DelNumSel(m.NumSel)
				m.Pack:SaveUnionStore(ret)
			end
		end
	end
	DelSelectBag(m.Pack)
	m:RequestStoreInfo()
end


local ClickGrid = function(m, i)
	if false == m:IsSaveAll() then
		return
	end
	UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_780)
	m.userSelectItem = m:GetPage() * 20 + i
	local ret = m:SelectItem(m.userSelectItem)
	if ret == true then
		m:OnClickGrid()
	else
		m:OnClickGrid()
		OpenSelectPack(m)
	end
end

local UpdateItem = function ( m, control )
	local img, nSN  = m:OnUpdateItem( m.ItemCount )
	UI_Engine.SetClientEmpty(m.formIndex, control)
	if img ~= nil then
		UI_Engine.SetVisible( m.formIndex, control, true )
		if 0 ~= nSN then
			UI_Engine.SetSurfaceImg( m.formIndex, control, img, 0, 0, false,  nSN)
		else
			UI_Engine.SetClientEmpty(m.formIndex, control)
		end
	else
		UI_Engine.SetVisible( m.formIndex, control, false )
	end
	m.ItemCount = m.ItemCount + 1
end

local RefreshBag = function( m )
	m:UpdateItemList()
	m.ItemCount = 0
	for i = 0, 19 do
		local id = UI2_COMPOSIT_779 + i
		UpdateItem( m, id)
	end
end

local BtnClick = function(m)
	local ptr = m:GetTabPtr()
	if ptr ~= nil then
		m.list = NewSingleList(m, ptr)
		m.list:WaitUserInput(m)
		local cmd, str = m.list:GetSelectList()
		if cmd ~= nil then
			m:ChangeTab(cmd)
			UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_805, str)
		end
		DelSingleList(m.list)
		UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_780)
		RefreshBag(m)
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
	if img ~= nil then
		UI_Engine.SetVisible( m.formIndex, nID, true )
		UI_Engine.SetSurfaceImg( m.formIndex, nID, img, 0, 0, false,  nSN)
	else
		UI_Engine.SetClientEmpty(m.formIndex, nID)
	end
end

local SetMoney = function(m)
	m.money, m.szMoney = m:GetGolden()
	UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_808, m.szMoney)
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

local DoMenu = function(m, index)
	local type = m:GetMenuType(index)
	if type == nil then
		return
	end
	UI_Engine.SetStateNull(m.formIndex)
	RefreshBag(m)
	UI_Engine.UpdateList( m.formIndex, UI2_COMPOSIT_780)
	if type == UNIONSTORE.MENU_SAVEMONEY then
		local num = m:GetPlayerMoney()
		if 0 == num then
			m:InvalidHandle()
			return
		end
		m.NumSel = NewNumSel(m, 2520, 1, 1, num)
		m.NumSel:WaitUserInput(m)
		local ret = m.NumSel:GetResult()
		DelNumSel(m.NumSel)
		if ret > 0 then
			m:SaveMoney(ret)
		end
		m:InitDraw()
	elseif type == UNIONSTORE.MENU_TAKEMONEY then
		local ret = m:IsNeedPwd()
		local num = m:GetUnionMoney()
		if 0 == num then
			m:InvalidHandle()
			return
		end
		if ret == false then
			m.input = NewInputBox(m, 2514, 1, "", 6)
			m.input:WaitUserInput(m)
			local pwd = m.input:GetInput()
			local code = m.input:ExitType()
			DelInputBox(m.input)
			if 0 == code then
				m:InitDraw()
				return
			end
			m:SetTempPwd(pwd)
			m.NumSel = NewNumSel(m, 2520, 1, 1, num)
			m.NumSel:WaitUserInput(m)
			local money = m.NumSel:GetResult()
			DelNumSel(m.NumSel)
			if money > 0 then
				m:TakeMoney( money )
			end
			m:InitDraw()
		else
			m.NumSel = NewNumSel(m, 2520, 1, 1, num)
			m.NumSel:WaitUserInput(m)
			local money = m.NumSel:GetResult()
			DelNumSel(m.NumSel)
			if money > 0 then
				m:TakeMoney( money )
			end
			m:InitDraw()
		end
	elseif type == UNIONSTORE.MENU_SAVEITEM then
		OpenSelectPack(m)
		m:InitDraw()
	elseif type == UNIONSTORE.MENU_INFO then
		local name, ptr = m:GetInfoPtr()
		if nil == ptr then
			m:InitDraw()
			return false
		else
			m.info = NewInfo(m, name, ptr)
			m:InitDraw()
			return true
		end
	elseif type == UNIONSTORE.MENU_SETPWD then
		m.old = NewInputBox(m, STR_INPUT_ORIGINAL_PWD, 1, "", 12)
		m.old:WaitUserInput(m)
		local old = m.old:GetInput()
		local code = m.input:ExitType()
		DelInputBox(m.old)
		
		if 0 == code then
			m:InitDraw()
			return
		end
		m.new = NewInputBox(m, STR_INPUT_NEW_PWD, 1, "", 12)
		m.new:WaitUserInput(m)
		local new = m.new:GetInput()
		local code = m.input:ExitType()
		DelInputBox(m.new)

		if 0 == code then
			m:InitDraw()
			return
		end
		m:SetPwd(old, new)	
		m:InitDraw()
	elseif type == UNIONSTORE.MENU_TAKEITEM then
		local ret = m:IsNeedPwd()
		if false == ret then
			local num = m:GetItemNum()
			if num == nil then
				m:InitDraw()
				return
			end
			m.input = NewInputBox(m, 2514, 1, "", 6)
			m.input:WaitUserInput(m)
			local pwd = m.input:GetInput()
			local code = m.input:ExitType()
			DelInputBox(m.input)
			m:SetTempPwd(pwd)
			if 0 == code then
				m:InitDraw()
				return
			end
			if num == 1 then
				m:TakeItem(1)
			else
				m.num = NewNumSel(m, 2415, num, 1, num)
				m.num:WaitUserInput(m)
				local nItem = m.num:GetResult()
				DelNumSel(m.num)
				if nItem > 0 then
					m:TakeItem(nItem)
				end
			end
			m:InitDraw()
		else
			local num = m:GetItemNum()
			if num == nil then
				m:InitDraw()
				return
			end
			if num == 1 then
				m:TakeItem(1)
			else
				m.NumSel = NewNumSel(m, 2415, num, 1, num)
				m.NumSel:WaitUserInput(m)
				local nItem = m.NumSel:GetResult()
				DelNumSel(m.NumSel)
				if nItem > 0 then
					m:TakeItem( nItem )
				end
			end
			m:InitDraw()
		end
	end
end
NEW_FORM_UNIONSTORE.C50798_OnClick = function( m )
ClickGrid(m, 19)
end
NEW_FORM_UNIONSTORE.C50798_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_798, 19)
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
NEW_FORM_UNIONSTORE.C50797_OnClick = function( m )
ClickGrid(m, 18)
end
NEW_FORM_UNIONSTORE.C50797_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_797, 18)
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
NEW_FORM_UNIONSTORE.C50796_OnClick = function( m )
ClickGrid(m, 17)
end
NEW_FORM_UNIONSTORE.C50796_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_796, 17)
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
NEW_FORM_UNIONSTORE.C50795_OnClick = function( m )
ClickGrid(m, 16)
end
NEW_FORM_UNIONSTORE.C50795_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_795, 16)
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
NEW_FORM_UNIONSTORE.C50794_OnClick = function( m )
ClickGrid(m, 15)
end
NEW_FORM_UNIONSTORE.C50794_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_794, 15)
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
NEW_FORM_UNIONSTORE.C50793_OnClick = function( m )
ClickGrid(m, 14)
end
NEW_FORM_UNIONSTORE.C50793_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_793, 14)
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
NEW_FORM_UNIONSTORE.C50792_OnClick = function( m )
ClickGrid(m, 13)
end
NEW_FORM_UNIONSTORE.C50792_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_792, 13)
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
NEW_FORM_UNIONSTORE.C50791_OnClick = function( m )
ClickGrid(m, 12)
end
NEW_FORM_UNIONSTORE.C50791_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_791, 12)
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
NEW_FORM_UNIONSTORE.C50790_OnClick = function( m )
ClickGrid(m, 11)
end
NEW_FORM_UNIONSTORE.C50790_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_790, 11)
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
NEW_FORM_UNIONSTORE.C50789_OnClick = function( m )
ClickGrid(m, 10)
end
NEW_FORM_UNIONSTORE.C50789_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_789, 10)
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
NEW_FORM_UNIONSTORE.C50788_OnClick = function( m )
ClickGrid(m, 9)
end
NEW_FORM_UNIONSTORE.C50788_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_788, 9)
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
NEW_FORM_UNIONSTORE.C50787_OnClick = function( m )
ClickGrid(m, 8)
end
NEW_FORM_UNIONSTORE.C50787_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_787, 8)
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
NEW_FORM_UNIONSTORE.C50786_OnClick = function( m )
ClickGrid(m, 7)
end
NEW_FORM_UNIONSTORE.C50786_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_786, 7)
local ret = m:GetNum(m:GetPage() * 20 +7 )
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
NEW_FORM_UNIONSTORE.C50785_OnClick = function( m )
ClickGrid(m, 6)
end
NEW_FORM_UNIONSTORE.C50785_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_785, 6)
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
NEW_FORM_UNIONSTORE.C50784_OnClick = function( m )
ClickGrid(m, 5)
end
NEW_FORM_UNIONSTORE.C50784_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_784, 5)
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
NEW_FORM_UNIONSTORE.C50783_OnClick = function( m )
ClickGrid(m, 4)
end
NEW_FORM_UNIONSTORE.C50783_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_783, 4)
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
NEW_FORM_UNIONSTORE.C50782_OnClick = function( m )
ClickGrid(m, 3)
end
NEW_FORM_UNIONSTORE.C50782_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_782, 3)
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
NEW_FORM_UNIONSTORE.C50781_OnClick = function( m )
ClickGrid(m, 2)
end
NEW_FORM_UNIONSTORE.C50781_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_781, 2)
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
NEW_FORM_UNIONSTORE.C50780_OnClick = function( m )
ClickGrid(m, 1)
end
NEW_FORM_UNIONSTORE.C50780_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_780, 1)
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
end
NEW_FORM_UNIONSTORE.C50779_OnClick = function( m )
ClickGrid(m, 0)
end
NEW_FORM_UNIONSTORE.C50779_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_779, 0)
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
NEW_FORM_UNIONSTORE.C50809_OnClick = function( m )
m:OnExpand(m.expand)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_780)
end
NEW_FORM_UNIONSTORE.C50805_OnClick = function( m )
BtnClick(m)
end
NEW_FORM_UNIONSTORE.C50801_OnClick = function( m )
m:ClickArrow(true)
--ChangePage(m)
local null = UI_Engine.GetNullString()
RefreshBag(m)
UI_Engine.UpdateList( m.formIndex, UI2_COMPOSIT_780 )
end
NEW_FORM_UNIONSTORE.C50800_OnClick = function( m )
m:ClickArrow(false)
--ChangePage(m)
local null = UI_Engine.GetNullString()
RefreshBag(m)
UI_Engine.UpdateList( m.formIndex, UI2_COMPOSIT_780 )
end
NEW_FORM_UNIONSTORE.C50799_OnClick = function( m )
m:Close()
end
NEW_FORM_UNIONSTORE.C50818_OnClick = function( m )
DoMenu(m,6)
end
NEW_FORM_UNIONSTORE.C50817_OnClick = function( m )
DoMenu(m,5)
end
NEW_FORM_UNIONSTORE.C50816_OnClick = function( m )
DoMenu(m,4)
end
NEW_FORM_UNIONSTORE.C50815_OnClick = function( m )
DoMenu(m,3)
end
NEW_FORM_UNIONSTORE.C50814_OnClick = function( m )
DoMenu(m,2)
end
NEW_FORM_UNIONSTORE.C50813_OnClick = function( m )
DoMenu(m,1)
end
NEW_FORM_UNIONSTORE.C50812_OnClick = function( m )
DoMenu(m,0)
end
NEW_FORM_UNIONSTORE.C50778_OnLoad = function( m )
m:ChangeTab(PackageTab.BAG_TAB_EQUIP)
m.expand = 0
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_780)
m.pageNum = m:GetTabNum()
RefreshBag( m )
end
