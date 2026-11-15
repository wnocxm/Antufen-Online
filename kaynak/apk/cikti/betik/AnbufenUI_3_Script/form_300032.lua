NEW_FORM_RESERVATION= { }
NEW_FORM_RESERVATION.Main = function( m )
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
NEW_FORM_RESERVATION.C50594_OnClick = function( m )
local formIndex,name =m:GetUserName()
m.InputBox = OpenInputBox(m,name,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserName(result)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_RESERVATION_INPUTUSER,result,0)

end
NEW_FORM_RESERVATION.C50595_OnClick = function( m )
local formIndex ,pwd =m:GetUserOldPwd()
m.InputBox = OpenInputBox(m,pwd,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserOldPwd(result)
local formIndex ,pwd,nlen =m:GetUserOldPwd()
if nlen == 0 then
UI_Engine.SetText(formIndex,UI3_COMPOSIT_RESERVATION_INPUTOLD,"",0)
else
UI_Engine.SetText(formIndex,UI3_COMPOSIT_RESERVATION_INPUTOLD,"******",0)
end
end
NEW_FORM_RESERVATION.C50596_OnClick = function( m )
local formIndex ,pwd =m:GetUserPwd()
m.InputBox = OpenInputBox(m,pwd,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserPwd(result)
local formIndex ,pwd,nlen =m:GetUserPwd()
if nlen == 0 then
UI_Engine.SetText(formIndex,UI3_COMPOSIT_RESERVATION_INPUTNEW,"",0)
else
UI_Engine.SetText(formIndex,UI3_COMPOSIT_RESERVATION_INPUTNEW,"******",0)
end
end
NEW_FORM_RESERVATION.C50597_OnClick = function( m )
local formIndex ,pwd =m:GetUserAffirmPwd()
m.InputBox = OpenInputBox(m,pwd,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
formIndex ,pwd =m:GetUserPwd() 
if result==pwd then
m:SetUserAffirmPwd(result)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_RESERVATION_INPUTAFFIRM,"******",0)
else
m.MsgBox = NewMsgBox(m,UI_Engine.GetLuaStr(STR_PWD_NOSAME) ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)
m:SetUserAffirmPwd("")
UI_Engine.SetText(formIndex,UI3_COMPOSIT_REGISTER_INPUTAFFIRM,"",0)
end

--m:SetUserAffirmPwd(result)
--UI_Engine.SetText(formIndex,UI3_COMPOSIT_RESERVATION_INPUTAFFIRM,"******",0)

end
NEW_FORM_RESERVATION.C50588_OnClick = function( m )
m:Change()

end
NEW_FORM_RESERVATION.C50589_OnClick = function( m )
m:InputFinished()

end
