FORM_INPUTIDCARD= { }
FORM_INPUTIDCARD.Main = function( m )
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
FORM_INPUTIDCARD.C52787_OnClick = function( m )
 if m:OnClick()==0 then
m.MsgBox = NewMsgBox(m,"请输入18位身份证号!!",MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)
else
m.MsgBox = NewMsgBox(m,"验证消息已发送……" ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)
--DelInputIDCard(m)
end
end
FORM_INPUTIDCARD.C52786_OnClick = function( m )
DelInputIDCard(m)
end
FORM_INPUTIDCARD.C52146_OnClick = function( m )
DBGPRINTF("ID Card Input!")
local formIndex,newID =m:GetCardID()
m.InputBox = OpenInputBox(m,newID,18)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()


if m:SetCardID(result) == 0 then
m.MsgBox = NewMsgBox(m,"请输入18位的身份证号！！" ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)
elseif m:SetCardID(result) == -1 then
m.MsgBox = NewMsgBox(m,"非法字符！！" ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)
result = ""
end
UI_Engine.SetText(formIndex,COMPOSIT_2146,result)

end
