NEW_FORM_SELBAG= { }
NEW_FORM_SELBAG.Main = function( m )
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
NEW_FORM_SELBAG.C50072_OnLoad = function( m )
m.describe = true
m.curPage = 0
m.pageNum = 0
m.mode = 0
m.money = 0
m.szMoney = ""
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

local QuerySelect = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_SELECT)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local DrawCap = function(m)
	local cap = m:DrawTabNum()
	UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_325, cap)
end

local ClickGrid = function(m, i)
	m.describe = true
	UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_57)
	m.userSelectItem = m:GetPage() * 16 + i
	m:SelectItem(m.userSelectItem)
	--m:OnClickGrid()
	local b = m:GetEquipMode()
	if m:IsValidClick(m.userSelectItem) then
		local str = m:GetDescribe()
		if MsgBox.ECODE_YES == QuerySelect(m, str) then
			if MsgBox.ECODE_YES == QueryUser(m, STR_CONFIRM_ITEM) then
				if b == true then
					m:TakeOn()
					m:SetEquipMode(false)
					m:SetExitCode(1)
					m:InputFinished()
					m:FormCloseEvt()
				else
					m:UserSelect(true)
					m:SetExitCode(1)
					m:InputFinished()
					m:FormCloseEvt()
				end
				return
			end
			m:UserSelect(false)
		end
		m:UserSelect(false)
	end
end

local UpdateItem = function ( m, control )
	local img, nSN  = m:OnUpdateItem( m.ItemCount )
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

local RefreshBag = function ( m )
	m:UpdateItemList()
	m.ItemCount = 0
	for i = 0, 16 do
		local id = UI2_COMPOSIT_56 + i
		UpdateItem( m, id)
	end
end

local SetPageMode = function(m)
	if m.curPage == 0 then
		DBGPRINTF("left false")
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_53, false)
	else
		DBGPRINTF("left true")
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_53, true)
	end

	if m.pageNum > m.curPage then
		DBGPRINTF("r true")
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_54, true)
	else
		DBGPRINTF("r false")
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_54, false)
	end
end

local DrawIcon = function(m, nID, nIndex)
	local img,nSN  = m:OnUpdateItem( nIndex )
	if img ~= nil then
		UI_Engine.SetVisible( m.formIndex, nID, true )
		UI_Engine.SetSurfaceImg( m.formIndex, nID, img, 0, 0, false,  nSN)
	else
		UI_Engine.SetVisible( m.formIndex, nID, false )
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
			UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_52, str)
		end
		DelSingleList(m.list)
		UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_70)
	end
end
NEW_FORM_SELBAG.C50071_OnClick = function( m )
ClickGrid(m, 15)
end
NEW_FORM_SELBAG.C50071_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_71, 15)
local ret = m:GetNum(m:GetPage() * 16 + 15)
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
NEW_FORM_SELBAG.C50070_OnClick = function( m )
ClickGrid(m, 14)
end
NEW_FORM_SELBAG.C50070_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_70, 14)
local ret = m:GetNum(m:GetPage() * 16 + 14)
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
NEW_FORM_SELBAG.C50069_OnClick = function( m )
ClickGrid(m, 13)
end
NEW_FORM_SELBAG.C50069_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_69, 13)
local ret = m:GetNum(m:GetPage() * 16 + 13)
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
NEW_FORM_SELBAG.C50068_OnClick = function( m )
ClickGrid(m, 12)
end
NEW_FORM_SELBAG.C50068_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_68, 12)
local ret = m:GetNum(m:GetPage() * 16 + 12)
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
NEW_FORM_SELBAG.C50067_OnClick = function( m )
ClickGrid(m, 11)
end
NEW_FORM_SELBAG.C50067_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_67, 11)
local ret = m:GetNum(m:GetPage() * 16 + 11)
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
NEW_FORM_SELBAG.C50066_OnClick = function( m )
ClickGrid(m, 10)
end
NEW_FORM_SELBAG.C50066_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_66, 10)
local ret = m:GetNum(m:GetPage() * 16 + 10)
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
NEW_FORM_SELBAG.C50065_OnClick = function( m )
ClickGrid(m, 9)
end
NEW_FORM_SELBAG.C50065_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_65, 9)
local ret = m:GetNum(m:GetPage() * 16 + 9)
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
NEW_FORM_SELBAG.C50064_OnClick = function( m )
ClickGrid(m, 8)
end
NEW_FORM_SELBAG.C50064_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_64, 8)
local ret = m:GetNum(m:GetPage() * 16 + 8)
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
NEW_FORM_SELBAG.C50063_OnClick = function( m )
ClickGrid(m, 7)
end
NEW_FORM_SELBAG.C50063_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_63, 7)
local ret = m:GetNum(m:GetPage() * 16 + 7)
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
NEW_FORM_SELBAG.C50062_OnClick = function( m )
ClickGrid(m, 6)
end
NEW_FORM_SELBAG.C50062_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_62, 6)
local ret = m:GetNum(m:GetPage() * 16 + 6)
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
NEW_FORM_SELBAG.C50061_OnClick = function( m )
ClickGrid(m, 5)
end
NEW_FORM_SELBAG.C50061_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_61, 5)
local ret = m:GetNum(m:GetPage() * 16 + 5)
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
NEW_FORM_SELBAG.C50060_OnClick = function( m )
ClickGrid(m, 4)
end
NEW_FORM_SELBAG.C50060_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_60, 4)
local ret = m:GetNum(m:GetPage()  * 16 + 4)
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
NEW_FORM_SELBAG.C50059_OnClick = function( m )
ClickGrid(m, 3)
end
NEW_FORM_SELBAG.C50059_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_59, 3)
local ret = m:GetNum(m:GetPage() * 16 + 3)
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
NEW_FORM_SELBAG.C50058_OnClick = function( m )
ClickGrid(m, 2)
end
NEW_FORM_SELBAG.C50058_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_58, 2)
local ret = m:GetNum(m:GetPage() * 16 + 2)
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
NEW_FORM_SELBAG.C50057_OnClick = function( m )
ClickGrid(m, 1)
end
NEW_FORM_SELBAG.C50057_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_57, 1)
local ret = m:GetNum(m:GetPage() * 16 + 1)
if ret == nil then
	CurrentControl.SetItemCount(-1)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
end
RefreshBag( m )
end
NEW_FORM_SELBAG.C50056_OnClick = function( m )
ClickGrid(m, 0)
end
NEW_FORM_SELBAG.C50056_OnUpdate = function( m )
DrawIcon(m, UI2_COMPOSIT_56, 0)
local ret = m:GetNum(m:GetPage() * 16 + 0)
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
NEW_FORM_SELBAG.C50054_OnClick = function( m )
m:OnChangePage(false)
RefreshBag(m)
UI_Engine.UpdateList( m.formIndex, UI2_COMPOSIT_57 )
end
NEW_FORM_SELBAG.C50053_OnClick = function( m )
m:OnChangePage(true)
RefreshBag(m)
UI_Engine.UpdateList( m.formIndex, UI2_COMPOSIT_57 )
end
NEW_FORM_SELBAG.C50052_OnClick = function( m )
BtnClick(m)
end
NEW_FORM_SELBAG.C50051_OnClick = function( m )
m:SetExitCode(0)
m:InputFinished()
m:Close()
m:FormCloseEvt()
end
NEW_FORM_SELBAG.C50050_OnLoad = function( m )
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_57)
end
