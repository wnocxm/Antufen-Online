NEW_FORM_SELNUM= { }
NEW_FORM_SELNUM.Main = function( m )
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
local GetInput = function(m, ctlID)		-- 创建输入框
	local text = UI_Engine.GetText(m.formIndex, ctlID, 0)
	m.InputBox = OpenInputBox(m,text,9)
	m.InputBox :WaitUserInput(m)
	local result = m.InputBox :GetResult()
	UI_Engine.SetText(m.formIndex,ctlID,result,0)
	return result
end

local WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_CANCEL)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end


NEW_FORM_SELNUM.C50259_OnClick = function( m )
local ret = GetInput(m, UI3_COMPOSIT_NUMSEL_NUMBER)
if false == Tools.IsNumberOnly(ret) then
	WarnUser(m, UI_Engine.GetLuaStr(R_STRING_INTO_CHAIN))
	ret = m:GetResult()
	UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_NUMSEL_NUMBER, ret)
else
	m:GetInputNum(ret)
end

end
NEW_FORM_SELNUM.C50258_OnLoad = function( m )
UI_Engine.SetText(0, UI3_COMPOSIT_NUMSEL_MAX, "MAX")

end
NEW_FORM_SELNUM.C50258_OnClick = function( m )
m:SetMax()

end
NEW_FORM_SELNUM.C50256_OnLoad = function( m )
UI_Engine.SetText(0, UI3_COMPOSIT_NUMSEL_MIN, "MIN")

end
NEW_FORM_SELNUM.C50256_OnClick = function( m )
m:SetMin()
end
NEW_FORM_SELNUM.C50255_OnClick = function( m )
m:AddNum()

end
NEW_FORM_SELNUM.C50254_OnClick = function( m )
m:DecNum()

end
NEW_FORM_SELNUM.C50263_OnClick = function( m )
m:SetResult(0)
m:InputFinished()


end
NEW_FORM_SELNUM.C50264_OnClick = function( m )
m:SetResult(1)
m:InputFinished()


end
