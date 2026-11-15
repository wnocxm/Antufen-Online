NEW_FORM_LOOKUP_MAIL= { }
NEW_FORM_LOOKUP_MAIL.Main = function( m )
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
local UpDateMenu = function(m)
	local nSize = m:GetMenuSize() - 1
	for k = 0,5 do
		local ID = UI1_COMPOSIT_LOOKUP_MAIL_MENU0 + k
		UI_Engine.SetVisible(m.formIndex,ID,false)
	end
	for i = 0,nSize do
		local name = m:GetMenu(i)
		local nCompositID = UI1_COMPOSIT_LOOKUP_MAIL_MENU0 + i
		if name ~= nil then
			UI_Engine.SetVisible(m.formIndex,nCompositID,true)
			UI_Engine.SetText(m.formIndex,nCompositID,name)
		else
			UI_Engine.SetVisible(m.formIndex,nCompositID,false)
		end
	end
end

local UpDateButton = function(m)
	local nItemCount = m:GetItemCount()
	if nItemCount > 0 then
		UI_Engine.SetVisible( m.formIndex, UI1_COMPOSIT_LOOKUP_MAIL_ITEM_BUTTON, true );
	else
		UI_Engine.SetVisible( m.formIndex, UI1_COMPOSIT_LOOKUP_MAIL_ITEM_BUTTON, false );
	end
end

local UpDate = function(m)
	local strText = m:GetContent()  --刷新文本
	UI_Engine.SetText( m.formIndex, UI1_COMPOSIT_LOOKUP_MAIL_TEXT, strText )
	
	local strNickName = m:GetSenderName()   --刷新名字
	UI_Engine.SetText( m.formIndex, UI1_COMPOSIT_LOOKUP_MAIL_SENDER_RECT, strNickName )
	
	local nMoney = m:GetMoneyCount()     --刷新金额
	UI_Engine.SetText( m.formIndex, UI1_COMPOSIT_LOOKUP_MAIL_MONEY_RECT, nMoney )
	
	UpDateButton(m)
	UpDateMenu(m)
end

local DoMenu = function(m,nIndex)
	m:DoMenu(nIndex)
	UpDate(m)
end
NEW_FORM_LOOKUP_MAIL.C50202_OnLoad = function( m )
UpDate(m)
end
NEW_FORM_LOOKUP_MAIL.C50202_OnDraw = function( m )
local strSenderName = m:GetSenderName()
UI_Engine.SetText( m.formIndex, UI1_COMPOSIT_LOOKUP_MAIL_SENDER_RECT, strSenderName )
end
NEW_FORM_LOOKUP_MAIL.C50203_OnDraw = function( m )
local nMoney = m:GetMoneyCount()     --刷新金额
UI_Engine.SetText( m.formIndex, UI1_COMPOSIT_LOOKUP_MAIL_MONEY_RECT, nMoney )
end
NEW_FORM_LOOKUP_MAIL.C50221_OnClick = function( m )
m:Close()
m:InputFinished()
end
NEW_FORM_LOOKUP_MAIL.C50223_OnClick = function( m )
DoMenu(m,0)
end
NEW_FORM_LOOKUP_MAIL.C50224_OnClick = function( m )
DoMenu(m,1)
end
NEW_FORM_LOOKUP_MAIL.C50225_OnClick = function( m )
DoMenu(m,2)
end
NEW_FORM_LOOKUP_MAIL.C50226_OnClick = function( m )
DoMenu(m,3)
end
NEW_FORM_LOOKUP_MAIL.C50227_OnClick = function( m )
DoMenu(m,4)
end
NEW_FORM_LOOKUP_MAIL.C50228_OnClick = function( m )
DoMenu(m,5)
end
NEW_FORM_LOOKUP_MAIL.C50229_OnClick = function( m )
DoMenu(m,6)
end
NEW_FORM_LOOKUP_MAIL.C50230_OnClick = function( m )
local pMail = m:GetMail()
m.Popup = NewPopupItemListForReceive(m, pMail )
m.Popup :WaitUserInput(m)
local vItemList = m.Popup:GetItemList()
DelPopupItemListForReceive( m.Popup )
m:SetItemList(vItemList)
UpDate(m)
end
