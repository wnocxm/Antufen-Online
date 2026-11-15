NEW_FORM_SENDMAIL= { }
NEW_FORM_SENDMAIL.Main = function( m )
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
local UpDate = function(m)             --更新
	local strText = m:GetContent()  --刷新文本
	UI_Engine.SetText( m.formIndex, UI1_COMPOSIT_SENDMAIL_TEXT, strText )
	
	local strNickName = m:GetNickName()   --刷新名字
	UI_Engine.SetText( m.formIndex, UI1_COMPOSIT_SENDMAIL_RECEIVE, strNickName )
	
	local nMoney = m:GetLookMailMoney()     --刷新金额
	UI_Engine.SetText( m.formIndex, UI1_COMPOSIT_SENDMAIL_MONEY, nMoney )
	
	if m.nMailOpenType == MailOpenType.TYPE_MAIL_SEND then  --刷新小键盘
		UI_Engine.SetState(m.formIndex ,UI1_COMPOSIT_SENDMAIL_RECEIVE,0)
		UI_Engine.SetState(m.formIndex ,UI1_COMPOSIT_SENDMAIL_MONEY,0)		
	end
	--UpDateMenu(m)
end

NEW_FORM_SENDMAIL.C50179_OnLoad = function( m )
m.nMailOpenType = m:GetOpenType()
m.nMailSendType = m:GetSendType()
UpDate(m)

end
NEW_FORM_SENDMAIL.C50179_OnClick = function( m )
local name =m:GetNickName()
m.InputBox = OpenInputBox(m,name,25)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if result  == nil then
	return 
end
if Tools.JudgeSpecialWord(result) then
	WarnUser(m, STR_INPUT_ERROR)
	return 
end
m:SetReceiver(result)
UpDate(m)
end
NEW_FORM_SENDMAIL.C50179_OnDraw = function( m )
local strNickName = m:GetNickName()
UI_Engine.SetText( m.formIndex, UI1_COMPOSIT_SENDMAIL_RECEIVE, strNickName )
end
NEW_FORM_SENDMAIL.C50180_OnClick = function( m )
local nMoney = m:GetLookMailMoney()
	m.InputBox = OpenInputBox(m,nMoney ,25)
	m.InputBox :WaitUserInput(m)
	local result = m.InputBox :GetResult()
	if result == nil then
		return 
	end
	if false == Tools.IsNumberOnly(result) then
		WarnUser(m, STR_ONLY_NUM)
		result = 0
		UI_Engine.SetText(m.formIndex, COMPOSIT_MONEY_EDITOR, result)
	end
	m:SetMoney(result)
UpDate(m)
end
NEW_FORM_SENDMAIL.C50182_OnClick = function( m )
local vItem = m:GetItemList()
local nMailSendType = m:GetSendType()
m.Popup = NewPopupItemListForSend(m, vItem,nMailSendType )
m.Popup :WaitUserInput(m)
local vItemList = m.Popup:GetItemList()
DelPopupItemListForSend( m.Popup )
m:SetItemList(vItemList)
end
NEW_FORM_SENDMAIL.C50187_OnClick = function( m )
--[
local name =m:GetNickName()
m.InputBox = OpenInputBox(m,name,25)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if result  == nil then
	return 
end
if Tools.JudgeSpecialWord(result) then
	WarnUser(m, R_STRING_CANNOT_INPUT_SPECIAL)
	return 
end
m:SetReceiver(result)
UpDate(m)
--]
end
NEW_FORM_SENDMAIL.C50187_OnDraw = function( m )
local name = m:ShowSelNum()
UI_Engine.SetText( m.formIndex, UI1_COMPOSIT_SENDMAIL_TEXTNUM_RECT, name)
end
NEW_FORM_SENDMAIL.C50175_OnClick = function( m )
DBGPRINTF("exit")
m:InputFinished()
m:Close()
DelMailSend(m)
end
NEW_FORM_SENDMAIL.C50215_OnClick = function( m )
local ptr = m:GetPointer()
m.friend = NewFriendList(m, ptr)
m.friend:WaitUserInput(m)
local ID = m.friend:GetUserSel()
DelFriendList(m.friend)
if ID ~= nil then
	m:SetReceiver(ID)
end
end
NEW_FORM_SENDMAIL.C50216_OnClick = function( m )
if m:IsMailItem() then
	if m.nMailSendType == MailSendType.SEND_MAIL_GM then
		m:SendGMMailMsg()
		m:InputFinished()
		m:Close()
		DelMailSend(m)
	elseif m.nMailSendType == MailSendType.SEND_MAIL_PLAYER then
		m:SendMailMsg() 
		m:InputFinished()
		m:Close()
		DelMailSend(m)
	end
else
	WarnUser(m, STR_NO_MAIL_ITEM)
end
end
NEW_FORM_SENDMAIL.C50233_OnClick = function( m )
local name =m:GetContent()
m.InputBox = OpenInputBox(m,name,100)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if result == nil  then
	return 
end
m:SetContent(result)
UpDate(m)
end
