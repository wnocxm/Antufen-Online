NEW_FORM_STORER= { }
NEW_FORM_STORER.Main = function( m )
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

local WarnUser = function(m, str)             --单项对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_CANCEL)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local ClearState = function(m)
	for i = 0, 19 do
		local id = UI1_COMPOSIT_36 - i
		UI_Engine.SetState(m.formIndex,id,0)
	end
end

local UpDateMenu = function(m)
	local name,name1,name2,name3,name4,name5 = m:GetMenu()
	if name ~= nil then
		UI_Engine.SetVisible(m.formIndex,UI1_COMPOSIT_13,true)
		UI_Engine.SetText(m.formIndex,UI1_COMPOSIT_13,name)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_MENUBUTTON_BACK, true)
	else
		UI_Engine.SetVisible(m.formIndex,UI1_COMPOSIT_13,false)
	end
	
	if name1 ~= nil then
		UI_Engine.SetVisible(m.formIndex,UI1_COMPOSIT_12,true)
		UI_Engine.SetText(m.formIndex,UI1_COMPOSIT_12,name1)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_MENUBUTTON_BACK, true)
	else
		UI_Engine.SetVisible(m.formIndex,UI1_COMPOSIT_12,false)
	end
	
	if name2 ~= nil then
		UI_Engine.SetVisible(m.formIndex,UI1_COMPOSIT_11,true)
		UI_Engine.SetText(m.formIndex,UI1_COMPOSIT_11,name2)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_MENUBUTTON_BACK, true)
	else
		UI_Engine.SetVisible(m.formIndex,UI1_COMPOSIT_11,false)
	end
	
	if name3 == nil then
		UI_Engine.SetVisible(m.formIndex,UI1_COMPOSIT_10,false)
	else
		UI_Engine.SetVisible(m.formIndex,UI1_COMPOSIT_10,true)
		UI_Engine.SetText(m.formIndex,UI1_COMPOSIT_10,name3)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_MENUBUTTON_BACK, true)
	end
	
	if name4 == nil then
		UI_Engine.SetVisible(m.formIndex,UI1_COMPOSIT_9,false)
	else
		UI_Engine.SetVisible(m.formIndex,UI1_COMPOSIT_9,true)
		UI_Engine.SetText(m.formIndex,UI1_COMPOSIT_9,name4)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_MENUBUTTON_BACK, true)
	end
	
	if name5 == nil then
		UI_Engine.SetVisible(m.formIndex,UI1_COMPOSIT_8,false)
	else
		UI_Engine.SetVisible(m.formIndex,UI1_COMPOSIT_8,true)
		UI_Engine.SetText(m.formIndex,UI1_COMPOSIT_8,name5)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_MENUBUTTON_BACK, true)
	end
	UI_Engine.SetVisible(m.formIndex,UI1_COMPOSIT_MENUBUTTON_1,false)
end


local UpDateDescribe = function(m , nIndex)
	local bValidity = m:IsIndexValidity(nIndex)
	local strDescribe = m:GetDescribe(nIndex)
	if strDescribe == nil then
		UI_Engine.SetText(m.formIndex,UI1_COMPOSIT_DESCRIBE,"")
	else
		UI_Engine.SetText(m.formIndex,UI1_COMPOSIT_DESCRIBE,strDescribe)
	end
	
	UpDateMenu(m)
end

local UpDatePageButton = function(m)
	m:UpdateSelectPageButton()
end

local UpDateMoney = function(m)
	local strMoney = m:GetMoney()
	if strMoney == nil then
		UI_Engine.SetText(m.formIndex,UI1_COMPOSIT_MONEY_COUNT,"0")
	else
		UI_Engine.SetText(m.formIndex,UI1_COMPOSIT_MONEY_COUNT,strMoney)
	end
end

local UpDateCapacity = function(m )
	local strCapacity = m:GetCapacity()
	if strCapacity == nil then
		UI_Engine.SetText(m.formIndex,UI1_COMPOSIT_ITEM_COUNT,"")
	else
		UI_Engine.SetText(m.formIndex,UI1_COMPOSIT_ITEM_COUNT,strCapacity )
	end
