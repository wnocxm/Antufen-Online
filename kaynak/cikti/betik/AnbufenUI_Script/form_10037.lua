FORM_BAG= { }
FORM_BAG.Main = function( m )
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
FORM_BAG.C51661_OnLoad = function( m )
m.describe = true
m.curPage = 0
m.pageNum = 0
DBGPRINTF("loading... m.pageNum = "..m.pageNum)
m.mode = 0
m.money = 0
m.szMoney = ""
end
local UpdateItem = function ( m, control )
	local img, nSN  = m:OnUpdateItem( m.ItemCount )
	if img ~= nil then
		UI_Engine.SetVisible( m.formIndex, control, true )
		if 0 ~= nSN then
		UI_Engine.SetSurfaceImg( m.formIndex, control, img, 0, 0, false,  nSN)		else
		UI_Engine.SetClientEmpty(m.formIndex, control)
		end
	else
		UI_Engine.SetVisible( m.formIndex, control, false )
	end
	m.ItemCount = m.ItemCount + 1
end

local SetMoney = function(m)
	m.money, m.szMoney = m:GetGolden()
	UI_Engine.SetText(m.formIndex, COMPOSIT_2402, m.szMoney)
end
local RefreshBag = function ( m )
	m:UpdateItemList()
	m.ItemCount = 0
	--m.curPage = 0
	UpdateItem( m, COMPOSIT_BAG_ITEM1_1 )
	UpdateItem( m, COMPOSIT_BAG_ITEM1_2 )
	UpdateItem( m, COMPOSIT_BAG_ITEM1_3 )
	UpdateItem( m, COMPOSIT_BAG_ITEM1_4 )
	UpdateItem( m, COMPOSIT_BAG_ITEM1_5 )
	UpdateItem( m, COMPOSIT_BAG_ITEM2_1 )
	UpdateItem( m, COMPOSIT_BAG_ITEM2_2 )
	UpdateItem( m, COMPOSIT_BAG_ITEM2_3 )
	UpdateItem( m, COMPOSIT_BAG_ITEM2_4 )
	UpdateItem( m, COMPOSIT_BAG_ITEM2_5 )
	UpdateItem( m, COMPOSIT_BAG_ITEM3_1 )
	UpdateItem( m, COMPOSIT_BAG_ITEM3_2 )
	UpdateItem( m, COMPOSIT_BAG_ITEM3_3 )
	UpdateItem( m, COMPOSIT_BAG_ITEM3_4 )
	UpdateItem( m, COMPOSIT_BAG_ITEM3_5 )
	UpdateItem( m, COMPOSIT_BAG_ITEM4_1 )
	UpdateItem( m, COMPOSIT_BAG_ITEM4_2 )
	UpdateItem( m, COMPOSIT_BAG_ITEM4_3 )
	UpdateItem( m, COMPOSIT_BAG_ITEM4_4 )
	UpdateItem( m, COMPOSIT_BAG_ITEM4_5 )
	UpdateItem( m, COMPOSIT_BAG_ITEM5_1 )
	UpdateItem( m, COMPOSIT_BAG_ITEM5_2 )
	UpdateItem( m, COMPOSIT_BAG_ITEM5_3 )
	UpdateItem( m, COMPOSIT_BAG_ITEM5_4 )
	UpdateItem( m, COMPOSIT_BAG_ITEM5_5 )
end

local QueryUser = function(m, str)
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

local Horse = function(m)
	if m:IsCallUpHorse() then
		if m:IsSelectCurHorseID() then
			m:TakeOff()
		else
			m:TakeOn()
		end
	else
		if m:IsEquipBind() then
			if QueryUser(m, "need replace text") then
				m:TakeOn()
			end
		else
			m:TakeOn()
		end
	end
end

local Equipment = function(m)
	if m:IsEquipOn() then
		m:TakeOff()
	else
		if m:IsEquipBind() then
			m:TakeOn()
		else
			m:TakeOn()
		end
	end
end

local Egg = function(m)
	if m:IsEnableHatch() then
		--打开孵化窗体
	else
		WarnUser(m, "cannot hatch")
	end
