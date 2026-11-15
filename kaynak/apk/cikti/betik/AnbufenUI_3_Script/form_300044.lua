NEW_FORM_AROUNDPLAYER= { }
NEW_FORM_AROUNDPLAYER.Main = function( m )
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
NEW_FORM_AROUNDPLAYER.C50836_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 1)
end
NEW_FORM_AROUNDPLAYER.C50836_OnClick = function( m )
m:InputFinished()
m:Close()
end
local SetDrawInfo = function(m, offset, ctlID)	-- 设置列表信息
local name,ID = m:GetDrawInfo(offset)
if name ~= nil then
	UI_Engine.SetText(m.formIndex, ctlID, name, 0)
	UI_Engine.SetText(m.formIndex, ctlID, ID, 1)
end
end
local Click = function(m)
local num  = m:Onclick(m.userSelectItem)
if num == 1 then
	UI_Engine.UpdateList(m.formIndex ,UI3_COMPOSIT_828)
else
	m:InputFinished()
	m:Close()
end
end

local SelectVisible = function(m)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_858, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_859, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_860, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_861, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_862, false)
end
NEW_FORM_AROUNDPLAYER.C50828_OnClick = function( m )
Click(m)
end
NEW_FORM_AROUNDPLAYER.C50828_OnUpdate = function( m )
SetDrawInfo(m, m.offset, UI3_COMPOSIT_828)

end
NEW_FORM_AROUNDPLAYER.C50829_OnClick = function( m )
Click(m)
end
NEW_FORM_AROUNDPLAYER.C50829_OnUpdate = function( m )
SetDrawInfo(m, m.offset+1, UI3_COMPOSIT_829)
end
NEW_FORM_AROUNDPLAYER.C50830_OnClick = function( m )
Click(m)
end
NEW_FORM_AROUNDPLAYER.C50830_OnUpdate = function( m )
SetDrawInfo(m, m.offset+2, UI3_COMPOSIT_830)
end
NEW_FORM_AROUNDPLAYER.C50831_OnClick = function( m )
Click(m)
end
NEW_FORM_AROUNDPLAYER.C50831_OnUpdate = function( m )
SetDrawInfo(m, m.offset+3, UI3_COMPOSIT_831)
end
NEW_FORM_AROUNDPLAYER.C50832_OnClick = function( m )
Click(m)
end
NEW_FORM_AROUNDPLAYER.C50832_OnUpdate = function( m )
SetDrawInfo(m, m.offset+4, UI3_COMPOSIT_832)
end
NEW_FORM_AROUNDPLAYER.C50833_OnClick = function( m )
Click(m)
end
NEW_FORM_AROUNDPLAYER.C50833_OnUpdate = function( m )
SetDrawInfo(m, m.offset+5, UI3_COMPOSIT_833)
end
NEW_FORM_AROUNDPLAYER.C50834_OnClick = function( m )
Click(m)
end
NEW_FORM_AROUNDPLAYER.C50834_OnUpdate = function( m )
SetDrawInfo(m, m.offset+6, UI3_COMPOSIT_834)
end
NEW_FORM_AROUNDPLAYER.C50835_OnClick = function( m )
Click(m)
end
NEW_FORM_AROUNDPLAYER.C50835_OnUpdate = function( m )
SetDrawInfo(m, m.offset+7, UI3_COMPOSIT_835)
end
