FORM_MAIL= { }
FORM_MAIL.Main = function( m )
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

local UpDateMenu = function(m)
	local name,name1,name2,name3,name4,name5,name6,name7 = m:GetMenu()
	if name ~= nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_0,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_MENU_0,name)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_0,false)
	end
	
	if name1 ~= nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_1,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_MENU_1,name1)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_1,false)
	end
	
	if name2 ~= nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_2,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_MENU_2,name2)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_2,false)
	end
	
	if name3 == nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_3,false)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_3,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_MENU_3,name3)
	end
	
	if name4 == nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_4,false)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_4,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_MENU_4,name4)
	end
	
	if name5 == nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_5,false)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_5,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_MENU_5,name5)
	end
	
	if name6 == nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_6,false)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_6,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_MENU_6,name6)
	end
	
	if name7 == nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_7,false)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_MENU_7,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_MENU_7,name7)
	end

end

local UpDateItem = function(m)
	local img,name,nSN,nCount = m:GetMailItem()
	if img ~= nil then
		UI_Engine.SetSurfaceImg( m.formIndex, COMPOSIT_2910, img,0,0,false,nSN )
		UI_Engine.SetText( m.formIndex, COMPOSIT_2910, name.."x"..nCount,1 )
	else
		UI_Engine.SetSurfaceImg( m.formIndex, COMPOSIT_2910, nil ,0)
		UI_Engine.SetText( m.formIndex, COMPOSIT_2910, nil,1 )
	end
end

local UpDate = function(m)             --更新
	local strText = m:GetContent()  --刷新文本
	UI_Engine.SetText( m.formIndex, COMPOSIT_1250, strText )
	
	local strNickName = m:GetNickName()   --刷新名字
	UI_Engine.SetText( m.formIndex, COMPOSIT_ID_EDITOR, strNickName )
	
	local nMoney = m:GetLookMailMoney()     --刷新金额
	UI_Engine.SetText( m.formIndex, COMPOSIT_MONEY_EDITOR, nMoney )
	
	if m.nMailOpenType == MailOpenType.TYPE_MAIL_SEND then  --刷新小键盘
		UI_Engine.SetState(m.formIndex ,COMPOSIT_2707,0)
		UI_Engine.SetState(m.formIndex ,COMPOSIT_2708,0)
		UI_Engine.SetVisible( m.formIndex, COMPOSIT_2790 , true )
	else
		UI_Engine.SetState(m.formIndex ,COMPOSIT_2707,1)
		UI_Engine.SetState(m.formIndex ,COMPOSIT_2708,1)
		UI_Engine.SetVisible( m.formIndex, COMPOSIT_2790 , false )			
	end
	
	UpDateItem(m)
	UpDateMenu(m)
end

local ClickMenu = function(m,nType)
	if m.nMailOpenType == MailOpenType.TYPE_MAIL_SEND then
		if nType == MailMenuSend.MENU_LINKMAN then    --联系人
			local ptr = m:GetPointer()
			m.friend = NewFriendList(m, ptr)
			m.friend:WaitUserInput(m)
			local ID = m.friend:GetUserSel()
			DelFriendList(m.friend)
			if ID ~= nil then
				m:SetReceiver(ID)
			end
		elseif nType == MailMenuSend.MENU_SEND then --发送
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
				WarnUser(m, "没有发送邮件道具")
			end
			return
		elseif nType == MailMenuSend.MENU_ADD_ITEM then  --添加附件
			if m.nMailSendType == MailSendType.SEND_MAIL_GM then
				WarnUser(m, "不能给GM发送附件")
			elseif m.nMailSendType == MailSendType.SEND_MAIL_PLAYER then
				if m:IsItemMax() == false then
					WarnUser(m, "附件数量已达到上线")
					return
				end
				local pfunction, pfunction2= m:FuncMailSendFilter_lua()  --获取打开背
				m.package = NewPackage(m,pfunction,pfunction2)           --打开背包

				if m.package == nil then
					WarnUser(m, "背包里面没有能够邮寄的物品")
					return
				end

				m.package:WaitUserInput(m)
				local vSelect = m.package:GetSelectItem()
				local nSN,nNum = m.package:GetSelectSimpleItem()
				DelPackage(m.package )

				m:SetItem(vSelect , nSN, nNum )    --添加物品成功
			else
				WarnUser(m, "没有物品")
			end
		elseif nType == MailMenuSend.MENU_DELETE_ITEM then		--删除附件
			m:RemoveItem()
		elseif nType == MailMenuSend.MENU_ITEM_INFO then   --详细
			local vInfo, name = m:GetInfo()
			if vInfo~= nil then
				m.info = NewInfo(m,name,vInfo)
				m.info:WaitUserInput(m)
				DelInfo(m.info)
			end
			return 
		end
	else
		if nType == MailMenuLook.MENU_RECEIVE then     --接受
			m:MailReceive(1)
		elseif nType == MailMenuLook.MENU_REPLY then --回复
			if m:GetLookMailType() ~=  MailType.MAIL_TYPE_GAME then 
				WarnUser(m, "无法回复GM或系统")
				return 
			end
			m:SetCloseType(MailExitType.EXIT_REPLY)
			m:InputFinished()
		elseif nType == MailMenuLook.MENU_DELETE then  --删除
			if QueryUser(m, "确实删除？") == MsgBox.ECODE_YES  then
				m:SetCloseType(MailExitType.EXIT_DELETE)
				m:InputFinished()
			end
		elseif nType == MailMenuLook.MENU_ADDFRIEND then		--添加好友
			--if m:GetLookMailType() ~=  MailType.MAIL_TYPE_GAME then 
				--WarnUser(m, "GM和系统不能加为好友")
			--end
			--if m:CanAddFriend() == false then
			--	WarnUser(m, "玩家不能加为好友")
			--end

			if m:AddFriend() == false then
				WarnUser(m, "玩家不能添加为好友")
			end
		elseif nType == MailMenuLook.MENU_RECEIVE_MONEY then   --取钱
			m:MailReceive(2)
		elseif nType == MailMenuLook.MENU_RECEIVE_ALL then       --全部接受
			m:MailReceive(3)
			m:SetCloseType(MailExitType.EXIT_RECEIVE)
			m:InputFinished()
		end
	end
	
	UpDate(m)
