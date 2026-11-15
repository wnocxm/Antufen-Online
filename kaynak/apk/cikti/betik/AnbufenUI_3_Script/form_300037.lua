NEW_FORM_SERIALNUM= { }
NEW_FORM_SERIALNUM.Main = function( m )
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
NEW_FORM_SERIALNUM.C50682_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_SERIALNUM.C50682_OnClick = function( m )
DelSerialNumber(m)

end
NEW_FORM_SERIALNUM.C50680_OnClick = function( m )
m:OnClick()

end
NEW_FORM_SERIALNUM.C50681_OnClick = function( m )
DelSerialNumber(m)

end
NEW_FORM_SERIALNUM.C50676_OnClick = function( m )
DBGPRINTF("Serlia NO Input!")
local formIndex,text =m:GetText1()
m.InputBox = OpenInputBox(m,text,5)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if false == Tools.IsNoneChinese(result) then
	WarnUser(m, UI_Engine.GetLuaStr(R_STRING_NOINPUT))
	result = text
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_676, result)
	return
end
m:SetText1(result)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_676,result)

end
NEW_FORM_SERIALNUM.C50677_OnClick = function( m )
DBGPRINTF("Serlia NO Input!")
local formIndex,text =m:GetText2()
m.InputBox = OpenInputBox(m,text,5)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if false == Tools.IsNoneChinese(result) then
	WarnUser(m, UI_Engine.GetLuaStr(R_STRING_NOINPUT))
	result = text
	UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_677, result)
	return
end
m:SetText2(result)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_677,result)

end
NEW_FORM_SERIALNUM.C50678_OnClick = function( m )
DBGPRINTF("Serlia NO Input!")
local formIndex,text =m:GetText3()
m.InputBox = OpenInputBox(m,text,5)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if false == Tools.IsNoneChinese(result) then
	WarnUser(m, UI_Engine.GetLuaStr(R_STRING_NOINPUT))
	result = text
	UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_676, result)
	return
end
m:SetText3(result)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_678,result)

end
NEW_FORM_SERIALNUM.C50679_OnClick = function( m )
DBGPRINTF("Serlia NO Input!")
local formIndex,text =m:GetText4()
m.InputBox = OpenInputBox(m,text,5)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if false == Tools.IsNoneChinese(result) then
	WarnUser(m, UI_Engine.GetLuaStr(R_STRING_NOINPUT))
	result = text
	UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_676, result)
	return
end
m:SetText4(result)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_679,result)

end
