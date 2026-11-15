FORM_LOGIN_INPUT= { }
FORM_LOGIN_INPUT.Main = function( m )
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
FORM_LOGIN_INPUT.C50076_OnLoad = function( m )
--local formIndex,name =m:GetUserName()

--UI_Engine.SetState(formIndex,COMPOSIT_LOGIN_RADIO,1)

local b=m:IsSave()
UI_Engine.SetState(m.formIndex,COMPOSIT_LOGIN_RADIO,b)

end
FORM_LOGIN_INPUT.C51994_OnClick = function( m )
m.chg=NewLoginChgPwd(m)
m.chg:WaitUserInput(m)

local bOK,msg=m.chg:GetOK()
if bOK==1 then
local formIndex =m:GetUserPwd()
local t1 ,name=m.chg:GetUserName()
local t2 ,pwd= m.chg:GetUserPwd()
m:SetUserName(name)
m:SetUserPwd(pwd)
UI_Engine.SetText(formIndex,COMPOSIT_LOGIN_INPUTNAME,name,0)
UI_Engine.SetText(formIndex,COMPOSIT_LOGIN_INPUTPWD,"******",0)
end

DelLoginChgPwd(m.chg)

if bOK==1 then
m.MsgBox = NewMsgBox(m,msg ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)
end
end
FORM_LOGIN_INPUT.C51992_OnClick = function( m )
m.reg=NewLoginReg(m)
m.reg:WaitUserInput(m)

local bOK,msg=m.reg:GetOK()
if bOK==1 then
local formIndex =m:GetUserPwd()
local t1 ,name=m.reg:GetUserName()
local t2 ,pwd= m.reg:GetUserPwd()
m:SetUserName(name)
m:SetUserPwd(pwd)
UI_Engine.SetText(formIndex,COMPOSIT_LOGIN_INPUTNAME,name,0)
UI_Engine.SetText(formIndex,COMPOSIT_LOGIN_INPUTPWD,"******",0)

end
DelLoginReg(m.reg)

if bOK==1 then
m.MsgBox = NewMsgBox(m,msg ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)
end


end
FORM_LOGIN_INPUT.C50084_OnClick = function( m )
DBGPRINTF("lua_info:onclick login")
local formIndex,name =m:GetUserName()
m.InputBox = OpenInputBox(m,name,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserName(result)
UI_Engine.SetText(formIndex,COMPOSIT_LOGIN_INPUTNAME,result,0)
end
FORM_LOGIN_INPUT.C50085_OnClick = function( m )
local formIndex ,pwd =m:GetUserPwd()
m.InputBox = OpenInputBox(m,pwd,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserPwd(result)
UI_Engine.SetText(formIndex,COMPOSIT_LOGIN_INPUTPWD,"******",0)
end
FORM_LOGIN_INPUT.C50094_OnClick = function( m )
m:InputFinished()
m:Close()
end
FORM_LOGIN_INPUT.C50092_OnClick = function( m )
local formIndex,name =m:GetUserName()

m:UserLogin(UI_Engine.GetState(formIndex,COMPOSIT_LOGIN_RADIO))
end