end

local SkillBook = function(m)
	if m:IsTestRequest() then
		if QueryUser(m, "Skill book") then
			m:Use()
		end
	else
		WarnUser(m, "cannot use skill book")
	end
end

local PetFood = function(m)
	WarnUser(m, "cannot use pet food")
end

local HorseFood = function(m)
	WarnUser(m, "cannot use horse food")
end

local PetMedic = function(m)
	WarnUser(m, "cannot use pet medic")
end

local StartTaskItem = function(m)
	if m:IsTaskEnable() then
		if m:IsTaskFinish() then
			WarnUser(m, "show task")
		else
			WarnUser(m, "new task")
		end
	end
end

local TypeYes = function(m)
	if m:IsNeedUse() then
		if m:IsTestRequest() then
			if m:IsConsumeProp() then
				if m:IsConsumePropExist() then
					if QueryUser(m, "use item?") then
						m:Use()
					end
				else
					WarnUser(m, "consume prop not exist")
				end
			else
				if QueryUser(m, "use item?") then
					m:Use()
				end
			end
		else
			WarnUser(m, "cannot use item")
		end
	else
		WarnUser(m, "cannot use item")
	end
end

local SpecialItem = function(m)
end

local SaveStore = function(m)
	local num = m:GetSelNum()
	if num == 0 then
		return false
	elseif 1 == num then
		m:luaSaveToStore(1)
	else
		m.NumSel = NewNumSel(m, "Select Number", num, 1, num)
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
		m.NumSel = NewNumSel(m, "Select Number", num, 1, num)
		m.NumSel:WaitUserInput(m)
		local ret = m.NumSel:GetResult()
		DelNumSel(m.NumSel)
		m:luaDonate(ret)
	end
		RefreshBag(m)
		return true
end
--快捷栏
local UpdateShotrCutItem = function(m,nIndex,control)
	local img = m:GetShortCutIcon(nIndex)
	UI_Engine.SetSurfaceImg( m.formIndex, control, img )
end

local UpdateShotrCut = function(m)
	UpdateShotrCutItem(m,0,COMPOSIT_1662)
	UpdateShotrCutItem(m,1,COMPOSIT_1663)
	UpdateShotrCutItem(m,2,COMPOSIT_1664)
	UpdateShotrCutItem(m,3,COMPOSIT_1665)
	UpdateShotrCutItem(m,4,COMPOSIT_1666)
	UpdateShotrCutItem(m,5,COMPOSIT_1667)
end

local SetShortCutVisible = function(m , bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1668,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1669,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1670,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1674,bDarw)
	
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1662,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1663,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1664,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1665,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1666,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1667,bDarw)
end


local AddShortCut = function(m , nIndex)
	if m.userDragItem == nil then
		return 
	end
	if m.bCheck  then
		if m:CanShortCut() == false  then
			WarnUser(m,"此物品不能设置快捷栏")
			return 
		end
	end
	m:SetShortCutItem(nIndex, m.userDragItem)
	
	UpdateShotrCut(m)
end



local SetShortTabState=function(m,nIndex)
	if nIndex == 0 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_1668,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_1668,0)
	end
	
	if nIndex == 1 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_1669,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_1669,0)
	end
	
	if nIndex == 2 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_1670,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_1670,0)
	end
	
	if nIndex == 3 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_1674,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_1674,0)
	end
end

local OnDragShortCut = function(m, nIndex)
	m:SelectItem(nIndex)
	m.userDragItem = m:GetShortCutSelectItem()
	m.bCheck = true    --是否检查
end

local DrawCap = function(m)
	local cap = m:DrawCap()
	UI_Engine.SetText(m.formIndex, COMPOSIT_2120, cap)
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
		m.NumSel = NewNumSel(m, "Select Number", num, 1, num)
		m.NumSel:WaitUserInput(m)
		local ret = m.NumSel:GetResult()
		DelNumSel(m.NumSel)
		m:DeleteItem(ret)
		RefreshBag(m)
		return true
	end
	RefreshBag(m)
end

