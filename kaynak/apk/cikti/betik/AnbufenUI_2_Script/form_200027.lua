NEW_FORM_ARENA_REPORT_NEW= { }
NEW_FORM_ARENA_REPORT_NEW.Main = function( m )
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
local UpdateText = function(m, id, offset)
	local name, score = m:GetList(m.offset + offset)
	if name ~= nil then
		UI_Engine.SetText(m.formIndex, id, name)
		UI_Engine.SetText(m.formIndex, id, score, 1)
	else
		UI_Engine.SetText(m.formIndex, id, "")
		UI_Engine.SetText(m.formIndex, id, "", 1)
	end
end

local UpdateSingle = function(m, id, offset)
	local str = m:GetList(m.offset + offset)
	if str ~= nil then
		UI_Engine.SetText(m.formIndex, id, str)
	else
		UI_Engine.SetText(m.formIndex, id, "")
	end
end
NEW_FORM_ARENA_REPORT_NEW.C50855_OnDraw = function( m )
local strTime = m:GetTime()

if strTime then
	UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_855,strTime )
end
end
NEW_FORM_ARENA_REPORT_NEW.C50734_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
NEW_FORM_ARENA_REPORT_NEW.C50734_OnUpdate = function( m )
UpdateSingle(m, UI2_COMPOSIT_734, 0)
end
NEW_FORM_ARENA_REPORT_NEW.C50735_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
NEW_FORM_ARENA_REPORT_NEW.C50735_OnUpdate = function( m )
UpdateSingle(m, UI2_COMPOSIT_735, 1)
end
NEW_FORM_ARENA_REPORT_NEW.C50736_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
NEW_FORM_ARENA_REPORT_NEW.C50736_OnUpdate = function( m )
UpdateSingle(m, UI2_COMPOSIT_736, 2)
end
NEW_FORM_ARENA_REPORT_NEW.C50737_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
NEW_FORM_ARENA_REPORT_NEW.C50737_OnUpdate = function( m )
UpdateSingle(m, UI2_COMPOSIT_737, 3)
end
NEW_FORM_ARENA_REPORT_NEW.C50738_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
NEW_FORM_ARENA_REPORT_NEW.C50738_OnUpdate = function( m )
UpdateSingle(m, UI2_COMPOSIT_738, 4)
end
NEW_FORM_ARENA_REPORT_NEW.C50739_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
NEW_FORM_ARENA_REPORT_NEW.C50739_OnUpdate = function( m )
UpdateSingle(m, UI2_COMPOSIT_739, 5)
end
NEW_FORM_ARENA_REPORT_NEW.C50853_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
NEW_FORM_ARENA_REPORT_NEW.C50853_OnUpdate = function( m )
UpdateSingle(m, UI2_COMPOSIT_853, 6)
end
NEW_FORM_ARENA_REPORT_NEW.C50727_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
NEW_FORM_ARENA_REPORT_NEW.C50727_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_727, 0 )
end
NEW_FORM_ARENA_REPORT_NEW.C50728_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
NEW_FORM_ARENA_REPORT_NEW.C50728_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_728, 1)
end
NEW_FORM_ARENA_REPORT_NEW.C50729_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
NEW_FORM_ARENA_REPORT_NEW.C50729_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_729, 2 )
end
NEW_FORM_ARENA_REPORT_NEW.C50730_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
NEW_FORM_ARENA_REPORT_NEW.C50730_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_730, 3 )
end
NEW_FORM_ARENA_REPORT_NEW.C50731_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
NEW_FORM_ARENA_REPORT_NEW.C50731_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_731, 4 )
end
NEW_FORM_ARENA_REPORT_NEW.C50732_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
NEW_FORM_ARENA_REPORT_NEW.C50732_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_732, 5 )
end
NEW_FORM_ARENA_REPORT_NEW.C50722_OnClick = function( m )
m:GetTab(0)
UI_Engine.SetFormTab(m.formIndex, 0)
end
NEW_FORM_ARENA_REPORT_NEW.C50723_OnClick = function( m )
m:GetTab(1)
UI_Engine.SetFormTab(m.formIndex, 1)
end
