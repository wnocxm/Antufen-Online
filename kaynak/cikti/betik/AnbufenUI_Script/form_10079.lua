FORM_DEPOSIT_V8= { }
FORM_DEPOSIT_V8.Main = function( m )
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
local WarnUser = function(m, str)             --单项对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_CANCEL)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end
FORM_DEPOSIT_V8.C52081_OnLoad = function( m )
local   name = m:GetSum()
UI_Engine.SetText(m.formIndex ,COMPOSIT_2081, name)
end
FORM_DEPOSIT_V8.C52086_OnLoad = function( m )
UI_Engine.SetState(m.formIndex ,COMPOSIT_2086,1)
end
FORM_DEPOSIT_V8.C52074_OnClick = function( m )
m:SetSum(1)

local   name = m:GetSum()
UI_Engine.SetText(m.formIndex ,COMPOSIT_2081, name)
end
FORM_DEPOSIT_V8.C52073_OnClick = function( m )
m:SetSum(0)

local   name = m:GetSum()
UI_Engine.SetText(m.formIndex ,COMPOSIT_2081, name)
end
FORM_DEPOSIT_V8.C52082_OnClick = function( m )
DBGPRINTF("cardid")
local name =m:GetCardID()
m.InputBox = OpenInputBox(m,name,17)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetCardID(result)
UI_Engine.SetText(m.formIndex,COMPOSIT_2082,result)
end
FORM_DEPOSIT_V8.C52083_OnClick = function( m )
DBGPRINTF("cardpwd")
local name =m:GetCardPwd()
m.InputBox = OpenInputBox(m,name,18)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetCardPwd(result)
UI_Engine.SetText(m.formIndex,COMPOSIT_2083,result)
end
FORM_DEPOSIT_V8.C52062_OnClick = function( m )
m:InputFinished()
m:Close()
end
FORM_DEPOSIT_V8.C52061_OnClick = function( m )
local nID = m:GetCardIDSize()
local nPwd = m:GetCardPwdSize()

if 0 >= nID then
	if 0 >= nPwd then 
		WarnUser(m,"充值卡密码为空")
		return 
	end
	WarnUser(m,"充值卡账号为空")
	return 
end 

if nPwd ~= 18 then
	WarnUser(m,"充值卡密码位数错误")
	return 
end

local strInfo = m:GetInfo()

 if QueryUser(m,strInfo ) == MsgBox.ECODE_YES then
	m:OnConfirm()
 else
	return 
 end
end
FORM_DEPOSIT_V8.C52763_OnClick = function( m )
m:InputFinished()
m:Close()
end
