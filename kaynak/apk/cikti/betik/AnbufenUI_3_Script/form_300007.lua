NEW_FORM_INFO= { }
NEW_FORM_INFO.Main = function( m )
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
NEW_FORM_INFO.C50061_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_INFO.C50061_OnClick = function( m )
m:InputFinished()
m:Close()
end
