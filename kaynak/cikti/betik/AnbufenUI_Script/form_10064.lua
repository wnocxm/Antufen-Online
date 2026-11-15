FORM_NPCLOOK= { }
FORM_NPCLOOK.Main = function( m )
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
FORM_NPCLOOK.C51705_OnClick = function( m )
if m.IsNew==1 then --add liao
	m:OnSearch(m.userSelectItem)
	m:InputFinished()
else
	m:OnSearch(m.userSelectItem)
	DelNPCLook(m)
end
end
FORM_NPCLOOK.C52703_OnUpdate = function( m )
SetDrawInfo(m, m.offset, COMPOSIT_2703)
end
FORM_NPCLOOK.C52702_OnUpdate = function( m )
SetDrawInfo(m, m.offset+1, COMPOSIT_2702)
end
FORM_NPCLOOK.C52701_OnUpdate = function( m )
SetDrawInfo(m, m.offset+2, COMPOSIT_2701)
end
FORM_NPCLOOK.C52700_OnUpdate = function( m )
SetDrawInfo(m, m.offset+3, COMPOSIT_2700)
end
FORM_NPCLOOK.C52699_OnUpdate = function( m )
SetDrawInfo(m, m.offset+4, COMPOSIT_2699)
end
FORM_NPCLOOK.C52698_OnUpdate = function( m )
SetDrawInfo(m, m.offset+5, COMPOSIT_2698)
end
FORM_NPCLOOK.C52697_OnUpdate = function( m )
SetDrawInfo(m, m.offset+6, COMPOSIT_2697)
end
FORM_NPCLOOK.C52704_OnClick = function( m )
if m.IsNew==1 then --add liao
	m:InputFinished()
else
	DelNPCLook(m)
end
end
