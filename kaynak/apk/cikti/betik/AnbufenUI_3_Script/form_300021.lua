NEW_FORM_RANK= { }
NEW_FORM_RANK.Main = function( m )
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
NEW_FORM_RANK.C50366_OnLoad = function( m )
local title = m:BeginQuery(0)
m:GetCurTab(-1)
UI_Engine.SetLevel(m.formIndex, 3)

end
NEW_FORM_RANK.C50366_OnClick = function( m )
m:InputFinished()
DelRankForm(m)

end
NEW_FORM_RANK.C50366_OnDraw = function( m )
UI_Engine.UpdateList(m.formIndex ,UI3_COMPOSIT_436)
end
NEW_FORM_RANK.C50366_OnUpdate = function( m )


end
local SetList = function(m, offset, nID)
	local rank, name, val = m:GetSubInfo(m.offset+offset)
	UI_Engine.SetText(m.formIndex, nID, rank, 0)
	UI_Engine.SetText(m.formIndex, nID, name, 1)
	UI_Engine.SetText(m.formIndex, nID, val, 2)
end

NEW_FORM_RANK.C50436_OnClick = function( m )
m:GetCurTab(1)

end
NEW_FORM_RANK.C50436_OnUpdate = function( m )
SetList(m, 0, UI3_COMPOSIT_436)

end
NEW_FORM_RANK.C50437_OnClick = function( m )
m:GetCurTab(1)
end
NEW_FORM_RANK.C50437_OnUpdate = function( m )
SetList(m, 1, UI3_COMPOSIT_437)
end
NEW_FORM_RANK.C50438_OnClick = function( m )
m:GetCurTab(1)
end
NEW_FORM_RANK.C50438_OnUpdate = function( m )
SetList(m, 2, UI3_COMPOSIT_438)
end
NEW_FORM_RANK.C50439_OnClick = function( m )
m:GetCurTab(1)
end
NEW_FORM_RANK.C50439_OnUpdate = function( m )
SetList(m, 3, UI3_COMPOSIT_439)
end
NEW_FORM_RANK.C50440_OnClick = function( m )
m:GetCurTab(1)
end
NEW_FORM_RANK.C50440_OnUpdate = function( m )
SetList(m, 4, UI3_COMPOSIT_440)
end
NEW_FORM_RANK.C50441_OnClick = function( m )
m:GetCurTab(1)
end
NEW_FORM_RANK.C50441_OnUpdate = function( m )
SetList(m, 5, UI3_COMPOSIT_441)
end
NEW_FORM_RANK.C50442_OnClick = function( m )
m:GetCurTab(1)
end
NEW_FORM_RANK.C50442_OnUpdate = function( m )
SetList(m, 6, UI3_COMPOSIT_442)
end
NEW_FORM_RANK.C50443_OnClick = function( m )
m:GetCurTab(1)

end
NEW_FORM_RANK.C50443_OnUpdate = function( m )
SetList(m, 7, UI3_COMPOSIT_443)
end
NEW_FORM_RANK.C50405_OnClick = function( m )
local title = m:BeginQuery(0)
m:GetCurTab(-1)
end
NEW_FORM_RANK.C50405_OnUpdate = function( m )
local title, text = m:GetMainInfo(m.offset+1)
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_405, text)
end
NEW_FORM_RANK.C50406_OnClick = function( m )
local title = m:BeginQuery(1)
m:GetCurTab(-1)

end
NEW_FORM_RANK.C50406_OnUpdate = function( m )
local title, text = m:GetMainInfo(m.offset+2)
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_406, text)
end
NEW_FORM_RANK.C50407_OnClick = function( m )
local title = m:BeginQuery(2)
m:GetCurTab(-1)
end
NEW_FORM_RANK.C50407_OnUpdate = function( m )
local title, text = m:GetMainInfo(m.offset+3)
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_407, text)
end
NEW_FORM_RANK.C50408_OnClick = function( m )
local title = m:BeginQuery(3)
m:GetCurTab(-1)
end
NEW_FORM_RANK.C50408_OnUpdate = function( m )
local title, text = m:GetMainInfo(m.offset+4)
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_408, text)
end
NEW_FORM_RANK.C50409_OnClick = function( m )
local title = m:BeginQuery(4)
m:GetCurTab(-1)
end
NEW_FORM_RANK.C50409_OnUpdate = function( m )
local title, text = m:GetMainInfo(m.offset+5)
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_409, text)
end
NEW_FORM_RANK.C50410_OnClick = function( m )
local title = m:BeginQuery(5)
m:GetCurTab(-1)
end
NEW_FORM_RANK.C50410_OnUpdate = function( m )
local title, text = m:GetMainInfo(m.offset+6)
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_410, text)
end
NEW_FORM_RANK.C50434_OnClick = function( m )
m:OnClick(0, m.userSelectItem)

end
NEW_FORM_RANK.C50435_OnClick = function( m )
m:OnClick(1, m.userSelectItem)


end
NEW_FORM_RANK.C50444_OnClick = function( m )
m:GetCurTab(0)
end
