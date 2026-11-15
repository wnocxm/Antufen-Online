FORM_BUILD_MONEY= { }
FORM_BUILD_MONEY.Main = function( m )
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
FORM_BUILD_MONEY.C51813_OnLoad = function( m )
m.num = -1
end
local GetInput = function(m, ctlID)		-- 创建输入框
	local text = UI_Engine.GetText(m.formIndex, ctlID)
	m.InputBox = OpenInputBox(m,text,16)
	m.InputBox :WaitUserInput(m)
	local result = m.InputBox :GetResult()
	UI_Engine.SetText(m.formIndex,ctlID,result)
	return result
end
FORM_BUILD_MONEY.C52986_OnClick = function( m )
m:SetResult()
m:InputFinished()
end
FORM_BUILD_MONEY.C52987_OnClick = function( m )
m.num = GetInput(m, COMPOSIT_2987)
if false == Tools.IsNumberOnly(m.num) then
	WarnUser(m, "仅接受数字输入!")
	m.num = 0
	UI_Engine.SetText(m.formIndex, COMPOSIT_2987, m.num)
end
end
FORM_BUILD_MONEY.C52985_OnClick = function( m )
m:OnSet(m.num)
m:InputFinished()
end