local SetDescribe = function(m, nID)
	if false == m.describe then
		UI_Engine.SetMultiRollText(m.formIndex, nID, "")
	else
		local text = m:GetDescribe()
		UI_Engine.SetMultiRollText(m.formIndex, nID, text)
	end
end

local UpdateIcon = function(m)
	m:DrawNumIcon( COMPOSIT_BAG_ITEM1_1, m.curPage * 25+0 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM1_2, m.curPage * 25+1 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM1_3, m.curPage * 25+2 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM1_4, m.curPage * 25+3 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM1_5, m.curPage * 25+4 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM2_1, m.curPage * 25+5 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM2_2, m.curPage * 25+6 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM2_3, m.curPage * 25+7 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM2_4, m.curPage * 25+8 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM2_5, m.curPage * 25+9 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM3_1, m.curPage * 25+10 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM3_2, m.curPage * 25+11 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM3_3, m.curPage * 25+12 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM3_4, m.curPage * 25+13 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM3_5, m.curPage * 25+14 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM4_1, m.curPage * 25+15 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM4_2, m.curPage * 25+16 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM4_3, m.curPage * 25+17 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM4_4, m.curPage * 25+18 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM4_5, m.curPage * 25+19 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM5_1, m.curPage * 25+20 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM5_2, m.curPage * 25+21 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM5_3, m.curPage * 25+22 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM5_4, m.curPage * 25+23 )
	m:DrawNumIcon( COMPOSIT_BAG_ITEM5_5, m.curPage * 25+24 )
end

local DrawIcon = function(m, nID, nIndex)
	local img  = m:OnUpdateItem( nIndex )
	if img ~= nil then
		DBGPRINTF("lua_INFO: get img!")
		UI_Engine.SetVisible( m.formIndex, nID, true )
		UI_Engine.SetSurfaceImg( m.formIndex, nID, img )
	else
		UI_Engine.SetVisible( m.formIndex, nID, false )
	end
end

local ShowShortCut = function(m)
	m:SelectItem(m.userSelectItem)
	local ret = m:IsConsumeShortCut()
	local auto = m:SetAutoBtn()

	if true == ret then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1672, true)
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1672, false)
	end

	if nil ~= auto then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2793, true)
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2793, false)
	end
end

local ChangeState = function(m)
	m:SelectItem(m.userSelectItem)
	local mode, tab ,usetype, type = m:SelectType()
  	if mode == PackageMode.MODE_EXAMIME then
		if tab == PackageTab.BAG_TAB_EQUIP then
			if usetype == PackageUseType.USE_TYPE_HORSE then
				if true == m:GetHorseState() then
					ShowShortCut(m)
					UI_Engine.SetText(m.formIndex, COMPOSIT_773, "离开坐骑")
				else
					ShowShortCut(m)
					UI_Engine.SetText(m.formIndex, COMPOSIT_773, "骑乘")
				end
			else
				ShowShortCut(m)
				UI_Engine.SetText(m.formIndex, COMPOSIT_773, "装备")
			end
		else 
			if usetype == PackageUseType.USE_TYPE_EGG then
				ShowShortCut(m)
				UI_Engine.SetText(m.formIndex, COMPOSIT_773, "孵化")
			elseif usetype == PackageUseType.USE_TYPE_SKILLBOOK then
				ShowShortCut(m)
				UI_Engine.SetText(m.formIndex, COMPOSIT_773, "学习")
			elseif usetype == PackageUseType.USE_TYPE_PETFOOD then
				ShowShortCut(m)
				UI_Engine.SetText(m.formIndex, COMPOSIT_773, "使用")
			elseif usetype == PackageUseType.USE_TYPE_NO_PET_MEDIC then
				ShowShortCut(m)
				UI_Engine.SetText(m.formIndex, COMPOSIT_773, "使用")
			elseif usetype == PackageUseType.USE_TYPE_START_TASK then
				ShowShortCut(m)
				UI_Engine.SetText(m.formIndex, COMPOSIT_773, "使用")
			elseif usetype == PackageUseType.USE_TYPE_SPECIAL_FUNCTION then
				ShowShortCut(m)
				UI_Engine.SetText(m.formIndex, COMPOSIT_773, "使用")
			elseif usetype == PackageUseType.USE_TYPE_HORSE_FOOD then
				ShowShortCut(m)
				UI_Engine.SetText(m.formIndex, COMPOSIT_773, "使用")
			else
				ShowShortCut(m)
				UI_Engine.SetText(m.formIndex, COMPOSIT_773, "使用")
			end
		end
	elseif mode == PackageMode.MODE_SELECT then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1672, false)
		UI_Engine.SetText(m.formIndex, COMPOSIT_773, "选择")
	elseif mode == PackageMode.MODE_STORE then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1672, false)
		UI_Engine.SetText(m.formIndex, COMPOSIT_773, "存放")
	elseif mode == PackageMode.MODE_DONATE then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1672, false)
		UI_Engine.SetText(m.formIndex, COMPOSIT_773, "捐献")
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1672, false)
		UI_Engine.SetText(m.formIndex, COMPOSIT_773, "选择")
	end
