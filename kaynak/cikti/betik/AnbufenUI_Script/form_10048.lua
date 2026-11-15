FORM_MAIL_LIST= { }
FORM_MAIL_LIST.Main = function( m )
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

local DrawDescribe = function(m, index)
	local strText = m:GetDescribe(index)
	if strText == nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_1255,false)
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_1254,false)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_1254,true)
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_1255,true)
	end

	if strText == nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_1258,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_1258,strText )
	end
end

local UpDateList = function(m)
	UI_Engine.UpdateList(m.formIndex ,COMPOSIT_MAIL_LIST_1)
	UI_Engine.UpdateList(m.formIndex ,COMPOSIT_1272)
	UI_Engine.UpdateList(m.formIndex ,COMPOSIT_1280)
end

local SetListItem = function(m,nIndex,composit)
	local imgMail, imgAnnex ,name , time = m:GetMailList(m.offset + nIndex)

	if imgMail == 0 then
	UI_Engine.SetSurfaceImg( m.formIndex, composit, nil ,0 )
	else
	UI_Engine.SetSurfaceImg( m.formIndex, composit, imgMail  ,0 )
	end

	if imgAnnex == 0 then
	UI_Engine.SetSurfaceImg( m.formIndex, composit, nil ,1 )
	else
	UI_Engine.SetSurfaceImg( m.formIndex, composit, imgAnnex  ,1)
	end

	if name == 0 then
	UI_Engine.SetText(m.formIndex,composit,"",2)
	else
	UI_Engine.SetText(m.formIndex,composit,name,2)
	end

	if time == 0 then
	UI_Engine.SetText(m.formIndex,composit,"",3)
	else
	UI_Engine.SetText(m.formIndex,composit,time ,3)
	end
end
FORM_MAIL_LIST.C51270_OnLoad = function( m )
local nDrawType = m:GetDrawType()
m:SetSel(0)
m:SetTab(MailLabelType.MAIL_LABEL_SYSTEM)
UI_Engine.SetFormTab( m.formIndex, 2)
if nDrawType == MailDrawType.DRAW_MAIL_GM_SYSTEM then
	UI_Engine.SetVisible( m.formIndex, COMPOSIT_1251 , false )
else
	UI_Engine.SetVisible( m.formIndex, COMPOSIT_1251 , true )
end
DrawDescribe(m, 0)
UpDateList(m)
end
FORM_MAIL_LIST.C51255_OnLoad = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51255_OnClick = function( m )

local imgMail, imgAnnex ,name , time = m:GetMailList(m.userSelectItem)
if imgAnnex == 0 then
	if QueryUser(m, "确实删除？") == MsgBox.ECODE_YES  then
		m:SendDeleteMsg(m.userSelectItem)
		UpDateList(m)
	end
else
	if QueryUser(m, "邮件含有附件，确实删除？") == MsgBox.ECODE_YES  then
		m:SendDeleteMsg(m.userSelectItem)
		UpDateList(m)
	end
end





end
FORM_MAIL_LIST.C51265_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51265_OnClick = function( m )
m:SetSel(m.userSelectItem)

end
FORM_MAIL_LIST.C51265_OnUpdate = function( m )
SetListItem(m, 0 ,COMPOSIT_MAIL_LIST_1)

end
FORM_MAIL_LIST.C51259_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51259_OnClick = function( m )
m:SetSel(m.userSelectItem)
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51259_OnUpdate = function( m )
SetListItem(m, 1 ,COMPOSIT_MAIL_LIST_2)
end
FORM_MAIL_LIST.C51260_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51260_OnClick = function( m )
m:SetSel(m.userSelectItem)
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51260_OnUpdate = function( m )
SetListItem(m, 2 ,COMPOSIT_MAIL_LIST_3)
end
FORM_MAIL_LIST.C51261_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51261_OnClick = function( m )
m:SetSel(m.userSelectItem)
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51261_OnUpdate = function( m )
SetListItem(m, 3 ,COMPOSIT_MAIL_LIST_4)
end
FORM_MAIL_LIST.C51262_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51262_OnClick = function( m )
m:SetSel(m.userSelectItem)
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51262_OnUpdate = function( m )
SetListItem(m, 4 ,COMPOSIT_MAIL_LIST_5)
end
FORM_MAIL_LIST.C51263_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51263_OnClick = function( m )
m:SetSel(m.userSelectItem)
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51263_OnUpdate = function( m )
SetListItem(m, 5 ,COMPOSIT_MAIL_LIST_6)
end
FORM_MAIL_LIST.C51264_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51264_OnClick = function( m )
m:SetSel(m.userSelectItem)
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51264_OnUpdate = function( m )
SetListItem(m, 6 ,COMPOSIT_MAIL_LIST_7)
end
FORM_MAIL_LIST.C51266_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51266_OnClick = function( m )
m:SetSel(m.userSelectItem)
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51266_OnUpdate = function( m )
SetListItem(m, 7 ,COMPOSIT_MAIL_LIST_8)
end
FORM_MAIL_LIST.C52705_OnClick = function( m )
m:InputFinished()
m:Close()
end
FORM_MAIL_LIST.C51256_OnClick = function( m )
m:InputFinished()
m:Close()
end
FORM_MAIL_LIST.C51272_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51272_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51272_OnUpdate = function( m )
SetListItem(m, 0 ,COMPOSIT_1272)
end
FORM_MAIL_LIST.C51273_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51273_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51273_OnUpdate = function( m )
SetListItem(m, 1 ,COMPOSIT_1273)
end
FORM_MAIL_LIST.C51274_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51274_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51274_OnUpdate = function( m )
SetListItem(m, 2 ,COMPOSIT_1274)
end
FORM_MAIL_LIST.C51275_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51275_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51275_OnUpdate = function( m )
SetListItem(m, 3 ,COMPOSIT_1275)
end
FORM_MAIL_LIST.C51276_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51276_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51276_OnUpdate = function( m )
SetListItem(m, 4 ,COMPOSIT_1276)
end
FORM_MAIL_LIST.C51277_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51277_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51277_OnUpdate = function( m )
SetListItem(m, 5 ,COMPOSIT_1277)
end
FORM_MAIL_LIST.C51278_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51278_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51278_OnUpdate = function( m )
SetListItem(m, 6 ,COMPOSIT_1278)
end
FORM_MAIL_LIST.C51279_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51279_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51279_OnUpdate = function( m )
SetListItem(m, 7 ,COMPOSIT_1279)
end
FORM_MAIL_LIST.C51254_OnClick = function( m )
local n  = m.userSelectItem
if m.userSelectItem ~= nil  then
	if n < 0 then
		n = 0
	end
