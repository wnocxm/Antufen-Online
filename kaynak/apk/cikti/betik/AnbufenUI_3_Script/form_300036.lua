NEW_FORM_IDEAREPORT= { }
NEW_FORM_IDEAREPORT.Main = function( m )
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
NEW_FORM_IDEAREPORT.C50663_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_IDEAREPORT.C50663_OnClick = function( m )
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

NEW_FORM_IDEAREPORT.C50662_OnClick = function( m )
m:OnConfirm()

end
NEW_FORM_IDEAREPORT.C50695_OnClick = function( m )
GetInput(m, UI3_COMPOSIT_661)


end
