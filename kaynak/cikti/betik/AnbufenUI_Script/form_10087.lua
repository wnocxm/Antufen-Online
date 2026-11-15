FORM_V5_MENU= { }
FORM_V5_MENU.Main = function( m )
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
FORM_V5_MENU.C52260_OnLoad = function( m )
m.mode = true
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2336, false)


end
FORM_V5_MENU.C52260_OnClick = function( m )
m:OpenMailList()
end
local ChangeState = function(m,mode)
	if true == mode then
	--	UI_Engine.SetText(m.formIndex, COMPOSIT_2336, "返回")
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2336, false)

	else
		UI_Engine.SetText(m.formIndex, COMPOSIT_2336, "返回")
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2336, true)
	end
end

local ClickEsc = function(m, mode)
	if true == mode then
		DelGameMenu(m)
	else
		UI_Engine.SetFormTab(m.formIndex, 0)
	end
end
	
FORM_V5_MENU.C52941_OnClick = function( m )
if m:GetRockerState()
 ==0 then
	m.MsgBox = NewMsgBox(m, "是否确定使用遥杆移动！", 	MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	if result == MsgBox.ECODE_YES then
		m:SetRocker(1)

	end 
else
	m.MsgBox = NewMsgBox(m, "是否确定使用触控移动！", 	MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	if result == MsgBox.ECODE_YES then
		m:SetRocker(0)	end 
end

end
FORM_V5_MENU.C52396_OnClick = function( m )
NewTask(m)
end
FORM_V5_MENU.C52259_OnClick = function( m )
DBGPRINTF("lua_info:new request")
m.request = NewRequestForm(m)
m.request:WaitUserInput(m)
DelRequestForm(m.request)
end
FORM_V5_MENU.C52790_OnClick = function( m )
DelGameMenu(m)
end
FORM_V5_MENU.C52258_OnClick = function( m )
--m:OnClickMenu(29)
NewSearchPlayer(m)
end
FORM_V5_MENU.C52257_OnClick = function( m )
NewRelationMenu(m)
end
FORM_V5_MENU.C52256_OnClick = function( m )
if true == m:IsOpenUnion() then
	m.union = NewUnionForm(m)
	m.union:WaitUserInput(m)
	DelUnionForm(m.union)
end
end
FORM_V5_MENU.C52252_OnClick = function( m )
NewCashShop(m)
end
FORM_V5_MENU.C52255_OnClick = function( m )
NewSerialNumber(m)
end
FORM_V5_MENU.C52254_OnClick = function( m )
NewDepositV8(m)
end
FORM_V5_MENU.C52253_OnClick = function( m )
NewDepositQuery(m)
end
FORM_V5_MENU.C52246_OnClick = function( m )
m.idea = NewIdeaForm(m)
m.idea:WaitUserInput(m)
DelIdeaForm(m.idea)
end
FORM_V5_MENU.C52398_OnClick = function( m )
NewLiveSkill(m)
end
FORM_V5_MENU.C52245_OnClick = function( m )
NewPhoneBind(m)
end
FORM_V5_MENU.C52243_OnClick = function( m )
m.fan = NewFantasize(m, 2)
m.fan:WaitUserInput(m)
DelFantasize(m.fan)
end
FORM_V5_MENU.C52244_OnClick = function( m )
NewSystemSetting(m)
end
FORM_V5_MENU.C52242_OnClick = function( m )
m.fan = NewFantasize(m, 1)
m.fan:WaitUserInput(m)
DelFantasize(m.fan)
end
FORM_V5_MENU.C52241_OnClick = function( m )
m.petUI = NewPetList(m,0,0,false)
m.petUI:WaitUserInput(m)
DelPetList(m.petUI)
end
FORM_V5_MENU.C52234_OnClick = function( m )
--m:OnClickMenu(11)
m.pack = NewPackage(m, 0)
m.pack:WaitUserInput(m)
DelPackage(m.pack)
end
FORM_V5_MENU.C52237_OnClick = function( m )
m:OnExitGame()
end
FORM_V5_MENU.C52236_OnClick = function( m )
m:OpenItemLock()
end
FORM_V5_MENU.C52233_OnClick = function( m )
m.map = NewWorldMap(m)
m.map:WaitUserInput(m)
DelWorldMap(m.map)
DelGameMenu(m)
end
FORM_V5_MENU.C52232_OnClick = function( m )
m.NPCLook = NewNPCLook(m)
m.NPCLook.IsNew=1
m.NPCLook:WaitUserInput(m)
DelNPCLook(m.NPCLook)
end
FORM_V5_MENU.C52231_OnClick = function( m )
NewGameSetting(m)

end
FORM_V5_MENU.C52230_OnClick = function( m )
--m:OnClickMenu(12)
m.tree = NewSkillTree(m)
m.tree:WaitUserInput(m)
DelSkillTree(m.tree)
end
FORM_V5_MENU.C52639_OnClick = function( m )
m:OpenBusiness()
end
FORM_V5_MENU.C52228_OnClick = function( m )
player = NewPlayerInfo(m)
end
FORM_V5_MENU.C52220_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 2)
m.mode = false
ChangeState(m, m.mode)
end
FORM_V5_MENU.C52336_OnClick = function( m )
if false == m.mode then
	ClickEsc(m, m.mode)
	m.mode = true
	ChangeState(m, m.mode)
else
	ClickEsc(m, m.mode)
	ChangeState(m, m.mode)
end
end
FORM_V5_MENU.C52219_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 1)
m.mode = false
ChangeState(m, m.mode)
end
FORM_V5_MENU.C52226_OnClick = function( m )
m:OnChat()
m:Close()
end
FORM_V5_MENU.C52225_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 7)
m.mode = false
ChangeState(m, m.mode)
end
FORM_V5_MENU.C52224_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 6)
m.mode = false
ChangeState(m, m.mode)
end
FORM_V5_MENU.C52223_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 5)
m.mode = false
ChangeState(m, m.mode)
end
FORM_V5_MENU.C52222_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 4)
m:IsNeedVis()
m.mode = false
ChangeState(m, m.mode)
end
FORM_V5_MENU.C52221_OnClick = function( m )
m.petUI = NewPetList(m,0,0,false)
m.petUI:WaitUserInput(m)
DelPetList(m.petUI)
end
FORM_V5_MENU.C52917_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 8)
m.mode = false
ChangeState(m, m.mode)
end
FORM_V5_MENU.C52916_OnClick = function( m )
m:Click(80)
end
FORM_V5_MENU.C52915_OnClick = function( m )
m:Click(81)
end
FORM_V5_MENU.C52940_OnClick = function( m )
m:Click(83)
end
FORM_V5_MENU.C52914_OnClick = function( m )
m:Click(82)
end
