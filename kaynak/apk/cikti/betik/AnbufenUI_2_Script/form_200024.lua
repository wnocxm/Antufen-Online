NEW_FORM_ITEMUPGRADE= { }
NEW_FORM_ITEMUPGRADE.Main = function( m )
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
NEW_FORM_ITEMUPGRADE.C50687_OnLoad = function( m )
m.item0 = false
m.item1 = false
m.item2 = false
m.item3 = false
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

local WaitBar = function(m , str, time)    --进度条
	m.waitBar = NewWaitBar(m,str,time,0)
	m.waitBar:WaitUserInput(m)
	local result = m.waitBar:GetResult()
	DelWaitBar(m.waitBar )
	return result
end

local DoMenu = function(m)
	local time = m:GetTime()
	if m:IsCanHandle() == true then
		local ret = WaitBar(m, STR_ITEM_UPGRADE_WAIT, time)
		if ret == 3 then
			m:SendMsg()
		end
	end
end
		

local UpdateMoney = function(m)
	local strMoney = m:GetMoney()      ---跟新描述区域
	UI_Engine.SetText(m.formIndex, COMPOSIT_MONEY ,strMoney)
end

local TakeBack = function(m, index)
	local img,str,info,sn = m:GetItemInfo(index)
	if img ~= nil then
		m.info = NewItemInfo(m, img, str, info, sn)
		m.info:WaitUserInput(m)
		local ret = m.info:GetResult()
		DelItemInfo(m.info)
		if ret == 2 then
			m:TakeBack(index)
		end
	end
end

