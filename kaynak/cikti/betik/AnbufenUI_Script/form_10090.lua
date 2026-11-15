FORM_INPUTBOX= { }
FORM_INPUTBOX.Main = function( m )
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
FORM_INPUTBOX.C52463_OnLoad = function( m )
local name = m:GetPrompt()
UI_Engine.SetText( m.formIndex, COMPOSIT_2463, name)
end
FORM_INPUTBOX.C52793_OnClick = function( m )
local name = UI_Engine.GetText(m.formIndex, COMPOSIT_2464 )
m:SetInput(name)
m:Close(1)
m:InputFinished()

end
FORM_INPUTBOX.C52792_OnClick = function( m )
m:Close(0)
m:InputFinished()

end
FORM_INPUTBOX.C52464_OnLoad = function( m )
local name = m:GetInput()
UI_Engine.SetText( m.formIndex, COMPOSIT_2464, name)
end
FORM_INPUTBOX.C52464_OnClick = function( m )
local name = m:GetInput()
local nMax = m:MaxLen()

m.InputBox = OpenInputBox(m,name,nMax )
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if Tools.JudgeSpecialWord(result) then
	WarnUser(m, "输入不合法，请重新输入!")
	result = name
end

UI_Engine.SetText(m.formIndex, COMPOSIT_2464 ,result )




end
