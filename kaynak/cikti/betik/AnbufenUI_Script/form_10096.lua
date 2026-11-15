FORM_WAITBAR= { }
FORM_WAITBAR.Main = function( m )
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
FORM_WAITBAR.C52796_OnClick = function( m )
m:Close()
m:InputFinished()
end
FORM_WAITBAR.C52796_OnDraw = function( m )
m:Draw()
end
