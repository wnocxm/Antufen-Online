FORM_SMRITI= { }
FORM_SMRITI.Main = function( m )
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

local UpDateDecribe = function(m)
	local Decribe = m:GetDescribe()
	UI_Engine.SetText(m.formIndex,COMPOSIT_DESCRIBE,Decribe)
end

local UpdateItem = function ( m,control , nType)    ---更新图标
	local img ,strShow,nSN = m:GetItem( nType )
	
	if img ~= nil then   --设置变灰图片
		if nType == SmritiType.RSMRITI_ITEM_TYPE_STARTITEM then  --启动道具
			if m:IsHaveRunItem() == false then--设置变灰图片	
				UI_Engine.SetSurfaceImg(m.formIndex, control, img,  0, 0,true)
			else
				UI_Engine.SetSurfaceImg( m.formIndex, control, img )  --设置
			end	
		else
			UI_Engine.SetSurfaceImg( m.formIndex, control, img,0,0,false,nSN )  --设置
		end
	else
		UI_Engine.SetSurfaceImg( m.formIndex, control, nil )
	end
	
	if nType == SmritiType.RSMRITI_ITEM_TYPE_MASTER then
		UI_Engine.SetText(m.formIndex,COMPOSIT_MASTER_NAME,strShow)
	elseif nType == SmritiType.RSMRITI_ITEM_TYPE_STUFF then
		UI_Engine.SetText(m.formIndex,COMPOSIT_STUFF_NAME,strShow)
	elseif nType == SmritiType.RSMRITI_ITEM_TYPE_STARTITEM then
		UI_Engine.SetText(m.formIndex,COMPOSIT_START_ITEM,strShow)
	end
end

local UpDateItemAll = function(m)
	UpdateItem(m,COMPOSIT_MASTER_IOCN,SmritiType.RSMRITI_ITEM_TYPE_MASTER)
	UpdateItem(m,COMPOSIT_STUFF_ICON,SmritiType.RSMRITI_ITEM_TYPE_STUFF)
	UpdateItem(m,COMPOSIT_ASSIST_ICON,SmritiType.RSMRITI_ITEM_TYPE_ASSISTENT_ITEM)
	UpdateItem(m,COMPOSIT_START_ICON,SmritiType.RSMRITI_ITEM_TYPE_STARTITEM)
end

local UpDateMenu = function(m)
	local name,name1,name2,name3,name4,name5 = m:GetMenu()
	if name ~= nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_BUTTON1,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_BUTTON1,name)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_BUTTON1,false)
	end
	
	if name1 ~= nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_BUTTON2,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_BUTTON2,name1)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_BUTTON2,false)
	end
	
	if name2 ~= nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_BUTTON3,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_BUTTON3,name2)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_BUTTON3,false)
	end
	
	if name3 == nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_BUTTON4,false)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_BUTTON4,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_BUTTON4,name3)
	end
	
	if name4 == nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_BUTTON5,false)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_BUTTON5,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_BUTTON5,name3)
	end
	
	if name5 == nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_BUTTON6,false)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_BUTTON6,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_BUTTON6,name3)
	end

end

local SelectItem = function(m,selectType)
	m.nSelectType = selectType
	m:SetSel(selectType)
	UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGNICON_1,0)
	UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGNICON_2,0)
	UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGNICON_3,0)
	UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGNICON_4,0)
	if selectType == SmritiType.RSMRITI_ITEM_TYPE_MASTER then    
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGNICON_1,1)
	elseif selectType == SmritiType.RSMRITI_ITEM_TYPE_STUFF then  
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGNICON_2,1)
	elseif selectType == SmritiType.RSMRITI_ITEM_TYPE_ASSISTENT_ITEM  then  
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGNICON_4,1)
	elseif selectType == SmritiType.RSMRITI_ITEM_TYPE_STARTITEM then    
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGNICON_3,1)
	end
	UpDateMenu(m)
	UpDateItemAll(m)
	UpDateDecribe(m)
end