end

local SetTabListText = function(m,nIndex,composit)
	local img ,nSN= m:GetItem(nIndex)
	if img == nil then
		UI_Engine.SetClientEmpty( m.formIndex, composit )
	else
		UI_Engine.SetSurfaceImg( m.formIndex, composit, img, 0, 0, false,  nSN )
	end

end

local HideMenu = function(m, mode)
	local reverse = false
	if mode == true then
		reverse = false
	else
		reverse = true
	end
	UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_DESCRIBE, mode)
	UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_BUTTON_DILATATION, reverse)
	UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_ITEM_COUNT, reverse)
	UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_MONEY_ICON, reverse)
	UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_MONEY_COUNT, reverse)
end

local UpDate = function(m)
	UI_Engine.UpdateList(m.formIndex ,UI1_COMPOSIT_36)
	UpDateDescribe(m,-1)
	UpDateMoney(m)
	UpDateCapacity(m)
	UpDateMenu(m)
	for i = 0, 19 do
		local id = UI1_COMPOSIT_36 - i
		SetTabListText( m, i, id)
	end
	HideMenu(m,false)
	UpDatePageButton(m)
end

local WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_CANCEL)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
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
					m.Pack:luaSaveToStore(1)
				else
					m.NumSel = NewNumSel(m, STR_COMBINE_NUMBER, itemCount, 1, itemCount)
					m.NumSel:WaitUserInput(m)
					local ret = m.NumSel:GetResult()
					DelNumSel(m.NumSel)
					m.Pack:luaSaveToStore(ret)
				end
			elseif nNum ~= 0 then
				m.NumSel = NewNumSel(m, STR_COMBINE_NUMBER, nNum, 1, nNum)
				m.NumSel:WaitUserInput(m)
				local ret = m.NumSel:GetResult()
				DelNumSel(m.NumSel)
				m.Pack:luaSaveToStore(ret)
			end
		end
		DelSelectBag(m.Pack)
		m:SendQueryStoreMsg(1,"")
		ClearState(m)
		UpDate(m)
end

local ClickMenu = function(m,nType)
	if nType == nil then
		return 
	end
	if nType == 0 then  --取物
		local nNum = m:GetItemNum(m.userSelectItem)
		if nNum == 0 then
			return 
		end

		if nNum == nil then
		return 
		end

		if nNum > 1 then
			m.numSel = NewNumSel(m, STR_COMBINE_NUMBER , 1, 1  , nNum )
			m.numSel :WaitUserInput(m)
			local num = m.numSel:GetResult(m)
			DelNumSel(m.numSel)

			m:SendTakeItemMsg(m.userSelectItem,num)
			if num == nNum then
				ClearState(m)
				UpDate(m)
			else
				UpDateDescribe(m,m.userSelectItem)
			end
		else
			m:SendTakeItemMsg(m.userSelectItem, nNum)
			ClearState(m)
			UpDate(m)
		end

	elseif nType == 1 then --取钱
		local nMoney = m:GetMoneyNum()
		--m.numSel = NewNumSel(m, STR_COMBINE_NUMBER , nMoney , 0 , 0 )
		--m.numSel :WaitUserInput(m)
		--local num = m.numSel:GetResult(m)
		--DelNumSel(m.numSel)
		--m:SendTakeMoneyMsg(num)
		--UpDate(m)


			m.InputBox = NewInputBox(m,STR_INPUT_MONEY_PRMOPT , 1,"0",10)
			m.InputBox:WaitUserInput(m)
			local num = m.InputBox:GetInput()
			local exit = m.InputBox:ExitType()
			DelInputBox(m.InputBox)
			
			if exit == 0 then
				return 
			end
			--if num > nMoney then
			--	return 
			--end

			m:SendTakeMoneyMsg(num)
			ClearState(m)
			UpDate(m)
	elseif nType == 2 then  --删除物品
		local nNum = m:GetItemNum(m.userSelectItem)
		if nNum == nil then
		return 
		end

		if nNum == 0 then
		return 
		end

		if QueryUser(m,STR_PACKAGE_DESTROY)  == false then
			return 
		end

		if nNum > 1 then
			m.numSel = NewNumSel(m, STR_COMBINE_NUMBER , 1, 1 , nNum )
			m.numSel :WaitUserInput(m)
			local num = m.numSel:GetResult(m)
			DelNumSel(m.numSel)
			m:SendDestroyItemMsg(m.userSelectItem,num)
			if num == nNum then
				ClearState(m)
				UpDate(m)
			else
				UpDateDescribe(m,m.userSelectItem)
			end
		else
			m:SendDestroyItemMsg(m.userSelectItem,nNum)
			ClearState(m)
			UpDate(m)
		end

		
	elseif nType == 4 then   --物品信息
		local name , vInfo = m:GetMakeInfo(m.userSelectItem)
		if name == nil then
		return 
		end

		if vInfo == nil then
		return 
		end

		m.info = NewInfo(m,name,vInfo )
		m.info:WaitUserInput(m)
		DelInfo(m.info)
	elseif nType == 5 then -- 存钱
		--local moneyNum = m:luaGetHaveMoney()
		--m.NumSel = NewNumSel(m, STR_INPUT_MONEY_PRMOPT, moneyNum, 1, moneyNum)
		--m.NumSel:WaitUserInput(m)
		--local ret = m.NumSel:GetResult()
		--DelNumSel(m.NumSel)

		m.InputBox = NewInputBox(m,STR_INPUT_MONEY_PRMOPT , 1,"0",10)
		m.InputBox:WaitUserInput(m)
		local num = m.InputBox:GetInput()
		local exit = m.InputBox:ExitType()
		DelInputBox(m.InputBox)
			
		if exit == 0 then
			return 
		end

		m:luaSaveMoney(num)
		UpDate(m)
		HideMenu(m, false)
		ClearState(m)
	elseif nType == 6 then --存入
		OpenSelectPack(m)
	end