end

local ClickGrid = function(m)
	m.describe = true
	if m.bDraw == true then
		SetShortCutVisible(m, false)
		m.bDraw = false
	end
	m:SaveShortCutData()
	ChangeState(m)
	SetDescribe(m, COMPOSIT_772)
	UI_Engine.UpdateList(m.formIndex, COMPOSIT_BAG_ITEM1_2)
end

local SetPageMode = function(m)
	if m.curPage == 0 then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2397, false)
		DBGPRINTF("show left! if..")
		DBGPRINTF("pageNum="..m.pageNum)
		DBGPRINTF("m.curPage ="..m.curPage )

	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2397, true)
		DBGPRINTF("show left! else..")
		DBGPRINTF("pageNum="..m.pageNum)
		DBGPRINTF("m.curPage ="..m.curPage )
	end

	if m.pageNum > m.curPage then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_BAG_RIGHTBUTTON, true)
		DBGPRINTF("show right! if..")
		DBGPRINTF("pageNum="..m.pageNum)
		DBGPRINTF("m.curPage ="..m.curPage )
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_BAG_RIGHTBUTTON, false)
		DBGPRINTF("show right! else..")
		DBGPRINTF("pageNum="..m.pageNum)
		DBGPRINTF("m.curPage ="..m.curPage )
	end
end