local ClickMenu = function(m,nType)
	if nType == nil then
		return 
	end
	if nType == SmritiMenuItem.MENU_ITEM_ADD_ITEM then  --添加
		if m.nSelectType == SmritiType.RSMRITI_ITEM_TYPE_MASTER then --主装备添加
			local pfun = m:SmritiMasterEquipFilter_lua()  --获取打开背包的指针
			m.package = NewPackage(m,pfun, m)           --打开背包

			if m.package == nil then
				WarnUser(m, "背包打开失败 没有装备")
				return
			end
			
			m.package:WaitUserInput(m)
			local vSelect = m.package:GetSelectItem()
			local nSn, nNum = m.package:GetSelectSimpleItem()
			DelPackage(m.package )
			m:AddItem(vSelect,nSn,nNum)
		elseif m.nSelectType == SmritiType.RSMRITI_ITEM_TYPE_STUFF then   --材料装备添加
			local pfun1 = m:SmritiStuffEquipFilter_lua()  --获取打开背包的指针
			m.package = NewPackage(m,pfun1, m)           --打开背包

			if m.package == nil then
				WarnUser(m, "没有符合条件的装备")
				return
			end
			
			m.package:WaitUserInput(m)
			local vSelect = m.package:GetSelectItem()
			local nSn, nNum = m.package:GetSelectSimpleItem()
			DelPackage(m.package )
			m:AddItem(vSelect,nSn,nNum)
		elseif m.nSelectType == SmritiType.RSMRITI_ITEM_TYPE_ASSISTENT_ITEM then  --辅助道具添加
			local plist = m:GetList_lua()  --获取打开背包的指针
			m.package = NewPackage(m,PackageMode.MODE_SELECT, plist)           --打开背包

			if m.package ==nil then
				if QueryUser(m, "背包里面没有此物品是否购买？") == MsgBox.ECODE_YES then
					if m:BuyAssistentItem() then   --如果是人民币就挂起
						m:WaitUserInput(m)
					end

					m.SelectNumBox = NewNumSel(m, "请选择数量", 1, 1, 30)
					m.SelectNumBox:WaitUserInput(m)
					local nNumSel = m.SelectNumBox:GetResult()
					DelNumSel(m.SelectNumBox)
					
					if nNumSel == -1 then
						return 
					end
					
					local nMoney , name = m:GetQueryRetPrice()
					
					if QueryUser(m,"购买["..name.."]需要钻石:"..nMoney.."钻".. ",是否购买？") == MsgBox.ECODE_YES  then
						m:SendBuyAssistentItem(nNumSel)
					end
				end
				return
			end
			m.package:WaitUserInput(m)
			local vSelect = m.package:GetSelectItem()
			local nSn, nNum = m.package:GetSelectSimpleItem()
			DelPackage(m.package )
			m:AddItem(vSelect,nSn,nNum)
		end
	elseif nType == SmritiMenuItem.MENU_ITEM_CLEAR_ITEM then --清除
		m:ClearItem()
	elseif nType == SmritiMenuItem.MENU_ITEM_VIEW_DESCRIBE then  --详细
		local name, pinfo = m:GetInfo()
		if name ~= nil and pinfo ~= nil  then
			m.info = NewInfo(m,name,pinfo)
			m.info:WaitUserInput(m)
			DelInfo(m.info)
		end
	elseif nType == SmritiMenuItem.MENU_ITEM_SMRITI then		--传承
		m:Smriti()
	elseif nType == SmritiMenuItem.MENU_ITEM_BUY then   --购买
		if m:BuyAssistentItem() then   --如果是人民币就挂起
			m:WaitUserInput(m)
		end

		m.SelectNumBox = NewNumSel(m, "请选择数量", 1, 1, 30)
		m.SelectNumBox:WaitUserInput(m)
		local nNumSel = m.SelectNumBox:GetResult()
		DelNumSel(m.SelectNumBox)
		
		if nNumSel == -1 then
			return 
		end
		local nMoney , name = m:GetQueryRetPrice()
		
		if QueryUser(m,"购买["..name.."]需要钻石:"..nMoney.."钻".. ",是否购买？") == MsgBox.ECODE_YES  then
			m:SendBuyAssistentItem(nNumSel)
		end
	end
	
	UpDateMenu(m)
	UpDateItemAll(m)
	UpDateDecribe(m)
end
FORM_SMRITI.C52961_OnClick = function( m )
m:Close()
end
FORM_SMRITI.C52967_OnLoad = function( m )
UpDateMenu(m)
end
FORM_SMRITI.C52967_OnClick = function( m )
local nType = m:DoMenu(0)
ClickMenu(m,nType)
end
FORM_SMRITI.C52966_OnClick = function( m )
local nType = m:DoMenu(1)
ClickMenu(m,nType)
end
FORM_SMRITI.C52965_OnClick = function( m )
local nType = m:DoMenu(2)
ClickMenu(m,nType)
end
FORM_SMRITI.C52964_OnClick = function( m )
local nType = m:DoMenu(3)
ClickMenu(m,nType)
end
FORM_SMRITI.C52963_OnClick = function( m )
local nType = m:DoMenu(4)
ClickMenu(m,nType)
end
FORM_SMRITI.C52962_OnClick = function( m )
local nType = m:DoMenu(5)
ClickMenu(m,nType)
end
FORM_SMRITI.C52955_OnLoad = function( m )
SelectItem(m,SmritiType.RSMRITI_ITEM_TYPE_MASTER)
end
FORM_SMRITI.C52955_OnClick = function( m )
SelectItem(m,SmritiType.RSMRITI_ITEM_TYPE_MASTER)
end
FORM_SMRITI.C52954_OnClick = function( m )
SelectItem(m,SmritiType.RSMRITI_ITEM_TYPE_STUFF)
end
FORM_SMRITI.C52953_OnClick = function( m )
SelectItem(m,SmritiType.RSMRITI_ITEM_TYPE_ASSISTENT_ITEM)
end
FORM_SMRITI.C52952_OnClick = function( m )
SelectItem(m,SmritiType.RSMRITI_ITEM_TYPE_STARTITEM)
end
