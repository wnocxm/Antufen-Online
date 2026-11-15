NEW_FORM_EXCHANGE_ARENA= { }
NEW_FORM_EXCHANGE_ARENA.Main = function( m )
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
NEW_FORM_EXCHANGE_ARENA.C50786_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local DrawList = function(m, nId, index)
	local str, img, color, nSN = m:DrawList(m.offset + index)
	if str ~= nil then
		UI_Engine.SetSurfaceImg(m.formIndex, nId, img, 0, 0, false, nSN)
		UI_Engine.SetText(m.formIndex, nId, str, 1, color);
	else
		UI_Engine.SetSurfaceImg(m.formIndex, nId, nil, 0)
		UI_Engine.SetText(m.formIndex, nId, "", 1)
	end
end

local OnClickList= function(m)
	m:OnClickList(m.userSelectItem)
	local m_String,m_info,img,nSN = m:GetInfoPtr()
	m.info = NewItemInfo(m,img, m_String, m_info,nSN)
	m.info:WaitUserInput(m)
	local ret = m.info:GetResult()
	DelItemInfo(m.info)
	if ret == 2 then
		m:OnExchange()
	end
end
	

NEW_FORM_EXCHANGE_ARENA.C50154_OnClick = function( m )
DelExchange(m)
end
NEW_FORM_EXCHANGE_ARENA.C50176_OnClick = function( m )
OnClickList(m)

end
NEW_FORM_EXCHANGE_ARENA.C50176_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_176, 0)
end
NEW_FORM_EXCHANGE_ARENA.C50177_OnClick = function( m )
OnClickList(m)


end
NEW_FORM_EXCHANGE_ARENA.C50177_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_177, 1)
end
NEW_FORM_EXCHANGE_ARENA.C50178_OnClick = function( m )
OnClickList(m)


end
NEW_FORM_EXCHANGE_ARENA.C50178_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_178, 2)
end
NEW_FORM_EXCHANGE_ARENA.C50179_OnClick = function( m )
OnClickList(m)


end
NEW_FORM_EXCHANGE_ARENA.C50179_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_179, 3)
end
NEW_FORM_EXCHANGE_ARENA.C50180_OnClick = function( m )
OnClickList(m)


end
NEW_FORM_EXCHANGE_ARENA.C50180_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_180, 4)
end
NEW_FORM_EXCHANGE_ARENA.C50181_OnClick = function( m )
OnClickList(m)



end
NEW_FORM_EXCHANGE_ARENA.C50181_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_181, 5)
end
NEW_FORM_EXCHANGE_ARENA.C50182_OnClick = function( m )
OnClickList(m)


end
NEW_FORM_EXCHANGE_ARENA.C50182_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_182, 6)
end
NEW_FORM_EXCHANGE_ARENA.C50168_OnClick = function( m )
OnClickList(m)

end
NEW_FORM_EXCHANGE_ARENA.C50168_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_168, 0)
end
NEW_FORM_EXCHANGE_ARENA.C50169_OnClick = function( m )
OnClickList(m)

end
NEW_FORM_EXCHANGE_ARENA.C50169_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_169, 1)
end
NEW_FORM_EXCHANGE_ARENA.C50170_OnClick = function( m )
OnClickList(m)

end
NEW_FORM_EXCHANGE_ARENA.C50170_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_170, 2)
end
NEW_FORM_EXCHANGE_ARENA.C50171_OnClick = function( m )
OnClickList(m)

end
NEW_FORM_EXCHANGE_ARENA.C50171_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_171, 3)
end
NEW_FORM_EXCHANGE_ARENA.C50172_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50172_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_172, 4)
end
NEW_FORM_EXCHANGE_ARENA.C50173_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50173_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_173, 5)
end
NEW_FORM_EXCHANGE_ARENA.C50174_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50174_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_174, 6)
end
NEW_FORM_EXCHANGE_ARENA.C50159_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50159_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_159, 0)
end
NEW_FORM_EXCHANGE_ARENA.C50160_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50160_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_160, 1)
end
NEW_FORM_EXCHANGE_ARENA.C50161_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50161_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_161, 2)
end
NEW_FORM_EXCHANGE_ARENA.C50162_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50162_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_162, 3)
end
NEW_FORM_EXCHANGE_ARENA.C50163_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50163_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_163, 4)
end
NEW_FORM_EXCHANGE_ARENA.C50164_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50164_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_164, 5)
end
NEW_FORM_EXCHANGE_ARENA.C50165_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50165_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_165, 6)
end
NEW_FORM_EXCHANGE_ARENA.C50149_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50149_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_149, 0)
end
NEW_FORM_EXCHANGE_ARENA.C50144_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50144_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_144, 1)
end
NEW_FORM_EXCHANGE_ARENA.C50145_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50145_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_145, 2)
end
NEW_FORM_EXCHANGE_ARENA.C50146_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50146_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_146, 3)
end
NEW_FORM_EXCHANGE_ARENA.C50147_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50147_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_147, 4)
end
NEW_FORM_EXCHANGE_ARENA.C50155_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50155_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_155, 5)
end
NEW_FORM_EXCHANGE_ARENA.C50156_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE_ARENA.C50156_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_156, 6)
end
NEW_FORM_EXCHANGE_ARENA.C50203_OnClick = function( m )
m:OnClickTab(0)
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_177)
end
NEW_FORM_EXCHANGE_ARENA.C50202_OnClick = function( m )
m:OnClickTab(1)
UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_169)
end
NEW_FORM_EXCHANGE_ARENA.C50201_OnClick = function( m )
m:OnClickTab(2)
UI_Engine.SetFormTab(m.formIndex, 2)
UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_160)
end
NEW_FORM_EXCHANGE_ARENA.C50200_OnClick = function( m )
m:OnClickTab(3)
UI_Engine.SetFormTab(m.formIndex, 3)
UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_144)

end
NEW_FORM_EXCHANGE_ARENA.C50129_OnDraw = function( m )
m:DrawInfo()
end
