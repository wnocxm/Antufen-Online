FORM_ROCKER= { }
FORM_ROCKER.Main = function( m )
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
FORM_ROCKER.C50145_OnDraw = function( m )
m:DrawTouchPoint()
end
