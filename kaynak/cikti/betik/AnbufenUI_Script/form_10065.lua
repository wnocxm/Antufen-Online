FORM_UNION_DISBAND= { }
FORM_UNION_DISBAND.Main = function( m )
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
FORM_UNION_DISBAND.C52792_OnClick = function( m )
m:InputFinished()
DelDisbandForm(m)
end
FORM_UNION_DISBAND.C51748_OnClick = function( m )
m:OnDisband()
m:InputFinished()
DelDisbandForm(m)
end
FORM_UNION_DISBAND.C51746_OnLoad = function( m )
local szDisband, szWarn = m:GetDrawInfo()
UI_Engine.SetText(m.formIndex, COMPOSIT_1746, szDisband)
UI_Engine.SetText(m.formIndex, COMPOSIT_1745, szWarn, 0)
end
