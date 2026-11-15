FORM_FANTASIZE_PET= { }
FORM_FANTASIZE_PET.Main = function( m )
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
FORM_FANTASIZE_PET.C50886_OnLoad = function( m )
m.nTab = 1
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

local OpenPack = function(m)
	local ptr = m:GetItemPointer()
	m.package = NewPackage(m,PackageMode.MODE_SELECT, ptr)
	if nil == m.package then
		local ret = QueryUser(m, "缺少辅助道具，是否进入商城购买")
		if ret == MsgBox.ECODE_YES then
			local cash = m:GetCashPointer()
			NewCashShop(m, cash, 0)
		end
	else 
		m.package:WaitUserInput(m)
		local vSelect = m.package:GetSelectItem()
		local nSN, num = m.package:GetSelectSimpleItem(m)
		DelPackage(m.package)
		m:SetItem(nSN, num)
	end
	m:SetBtn()
end
local InitText = function(m)
	UI_Engine.SetText(m.formIndex, COMPOSIT_STUFF_PET_NAME, "副魔法兽")
	UI_Engine.SetText(m.formIndex, COMPOSIT_MAIN_PET_NAME, "主魔法兽")
	UI_Engine.SetText(m.formIndex, COMPOSIT_PET_ITEM_NAME, "启动材料")
	UI_Engine.SetText(m.formIndex, COMPOSIT_2043, "辅助道具")
	UI_Engine.SetText(m.formIndex, COMPOSIT_2042, "0/0")
	if 1 == m.nTab then
		UI_Engine.SetText(m.formIndex, COMPOSIT_907, "幻化")
		UI_Engine.SetText(m.formIndex, COMPOSIT_2399, "开始幻化")
	elseif 2 == m.nTab then
		UI_Engine.SetText(m.formIndex, COMPOSIT_907, "技能转移")
		UI_Engine.SetText(m.formIndex, COMPOSIT_2399, "开始转移")
	end
end

local OnSel = function(m)
	if 0 == m.nSel then
		m:GetUserSel(m.nSel)
		m.petUI = NewPetList(m,0,1,false)
		m.petUI:WaitUserInput(m)
		m.MainPet = m.petUI:GetSelectedPet()
		DelPetList(m.petUI)
		m:OnClickSel(m.MainPet)
		m:GetDrawInfo()
	elseif 1 == m.nSel then
		m:GetUserSel(m.nSel)
		m.petUI = NewPetList(m,0,1,false)
		m.petUI:WaitUserInput(m)
		m.StuffPet = m.petUI:GetSelectedPet()
		DelPetList(m.petUI)
		m:OnClickSel(m.StuffPet)
		m:GetDrawInfo()
	elseif 2 == m.nSel then
		m:GetUserSel(m.nSel)
		OpenPack(m)
		m:GetDrawInfo()
	end
	m:SetBtn()
end

local InitFormText = function(m)
	m.mode = m:GetOpenMode()
	if true == m.mode then
		UI_Engine.SetState(m.formIndex, COMPOSIT_897, 1)
		UI_Engine.SetState(m.formIndex, COMPOSIT_898, 0)
		UI_Engine.SetFormTab(m.formIndex, 0)
		UI_Engine.SetText(m.formIndex, COMPOSIT_907, "幻化")
		UI_Engine.SetText(m.formIndex, COMPOSIT_2399, "开始幻化")
	else
		UI_Engine.SetState(m.formIndex, COMPOSIT_897, 0)
		UI_Engine.SetState(m.formIndex, COMPOSIT_898, 1)
		UI_Engine.SetFormTab(m.formIndex, 1)
		UI_Engine.SetText(m.formIndex, COMPOSIT_907, "技能转移")
		UI_Engine.SetText(m.formIndex, COMPOSIT_2399, "开始转移")
	end
end

local IsCanFantasize = function(m)
	local main = UI_Engine.GetText(m.formIndex, COMPOSIT_MAIN_PET_NAME)
	local stuff = UI_Engine.GetText(m.formIndex, COMPOSIT_STUFF_PET_NAME)
	local item = UI_Engine.GetText(m.formIndex, COMPOSIT_2043)

	if main == "主魔法兽" then
		WarnUser(m, "缺少主魔法兽!")
		return false
	elseif stuff == "副魔法兽" then
		WarnUser(m, "缺少副魔法兽!")
		return false
	elseif item == "辅助道具" then
		WarnUser(m, "缺少辅助道具!")
		return false
	end
	return true
end

local MakeMenu = function(m, index)
	local bExsit = m:IsItemExsit(index)
	local str = m:GetDescribe(index)
	m:GetUserSel(index)
	if 2 == index then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2037, true)
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2037, false)
	end
	if bExsit then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_895, true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2038, true)
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_895, false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2038, false)
	end
	if m:IsItemExsit(0) then
		if m:IsItemExsit(1) then
			if m:IsItemExsit(3) then
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2399, true)
			else
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2399, false)
			end
		else
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_2399, false)
		end
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2399, false)
	end
	UI_Engine.SetText(m.formIndex, COMPOSIT_2786, str, 0)
	m:SetBtn()
