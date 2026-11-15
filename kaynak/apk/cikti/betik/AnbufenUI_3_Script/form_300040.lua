NEW_FORM_EQUIP_SUBLIMATION= { }
NEW_FORM_EQUIP_SUBLIMATION.Main = function( m )
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
NEW_FORM_EQUIP_SUBLIMATION.C50760_OnLoad = function( m )
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_PETEQUIP_NAME, UI_Engine.GetLuaStr(R_STRING_PETEQUIP_ICON))
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_PETEQUIP_START, UI_Engine.GetLuaStr(STR_RUN_ITEM))
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_PETEQUIP_ITEM_NAME, UI_Engine.GetLuaStr(R_STRING_PETEQUIP_ITEM_ICON))
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_PETEQUIP_ASSIST, UI_Engine.GetLuaStr(R_STRING_PETEQUIP_ASSISTENT_ICON))
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_759, "0/0")
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_752, UI_Engine.GetLuaStr(R_STRING_QIYUE_MENU_SUBLIME))
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_768, UI_Engine.GetLuaStr(R_STRING_GAME_CONTINUE))
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_752, true)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_768, false)
end
NEW_FORM_EQUIP_SUBLIMATION.C50760_OnClick = function( m )
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
local Opinion = function(m,n)
local num  = m:Equip_YESNO(n)
if num == 0 then
	return false
else
	return true
end
end
local ClickMenu = function(m,nType,n)
local opinion = Opinion(m,n)
	if opinion == false then
		if nType == SublimeMenuItem.MENU_ITEM_ADD_ITEM then  --添加
			if m.nSelectType == EquipSublime.SUBLIME_PETEQUIP_TYPE_WEAPON then --主装备添加
				local pfun = m:FuncUpgradeEquipFilter_lua()  --获取打开背包的指针
				m.package = NewSelectBag(m,pfun)	--打开背包
				if m.package == nil then
					local str = UI_Engine.GetLuaStr(STR_NO_OPEN_PACK)
					WarnUser(m, str)
					return	
				end
				
				m.package:WaitUserInput(m)
				local vSelect = m.package:GetSelectItem()
				local nSn, nNum = m.package:GetSelectSimpleItem()
				if nSn == nil then
					return
				else
					DelSelectBag(m.package )
					m:AddItem(vSelect,nSn,nNum)
					return 
				end
			end
		elseif n == 1 then
			local str = UI_Engine.GetLuaStr(R_STRING_QY_PLAY) 
			WarnUser(m,str)
		elseif n ==2 then
			local str = UI_Engine.GetLuaStr(R_STRING_QY_PLAY) 
			WarnUser(m, str )
		elseif n == 0 then
			m:SetSel(EquipSublime.SUBLIME_PETEQUIP_TYPE_WEAPON)
			local pfun = m:FuncUpgradeEquipFilter_lua()  --获取打开背包的指针
			m.package = NewSelectBag(m,pfun)	--打开背包
			if m.package == nil then
				local str = UI_Engine.GetLuaStr(STR_NO_OPEN_PACK)
				WarnUser(m, str )
				return	
			end
				
			m.package:WaitUserInput(m)
			local vSelect = m.package:GetSelectItem()
			local nSn, nNum = m.package:GetSelectSimpleItem()
			if nSn == nil then
				return
			else
				DelSelectBag(m.package )
				m:AddItem(vSelect,nSn,nNum)
				return 
			end
		elseif n == 3 then  --辅助道具添加
			local plist = m:GetOpenPageList()  --获取打开背包的指针
			m.package = NewSelectBag(m,0,plist)           --打开背包

			if m.package ==nil then
				local str = UI_Engine.GetLuaStr(R_STRING_PACK) 
				if QueryUser(m, str) == MsgBox.ECODE_YES then
					m:BuyAssistentItem()
				end
				return
			end
			m.package:WaitUserInput(m)
			local vSelect = m.package:GetSelectItem()
			local nSn, nNum = m.package:GetSelectSimpleItem()
			DelSelectBag(m.package )
			m:AddItem(vSelect,nSn,nNum)
		end
	else
		local m_vString, m_vInfo,img,nSN =m:GetItemDescribe()
		m.info = NewItemInfo(m, img, m_vString, m_vInfo,nSN )
		m.info:WaitUserInput(m)
		local ret = m.info:GetResult()
		DelItemInfo(m.info)
		if ret == 2 then
			if n== 2 then
				local bRmb = false
				if m:BuyUpgradeItem() then   --如果是人民币就挂起
					bRmb = true
					--m:WaitUserInput(m)
				end
				local str = UI_Engine.GetLuaStr(STR_COMBINE_NUMBER)
				m.SelectNumBox = NewNumSel(m, str , 1, 1, 30)
				m.SelectNumBox:WaitUserInput(m)
				local nNumSel = m.SelectNumBox:GetResult()
				DelNumSel(m.SelectNumBox)
				if nNumSel == -1 then
					return 
				end
				if bRmb == true then
					local nMoney , name = m:GetQueryRetPrice(nNumSel)
					if QueryUser(m,UI_Engine.GetLuaStr(R_STRING_GAME_MENU_BUY).. "["..name.."]"..UI_Engine.GetLuaStr(R_STRING_NEED_DIAMOND)..nMoney..UI_Engine.GetLuaStr(R_STRING_DRILL).. ","..UI_Engine.GetLuaStr(R_STRING_BUY_YESNO)) == MsgBox.ECODE_YES  then
						m:SendBuyUpdradeItem(nNumSel)
					end
				else
					local name = m:GetQueryRetPrice(nNumSel)
					if QueryUser(m,name) == MsgBox.ECODE_YES  then
						m:SendBuyUpdradeItem(nNumSel)
					end
				end
			else
				m:ClearItem()
			end
		end
	end