local UseItem = function(m)
	m:SelectItem(m.userSelectItem)
	local mode, tab ,usetype, type = m:SelectType()
	if mode == nil then
		return
	end
  	if mode == PackageMode.MODE_EXAMIME then
		DBGPRINTF("mode nomal")
		if tab == PackageTab.BAG_TAB_EQUIP then
			--[[if usetype == PackageUseType.USE_TYPE_HORSE then
				Horse(m)
			else
				Equipment(m)
			end
			--]]
			DBGPRINTF("tab is use equip")
			local str = m:luaModeExamineEquip()
			if str ~= nil then
				DBGPRINTF(str)
				local result = QueryUser(m, str)
				if MsgBox.ECODE_YES == result then
					m:TakeOn()
				end
			end
			RefreshBag(m)
			ClickGrid(m)
		else 
			--[[if usetype == PackageUseType.USE_TYPE_EGG then
				Egg(m)
			elseif usetype == PackageUseType.USE_TYPE_SKILLBOOK then
				SkillBook(m)
			elseif usetype == PackageUseType.USE_TYPE_PETFOOD then
				PetFood(m)
			elseif usetype == PackageUseType.USE_TYPE_NO_PET_MEDIC then
				PetMedic(m)
			elseif usetype == PackageUseType.USE_TYPE_START_TASK then
				StartTaskItem(m)
			elseif usetype == PackageUseType.USE_TYPE_SPECIAL_FUNCTION then
				SpecialItem(m)
			elseif usetype == PackageUseType.USE_TYPE_HORSE_FOOD then
				HorseFood(m)
			else
				m:Use()
			end
			--]]
			local num, str = m:luaModeExamineProp()
			if num ~= nil then
				if num == 0 then
					if MsgBox.ECODE_YES == QueryUser(m, str) then
						m:Use()
						RefreshBag(m)
					end
				else
					WarnUser(m, str)
				end
			end
			RefreshBag(m)
			ClickGrid(m)
		end
	elseif mode == PackageMode.MODE_SELECT then
		--[[DBGPRINTF("mode Select")
		if tab == PackageTab.BAG_TAB_EQUIP then
			Equipment(m)
		elseif tab == PackageTab.BAG_TAB_CONSUME then
			m:Use()
		elseif tab == PackageTab.BAG_TAB_NORMAL then
		elseif tab == PackageTab.BAG_TAB_TASK then
		else 
		end
		--]]
		if m:GetEquipMode() then
			if tab == PackageTab.BAG_TAB_EQUIP then
				Equipment(m)
				m:InputFinished()
			end
		end
		local ret = m:luaModeSelect()
		if ret == nil then
			m:InputFinished()
		else
			WarnUser(m, ret)
		end
	elseif mode == PackageMode.MODE_STORE then
		DBGPRINTF("mode store")
		if tab == PackageTab.BAG_TAB_EQUIP then
		elseif tab == PackageTab.BAG_TAB_CONSUME then
		elseif tab == PackageTab.BAG_TAB_NORMAL then
		elseif tab == PackageTab.BAG_TAB_TASK then
		else 
		end
		SaveStore(m)
		RefreshBag(m)
		ClickGrid(m)
		--m:InputFinished()
	elseif mode == PackageMode.MODE_DONATE then
		DBGPRINTF("mode donate")
		if tab == PackageTab.BAG_TAB_EQUIP then
		elseif tab == PackageTab.BAG_TAB_CONSUME then
		elseif tab == PackageTab.BAG_TAB_NORMAL then
		elseif tab == PackageTab.BAG_TAB_TASK then
		else 
		end
		lDonate(m)
		RefreshBag(m)
		ClickGrid(m)
		--m:InputFinished()
	else
		DBGPRINTF("mode others")
		if tab == PackageTab.BAG_TAB_EQUIP then
		elseif tab == PackageTab.BAG_TAB_CONSUME then
		elseif tab == PackageTab.BAG_TAB_NORMAL then
		elseif tab == PackageTab.BAG_TAB_TASK then
		else 
		end
		RefreshBag(m)
	end
end

local SetMenuByMode = function(m)	--根据创建模式设置背包不同TAB下的按钮状态
	local mode = m:GetCreateMode()
	if 1 == mode then
		UI_Engine.SetText(m.formIndex, COMPOSIT_773, "选择")
	elseif 2 == mode then
		UI_Engine.SetText(m.formIndex, COMPOSIT_773, "存放")
	elseif 3 == mode then
		UI_Engine.SetText(m.formIndex, COMPOSIT_773, "捐献")
	end
end
FORM_BAG.C51668_OnClick = function( m )
m:SetShortCutTab(0)
SetShortTabState(m,0)
UpdateShotrCut(m)
end
FORM_BAG.C51669_OnClick = function( m )
m:SetShortCutTab(1)
SetShortTabState(m,1)
UpdateShotrCut(m)
end
FORM_BAG.C51670_OnClick = function( m )
m:SetShortCutTab(2)
SetShortTabState(m,2)
UpdateShotrCut(m)
end
FORM_BAG.C51674_OnClick = function( m )
m:SetShortCutTab(3)
SetShortTabState(m,3)
UpdateShotrCut(m)
end
FORM_BAG.C51672_OnLoad = function( m )
m.bDraw = false
SetShortCutVisible(m, false)
end
FORM_BAG.C51672_OnClick = function( m )
--[[if m.describe == true then
	m.describe = false
else
	m.describe = true
end
SetDescribe(m, COMPOSIT_772)

if m.bDraw == false then
	m.bDraw = true
	SetShortCutVisible(m, true)
	SetShortTabState(m,0)
	m:LoadShortCutData()
	UpdateShotrCut(m)
else
	m.bDraw = false
	SetShortCutVisible(m, false)
	m:SaveShortCutData()
end
--]]
if true == m:CanShortCut() then
	m.userDragItem = m:GetShortCutSelectItem()
	m.setShortcut = NewSetShortcut(m, m.userDragItem)
	m.setShortcut:WaitUserInput(m)
	DelSetShortcut(m.setShortcut)
