NEW_FORM_REQUEST= { }
NEW_FORM_REQUEST.Main = function( m )
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
NEW_FORM_REQUEST.C50250_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_REQUEST.C50250_OnClick = function( m )
DBGPRINTF("lua_info:End form")
m:InputFinished()
m:Close();

end
NEW_FORM_REQUEST.C50250_OnDraw = function( m )
UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_244)

end
local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_244)
	return result
end

local SetDrawInfo = function(m, offset, ctlID)	-- 设置显示信息
	local img, type, name = m:GetDrawInfo(offset)
	UI_Engine.SetSurfaceImg(m.formIndex, ctlID, img, 0)
	UI_Engine.SetText(m.formIndex, ctlID, type, 1)
	UI_Engine.SetText(m.formIndex, ctlID, name, 2)
end

local Confirm = function(m, sel)			-- 点击确定按钮
	m:GetSelType(sel)
end

NEW_FORM_REQUEST.C50242_OnClick = function( m )
Confirm(m, m.userSelectItem)

end
NEW_FORM_REQUEST.C50242_OnUpdate = function( m )
SetDrawInfo(m, m.offset, UI3_COMPOSIT_242)

end
NEW_FORM_REQUEST.C50243_OnClick = function( m )
Confirm(m, m.userSelectItem)

end
NEW_FORM_REQUEST.C50243_OnUpdate = function( m )
SetDrawInfo(m, m.offset+1, UI3_COMPOSIT_243)
end
NEW_FORM_REQUEST.C50244_OnClick = function( m )
Confirm(m, m.userSelectItem)

end
NEW_FORM_REQUEST.C50244_OnUpdate = function( m )
SetDrawInfo(m, m.offset+2, UI3_COMPOSIT_244)
end
NEW_FORM_REQUEST.C50245_OnClick = function( m )
Confirm(m, m.userSelectItem)

end
NEW_FORM_REQUEST.C50245_OnUpdate = function( m )
SetDrawInfo(m, m.offset+3, UI3_COMPOSIT_245)
end
NEW_FORM_REQUEST.C50246_OnClick = function( m )
Confirm(m, m.userSelectItem)

end
NEW_FORM_REQUEST.C50246_OnUpdate = function( m )
SetDrawInfo(m, m.offset+4, UI3_COMPOSIT_246)
end
NEW_FORM_REQUEST.C50247_OnClick = function( m )
Confirm(m, m.userSelectItem)

end
NEW_FORM_REQUEST.C50247_OnUpdate = function( m )
SetDrawInfo(m, m.offset+5, UI3_COMPOSIT_247)
end
NEW_FORM_REQUEST.C50248_OnClick = function( m )
Confirm(m, m.userSelectItem)

end
NEW_FORM_REQUEST.C50248_OnUpdate = function( m )
SetDrawInfo(m, m.offset+6, UI3_COMPOSIT_248)
end
NEW_FORM_REQUEST.C50398_OnClick = function( m )
Confirm(m, m.userSelectItem)


end
NEW_FORM_REQUEST.C50398_OnUpdate = function( m )
SetDrawInfo(m, m.offset+7, UI3_COMPOSIT_398)

end
