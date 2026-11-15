FORM_SELNUM= { }
FORM_SELNUM.Main = function( m )
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
FORM_SELNUM.C50764_OnLoad = function( m )
UI_Engine.SetText(0, COMPOSIT_NUMSEL_MIN, "MIN")
end
FORM_SELNUM.C50764_OnClick = function( m )
m:SetMin()
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
FORM_SELNUM.C50763_OnLoad = function( m )
UI_Engine.SetText(0, COMPOSIT_NUMSEL_MAX, "MAX")
end
FORM_SELNUM.C50763_OnClick = function( m )
m:SetMax()
end
FORM_SELNUM.C50761_OnClick = function( m )
local ret = GetInput(m, COMPOSIT_NUMSEL_NUMBER)
if false == Tools.IsNumberOnly(ret) then
	WarnUser(m, "仅接受数字输入!")
	ret = m:GetResult()
	UI_Engine.SetText(m.formIndex, COMPOSIT_NUMSEL_NUMBER, ret)
else
	m:GetInputNum(ret)
end
end
FORM_SELNUM.C50759_OnClick = function( m )
m:AddNum()
end
FORM_SELNUM.C50758_OnClick = function( m )
m:DecNum()
end
FORM_SELNUM.C52792_OnClick = function( m )
m:SetResult(1)
m:InputFinished()
end
FORM_SELNUM.C52791_OnClick = function( m )
m:SetResult(0)
m:InputFinished()
end