end
end
FORM_BAG.C51662_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(0)
m.bCheck = false     --是否检查可以设置快捷栏
end
FORM_BAG.C51662_OnDrop = function( m )
AddShortCut(m, 0)
end
FORM_BAG.C51663_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(1)
m.bCheck = false     --是否检查可以设置快捷栏
end
FORM_BAG.C51663_OnDrop = function( m )
AddShortCut(m, 1)
end
FORM_BAG.C51664_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(2)
m.bCheck = false     --是否检查可以设置快捷栏
end
FORM_BAG.C51664_OnDrop = function( m )
AddShortCut(m, 2)
end
FORM_BAG.C51665_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(3)
m.bCheck = false     --是否检查可以设置快捷栏
end
FORM_BAG.C51665_OnDrop = function( m )
AddShortCut(m, 3)
end
FORM_BAG.C51666_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(4)
m.bCheck = false     --是否检查可以设置快捷栏
end
FORM_BAG.C51666_OnDrop = function( m )
AddShortCut(m, 4)
end
FORM_BAG.C51667_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(5)
m.bCheck = false     --是否检查可以设置快捷栏
end
FORM_BAG.C51667_OnDrop = function( m )
AddShortCut(m, 5)
end
FORM_BAG.C50778_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 0
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50778_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50778_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50778_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM1_1, 0)
local ret = m:GetNum(m.curPage * 25 + 0)
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
FORM_BAG.C50779_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 1
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50779_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50779_OnDrag = function( m )

OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50779_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM1_2, 1)
local ret = m:GetNum(m.curPage * 25 + 1)
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
SetPageMode(m)
end
FORM_BAG.C50780_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 2
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50780_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50780_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50780_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM1_3, 2)
local ret = m:GetNum(m.curPage * 25 + 2)
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
FORM_BAG.C50782_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 3
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50782_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50782_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50782_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM1_4, 3)
local ret = m:GetNum(m.curPage * 25 + 3)
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
FORM_BAG.C50781_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 4
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50781_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50781_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50781_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM1_5, 4)
local ret = m:GetNum(m.curPage * 25 + 4)
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
FORM_BAG.C50783_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 5
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50783_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50783_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50783_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM2_1, 5)
local ret = m:GetNum(m.curPage * 25 + 5)
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
FORM_BAG.C50787_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 6
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50787_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50787_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50787_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM2_2, 6)
local ret = m:GetNum(m.curPage * 25 + 6)
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
FORM_BAG.C50788_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 7
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50788_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50788_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50788_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM2_3, 7)
local ret = m:GetNum(m.curPage * 25 + 7)
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
FORM_BAG.C50789_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 8
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50789_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50789_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50789_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM2_4, 8)
local ret = m:GetNum(m.curPage * 25 + 8)
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
FORM_BAG.C50790_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 9
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50790_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50790_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50790_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM2_5, 9)
local ret = m:GetNum(m.curPage * 25 + 9)
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
FORM_BAG.C50784_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 10
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50784_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50784_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50784_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM3_1, 10)
local ret = m:GetNum(m.curPage * 25 + 10)
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
FORM_BAG.C50791_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 11
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50791_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50791_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50791_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM3_2, 11)
local ret = m:GetNum(m.curPage * 25 + 11)
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
FORM_BAG.C50792_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 12
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50792_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50792_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50792_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM3_3, 12)
local ret = m:GetNum(m.curPage * 25 + 12)
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
FORM_BAG.C50793_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 13
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50793_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50793_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50793_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM3_4, 13)
local ret = m:GetNum(m.curPage * 25 + 13)
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
FORM_BAG.C50794_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 14
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50794_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50794_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50794_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM3_5, 14)
local ret = m:GetNum(m.curPage * 25 + 14)
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
FORM_BAG.C50785_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 15
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50785_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50785_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50785_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM4_1, 15)
local ret = m:GetNum(m.curPage * 25 + 15)
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
FORM_BAG.C50795_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 16
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50795_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50795_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50795_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM4_2, 16)
local ret = m:GetNum(m.curPage * 25 + 16)
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
FORM_BAG.C50796_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 17
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50796_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50796_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50796_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM4_3, 17)
local ret = m:GetNum(m.curPage * 25 + 17)
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
FORM_BAG.C50797_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 18
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50797_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50797_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50797_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM4_4, 18)
local ret = m:GetNum(m.curPage * 25 + 18)
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
FORM_BAG.C50799_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 19
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50799_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50799_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50799_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM4_5, 19)
local ret = m:GetNum(m.curPage * 25 + 19)
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
FORM_BAG.C50786_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 20
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50786_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50786_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50786_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM5_1, 20)
local ret = m:GetNum(m.curPage * 25 + 20)
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
FORM_BAG.C50800_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 21
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50800_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50800_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50800_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM5_2, 21)
local ret = m:GetNum(m.curPage * 25 + 21)
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
FORM_BAG.C50801_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 22
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50801_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50801_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50801_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM5_3, 22)
local ret = m:GetNum(m.curPage * 25 + 22)
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
FORM_BAG.C50802_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 23
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50802_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50802_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50802_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM5_4, 23)
local ret = m:GetNum(m.curPage * 25 + 23)
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
FORM_BAG.C50804_OnFocus = function( m )
m.userSelectItem = m.curPage * 25 + 24
m:SelectItem(m.userSelectItem)
end
FORM_BAG.C50804_OnClick = function( m )
ClickGrid(m)
end
FORM_BAG.C50804_OnDrag = function( m )
OnDragShortCut(m,m.userSelectItem)
end
FORM_BAG.C50804_OnUpdate = function( m )
DrawIcon(m, COMPOSIT_BAG_ITEM5_5, 24)
local ret = m:GetNum(m.curPage * 25 + 24)
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
FORM_BAG.C50806_OnClick = function( m )
if m:GetTabNum() ~= m.curPage then
	m.curPage = m.curPage  + 1
	m:SetArrow(m.curPage)
	RefreshBag( m )
