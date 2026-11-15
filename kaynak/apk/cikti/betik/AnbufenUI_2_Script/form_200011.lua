NEW_FORM_V5_MENU= { }
NEW_FORM_V5_MENU.Main = function( m )
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
NEW_FORM_V5_MENU.C50253_OnLoad = function( m )
m.mode = true
end
local ClickEsc = function(m)
	if true == m.mode then
		DelGameMenu(m)
	else
		UI_Engine.SetFormTab(m.formIndex, 0)
		m.mode = true
		UI_Engine.SetLevel(m.formIndex, 0)
	end
end

local SetOverlap = function(m)
	for i = 0, 21 do 
		local id = UI2_COMPOSIT_231 + i
		UI_Engine.SetOverlap(m.formIndex, id)
	end
	UI_Engine.SetOverlap(m.formIndex, UI2_COMPOSIT_873)
	UI_Engine.SetOverlap(m.formIndex, UI2_COMPOSIT_874)
	UI_Engine.SetOverlap(m.formIndex, UI2_COMPOSIT_875)
	UI_Engine.SetOverlap(m.formIndex, UI2_COMPOSIT_876)
	UI_Engine.SetOverlap(m.formIndex, UI2_COMPOSIT_877)
	UI_Engine.SetOverlap(m.formIndex, UI2_COMPOSIT_878)
	UI_Engine.SetOverlap(m.formIndex, UI2_COMPOSIT_879)
end
NEW_FORM_V5_MENU.C50230_OnClick = function( m )
ClickEsc(m)
end
NEW_FORM_V5_MENU.C50879_OnClick = function( m )
m:ExitGame()
end
NEW_FORM_V5_MENU.C50878_OnClick = function( m )
m.idea = NewIdeaForm(m)
m.idea:WaitUserInput(m)
DelIdeaForm(m.idea)
end
NEW_FORM_V5_MENU.C50877_OnClick = function( m )
NewSystemSetting(m)
end
NEW_FORM_V5_MENU.C50252_OnClick = function( m )
m:ExitGame()
end
NEW_FORM_V5_MENU.C50251_OnClick = function( m )
m.idea = NewIdeaForm(m)
m.idea:WaitUserInput(m)
DelIdeaForm(m.idea)
end
NEW_FORM_V5_MENU.C50249_OnClick = function( m )
NewSystemSetting(m)
end
NEW_FORM_V5_MENU.C50873_OnClick = function( m )
NewGameSetting(m)
end
NEW_FORM_V5_MENU.C50875_OnClick = function( m )
NewDepositQuery(m)
end
NEW_FORM_V5_MENU.C50876_OnClick = function( m )
NewDepositV8(m)
end
NEW_FORM_V5_MENU.C50874_OnClick = function( m )
NewDepositIOS(m)
end
NEW_FORM_V5_MENU.C50246_OnClick = function( m )
NewSerialNumber(m)
end
NEW_FORM_V5_MENU.C50245_OnClick = function( m )
NewCashShop(m)
end
NEW_FORM_V5_MENU.C50244_OnClick = function( m )
m:Click(83)
end
NEW_FORM_V5_MENU.C50243_OnClick = function( m )
m:Click(82)
end
NEW_FORM_V5_MENU.C50242_OnClick = function( m )
m:Click(81)
end
NEW_FORM_V5_MENU.C50241_OnClick = function( m )
m:Click(80)
end
NEW_FORM_V5_MENU.C50852_OnClick = function( m )
m.request = NewRequestForm(m)
end
NEW_FORM_V5_MENU.C50240_OnClick = function( m )
m:OpenMailList()
end
NEW_FORM_V5_MENU.C50239_OnClick = function( m )
if true == m:IsOpenUnion() then
	m.union = NewUnionForm(m)
	m.union:WaitUserInput(m)
	DelUnionForm(m.union)
end
end
NEW_FORM_V5_MENU.C50238_OnClick = function( m )
m.unlist = NewUnionCreate(m, 1)
m.unlist:WaitUserInput(m)
DelUnionCreate(m.unlist)
end
NEW_FORM_V5_MENU.C50237_OnClick = function( m )
local index = m.formIndex
m.search = NewSearchPlayer(m)
m.search:GetFatherIndex(index)
end
NEW_FORM_V5_MENU.C50236_OnClick = function( m )
NewRelationMenu(m)
end
NEW_FORM_V5_MENU.C50235_OnClick = function( m )
NewLiveSkill(m)
end
NEW_FORM_V5_MENU.C50234_OnClick = function( m )
NewGameSetting(m)
end
NEW_FORM_V5_MENU.C50232_OnClick = function( m )
m.tree = NewSkillTree(m)
m.tree:WaitUserInput(m)
DelSkillTree(m.tree)
end
NEW_FORM_V5_MENU.C50231_OnClick = function( m )
player = NewPlayerInfo(m)
end
NEW_FORM_V5_MENU.C50229_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 5)
m.mode = false
m:HideCtrlByVersion()
UI_Engine.SetLevel(m.formIndex, 2)
end
NEW_FORM_V5_MENU.C50228_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 4)
m.mode = false
m:HideCtrlByVersion()
UI_Engine.SetLevel(m.formIndex, 2)
end
NEW_FORM_V5_MENU.C50227_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 2)
m.mode = false
UI_Engine.SetLevel(m.formIndex, 2)
end
NEW_FORM_V5_MENU.C50226_OnClick = function( m )
NewTask(m)
end
NEW_FORM_V5_MENU.C50225_OnClick = function( m )
m.pack = NewPackage(m, 0)
m.pack:WaitUserInput(m)
DelPackage(m.pack)
end
NEW_FORM_V5_MENU.C50224_OnClick = function( m )
m.tree = NewSkillTree(m)
m.tree:WaitUserInput(m)
DelSkillTree(m.tree)
end
NEW_FORM_V5_MENU.C50223_OnClick = function( m )
player = NewPlayerInfo(m)

end
NEW_FORM_V5_MENU.C50222_OnLoad = function( m )
SetOverlap(m)
UI_Engine.SetState(m.formIndex, UI2_COMPOSIT_229, 0)
end
