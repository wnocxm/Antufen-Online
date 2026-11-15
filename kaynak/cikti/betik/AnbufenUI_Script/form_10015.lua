FORM_GAME_MAINMENU= { }
FORM_GAME_MAINMENU.Main = function( m )
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
FORM_GAME_MAINMENU.C50162_OnClick = function( m )
m:OnClickMenu(6)
DBGPRINTF("studend55555555555555")
m:InputFinished()
m:Close()
m.EquipStrong = NewEquipStrong(m)
end
FORM_GAME_MAINMENU.C50161_OnClick = function( m )
m:OnClickMenu(2)

end
FORM_GAME_MAINMENU.C50160_OnClick = function( m )
m:OnClickMenu(0)

end
FORM_GAME_MAINMENU.C50159_OnClick = function( m )
m:OnClickMenu(4)

end
FORM_GAME_MAINMENU.C50158_OnClick = function( m )
m:OnClickMenu(1)

end