end

local InitForm = function(m)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_895, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2038, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2037, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2399, false)
end
	
		
		
FORM_FANTASIZE_PET.C50911_OnDraw = function( m )
m:PlayFrame()
end
FORM_FANTASIZE_PET.C50901_OnClick = function( m )
m.nSel = 0
UI_Engine.SetState(m.formIndex, COMPOSIT_889, 1)
UI_Engine.SetState(m.formIndex, COMPOSIT_890, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_891, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_2035, 0)
MakeMenu(m, m.nSel)
end
FORM_FANTASIZE_PET.C50902_OnClick = function( m )
m.nSel = 1
UI_Engine.SetState(m.formIndex, COMPOSIT_889, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_890, 1)
UI_Engine.SetState(m.formIndex, COMPOSIT_891, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_2035, 0)
MakeMenu(m, m.nSel)
end
FORM_FANTASIZE_PET.C51088_OnClick = function( m )
m.nSel = 3
UI_Engine.SetState(m.formIndex, COMPOSIT_889, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_890, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_891, 1)
UI_Engine.SetState(m.formIndex, COMPOSIT_2035, 0)
MakeMenu(m, m.nSel)
end
FORM_FANTASIZE_PET.C50891_OnClick = function( m )
m.nSel = 3
UI_Engine.SetState(m.formIndex, COMPOSIT_889, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_890, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_891, 1)
UI_Engine.SetState(m.formIndex, COMPOSIT_2035, 0)
MakeMenu(m, m.nSel)
end
FORM_FANTASIZE_PET.C50890_OnClick = function( m )
m.nSel = 1
UI_Engine.SetState(m.formIndex, COMPOSIT_889, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_890, 1)
UI_Engine.SetState(m.formIndex, COMPOSIT_891, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_2035, 0)
MakeMenu(m, m.nSel)
end
FORM_FANTASIZE_PET.C50889_OnClick = function( m )
m.nSel = 0
UI_Engine.SetState(m.formIndex, COMPOSIT_889, 1)
UI_Engine.SetState(m.formIndex, COMPOSIT_890, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_891, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_2035, 0)
MakeMenu(m, m.nSel)
end
FORM_FANTASIZE_PET.C50897_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 0)
m.nTab = 1
--m:SetOpenType(1)
InitText(m)
end
FORM_FANTASIZE_PET.C50898_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 1)
m.nTab = 2
--m:SetOpenType(2)
InitText(m)
end
FORM_FANTASIZE_PET.C50895_OnClick = function( m )
m:GetUserSel(m.nSel)
m:LookDetail()
end
FORM_FANTASIZE_PET.C50894_OnClick = function( m )
OnSel(m)
MakeMenu(m, m.nSel)
m:SetBtn()
end
FORM_FANTASIZE_PET.C52036_OnClick = function( m )
m.nSel = 2
UI_Engine.SetState(m.formIndex, COMPOSIT_889, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_890, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_891, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_2035, 1)
MakeMenu(m, m.nSel)
end
FORM_FANTASIZE_PET.C52035_OnClick = function( m )
m.nSel = 2
UI_Engine.SetState(m.formIndex, COMPOSIT_889, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_890, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_891, 0)
UI_Engine.SetState(m.formIndex, COMPOSIT_2035, 1)
MakeMenu(m, m.nSel)
end
FORM_FANTASIZE_PET.C52399_OnClick = function( m )
if nil ~= m:BeginFantasize(m.nTab) then
	UI_Engine.SetText(m.formIndex, COMPOSIT_STUFF_PET_NAME, "副魔法兽")
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_PET_STUFF, nil)
end
MakeMenu(m, m.nSel)
end
FORM_FANTASIZE_PET.C52038_OnClick = function( m )
m:GetUserSel(m.nSel)
m:UnLoad()
MakeMenu(m, m.nSel)
m:SetBtn()
end
FORM_FANTASIZE_PET.C52037_OnClick = function( m )
local cash = m:GetCashPointer()
NewCashShop(m, cash, 0)
end
FORM_FANTASIZE_PET.C52702_OnClick = function( m )
DBGPRINTF("exit ___Close1____begin")
m:InputFinished()
DBGPRINTF("exit ___Close2____can")
m:Close()
DelFantasize(m)
DBGPRINTF("exit ___Close3____end")
end
FORM_FANTASIZE_PET.C50899_OnLoad = function( m )
local img, name,ret = m:GetRunItem()
if ret then
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_PET_ITEM, img)
else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_PET_ITEM, img,  0, 0,true)
end
UI_Engine.SetText(m.formIndex, COMPOSIT_PET_ITEM_NAME, name)
InitFormText(m)
UI_Engine.SetText(m.formIndex, COMPOSIT_STUFF_PET_NAME, "副魔法兽")
UI_Engine.SetText(m.formIndex, COMPOSIT_MAIN_PET_NAME, "主魔法兽")
UI_Engine.SetText(m.formIndex, COMPOSIT_PET_ITEM_NAME, "启动材料")
UI_Engine.SetText(m.formIndex, COMPOSIT_2043, "辅助道具")
InitForm(m)
end
