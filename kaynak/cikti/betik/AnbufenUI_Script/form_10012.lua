FORM_RESERVATION= { }
FORM_RESERVATION.Main = function( m )
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
FORM_RESERVATION.C52002_OnClick = function( m )
m:InputFinished()
end
FORM_RESERVATION.C50124_OnClick = function( m )
m:Change()
end
FORM_RESERVATION.C50143_OnClick = function( m )
local formIndex ,pwd =m:GetUserAffirmPwd()
m.InputBox = OpenInputBox(m,pwd,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserAffirmPwd(result)
UI_Engine.SetText(formIndex,COMPOSIT_RESERVATION_INPUTAFFIRM,"******",0)
end
FORM_RESERVATION.C50142_OnClick = function( m )
local formIndex ,pwd =m:GetUserPwd()
m.InputBox = OpenInputBox(m,pwd,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserPwd(result)
UI_Engine.SetText(formIndex,COMPOSIT_RESERVATION_INPUTNEW,"******",0)
end
FORM_RESERVATION.C50141_OnClick = function( m )
local formIndex ,pwd =m:GetUserOldPwd()
m.InputBox = OpenInputBox(m,pwd,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserOldPwd(result)
UI_Engine.SetText(formIndex,COMPOSIT_RESERVATION_INPUTOLD,"******",0)
end
FORM_RESERVATION.C50140_OnClick = function( m )
local formIndex,name =m:GetUserName()
m.InputBox = OpenInputBox(m,name,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserName(result)
UI_Engine.SetText(formIndex,COMPOSIT_RESERVATION_INPUTUSER,result,0)
end
