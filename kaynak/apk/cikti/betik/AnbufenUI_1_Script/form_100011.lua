NEW_FORM_POPUPITEMLIST= { }
NEW_FORM_POPUPITEMLIST.Main = function( m )
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

local SetListData = function(m,nIndex,composit)
	local opentype = m:GetOpenType()
	if opentype == 1 then
	end
	local img,name,strEnd,color,sn= m:GetListData(m.offset + nIndex)
	if color ~= 0 then
		UI_Engine.SetSurfaceImg( m.formIndex, composit, img ,0,0,false,sn )
		UI_Engine.SetText(m.formIndex,composit,name,1,color)
		local nSel = m.offset + nIndex
		if nSel > 0 then
			UI_Engine.SetText(m.formIndex,composit,strEnd,2,color)
		else
			UI_Engine.SetText(m.formIndex,composit,"",2,color)
		end	
	else
		UI_Engine.SetSurfaceImg( m.formIndex, composit, img ,0,0,false,sn )
		UI_Engine.SetText(m.formIndex,composit,name,1)
		local nSel = m.offset + nIndex
		if nSel > 0 then
			UI_Engine.SetText(m.formIndex,composit,strEnd,2)
		else
			UI_Engine.SetText(m.formIndex,composit,"",2,color)
		end
	end

end

local Click = function(m,nIndex)
	local opentype = m:GetOpenType()
	local sendtype = m:GetSendType()
	if opentype == 1 then
		if sendtype == MailSendType.SEND_MAIL_GM then
			WarnUser(m, STR_CANNOT_MAIL_ATTACH_TO_GM)
			return
		end
		if nIndex == 0 then
			if m:IsItemMax() == false then
				WarnUser(m, STR_MAIL_ANNEX_ADDERROR)
				return
			end
			local pfunction, pfunction2= m:FuncMailSendFilter_lua()  --获取打开背
			m.package = NewSelectBag(m,pfunction,pfunction2)           --打开背包

			if m.package == nil then
				WarnUser(m, STR_HAVE_NO_MATH_ITEM)
				return
			end

			m.package:WaitUserInput(m)
			local vSelect = m.package:GetSelectItem()
			local nSN,nNum = m.package:GetSelectSimpleItem()
			local code = m.package:GetExitCode()
			if code == 0 then 
				DelSelectBag(m.package)
				return
			end
			DelPackage(m.package )

			m:SetItem(vSelect , nSN, nNum )    --添加物品成功
			for i = 0 , 5 do
				local id = UI1_COMPOSIT_POPUP_ITEMLIST_0 + i
				SetListData(m,i,id)
			end
		else
			--点的不是第一个的话就是查看信息了
			local img,str,pinfo,sn = m:GetDescribe(m.userSelectItem)
			m.info = NewItemInfo(m,img,str,pinfo,sn)
			m.info:WaitUserInput(m)
			local exit = m.info:GetResult()
			DelItemInfo(m.info)
			if exit ~= 0 then
				m:RemoveItem(nIndex)
			end

		end
	else
		if nIndex == 0 then
			m:SendReceiveAllMsg()
			m:InputFinished()
		else
			local img,str,pinfo,sn = m:GetDescribe(m.userSelectItem)
			m.info = NewItemInfo(m,img,str,pinfo,sn)
			m.info:WaitUserInput(m)
			local exit = m.info:GetResult()
			DelItemInfo(m.info)
			if exit ~= 0 then
				m:SendReceiveMsg(nIndex)
			end
		end
	end
end
NEW_FORM_POPUPITEMLIST.C50192_OnLoad = function( m )
UI_Engine.UpdateList(m.formIndex ,UI1_COMPOSIT_POPUP_ITEMLIST_0)

end
NEW_FORM_POPUPITEMLIST.C50192_OnClick = function( m )
Click(m,m.userSelectItem)
end
NEW_FORM_POPUPITEMLIST.C50192_OnUpdate = function( m )
SetListData(m,0,UI1_COMPOSIT_POPUP_ITEMLIST_0)
end
NEW_FORM_POPUPITEMLIST.C50193_OnLoad = function( m )
UI_Engine.UpdateList(m.formIndex ,UI1_COMPOSIT_POPUP_ITEMLIST_1)
end
NEW_FORM_POPUPITEMLIST.C50193_OnClick = function( m )
Click(m,m.userSelectItem)
end
NEW_FORM_POPUPITEMLIST.C50193_OnUpdate = function( m )
SetListData(m,1,UI1_COMPOSIT_POPUP_ITEMLIST_1)
end
NEW_FORM_POPUPITEMLIST.C50194_OnLoad = function( m )
UI_Engine.UpdateList(m.formIndex ,UI1_COMPOSIT_POPUP_ITEMLIST_2)
end
NEW_FORM_POPUPITEMLIST.C50194_OnClick = function( m )
Click(m,m.userSelectItem)
end
NEW_FORM_POPUPITEMLIST.C50194_OnUpdate = function( m )
SetListData(m,2,UI1_COMPOSIT_POPUP_ITEMLIST_2)
end
NEW_FORM_POPUPITEMLIST.C50195_OnLoad = function( m )
UI_Engine.UpdateList(m.formIndex ,UI1_COMPOSIT_POPUP_ITEMLIST_3)
end
NEW_FORM_POPUPITEMLIST.C50195_OnClick = function( m )
Click(m,m.userSelectItem)
end
NEW_FORM_POPUPITEMLIST.C50195_OnUpdate = function( m )
SetListData(m,3,UI1_COMPOSIT_POPUP_ITEMLIST_3)
end
NEW_FORM_POPUPITEMLIST.C50196_OnLoad = function( m )
UI_Engine.UpdateList(m.formIndex ,UI1_COMPOSIT_POPUP_ITEMLIST_4)
end
NEW_FORM_POPUPITEMLIST.C50196_OnClick = function( m )
Click(m,m.userSelectItem)
end
NEW_FORM_POPUPITEMLIST.C50196_OnUpdate = function( m )
SetListData(m,4,UI1_COMPOSIT_POPUP_ITEMLIST_4)
end
NEW_FORM_POPUPITEMLIST.C50197_OnLoad = function( m )
UI_Engine.UpdateList(m.formIndex ,UI1_COMPOSIT_POPUP_ITEMLIST_5)
end
NEW_FORM_POPUPITEMLIST.C50197_OnClick = function( m )
Click(m,m.userSelectItem)
end
NEW_FORM_POPUPITEMLIST.C50197_OnUpdate = function( m )
SetListData(m,5,UI1_COMPOSIT_POPUP_ITEMLIST_5)
end
NEW_FORM_POPUPITEMLIST.C50198_OnClick = function( m )
m:OnClick(-1)
m:Close()
m:InputFinished()
end
