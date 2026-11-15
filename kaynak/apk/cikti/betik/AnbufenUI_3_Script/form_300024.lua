NEW_FORM_NPCLOOK= { }
NEW_FORM_NPCLOOK.Main = function( m )
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
NEW_FORM_NPCLOOK.C50771_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
local SetDrawInfo = function(m, offset, ctlID)	-- 设置列表信息
	local img, name, pos = m:GetDrawInfo(offset)
	if -1 == img then
		UI_Engine.SetSurfaceImg(m.formIndex, ctlID, nil, 0)
		UI_Engine.SetText(m.formIndex, ctlID, name, 1)
		UI_Engine.SetText(m.formIndex, ctlID, pos, 2)
	elseif nil == img then
		UI_Engine.SetSurfaceImg(m.formIndex, ctlID, nil, 0)
		UI_Engine.SetText(m.formIndex, ctlID, "", 1)
		UI_Engine.SetText(m.formIndex, ctlID, "", 2)
	else
		UI_Engine.SetImg(m.formIndex, ctlID, "UIData.godat", 2055, img, 0)
		UI_Engine.SetText(m.formIndex, ctlID, name, 1)
		UI_Engine.SetText(m.formIndex, ctlID, pos, 2)
	end
end
local Click = function(m)
if m.IsNew==1 then --add liao
	m:OnSearch(m.userSelectItem)
	m:InputFinished()
else
	m:OnSearch(m.userSelectItem)
	DelNPCLook(m)
end
end
NEW_FORM_NPCLOOK.C50772_OnClick = function( m )
if m.IsNew==1 then --add liao
	m:InputFinished()
else
	DelNPCLook(m)
end

end
NEW_FORM_NPCLOOK.C50837_OnClick = function( m )
Click(m)
end
NEW_FORM_NPCLOOK.C50837_OnUpdate = function( m )
SetDrawInfo(m, m.offset, UI3_COMPOSIT_NPC_0)
end
NEW_FORM_NPCLOOK.C50838_OnClick = function( m )
Click(m)
end
NEW_FORM_NPCLOOK.C50838_OnUpdate = function( m )
SetDrawInfo(m, m.offset+1, UI3_COMPOSIT_NPC_1)
end
NEW_FORM_NPCLOOK.C50839_OnClick = function( m )
Click(m)
end
NEW_FORM_NPCLOOK.C50839_OnUpdate = function( m )
SetDrawInfo(m, m.offset+2, UI3_COMPOSIT_NPC_2)
end
NEW_FORM_NPCLOOK.C50840_OnClick = function( m )
Click(m)
end
NEW_FORM_NPCLOOK.C50840_OnUpdate = function( m )
SetDrawInfo(m, m.offset+3, UI3_COMPOSIT_NPC_3)
end
NEW_FORM_NPCLOOK.C50841_OnClick = function( m )
Click(m)
end
NEW_FORM_NPCLOOK.C50841_OnUpdate = function( m )
SetDrawInfo(m, m.offset+4, UI3_COMPOSIT_NPC_4)
end
NEW_FORM_NPCLOOK.C50842_OnClick = function( m )
Click(m)
end
NEW_FORM_NPCLOOK.C50842_OnUpdate = function( m )
SetDrawInfo(m, m.offset+5, UI3_COMPOSIT_NPC_5)
end
NEW_FORM_NPCLOOK.C50843_OnClick = function( m )
Click(m)
end
NEW_FORM_NPCLOOK.C50843_OnUpdate = function( m )
SetDrawInfo(m, m.offset+6, UI3_COMPOSIT_NPC_6)
end
NEW_FORM_NPCLOOK.C50844_OnClick = function( m )
Click(m)
end
NEW_FORM_NPCLOOK.C50844_OnUpdate = function( m )
SetDrawInfo(m, m.offset+7, UI3_COMPOSIT_NPC_7)
end
