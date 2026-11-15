FORM_REGISTER= { }
FORM_REGISTER.Main = function( m )
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
FORM_REGISTER.C52001_OnClick = function( m )
m:InputFinished()
end
FORM_REGISTER.C51999_OnClick = function( m )
local name,pwd,Apwd=m:GetAll()

if name==nil then
m.MsgBox = NewMsgBox(m," 用户名不能为空！！" ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)

elseif pwd==nil then
m.MsgBox = NewMsgBox(m,"密码不能为空！！" ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)

elseif Apwd==nil then
m.MsgBox = NewMsgBox(m,"确认密码不能为空！！" ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)

else
m:Register()
end
end
FORM_REGISTER.C50133_OnClick = function( m )
local formIndex,name =m:GetUserPhone()
m.InputBox = OpenInputBox(m,name,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserPhone(result)
UI_Engine.SetText(formIndex,COMPOSIT_REGISTER_IPNUTPHONE,result,0)
end
FORM_REGISTER.C50137_OnClick = function( m )
local formIndex ,pwd =m:GetUserAffirmPwd()
m.InputBox = OpenInputBox(m,pwd,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
formIndex ,pwd =m:GetUserPwd() 
if result==pwd then
m:SetUserAffirmPwd(result)
UI_Engine.SetText(formIndex,COMPOSIT_REGISTER_INPUTAFFIRM,"******",0)
else
m.MsgBox = NewMsgBox(m,"与输入密码不一致！！" ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)
m:SetUserAffirmPwd("")
UI_Engine.SetText(formIndex,COMPOSIT_REGISTER_INPUTAFFIRM,"",0)
end
end
FORM_REGISTER.C50136_OnClick = function( m )
local formIndex ,pwd =m:GetUserPwd()
m.InputBox = OpenInputBox(m,pwd,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserPwd(result)
UI_Engine.SetText(formIndex,COMPOSIT_REGISTER_INPUTPWD,"******",0)
end
FORM_REGISTER.C50135_OnClick = function( m )
local formIndex,name =m:GetUserName()
m.InputBox = OpenInputBox(m,name,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserName(result)
UI_Engine.SetText(formIndex,COMPOSIT_REGISTER_INPUTUSER,result,0)
end
