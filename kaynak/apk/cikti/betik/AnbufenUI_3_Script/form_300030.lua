NEW_FORM_UNION_DISBAND= { }
NEW_FORM_UNION_DISBAND.Main = function( m )
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
NEW_FORM_UNION_DISBAND.C50555_OnLoad = function( m )
local szDisband, szWarn = m:GetDrawInfo()
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_552, szDisband)
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_553, szWarn, 0)

end
NEW_FORM_UNION_DISBAND.C50555_OnClick = function( m )
m:InputFinished()
DelDisbandForm(m)

end
NEW_FORM_UNION_DISBAND.C50554_OnClick = function( m )
m:OnDisband()
m:InputFinished()
DelDisbandForm(m)
end
