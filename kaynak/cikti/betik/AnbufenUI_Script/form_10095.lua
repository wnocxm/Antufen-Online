FORM_NEW_PETLIST= { }
FORM_NEW_PETLIST.Main = function( m )
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
FORM_NEW_PETLIST.C52698_OnClick = function( m )
m:SaveShortCutData()
m:InputFinished()
end
local DrawList = function(m, offset, ctlID)
	local status,img = m:OnUpdateList(offset)
	if status ~= nil then
		UI_Engine.SetSurfaceImg(m.formIndex, ctlID, img)
	else
		UI_Engine.SetSurfaceImg(m.formIndex, ctlID, nil)
	end
end

local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local Init = function(m)
	for i = 0, 20 do
		DrawList(m, i, COMPOSIT_2587 + i)
	end
end

--快捷栏
local UpdateShotrCutItem = function(m,nIndex,control)
	local img = m:GetShortCutIcon(nIndex)
	UI_Engine.SetSurfaceImg( m.formIndex, control, img )
end

local UpdateShotrCut = function(m)
	UpdateShotrCutItem(m,0,COMPOSIT_2611)
	UpdateShotrCutItem(m,1,COMPOSIT_2612)
	UpdateShotrCutItem(m,2,COMPOSIT_2613)
	UpdateShotrCutItem(m,3,COMPOSIT_2614)
	UpdateShotrCutItem(m,4,COMPOSIT_2615)
	UpdateShotrCutItem(m,5,COMPOSIT_2616)
end

local SetShortCutVisible = function(m , bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2617,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2618,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2619,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2620,bDarw)
	
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2611,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2612,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2613,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2614,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2615,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2616,bDarw)
end


local AddShortCut = function(m , nIndex)
	if m.userDragItem == nil then
		return 
	end
	if m.bCheck then
		if m:CanShortCut() == false  then
			WarnUser(m,"此技能不能设置快捷栏")
			return 
		end
	end
	m:SetShortCutItem(nIndex, m.userDragItem)
	
	UpdateShotrCut(m)
end



local SetShortTabState=function(m,nIndex)
	if nIndex == 0 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_2617,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_2617,0)
	end
	
	if nIndex == 1 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_2618,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_2618,0)
	end
	
	if nIndex == 2 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_2619,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_2619,0)
	end
	
	if nIndex == 3 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_2620,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_2620,0)
	end
end

local OnDragShortCut = function(m, index)
	m:SetVal(index)
	m.userDragItem = m:GetShortCutSelectItem()
	m.bCheck = true    --是否检查
end

local SetControl = function(m, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2610, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2607, mode)
end
FORM_NEW_PETLIST.C52608_OnClick = function( m )
m:OnExpand()
end
FORM_NEW_PETLIST.C52917_OnClick = function( m )
str = m:DoMenu(2)
if QueryUser(m, str) == MsgBox.ECODE_YES then
	m:Free()
end
end
FORM_NEW_PETLIST.C52916_OnClick = function( m )
m:DoMenu(0)
end
FORM_NEW_PETLIST.C52914_OnClick = function( m )
m:DoMenu(1)
end
FORM_NEW_PETLIST.C52610_OnLoad = function( m )
m.bDraw = false
SetShortCutVisible(m, false)
end
FORM_NEW_PETLIST.C52610_OnClick = function( m )
--[[m.text = UI_Engine.GetText(m.formIndex,COMPOSIT_2586)
if m.bDraw == false then
	m.bDraw = true
	SetShortCutVisible(m, true)
	SetShortTabState(m,0)
	m:LoadShortCutData()
	UpdateShotrCut(m)
	UI_Engine.SetText(m.formIndex, COMPOSIT_2586, "")
else
	m.bDraw = false
	SetShortCutVisible(m, false)
	m:SaveShortCutData()
	UI_Engine.SetText(m.formIndex, COMPOSIT_2586, m.text)
end
--]]
if true == m:CanShortCut() then
	m.userDragItem = m:GetShortCutSelectItem()
	m.setShortcut = NewSetShortcut(m, m.userDragItem)
	m.setShortcut:WaitUserInput(m)
	DelSetShortcut(m.setShortcut)
end
end
FORM_NEW_PETLIST.C52620_OnClick = function( m )
m:SetShortCutTab(3)
SetShortTabState(m,3)
UpdateShotrCut(m)
end
FORM_NEW_PETLIST.C52619_OnClick = function( m )
m:SetShortCutTab(2)
SetShortTabState(m,2)
UpdateShotrCut(m)
end
FORM_NEW_PETLIST.C52618_OnClick = function( m )
m:SetShortCutTab(1)
SetShortTabState(m,1)
UpdateShotrCut(m)
end
FORM_NEW_PETLIST.C52617_OnClick = function( m )
m:SetShortCutTab(0)
SetShortTabState(m,0)
UpdateShotrCut(m)
end
FORM_NEW_PETLIST.C52616_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(5)
m.bCheck = false    --是否检查
end
FORM_NEW_PETLIST.C52616_OnDrop = function( m )
AddShortCut(m, 5)
end
FORM_NEW_PETLIST.C52615_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(4)
m.bCheck = false    --是否检查
end
FORM_NEW_PETLIST.C52615_OnDrop = function( m )
AddShortCut(m, 4)
end
FORM_NEW_PETLIST.C52614_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(3)
m.bCheck = false    --是否检查
end
FORM_NEW_PETLIST.C52614_OnDrop = function( m )
AddShortCut(m, 3)
end
FORM_NEW_PETLIST.C52613_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(2)
m.bCheck = false    --是否检查
end
FORM_NEW_PETLIST.C52613_OnDrop = function( m )
AddShortCut(m, 2)
end
FORM_NEW_PETLIST.C52612_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(1)
m.bCheck = false    --是否检查
end
FORM_NEW_PETLIST.C52612_OnDrop = function( m )
AddShortCut(m, 1)
end
FORM_NEW_PETLIST.C52611_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(0)
m.bCheck = false    --是否检查
end
FORM_NEW_PETLIST.C52611_OnDrop = function( m )
AddShortCut(m, 0)
end
FORM_NEW_PETLIST.C52607_OnClick = function( m )
m:ClickConfirm()
if m:GetMode()==1 then
	m:InputFinished()
