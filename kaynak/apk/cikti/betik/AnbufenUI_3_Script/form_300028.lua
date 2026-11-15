NEW_FORM_LOGIN_INPUT= { }
NEW_FORM_LOGIN_INPUT.Main = function( m )
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
NEW_FORM_LOGIN_INPUT.C50562_OnLoad = function( m )
local b=m:IsSave()
UI_Engine.SetState(m.formIndex,UI3_COMPOSIT_RADIO,b)


end
NEW_FORM_LOGIN_INPUT.C50566_OnClick = function( m )
m.chg=NewLoginChgPwd(m)
m.chg:WaitUserInput(m)

local bOK,msg=m.chg:GetOK()
if bOK==1 then
local formIndex =m:GetUserPwd()
local t1 ,name=m.chg:GetUserName()
local t2 ,pwd= m.chg:GetUserPwd()
m:SetUserName(name)
m:SetUserPwd(pwd)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_LOGIN_INPUTNAME,name,0)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_LOGIN_INPUTPWD,"******",0)
end

DelLoginChgPwd(m.chg)

if bOK==1 then
m.MsgBox = NewMsgBox(m,msg ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)
end

end
NEW_FORM_LOGIN_INPUT.C50565_OnClick = function( m )
m.reg=NewLoginReg(m)
m.reg:WaitUserInput(m)

local bOK,msg=m.reg:GetOK()
if bOK==1 then
local formIndex =m:GetUserPwd()
local t1 ,name=m.reg:GetUserName()
local t2 ,pwd= m.reg:GetUserPwd()
m:SetUserName(name)
m:SetUserPwd(pwd)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_LOGIN_INPUTNAME,name,0)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_LOGIN_INPUTPWD,"******",0)

end
DelLoginReg(m.reg)

if bOK==1 then
m.MsgBox = NewMsgBox(m,msg ,MsgBox.MODE_OK)
m.MsgBox:WaitUserInput(m)
DelMsgBox(m.MsgBox)
end



end
NEW_FORM_LOGIN_INPUT.C50571_OnClick = function( m )
DBGPRINTF("lua_info:onclick login")
local formIndex,name =m:GetUserName()
m.InputBox = OpenInputBox(m,name,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserName(result)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_LOGIN_INPUTNAME,result,0)


end
NEW_FORM_LOGIN_INPUT.C50572_OnClick = function( m )
local formIndex ,pwd,nlen=m:GetUserPwd()
m.InputBox = OpenInputBox(m,pwd,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserPwd(result)
local formIndex ,pwd,nlen=m:GetUserPwd()
if nlen==0 then
	UI_Engine.SetText(formIndex,UI3_COMPOSIT_LOGIN_INPUTPWD,"",0)
else
	UI_Engine.SetText(formIndex,UI3_COMPOSIT_LOGIN_INPUTPWD,"******",0)	
end
end
NEW_FORM_LOGIN_INPUT.C50564_OnClick = function( m )
local formIndex,name =m:GetUserName()
m:UserLogin(UI_Engine.GetState(formIndex,UI3_COMPOSIT_RADIO))

end
NEW_FORM_LOGIN_INPUT.C50567_OnClick = function( m )
m:InputFinished()
m:Close()

end
