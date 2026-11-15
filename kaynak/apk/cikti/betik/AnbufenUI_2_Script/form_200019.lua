NEW_FORM_RELATION_MENU= { }
NEW_FORM_RELATION_MENU.Main = function( m )
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

local UpdateText = function(m, id, offset)
	local name,status,others = m:GetRelationInfo(m.offset + offset)
	UI_Engine.SetText(m.formIndex,id,name,0)
	UI_Engine.SetText(m.formIndex,id,status,1)
	if others ~= nil then
		UI_Engine.SetText(m.formIndex,id,others,2)
	end
end

local DoMenu = function(m, index)
	m:OnClick(index)
end

local HideMenu = function(m, mode)
	for i = 0, 10 do
		local id = UI2_COMPOSIT_510 + i
		UI_Engine.SetVisible(m.formIndex, id, mode )
	end
end
NEW_FORM_RELATION_MENU.C50521_OnClick = function( m )
if m:IsNew()==1 then--add by liao
DelRelationMenu(m)
else
m:OnClickLRFunction(1)
end
end
NEW_FORM_RELATION_MENU.C50520_OnClick = function( m )
m:OnAdd(1)
end
NEW_FORM_RELATION_MENU.C50519_OnClick = function( m )
m:OnAdd(0)
end
NEW_FORM_RELATION_MENU.C50512_OnClick = function( m )
DoMenu(m, 0)
end
NEW_FORM_RELATION_MENU.C50513_OnClick = function( m )
DoMenu(m, 1)
end
NEW_FORM_RELATION_MENU.C50514_OnClick = function( m )
DoMenu(m, 2)
end
NEW_FORM_RELATION_MENU.C50515_OnClick = function( m )
DoMenu(m, 3)
end
NEW_FORM_RELATION_MENU.C50516_OnClick = function( m )
DoMenu(m, 4)
end
NEW_FORM_RELATION_MENU.C50517_OnClick = function( m )
DoMenu(m, 5)
end
NEW_FORM_RELATION_MENU.C50518_OnClick = function( m )
DoMenu(m, 6)
end
NEW_FORM_RELATION_MENU.C50511_OnClick = function( m )
--HideMenu(m, false)
m:OnClick(100)
end
NEW_FORM_RELATION_MENU.C50502_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50502_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_502, 0)
end
NEW_FORM_RELATION_MENU.C50503_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50503_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_503, 1)
end
NEW_FORM_RELATION_MENU.C50504_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50504_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_504, 2)
end
NEW_FORM_RELATION_MENU.C50505_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50505_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_505, 3)
end
NEW_FORM_RELATION_MENU.C50506_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50506_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_506, 4)
end
NEW_FORM_RELATION_MENU.C50507_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50507_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_507, 5)
end
NEW_FORM_RELATION_MENU.C50508_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50508_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_508, 6)
end
NEW_FORM_RELATION_MENU.C50509_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50509_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_509, 7)
end
NEW_FORM_RELATION_MENU.C50493_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50493_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_493, 0)
end
NEW_FORM_RELATION_MENU.C50494_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50494_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_494, 1)
end
NEW_FORM_RELATION_MENU.C50495_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50495_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_495, 2)
end
NEW_FORM_RELATION_MENU.C50496_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50496_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_496, 3)
end
NEW_FORM_RELATION_MENU.C50497_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50497_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_497, 4)
end
NEW_FORM_RELATION_MENU.C50498_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50498_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_498, 5)
end
NEW_FORM_RELATION_MENU.C50499_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50499_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_499, 6)
end
NEW_FORM_RELATION_MENU.C50500_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50500_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_500, 7)
end
NEW_FORM_RELATION_MENU.C50484_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50484_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_484, 0)
end
NEW_FORM_RELATION_MENU.C50485_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50485_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_485, 1)
end
NEW_FORM_RELATION_MENU.C50486_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50486_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_486, 2)
end
NEW_FORM_RELATION_MENU.C50487_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50487_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_487, 3)
end
NEW_FORM_RELATION_MENU.C50488_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50488_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_488, 4)
end
NEW_FORM_RELATION_MENU.C50489_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50489_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_489, 5)
end
NEW_FORM_RELATION_MENU.C50490_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50490_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_490, 6)
end
NEW_FORM_RELATION_MENU.C50491_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50491_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_491, 7)
end
NEW_FORM_RELATION_MENU.C50475_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50475_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_475, 0)
end
NEW_FORM_RELATION_MENU.C50476_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50476_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_476, 1)
end
NEW_FORM_RELATION_MENU.C50477_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50477_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_477, 2)
end
NEW_FORM_RELATION_MENU.C50478_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50478_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_478, 3)
end
NEW_FORM_RELATION_MENU.C50479_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50479_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_479, 4)
end
NEW_FORM_RELATION_MENU.C50480_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50480_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_480, 5)
end
NEW_FORM_RELATION_MENU.C50481_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50481_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_481, 6)
end
NEW_FORM_RELATION_MENU.C50482_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50482_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_482, 7)
end
NEW_FORM_RELATION_MENU.C50466_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50466_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_466, 0)
end
NEW_FORM_RELATION_MENU.C50467_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50467_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_467, 1)
end
NEW_FORM_RELATION_MENU.C50468_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50468_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_468, 2)
end
NEW_FORM_RELATION_MENU.C50469_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50469_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_469, 3)
end
NEW_FORM_RELATION_MENU.C50470_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50470_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_470, 4)
end
NEW_FORM_RELATION_MENU.C50471_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50471_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_471, 5)
end
NEW_FORM_RELATION_MENU.C50472_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50472_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_472, 6)
end
NEW_FORM_RELATION_MENU.C50473_OnClick = function( m )
m:OnClickChat(m.userSelectItem)
end
NEW_FORM_RELATION_MENU.C50473_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_473, 7)
end
NEW_FORM_RELATION_MENU.C50460_OnClick = function( m )
m:SetTabIndex(0)
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.UpdateList(m.formIndex,  UI2_COMPOSIT_467)
end
NEW_FORM_RELATION_MENU.C50461_OnClick = function( m )
m:SetTabIndex(1)
UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.UpdateList(m.formIndex,  UI2_COMPOSIT_476)
end
NEW_FORM_RELATION_MENU.C50462_OnClick = function( m )
m:SetTabIndex(2)
UI_Engine.SetFormTab(m.formIndex, 2)
UI_Engine.UpdateList(m.formIndex,  UI2_COMPOSIT_485)
end
NEW_FORM_RELATION_MENU.C50463_OnClick = function( m )
m:SetTabIndex(3)
UI_Engine.SetFormTab(m.formIndex, 3)
UI_Engine.UpdateList(m.formIndex,  UI2_COMPOSIT_494)
end
NEW_FORM_RELATION_MENU.C50464_OnClick = function( m )
m:SetTabIndex(4)
UI_Engine.SetFormTab(m.formIndex, 4)
UI_Engine.UpdateList(m.formIndex,  UI2_COMPOSIT_503)
end
NEW_FORM_RELATION_MENU.C50458_OnLoad = function( m )
HideMenu(m, false)
UI_Engine.SetLevel(m.formIndex, 3)
end
