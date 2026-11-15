NEW_FORM_CITYBATTLE_RANK= { }
NEW_FORM_CITYBATTLE_RANK.Main = function( m )
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
NEW_FORM_CITYBATTLE_RANK.C50831_OnClick = function( m )
m:Close()
end
local DrawText = function(m, nID, offset)
	local rank, name, point = m:GetDrawInfo(m.offset + offset)
	if rank ~= nil then
		UI_Engine.SetText(m.formIndex, nID, rank)
		UI_Engine.SetText(m.formIndex, nID, name, 1)
		UI_Engine.SetText(m.formIndex, nID, point, 2)
	end
end
NEW_FORM_CITYBATTLE_RANK.C50824_OnUpdate = function( m )
DrawText(m, UI2_COMPOSIT_824, 0)
end
NEW_FORM_CITYBATTLE_RANK.C50825_OnUpdate = function( m )
DrawText(m, UI2_COMPOSIT_825, 1)
end
NEW_FORM_CITYBATTLE_RANK.C50826_OnUpdate = function( m )
DrawText(m, UI2_COMPOSIT_826, 2)
end
NEW_FORM_CITYBATTLE_RANK.C50827_OnUpdate = function( m )
DrawText(m, UI2_COMPOSIT_827, 3)
end
NEW_FORM_CITYBATTLE_RANK.C50828_OnUpdate = function( m )
DrawText(m, UI2_COMPOSIT_828, 4)
end
NEW_FORM_CITYBATTLE_RANK.C50829_OnUpdate = function( m )
DrawText(m, UI2_COMPOSIT_829, 5)
end
NEW_FORM_CITYBATTLE_RANK.C50830_OnUpdate = function( m )
DrawText(m, UI2_COMPOSIT_830, 6)
end