end

local ClickGrid = function(m, i)
	local bValidity = m:IsIndexValidity(i)

	if bValidity ~= 0 then
		HideMenu(m, true)
	else
		HideMenu(m, false)
		ClearState(m)
	end
	UpDateDescribe(m,m.userSelectItem)

	if bValidity == 0 then 
		OpenSelectPack(m)
	end
	
end
NEW_FORM_STORER.C50016_OnLoad = function( m )
m.bShow  = false
m:SetTab(StoreTab.TAB_ALL)
m:SetSel(0)
m:SetPage(-1)
m:SetGridNum(20)

--是否有密码
if m:IsNeedPwd() then
	m.InputBox = NewInputBox(m,STR_PLEASE_INPUT_PWD , 1,"",12)
	m.InputBox:WaitUserInput(m)
	local pwd = m.InputBox:GetInput()
	local exit = m.InputBox:ExitType()
	DelInputBox(m.InputBox)
	
	if exit == 0 then
		m:Close(m.formIndex)
		m:InputFinished()
		return 
	end
	
	m:SendQueryStoreMsg(0,pwd)
	m:SetStrInput(pwd)
	m:WaitUserInput(m)
	
	local query = m:GetQuery(pwd)
	
	if query == 1 then
		--成功进入仓库
	UpDate(m)
	else
		--密码错误
		WarnUser(m,STR_PWD_ERROR)
		m:Close(m.formIndex)
		m:InputFinished()

		return 
	end


else
	m:SendQueryStoreMsg(-1, "")
	--m:SetStrInput(pwd)
	m:WaitUserInput(m)
	
	local query = m:GetQuery(pwd)
	
	if query == 1 then
		--成功进入仓库

	else
		--密码错误
		WarnUser(m,STR_PWD_ERROR)
		m:Close(m.formIndex)
		m:InputFinished()

		return 
	end
end

UpDate(m)
end
NEW_FORM_STORER.C50016_OnClick = function( m )
m:Close(m.formIndex)
m:InputFinished()
end
NEW_FORM_STORER.C50052_OnClick = function( m )
local vTab = m:GetTabList()
m.Popup = NewPopUpForm(m, vTab)
m.Popup :WaitUserInput(m)
local nSelect = m.Popup:GetResult()
DelPopUpForm(m.Popup )
m:SetTabTitle(nSelect )
if nSelect == StoreTab.TAB_ALL then

