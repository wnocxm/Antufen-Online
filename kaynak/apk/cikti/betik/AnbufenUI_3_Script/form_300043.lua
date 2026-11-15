NEW_FORM_DEPOSIT_V8= { }
NEW_FORM_DEPOSIT_V8.Main = function( m )
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
NEW_FORM_DEPOSIT_V8.C50816_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_DEPOSIT_V8.C50816_OnClick = function( m )
m:InputFinished()
m:Close()

end
local WarnUser = function(m, str)             --单项对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_OK)
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

NEW_FORM_DEPOSIT_V8.C50815_OnClick = function( m )
local nID = m:GetCardIDSize()
local nPwd = m:GetCardPwdSize()

if 0 >= nID then
	WarnUser(m,UI_Engine.GetLuaStr(STR_DEPOSIT_CARD_ID_EMPTY))
	return 
else
	if 0 >= nPwd then 
		WarnUser(m,UI_Engine.GetLuaStr(STR_DEPOSIT_CARD_PWD_EMPTY))
		return 
	end
end 

if nPwd ~= 18 then
	WarnUser(m,UI_Engine.GetLuaStr(STR_DEPOSIT_CARD_PWD_ERR))
	return 
end

local strInfo = m:GetInfo()

 if QueryUser(m,strInfo ) == MsgBox.ECODE_YES then
	m:OnConfirm()
 else
	return 
 end

end
NEW_FORM_DEPOSIT_V8.C50814_OnClick = function( m )
DBGPRINTF("cardpwd")
local name =m:GetCardPwd()
m.InputBox = OpenInputBox(m,name,18)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetCardPwd(result)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_814,result)

end
NEW_FORM_DEPOSIT_V8.C50812_OnClick = function( m )
DBGPRINTF("cardid")
local name =m:GetCardID()
m.InputBox = OpenInputBox(m,name,17)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetCardID(result)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_812,result)

end
NEW_FORM_DEPOSIT_V8.C50810_OnLoad = function( m )
local   name = m:GetSum()
UI_Engine.SetText(m.formIndex ,UI3_COMPOSIT_810, name)

end
NEW_FORM_DEPOSIT_V8.C50809_OnClick = function( m )
m:SetSum(1)

local   name = m:GetSum()
UI_Engine.SetText(m.formIndex ,UI3_COMPOSIT_810, name)

end
NEW_FORM_DEPOSIT_V8.C50808_OnClick = function( m )
m:SetSum(0)

local   name = m:GetSum()
UI_Engine.SetText(m.formIndex ,UI3_COMPOSIT_810, name)

end
