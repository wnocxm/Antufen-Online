FORM_SAIL_INFO= { }
FORM_SAIL_INFO.Main = function( m )
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
FORM_SAIL_INFO.C51468_OnClick = function( m )
m:InputFinished()
end
FORM_SAIL_INFO.C51467_OnLoad = function( m )
local name, quality, type, hard, slot, describe, needLv, needJob, level = m:GetShowInfo()
UI_Engine.SetText(m.formIndex, COMPOSIT_1469, name)
UI_Engine.SetText(m.formIndex, COMPOSIT_1470, name)
UI_Engine.SetText(m.formIndex, COMPOSIT_1471, quality)
UI_Engine.SetText(m.formIndex, COMPOSIT_1533, type)
UI_Engine.SetText(m.formIndex, COMPOSIT_1534, hard)
UI_Engine.SetText(m.formIndex, COMPOSIT_1535, needLv)
UI_Engine.SetText(m.formIndex, COMPOSIT_1536, needJob)
UI_Engine.SetText(m.formIndex, COMPOSIT_1472, describe)
UI_Engine.SetText(m.formIndex, COMPOSIT_1481, level)
end