m:SetTab(StoreTab.TAB_ALL)
m:SetSel(-1)
m.userSelectItem = -1
m:SetPage(-1)
UpDate(m)

elseif nSelect == StoreTab.TAB_EQUIP then 

m:SetTab(StoreTab.TAB_EQUIP)
m:SetSel(-1)
m.userSelectItem = -1
m:SetPage(-1)
UpDate(m)

elseif nSelect == StoreTab.TAB_CONSUME then

m:SetTab(StoreTab.TAB_CONSUME)
m:SetSel(-1)
m.userSelectItem = -1
m:SetPage(-1)
UpDate(m)

elseif nSelect == StoreTab.TAB_NORMAL then

m:SetTab(StoreTab.TAB_NORMAL)
m:SetSel(-1)
m.userSelectItem = -1
m:SetPage(-1)
UpDate(m)

end
end
NEW_FORM_STORER.C50042_OnClick = function( m )
m:OnExpand()
end
NEW_FORM_STORER.C50038_OnClick = function( m )
 m:SetPage(1)
ClearState(m)
UpDate(m)
end
NEW_FORM_STORER.C50037_OnClick = function( m )
 m:SetPage(0)
ClearState(m)
UpDate(m)
end
NEW_FORM_STORER.C50013_OnClick = function( m )
local nType = m:DoMenu(0)
ClickMenu(m,nType)
end
NEW_FORM_STORER.C50012_OnClick = function( m )
local nType = m:DoMenu(1)
ClickMenu(m,nType)
end
NEW_FORM_STORER.C50011_OnClick = function( m )
local nType = m:DoMenu(2)
ClickMenu(m,nType)
end
NEW_FORM_STORER.C50010_OnClick = function( m )
local nType = m:DoMenu(3)
ClickMenu(m,nType)
end
NEW_FORM_STORER.C50009_OnClick = function( m )
local nType = m:DoMenu(4)
ClickMenu(m,nType)
end
NEW_FORM_STORER.C50008_OnClick = function( m )
local nType = m:DoMenu(5)
ClickMenu(m,nType)
end
NEW_FORM_STORER.C50007_OnClick = function( m )
local nType = m:DoMenu(6)
ClickMenu(m,nType)
end
NEW_FORM_STORER.C50036_OnClick = function( m )
m.userSelectItem = 0
ClickGrid(m, 0)

end
NEW_FORM_STORER.C50036_OnUpdate = function( m )
SetTabListText(m,0,UI1_COMPOSIT_36)

local num = m:GetItemNum(0)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50035_OnClick = function( m )
m.userSelectItem = 1
ClickGrid(m, 1)

end
NEW_FORM_STORER.C50035_OnUpdate = function( m )
	SetTabListText(m,1,UI1_COMPOSIT_35)
local num = m:GetItemNum(1)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50034_OnClick = function( m )
m.userSelectItem = 2
ClickGrid(m, 2)

end
NEW_FORM_STORER.C50034_OnUpdate = function( m )
	SetTabListText(m,2,UI1_COMPOSIT_34)
local num = m:GetItemNum(2)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50033_OnClick = function( m )
m.userSelectItem = 3
ClickGrid(m, 3)

end
NEW_FORM_STORER.C50033_OnUpdate = function( m )
	SetTabListText(m,3,UI1_COMPOSIT_33)
local num = m:GetItemNum(3)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50032_OnClick = function( m )
m.userSelectItem = 4
ClickGrid(m, 4)

end
NEW_FORM_STORER.C50032_OnUpdate = function( m )
	SetTabListText(m,4,UI1_COMPOSIT_32)
local num = m:GetItemNum(4)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50031_OnClick = function( m )
m.userSelectItem = 5
ClickGrid(m, 5)
end
NEW_FORM_STORER.C50031_OnUpdate = function( m )
	SetTabListText(m,5,UI1_COMPOSIT_31)
