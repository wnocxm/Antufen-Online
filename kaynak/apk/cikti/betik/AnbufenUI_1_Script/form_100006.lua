NEW_FORM_GATESERVER_SEL= { }
NEW_FORM_GATESERVER_SEL.Main = function( m )
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
NEW_FORM_GATESERVER_SEL.C50304_OnClick = function( m )
m:Close()
end
