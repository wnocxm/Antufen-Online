NEW_FORM_SYS_CHAT= { }
NEW_FORM_SYS_CHAT.Main = function( m )
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
NEW_FORM_SYS_CHAT.C50064_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_SYS_CHAT.C50064_OnClick = function( m )
m:Close()
end