local num = m:GetItemNum(5)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50030_OnClick = function( m )
m.userSelectItem = 6
ClickGrid(m, 6)

end
NEW_FORM_STORER.C50030_OnUpdate = function( m )
	SetTabListText(m,6,UI1_COMPOSIT_30)
local num = m:GetItemNum(6)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50029_OnClick = function( m )
m.userSelectItem = 7
ClickGrid(m, 7)

end
NEW_FORM_STORER.C50029_OnUpdate = function( m )
	SetTabListText(m,7,UI1_COMPOSIT_29)
local num = m:GetItemNum(7)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50028_OnClick = function( m )
m.userSelectItem = 8
ClickGrid(m, 8)

end
NEW_FORM_STORER.C50028_OnUpdate = function( m )
	SetTabListText(m,8,UI1_COMPOSIT_28)
local num = m:GetItemNum(8)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50027_OnClick = function( m )
m.userSelectItem = 9
ClickGrid(m, 9)

end
NEW_FORM_STORER.C50027_OnUpdate = function( m )
	SetTabListText(m,9,UI1_COMPOSIT_27)
local num = m:GetItemNum(9)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50026_OnClick = function( m )
m.userSelectItem = 10
ClickGrid(m, 10)

end
NEW_FORM_STORER.C50026_OnUpdate = function( m )
	SetTabListText(m,10,UI1_COMPOSIT_26)
local num = m:GetItemNum(10)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50025_OnClick = function( m )
m.userSelectItem = 11
ClickGrid(m, 11)

end
NEW_FORM_STORER.C50025_OnUpdate = function( m )
	SetTabListText(m,11,UI1_COMPOSIT_25)
local num = m:GetItemNum(11)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50024_OnClick = function( m )
m.userSelectItem = 12
ClickGrid(m, 12)

end
NEW_FORM_STORER.C50024_OnUpdate = function( m )
	SetTabListText(m,12,UI1_COMPOSIT_24)
local num = m:GetItemNum(12)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50023_OnClick = function( m )
m.userSelectItem = 13
ClickGrid(m, 13)

end
NEW_FORM_STORER.C50023_OnUpdate = function( m )
	SetTabListText(m,13,UI1_COMPOSIT_23)
local num = m:GetItemNum(13)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50022_OnClick = function( m )
m.userSelectItem = 14
ClickGrid(m, 14)

end
NEW_FORM_STORER.C50022_OnUpdate = function( m )
	SetTabListText(m,14,UI1_COMPOSIT_22)
local num = m:GetItemNum(14)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50021_OnClick = function( m )
m.userSelectItem = 15
ClickGrid(m, 15)

end
NEW_FORM_STORER.C50021_OnUpdate = function( m )
	SetTabListText(m,15,UI1_COMPOSIT_21)
local num = m:GetItemNum(15)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50020_OnClick = function( m )
m.userSelectItem = 16
ClickGrid(m, 16)

end
NEW_FORM_STORER.C50020_OnUpdate = function( m )
	SetTabListText(m,16,UI1_COMPOSIT_20)
local num = m:GetItemNum(16)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50019_OnClick = function( m )
m.userSelectItem = 17
ClickGrid(m, 17)

end
NEW_FORM_STORER.C50019_OnUpdate = function( m )
	SetTabListText(m,17,UI1_COMPOSIT_19)
local num = m:GetItemNum(17)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50018_OnClick = function( m )
m.userSelectItem = 18
ClickGrid(m, 18)

end
NEW_FORM_STORER.C50018_OnUpdate = function( m )
	SetTabListText(m,18,UI1_COMPOSIT_18)
local num = m:GetItemNum(18)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50017_OnClick = function( m )
m.userSelectItem = 19
ClickGrid(m, 19)

end
NEW_FORM_STORER.C50017_OnUpdate = function( m )
SetTabListText(m,19,UI1_COMPOSIT_17)
local num = m:GetItemNum(19)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
NEW_FORM_STORER.C50053_OnClick = function( m )
--HideMenu(m, false)
end
