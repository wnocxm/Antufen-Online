NEW_FORM_UNION_CITY= { }
NEW_FORM_UNION_CITY.Main = function( m )
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
NEW_FORM_UNION_CITY.C50867_OnClick = function( m )
m:Close()
end
local DrawText = function(m, nID, offset)
	local city, union = m:GetDrawInfo(m.offset + offset)
	if city ~= nil then
		UI_Engine.SetText(m.formIndex, nID, city)
		UI_Engine.SetText(m.formIndex, nID, union, 1)
	end
end
NEW_FORM_UNION_CITY.C50860_OnUpdate = function( m )
DrawText(m, UI2_COMPOSIT_860, 0)
end
NEW_FORM_UNION_CITY.C50861_OnUpdate = function( m )
DrawText(m, UI2_COMPOSIT_861, 1)
end
NEW_FORM_UNION_CITY.C50862_OnUpdate = function( m )
DrawText(m, UI2_COMPOSIT_862, 2)
end
NEW_FORM_UNION_CITY.C50863_OnUpdate = function( m )
DrawText(m, UI2_COMPOSIT_863, 3)
end
NEW_FORM_UNION_CITY.C50864_OnUpdate = function( m )
DrawText(m, UI2_COMPOSIT_864, 4)
end
NEW_FORM_UNION_CITY.C50865_OnUpdate = function( m )
DrawText(m, UI2_COMPOSIT_865, 5)
end
NEW_FORM_UNION_CITY.C50866_OnUpdate = function( m )
DrawText(m, UI2_COMPOSIT_866, 6)
end