end
end
FORM_NEW_PETLIST.C52606_OnClick = function( m )
m:OnClickList(19)
end
FORM_NEW_PETLIST.C52606_OnDrag = function( m )
OnDragShortCut(m, 19)
end
FORM_NEW_PETLIST.C52605_OnClick = function( m )
m:OnClickList(18)
end
FORM_NEW_PETLIST.C52605_OnDrag = function( m )
OnDragShortCut(m, 18)
end
FORM_NEW_PETLIST.C52604_OnClick = function( m )
m:OnClickList(17)
end
FORM_NEW_PETLIST.C52604_OnDrag = function( m )
OnDragShortCut(m, 17)
end
FORM_NEW_PETLIST.C52603_OnClick = function( m )
m:OnClickList(16)
end
FORM_NEW_PETLIST.C52603_OnDrag = function( m )
OnDragShortCut(m, 16)
end
FORM_NEW_PETLIST.C52602_OnClick = function( m )
m:OnClickList(15)
end
FORM_NEW_PETLIST.C52602_OnDrag = function( m )
OnDragShortCut(m, 15)
end
FORM_NEW_PETLIST.C52601_OnClick = function( m )
m:OnClickList(14)
end
FORM_NEW_PETLIST.C52601_OnDrag = function( m )
OnDragShortCut(m, 14)
end
FORM_NEW_PETLIST.C52600_OnClick = function( m )
m:OnClickList(13)
end
FORM_NEW_PETLIST.C52600_OnDrag = function( m )
OnDragShortCut(m, 13)
end
FORM_NEW_PETLIST.C52599_OnClick = function( m )
m:OnClickList(12)
end
FORM_NEW_PETLIST.C52599_OnDrag = function( m )
OnDragShortCut(m, 12)
end
FORM_NEW_PETLIST.C52598_OnClick = function( m )
m:OnClickList(11)
end
FORM_NEW_PETLIST.C52598_OnDrag = function( m )
OnDragShortCut(m, 11)
end
FORM_NEW_PETLIST.C52597_OnClick = function( m )
m:OnClickList(10)
end
FORM_NEW_PETLIST.C52597_OnDrag = function( m )
OnDragShortCut(m, 10)
end
FORM_NEW_PETLIST.C52596_OnClick = function( m )
m:OnClickList(9)
end
FORM_NEW_PETLIST.C52596_OnDrag = function( m )
OnDragShortCut(m, 9)
end
FORM_NEW_PETLIST.C52595_OnClick = function( m )
m:OnClickList(8)
end
FORM_NEW_PETLIST.C52595_OnDrag = function( m )
OnDragShortCut(m, 8)
end
FORM_NEW_PETLIST.C52594_OnClick = function( m )
m:OnClickList(7)
end
FORM_NEW_PETLIST.C52594_OnDrag = function( m )
OnDragShortCut(m, 7)
end
FORM_NEW_PETLIST.C52593_OnClick = function( m )
m:OnClickList(6)
end
FORM_NEW_PETLIST.C52593_OnDrag = function( m )
OnDragShortCut(m, 6)
end
FORM_NEW_PETLIST.C52592_OnClick = function( m )
m:OnClickList(5)
end
FORM_NEW_PETLIST.C52592_OnDrag = function( m )
OnDragShortCut(m, 5)
end
FORM_NEW_PETLIST.C52591_OnClick = function( m )
m:OnClickList(4)
end
FORM_NEW_PETLIST.C52591_OnDrag = function( m )
OnDragShortCut(m, 4)
end
FORM_NEW_PETLIST.C52590_OnClick = function( m )
m:OnClickList(3)
end
FORM_NEW_PETLIST.C52590_OnDrag = function( m )
OnDragShortCut(m, 3)
end
FORM_NEW_PETLIST.C52589_OnClick = function( m )
m:OnClickList(2)
end
FORM_NEW_PETLIST.C52589_OnDrag = function( m )
OnDragShortCut(m, 2)
end
FORM_NEW_PETLIST.C52588_OnClick = function( m )
m:OnClickList(1)
end
FORM_NEW_PETLIST.C52588_OnDrag = function( m )
OnDragShortCut(m, 1)
end
FORM_NEW_PETLIST.C52588_OnUpdate = function( m )
Init(m)
local grid = m:GetCapInfo()
UI_Engine.SetText(m.formIndex, COMPOSIT_2812, grid)
end
FORM_NEW_PETLIST.C52587_OnClick = function( m )
m:OnClickList(0)
end
FORM_NEW_PETLIST.C52587_OnDrag = function( m )
OnDragShortCut(m, 0)
end
FORM_NEW_PETLIST.C52585_OnLoad = function( m )
Init(m)
m:OnClickList(0)
local grid = m:GetCapInfo()
UI_Engine.SetText(m.formIndex, COMPOSIT_2812, grid)
SetControl(m, false)
end
