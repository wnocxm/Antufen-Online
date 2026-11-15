NEW_FORM_ROCKER= { }
NEW_FORM_ROCKER.Main = function( m )
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
NEW_FORM_ROCKER.C50000_OnDraw = function( m )
m:MyDraw()
end
