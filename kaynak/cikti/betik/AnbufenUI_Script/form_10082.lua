FORM_IDEAREPORT= { }
FORM_IDEAREPORT.Main = function( m )
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
FORM_IDEAREPORT.C52733_OnClick = function( m )
m:InputFinished()
end
local GetInput = function(m, ctlID)		-- 创建输入框
	local text = UI_Engine.GetText(m.formIndex, ctlID, 0)
	m.InputBox = OpenInputBox(m,text,2048)
	m.InputBox :WaitUserInput(m)
	local result = m.InputBox :GetResult()
	if result == nil then
	return
	end
	
	UI_Engine.SetText(m.formIndex,ctlID,result,0)

	m:SetIdeaReport(result)
	
	return result
end
FORM_IDEAREPORT.C52124_OnClick = function( m )
m:OnConfirm()
m:InputFinished()
end
FORM_IDEAREPORT.C52811_OnClick = function( m )
GetInput(m, COMPOSIT_2810)
end
