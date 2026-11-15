FORM_NEW_MAINMENU= { }
FORM_NEW_MAINMENU.Main = function( m )
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
FORM_NEW_MAINMENU.C51001_OnClick = function( m )
NewSystemSetting(m)
end
FORM_NEW_MAINMENU.C51002_OnClick = function( m )
NewPhoneBind(m)
end
FORM_NEW_MAINMENU.C51003_OnClick = function( m )
m.idea = NewIdeaForm(m)
m.idea:WaitUserInput(m)
DelIdeaForm(m.idea)

end
FORM_NEW_MAINMENU.C50992_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 0)
end
FORM_NEW_MAINMENU.C50993_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 1)
end
FORM_NEW_MAINMENU.C50999_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 7)
m:OnChat()
m:Close()
end
FORM_NEW_MAINMENU.C50998_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 6)
end
FORM_NEW_MAINMENU.C50997_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 5)
end
FORM_NEW_MAINMENU.C50996_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 4)
end
FORM_NEW_MAINMENU.C50995_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 3)
end
FORM_NEW_MAINMENU.C50994_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 2)
end
FORM_NEW_MAINMENU.C51027_OnClick = function( m )
m.map = NewWorldMap(m)
m.map:WaitUserInput(m)
DelWorldMap(m.map)

end
FORM_NEW_MAINMENU.C51026_OnClick = function( m )
m.NPCLook = NewNPCLook(m)
m.NPCLook:WaitUserInput(m)
DelNPCLook(m.NPCLook)
end
FORM_NEW_MAINMENU.C51025_OnClick = function( m )
NewGameSetting(m)
end
FORM_NEW_MAINMENU.C51024_OnClick = function( m )
m:OnClickMenu(12)
end
FORM_NEW_MAINMENU.C51023_OnClick = function( m )
m:OnClickMenu(14)
end
FORM_NEW_MAINMENU.C51022_OnClick = function( m )
--m:OnClickMenu(10)
player = NewPlayerInfo(m)
end
FORM_NEW_MAINMENU.C51035_OnClick = function( m )
NewEquipStrong(m , EquipStrongTab.REQUIRE_ALL)
end
FORM_NEW_MAINMENU.C51034_OnClick = function( m )
m:OnClickMenu(11)
end
FORM_NEW_MAINMENU.C51041_OnClick = function( m )
m.fan = NewFantasize(m, 1)
m.fan:WaitUserInput(m)
DelFantasize(m.fan)
end
FORM_NEW_MAINMENU.C51040_OnClick = function( m )
--m:OnClickMenu(2)
m.petUI = NewPetList(m,0,0,false)
m.petUI:WaitUserInput(m)
DelPetList(m.petUI)
end
FORM_NEW_MAINMENU.C51060_OnClick = function( m )
NewDepositQuery(m)
end
FORM_NEW_MAINMENU.C51059_OnClick = function( m )
NewSerialNumber(m)
end
FORM_NEW_MAINMENU.C51058_OnClick = function( m )
NewDepositV8(m)
end
FORM_NEW_MAINMENU.C51057_OnClick = function( m )
NewCashShop(m)
end
FORM_NEW_MAINMENU.C51070_OnClick = function( m )
NewMailSend(m)
end
FORM_NEW_MAINMENU.C51069_OnClick = function( m )
--m:OnClickMenu(28)
DBGPRINTF("lua_info:new request")
m.request = NewRequestForm(m)
m.request:WaitUserInput(m)
DelRequestForm(m.request)
end
FORM_NEW_MAINMENU.C51068_OnClick = function( m )
m:OnClickMenu(29)
end
FORM_NEW_MAINMENU.C51067_OnClick = function( m )
m:OnClickMenu(26)
end
FORM_NEW_MAINMENU.C51066_OnClick = function( m )
m.union = NewUnionForm(m)
m.union:WaitUserInput(m)
DelUnionForm(m.union)
end
