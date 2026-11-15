NEW_FORM_INPUTBOX= { }
NEW_FORM_INPUTBOX.Main = function( m )
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
NEW_FORM_INPUTBOX.C50650_OnLoad = function( m )
local name = m:GetPrompt()
UI_Engine.SetRollText( m.formIndex, UI3_COMPOSIT_650, name)
end
NEW_FORM_INPUTBOX.C50656_OnLoad = function( m )
local name = m:GetInput()
UI_Engine.SetText( m.formIndex,UI3_COMPOSIT_656, name)

end
NEW_FORM_INPUTBOX.C50656_OnClick = function( m )
local name = m:GetInput()
local nMax = m:MaxLen()
local mode = m:GetMode()
m.InputBox = OpenInputBox(m,name,nMax )
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if 0 == mode then
	if false == Tools.IsNumberOnly(result) then
		WarnUser(m, UI_Engine.GetLuaStr(R_STRING_INTO_CHAIN))
		result = name
	end
else
	if Tools.JudgeSpecialWord(result) then
		WarnUser(m, UI_Engine.GetLuaStr(R_STRING_NO_LEGAL))
		result = name
	end
end
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_656 ,result )
end
NEW_FORM_INPUTBOX.C50644_OnClick = function( m )
local name = UI_Engine.GetText(m.formIndex, UI3_COMPOSIT_656)
m:SetInput(name)
m:Close(1)
m:InputFinished()
end
NEW_FORM_INPUTBOX.C50645_OnClick = function( m )
m:Close(0)
m:InputFinished()


end