end
end
FORM_BAG.C52397_OnLoad = function( m )
if m.curPage ~= 0 then
	m.curPage = m.curPage - 1
	SetPageMode(m)
	RefreshBag( m )
end
end
FORM_BAG.C52397_OnClick = function( m )
if m.curPage ~= 0 then
	m.curPage = m.curPage - 1
	m:SetArrow(m.curPage)
	RefreshBag( m )
end
end
FORM_BAG.C50774_OnClick = function( m )
m:ChangeTab(PackageTab.BAG_TAB_EQUIP)
m.expand = 0
DrawCap(m)
UI_Engine.SetText(m.formIndex, COMPOSIT_773, "装备")
UI_Engine.UpdateList(m.formIndex, COMPOSIT_BAG_ITEM1_1)
ClickGrid(m)
m.curPage = 0
m.pageNum = m:GetTabNum()
DBGPRINTF("change tab:m.pageNum is"..m.pageNum)
SetPageMode(m)
RefreshBag( m )
if 0 == m.mode then
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2400, false)
elseif 2 == m.mode then
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2337, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2093, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2400, true)	
else
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2337, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2093, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2400, false)
end
SetMenuByMode(m)
end
FORM_BAG.C50775_OnClick = function( m )
m:ChangeTab(PackageTab.BAG_TAB_CONSUME)
m.expand = 1
DrawCap(m)
UI_Engine.SetText(m.formIndex, COMPOSIT_773, "使用")
UI_Engine.UpdateList(m.formIndex, COMPOSIT_BAG_ITEM1_1)
ClickGrid(m)
m.curPage = 0
m.pageNum = m:GetTabNum()
DBGPRINTF("change tab:m.pageNum is"..m.pageNum)
SetPageMode(m)
RefreshBag( m )
if 0 == m.mode then
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2400, false)
elseif 2 == m.mode then
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2337, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2093, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2400, true)	
else
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2337, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2093, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2400, false)
end
SetMenuByMode(m)
end
FORM_BAG.C50776_OnClick = function( m )
m:ChangeTab(PackageTab.BAG_TAB_NORMAL)
m.expand = 2
DrawCap(m)
UI_Engine.SetText(m.formIndex, COMPOSIT_773, "使用")
UI_Engine.UpdateList(m.formIndex, COMPOSIT_BAG_ITEM1_1)
ClickGrid(m)
m.curPage = 0
m.pageNum = m:GetTabNum()
DBGPRINTF("change tab:m.pageNum is"..m.pageNum)
SetPageMode(m)
RefreshBag( m )
if 0 == m.mode then
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2400, false)
elseif 2 == m.mode then
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2337, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2093, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2400, true)	
else
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2337, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2093, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2400, false)
end
SetMenuByMode(m)
end
FORM_BAG.C50777_OnClick = function( m )
m:ChangeTab(PackageTab.BAG_TAB_TASK )
m.expand = 3
DrawCap(m)
UI_Engine.SetText(m.formIndex, COMPOSIT_773, "使用")
UI_Engine.UpdateList(m.formIndex, COMPOSIT_BAG_ITEM1_1)
ClickGrid(m)
m.curPage = 0
m.pageNum = m:GetTabNum()
DBGPRINTF("change tab:m.pageNum is"..m.pageNum)
SetPageMode(m)
RefreshBag( m )
if 0 == m.mode then
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2400, false)
elseif 2 == m.mode then
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2337, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2093, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2400, true)	
else
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2337, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2093, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2400, false)
end
SetMenuByMode(m)
end
FORM_BAG.C52400_OnClick = function( m )
m.NumSel = NewNumSel(m, "Select Number", m.money, 1, m.money)
m.NumSel:WaitUserInput(m)
local ret = m.NumSel:GetResult()
DelNumSel(m.NumSel)
m:luaSaveMoney(ret)
SetMoney(m)
end
FORM_BAG.C52793_OnClick = function( m )
local ret = m:SetAutoBtn()
if nil ~= ret then
	local szTitle, szDef = m:GetAutoString(ret)
	m.input = NewInputBox(m, szTitle, 0, szDef, 100)
	m.input:WaitUserInput(m)
	local num = m.input:GetInput()
	DelInputBox(m.input)
	m:SetAutoIni(ret, num)