end
FORM_MAIL.C52360_OnLoad = function( m )
m.nMailOpenType = m:GetOpenType()
m.nMailSendType = m:GetSendType()
UpDate(m)

end
FORM_MAIL.C52360_OnClick = function( m )
if m.nMailOpenType == MailOpenType.TYPE_MAIL_SEND then
--打开的方式是发送模式
	local name =m:GetNickName()
	m.InputBox = OpenInputBox(m,name,25)
	m.InputBox :WaitUserInput(m)
	local result = m.InputBox :GetResult()
	if result  == nil then
		return 
	end
	if Tools.JudgeSpecialWord(result) then
		WarnUser(m, "输入不合法，请重新输入!")
		return 
	end
	m:SetReceiver(result)
	UpDate(m)
else
--打开的方式是查看模式
	
end


end
FORM_MAIL.C52360_OnDraw = function( m )
	local strNickName = m:GetNickName()
	UI_Engine.SetText( m.formIndex, COMPOSIT_ID_EDITOR, strNickName )
end
FORM_MAIL.C52361_OnClick = function( m )
if m.nMailOpenType == MailOpenType.TYPE_MAIL_SEND then
--打开的方式是发送模式
	local nMoney = m:GetLookMailMoney()
	m.InputBox = OpenInputBox(m,nMoney ,25)
	m.InputBox :WaitUserInput(m)
	local result = m.InputBox :GetResult()
	if result == nil then
		return 
	end
	if false == Tools.IsNumberOnly(result) then
		WarnUser(m, "仅接受数字输入!")
		result = 0
		UI_Engine.SetText(m.formIndex, COMPOSIT_MONEY_EDITOR, result)
	end
	m:SetMoney(result)

	UpDate(m)
else
--打开的方式是查看模式
	
end


end
FORM_MAIL.C52969_OnLoad = function( m )
if m.nMailOpenType == MailOpenType.TYPE_MAIL_SEND then
	UI_Engine.SetText(m.formIndex,COMPOSIT_2969,"收件人（ID）")
else
--打开的方式是查看模式
	UI_Engine.SetText(m.formIndex,COMPOSIT_2969,"发件人（ID）")
end

end
FORM_MAIL.C51214_OnClick = function( m )
local nType = m:DoMenu(0)
ClickMenu(m,nType)
end
FORM_MAIL.C51162_OnClick = function( m )
local nType = m:DoMenu(1)
ClickMenu(m,nType)
end
FORM_MAIL.C51161_OnClick = function( m )
local nType = m:DoMenu(2)
ClickMenu(m,nType)
end
FORM_MAIL.C51164_OnClick = function( m )
local nType = m:DoMenu(3)
ClickMenu(m,nType)
end
FORM_MAIL.C52911_OnClick = function( m )
local nType = m:DoMenu(4)
ClickMenu(m,nType)
end
FORM_MAIL.C52912_OnClick = function( m )
local nType = m:DoMenu(5)
ClickMenu(m,nType)
end
FORM_MAIL.C52913_OnClick = function( m )
local nType = m:DoMenu(6)
ClickMenu(m,nType)
end
FORM_MAIL.C52869_OnClick = function( m )
m:SetSel(1)
UpDateItem(m)
end
FORM_MAIL.C52868_OnClick = function( m )
m:SetSel(0)
UpDateItem(m)
end
FORM_MAIL.C52914_OnDraw = function( m )
local name = m:ShowSelNum()
UI_Engine.SetText( m.formIndex, COMPOSIT_2914, name)

end
FORM_MAIL.C52710_OnClick = function( m )
DBGPRINTF("exit")
m:InputFinished()
m:Close()
DelMailSend(m)
end
FORM_MAIL.C51185_OnLoad = function( m )
UI_Engine.SetText( m.formIndex, COMPOSIT_1185, "邮件")

end
FORM_MAIL.C51250_OnClick = function( m )
if m.nMailOpenType == MailOpenType.TYPE_MAIL_SEND then
--打开的方式是发送模式
	local name =m:GetContent()
	m.InputBox = OpenInputBox(m,name,200)
	m.InputBox :WaitUserInput(m)
	local result = m.InputBox :GetResult()
	if result == nil  then
		return 
	end
	m:SetContent(result)

	UpDate(m)
else
--打开的方式是查看模式
	
end


end
