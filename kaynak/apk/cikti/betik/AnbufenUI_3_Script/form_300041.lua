NEW_FORM_WAITBAR= { }
NEW_FORM_WAITBAR.Main = function( m )
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
NEW_FORM_WAITBAR.C50782_OnClick = function( m )
m:Close()
m:InputFinished()
end
NEW_FORM_WAITBAR.C50783_OnDraw = function( m )
m:Draw()

end