end
	
end
FORM_BAG.C52093_OnClick = function( m )
m:OnExpand(m.expand)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_BAG_ITEM1_1)
end
FORM_BAG.C52337_OnClick = function( m )
if MsgBox.ECODE_YES == QueryUser(m, "确定销毁物品吗?") then
	OnDestroy(m)
	UI_Engine.UpdateList(m.formIndex, COMPOSIT_BAG_ITEM1_1)
end
end
FORM_BAG.C52336_OnClick = function( m )
local name, ptr = m:GetInfoPtr()
if nil == ptr then
	return false
else
	m.info = NewInfo(m, name, ptr)
	return true
end
end
FORM_BAG.C50773_OnClick = function( m )
UseItem(m)
end
FORM_BAG.C52696_OnLoad = function( m )
m.expand = 0
m.curPage = 0
UI_Engine.SetText(m.formIndex, COMPOSIT_773, "装备")
UpdateIcon(m)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_BAG_ITEM1_1)
DrawCap(m)
m.pageNum = m:GetTabNum()
DBGPRINTF("change tab:m.pageNum is"..m.pageNum)
SetPageMode(m)
RefreshBag(m)
SetMoney(m)
m.mode = m:GetOpenMode()
if 0 == m.mode then
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2400, false)
elseif 2 == m.mode then
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2337, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2093, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2400, true)	
else
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2337, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2093, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2400, false)
end
end
FORM_BAG.C52696_OnClick = function( m )
m:SaveShortCutData()
m:InputFinished()
m:Close()
end
FORM_BAG.C50771_OnLoad = function( m )
m:ChangeGridNum(25)
end
FORM_BAG.C52784_OnLoad = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2793, false)
SetMenuByMode(m)
end
