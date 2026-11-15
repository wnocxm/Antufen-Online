FORM_SERIALNUM= { }
FORM_SERIALNUM.Main = function( m )
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
FORM_SERIALNUM.C52167_OnClick = function( m )
DBGPRINTF("Serlia NO Input!")
local formIndex,text =m:GetText1()
m.InputBox = OpenInputBox(m,text,5)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if false == Tools.IsNoneChinese(result) then
	WarnUser(m, "输入无效，请输入字母和数字!")
	result = text
	UI_Engine.SetText(m.formIndex, COMPOSIT_2167, result)
	return
end
m:SetText1(result)
UI_Engine.SetText(formIndex,COMPOSIT_2167,result)
end
FORM_SERIALNUM.C52166_OnClick = function( m )
DBGPRINTF("Serlia NO Input!")
local formIndex,text =m:GetText2()
m.InputBox = OpenInputBox(m,text,5)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if false == Tools.IsNoneChinese(result) then
	WarnUser(m, "输入无效，请输入字母和数字!")
	result = text
	UI_Engine.SetText(m.formIndex, COMPOSIT_2166, result)
	return
end
m:SetText2(result)
UI_Engine.SetText(formIndex,COMPOSIT_2166,result)
end
FORM_SERIALNUM.C52165_OnClick = function( m )
DBGPRINTF("Serlia NO Input!")
local formIndex,text =m:GetText3()
m.InputBox = OpenInputBox(m,text,5)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if false == Tools.IsNoneChinese(result) then
	WarnUser(m, "输入无效，请输入字母和数字!")
	result = text
	UI_Engine.SetText(m.formIndex, COMPOSIT_2167, result)
	return
end
m:SetText3(result)
UI_Engine.SetText(formIndex,COMPOSIT_2165,result)
end
FORM_SERIALNUM.C52164_OnClick = function( m )
DBGPRINTF("Serlia NO Input!")
local formIndex,text =m:GetText4()
m.InputBox = OpenInputBox(m,text,5)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if false == Tools.IsNoneChinese(result) then
	WarnUser(m, "输入无效，请输入字母和数字!")
	result = text
	UI_Engine.SetText(m.formIndex, COMPOSIT_2167, result)
	return
end
m:SetText4(result)
UI_Engine.SetText(formIndex,COMPOSIT_2164,result)
end
FORM_SERIALNUM.C52789_OnClick = function( m )
m:OnClick()
end
FORM_SERIALNUM.C52788_OnClick = function( m )
DelSerialNumber(m)
end
