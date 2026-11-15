FORM_REQUEST= { }
FORM_REQUEST.Main = function( m )
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
local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	UI_Engine.UpdateList(m.formIndex, COMPOSIT_1666)
	return result
end

local SetDrawInfo = function(m, offset, ctlID)	-- 设置显示信息
	local img, type, name = m:GetDrawInfo(offset)
	UI_Engine.SetSurfaceImg(m.formIndex, ctlID, img, 0)
	UI_Engine.SetText(m.formIndex, ctlID, type, 1)
	UI_Engine.SetText(m.formIndex, ctlID, name, 2)
end

local Confirm = function(m, sel)			-- 点击确定按钮
	local type ,type2,str1,str2= m:GetSelType(sel)
	if 4 == type then
		local ret = QueryUser(m, "你确定要接受公会战吗?")
		if MsgBox.ECODE_YES == ret then
			m:OnConfirm(type, sel)
			return true
		end
	elseif 2 == type then
		if 99 == type2 then
			local ret = QueryUser(m, str1)
			if MsgBox.ECODE_YES == ret then
				m:OnConfirm(type, sel)
				return true
			end
		elseif 88 == type2 then
			local ret = QueryUser(m, str1)
			if MsgBox.ECODE_YES == ret then
			--	local ret2 = QueryUser(m, str2)
			--	if MsgBox.ECODE_YES == ret2 then
					m:OnConfirm(type, sel)
			--	end
				return true
			end

		else
		m:OnConfirm(type, sel)
		end
	end
end

local SetBtn = function(m)
	local ret = m:IsCanRecive(m.userSelectItem)
	if ret ~= nil then
		if true == ret then
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_1657, true)
		else
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_1657, false)
		end
	end
end
FORM_REQUEST.C52735_OnClick = function( m )
DBGPRINTF("lua_info:End form")
m:InputFinished()
DelRequestForm(m)
end
FORM_REQUEST.C51659_OnClick = function( m )
DBGPRINTF("lua_info:End form")
m:InputFinished()
DelRequestForm(m)
end
FORM_REQUEST.C51658_OnClick = function( m )
m:OnDelItem(m.userSelectItem)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_1665)
end
FORM_REQUEST.C51657_OnClick = function( m )
Confirm(m, m.userSelectItem)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_1665)
end
FORM_REQUEST.C51664_OnFocus = function( m )
SetBtn(m)
end
FORM_REQUEST.C51664_OnDraw = function( m )
SetBtn(m)
end
FORM_REQUEST.C51664_OnUpdate = function( m )
SetDrawInfo(m, m.offset, COMPOSIT_1664)
end
FORM_REQUEST.C51665_OnFocus = function( m )
SetBtn(m)
end
FORM_REQUEST.C51665_OnUpdate = function( m )
SetDrawInfo(m, m.offset+1, COMPOSIT_1665)
end
FORM_REQUEST.C51666_OnFocus = function( m )
SetBtn(m)
end
FORM_REQUEST.C51666_OnUpdate = function( m )
SetDrawInfo(m, m.offset+2, COMPOSIT_1666)
end
FORM_REQUEST.C51667_OnFocus = function( m )
SetBtn(m)
end
FORM_REQUEST.C51667_OnUpdate = function( m )
SetDrawInfo(m, m.offset+3, COMPOSIT_1667)
end
FORM_REQUEST.C51668_OnFocus = function( m )
SetBtn(m)
end
FORM_REQUEST.C51668_OnUpdate = function( m )
SetDrawInfo(m, m.offset+4, COMPOSIT_1668)
end
FORM_REQUEST.C51669_OnFocus = function( m )
SetBtn(m)
end
FORM_REQUEST.C51669_OnUpdate = function( m )
SetDrawInfo(m, m.offset+5, COMPOSIT_1669)
end
FORM_REQUEST.C51670_OnFocus = function( m )
SetBtn(m)
end
FORM_REQUEST.C51670_OnUpdate = function( m )
SetDrawInfo(m, m.offset+6, COMPOSIT_1670)
end
FORM_REQUEST.C52706_OnFocus = function( m )
SetBtn(m)
end
FORM_REQUEST.C52706_OnUpdate = function( m )
SetDrawInfo(m, m.offset+7, COMPOSIT_2706)
end
FORM_REQUEST.C51655_OnLoad = function( m )
SetBtn(m)
end
