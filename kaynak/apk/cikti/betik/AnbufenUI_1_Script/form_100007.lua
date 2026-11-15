NEW_FORM_UPDATE= { }
NEW_FORM_UPDATE.Main = function( m )
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
NEW_FORM_UPDATE.C50331_OnClick = function( m )
m:OnClick(0)
end
NEW_FORM_UPDATE.C50100_OnDraw = function( m )
m:Draw()
end