else
	n= 0
end
m:SendLookMsg(n)
local senderld = m:GetElement(n)

if senderld  == nil then
return 
end

m.sendmail = NewMailSend(m,senderld)
if m.sendmail == nil then
	WarnUser(m, "没有邮件")
	return
end
m.sendmail:WaitUserInput(m)
m.ExitType = m.sendmail:GetCloseType()
local nSenderId = m.sendmail:GetLookReceiver()
DelMailSend(m.sendmail)

if m.ExitType == MailExitType.EXIT_RECEIVE then
	m:SendAttachment(n )
elseif m.ExitType == MailExitType.EXIT_DELETE then
	m:SendDeleteMsg(n )
elseif m.ExitType == MailExitType.EXIT_REPLY   then

	 NewMailSend(m,nSenderId , MailSendType.SEND_MAIL_PLAYER)           

	--if m.sendmail == nil then
	--	WarnUser(m, "邮件打开失败")
	--	UpDate(m)
	--	return
	--end

	--m.sendmail:WaitUserInput(m)
	--DelMailSend(m.sendmail)
	m:InputFinished()
	m:Close()
end


UpDateList(m)
end
FORM_MAIL_LIST.C51280_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51280_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51280_OnUpdate = function( m )
SetListItem(m, 0 ,COMPOSIT_1280)
end
FORM_MAIL_LIST.C51281_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51281_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51281_OnUpdate = function( m )
SetListItem(m, 1 ,COMPOSIT_1281)
end
FORM_MAIL_LIST.C51282_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51282_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51282_OnUpdate = function( m )
SetListItem(m, 2 ,COMPOSIT_1282)
end
FORM_MAIL_LIST.C51283_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51283_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51283_OnUpdate = function( m )
SetListItem(m, 3 ,COMPOSIT_1283)
end
FORM_MAIL_LIST.C51284_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51284_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51284_OnUpdate = function( m )
SetListItem(m, 4 ,COMPOSIT_1284)
end
FORM_MAIL_LIST.C51285_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51285_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51285_OnUpdate = function( m )
SetListItem(m, 5 ,COMPOSIT_1285)
end
FORM_MAIL_LIST.C51286_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51286_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51286_OnUpdate = function( m )
SetListItem(m, 6 ,COMPOSIT_1286)
end
FORM_MAIL_LIST.C51287_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)
end
FORM_MAIL_LIST.C51287_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_MAIL_LIST.C51287_OnUpdate = function( m )
SetListItem(m, 7 ,COMPOSIT_1287)
end
FORM_MAIL_LIST.C51253_OnClick = function( m )
m:SetSel(0)
m:SetTab(MailLabelType.MAIL_LABEL_SYSTEM)
UI_Engine.SetFormTab( m.formIndex, 2 )
UpDateList(m)
DrawDescribe(m,0)
end
FORM_MAIL_LIST.C51252_OnClick = function( m )

m:SetSel(0)
m:SetTab(MailLabelType.MAIL_LABEL_GM)
UI_Engine.SetFormTab( m.formIndex, 1)

UpDateList(m)
DrawDescribe(m,0)

end
FORM_MAIL_LIST.C51251_OnClick = function( m )
local nDrawType = m:GetDrawType()
if nDrawType == MailDrawType.DRAW_MAIL_GM_SYSTEM then
else
m:SetSel(0)
m:SetTab(MailLabelType.MAIL_LABEL_PLAYER)
UI_Engine.SetFormTab( m.formIndex, 0 )
end

UpDateList(m)
DrawDescribe(m,0)
end