local ClickGrid = function(m, index)
	local valid = m:IsValidClick()
	if index == 0 then
		if m:IsItemExsit(0) == true then	--第一个格子有道具
			if valid then
				TakeBack(m, 0)
			else
				local ptr = m:GetEquipPtr()
				m.bag = NewSelectBag(m, ptr, m)
				if nil == m.bag then
					WarnUser(m, STR_NO_EQUIP)
					return
				end
				m.bag:WaitUserInput(m)
				local item = m.bag:GetSelectItem()
				local sn, num = m.bag:GetSelectSimpleItem()
				if item == nil then
					DBGPRINTF("bag == nil")
					DelSelectBag(m.bag)
				elseif item ~= nil then
					DBGPRINTF("bag != nil")
					local ret = m:AddItem(0,item,sn,num)
					DelSelectBag(m.bag)
				end
			end
		else
			local ptr = m:GetEquipPtr()
			m.bag = NewSelectBag(m, ptr, m)
			if nil == m.bag then
				WarnUser(m, STR_NO_EQUIP)
				return
			end
			m.bag:WaitUserInput(m)
			local item = m.bag:GetSelectItem()
			local sn, num = m.bag:GetSelectSimpleItem()
			if item == nil then
				DBGPRINTF("bag == nil")
				DelSelectBag(m.bag)
			elseif item ~= nil then
				DBGPRINTF("bag != nil")
				local ret = m:AddItem(0,item,sn,num)
				DelSelectBag(m.bag)
			end
		end
	elseif index == 1 then
		if m:IsItemExsit(0) == false then
			WarnUser(m, R_STRING_NEED_EQUIP_UPGRADE)
			return
		elseif valid == false then
			WarnUser(m, R_STRING_NEED_EQUIP_UPGRADE)
			return
		end
		local img,str,info,sn = m:GetItemInfo(index)
		if img ~= nil then
			m.info = NewItemInfo(m, img, str, info, sn)
			m.info:WaitUserInput(m)
			DelItemInfo(m.info)
		end
	elseif index == 2 then
		if m:IsItemExsit(0) == false then
			WarnUser(m, R_STRING_NEED_EQUIP_UPGRADE)
			return
		elseif valid == false then
			WarnUser(m, R_STRING_NEED_EQUIP_UPGRADE)
			return
		end
		local img,str,info,sn = m:GetItemInfo(index)
		if img ~= nil then
			m.info = NewItemInfo(m, img, str, info, sn)
			m.info:WaitUserInput(m)
			local ret = m.info:GetResult()
			DelItemInfo(m.info)
			if ret == 2 then
				local bRmb = false
				if m:luaBuyUpgradeItem() then   --如果是人民币就挂起
					bRmb = true
					m:WaitUserInput(m)
				end
				m.num = NewNumSel(m,STR_SELECTNUMBER_TYPE_BUY,1,1,20)
				m.num:WaitUserInput(m)
				local num = m.num:GetResult()
				DelNumSel(m.num)
				if num > 0 then
					local ask = m:GetAskString(num)
					if QueryUser(m, ask) == MsgBox.ECODE_YES  then
						m:OnBuyStone(num)
					end
				end

			end
		end
	elseif index == 3 then
		--[[if m:IsItemExsit(0) == false then
			WarnUser(m, R_STRING_NEED_EQUIP_UPGRADE)
			return
		elseif valid == false then
			WarnUser(m, R_STRING_NEED_EQUIP_UPGRADE)
			return
		end]]--
		if m:IsItemExsit(3) == true then	--最后一个格子有道具
			if valid then
				TakeBack(m, 3)
			else
				local ptr = m:GetItemPtr()
				m.bag = NewSelectBag(m, 0, ptr)
				if nil == m.bag then
					if MsgBox.ECODE_YES == QueryUser(m, STR_FANTASIZE_NOHAVE_ITEM) then
						m:OpenCashShop(EquipStrong.REQUIRE_UPGRADE)
						return
					end
				else
					m.bag:WaitUserInput(m)
					local item = m.bag:GetSelectItem()
					local sn, num = m.bag:GetSelectSimpleItem()
					local code = m.bag:GetExitCode()
					if code == 0 then
						DelSelectBag(m.bag)
					end
					if item ~= nil then
						local ret = m:AddItem(3,item,sn,num)
						DelSelectBag(m.bag)
					else
						if sn == 0 then
							DelSelectBag(m.bag)
						else
							local ret = m:AddItem(3,item,sn,num)
							DelSelectBag(m.bag)
						end
					end
				end
			end
		else
			local ptr = m:GetItemPtr()
			m.bag = NewSelectBag(m, 0, ptr)
			if nil == m.bag then
				if MsgBox.ECODE_YES == QueryUser(m, STR_FANTASIZE_NOHAVE_ITEM) then
					m:OpenCashShop(EquipStrong.REQUIRE_UPGRADE)
					return
				end
			else
				m.bag:WaitUserInput(m)
				local item = m.bag:GetSelectItem()
				local sn, num = m.bag:GetSelectSimpleItem()
				local code = m.bag:GetExitCode()
				if code == 0 then
					DelSelectBag(m.bag)
				end
				if item ~= nil then
					local ret = m:AddItem(3,item,sn,num)
					DelSelectBag(m.bag)
				else
					if sn == 0 then
						DelSelectBag(m.bag)
					else
						local ret = m:AddItem(3,item,sn,num)
						DelSelectBag(m.bag)
					end
				end
			end
		end
	end
end
NEW_FORM_ITEMUPGRADE.C50707_OnClick = function( m )
m:OpenCashShop()
end
NEW_FORM_ITEMUPGRADE.C50686_OnClick = function( m )
if m:IsItemExsit(0) == true then	--第一个格子有道具
	if false == m:IsValidClick() then
		TakeBack(m, 0)
	end
end
end
NEW_FORM_ITEMUPGRADE.C50685_OnClick = function( m )
m:CurClick(3)
ClickGrid(m, 3)
end
NEW_FORM_ITEMUPGRADE.C50684_OnClick = function( m )
m:CurClick(2)
ClickGrid(m, 2)
end
NEW_FORM_ITEMUPGRADE.C50683_OnClick = function( m )
m:CurClick(1)
ClickGrid(m, 1)
end
NEW_FORM_ITEMUPGRADE.C50682_OnClick = function( m )
m:CurClick(0)
ClickGrid(m, 0)
end
NEW_FORM_ITEMUPGRADE.C50677_OnClick = function( m )
DoMenu(m)
end
NEW_FORM_ITEMUPGRADE.C50674_OnClick = function( m )
m:Close()
end
NEW_FORM_ITEMUPGRADE.C50673_OnDraw = function( m )
m:DrawMoney()
end
