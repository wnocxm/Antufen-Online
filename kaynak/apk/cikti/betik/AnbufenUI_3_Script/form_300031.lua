NEW_FORM_REGISTER= { }
NEW_FORM_REGISTER.Main = function( m )
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
NEW_FORM_REGISTER.C50579_OnClick = function( m )
local name,pwd,Apwd=m:GetAll()

if name==nil then
m.MsgBox = NewMsgBox(m,UI_Engine.GetLuaStr(R_STRING_USERNULL)  ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)

elseif pwd==nil then
m.MsgBox = NewMsgBox(m,UI_Engine.GetLuaStr(R_STRING_PWDNULL) ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)

elseif Apwd==nil then
m.MsgBox = NewMsgBox(m,UI_Engine.GetLuaStr(R_STRING_SUER_NO) ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)

else
m:Register()
end
end
NEW_FORM_REGISTER.C50580_OnClick = function( m )
m:InputFinished()
end
NEW_FORM_REGISTER.C50581_OnClick = function( m )
local formIndex,name =m:GetUserName()
m.InputBox = OpenInputBox(m,name,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserName(result)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_REGISTER_INPUTUSER,result,0)

end
NEW_FORM_REGISTER.C50582_OnClick = function( m )
local formIndex ,pwd =m:GetUserPwd()
m.InputBox = OpenInputBox(m,pwd,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserPwd(result)
local formIndex ,pwd,nlen =m:GetUserPwd()
if nlen == 0 then
UI_Engine.SetText(formIndex,UI3_COMPOSIT_REGISTER_INPUTPWD,"",0)
else
UI_Engine.SetText(formIndex,UI3_COMPOSIT_REGISTER_INPUTPWD,"******",0)
end
end
NEW_FORM_REGISTER.C50583_OnClick = function( m )
local formIndex ,pwd =m:GetUserAffirmPwd()
m.InputBox = OpenInputBox(m,pwd,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
formIndex ,pwd =m:GetUserPwd() 
if result==pwd then
m:SetUserAffirmPwd(result)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_REGISTER_INPUTAFFIRM,"******",0)
else
m.MsgBox = NewMsgBox(m,UI_Engine.GetLuaStr(STR_PWD_NOSAME)  ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)
m:SetUserAffirmPwd("")
UI_Engine.SetText(formIndex,UI3_COMPOSIT_REGISTER_INPUTAFFIRM,"",0)
end

end