end
NEW_FORM_EQUIP_SUBLIMATION.C50752_OnClick = function( m )
local opinion_1 = Opinion(m,0)
if opinion_1 == false then
	WarnUser(m, UI_Engine.GetLuaStr(R_STRING_QY_PLAY))
else 
	 m:Sublime(true)
end

end
NEW_FORM_EQUIP_SUBLIMATION.C50768_OnClick = function( m )
m:Sublime(false)
end
NEW_FORM_EQUIP_SUBLIMATION.C50761_OnClick = function( m )
m:BuyAssistentItem()

end
NEW_FORM_EQUIP_SUBLIMATION.C50742_OnClick = function( m )
m:SetSel(EquipSublime.SUBLIME_PETEQUIP_TYPE_WEAPON)
m.nSelectType = EquipSublime.SUBLIME_PETEQUIP_TYPE_WEAPON
local nType = m:DoMenu(0)
ClickMenu(m,nType,0)

end
NEW_FORM_EQUIP_SUBLIMATION.C50743_OnClick = function( m )
m:SetSel(EquipSublime.SUBLIME_PETEQUIP_TYPE_STARTITEM)
ClickMenu(m,"",1)
end
NEW_FORM_EQUIP_SUBLIMATION.C50744_OnClick = function( m )
m:SetSel(EquipSublime.SUBLIME_PETEQUIP_TYPE_ITEM)
ClickMenu(m,"",2)

end
NEW_FORM_EQUIP_SUBLIMATION.C50745_OnClick = function( m )
m:SetSel(EquipSublime.SUBLIME_PETEQUIP_TYPE_ASSISTENT_ITEM)
ClickMenu(m,"",3)
end
NEW_FORM_EQUIP_SUBLIMATION.C50746_OnClick = function( m )
m:SetSel(EquipSublime.SUBLIME_PETEQUIP_TYPE_LAST)
ClickMenu(m,nType,4)

end
