FORM_EQUIP_UPGRADE= { }
FORM_EQUIP_UPGRADE.Main = function( m )
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

local WaitBar = function(m , str, time)    --进度条
	m.waitBar = NewWaitBar(m,str,time,0)           
	m.waitBar:WaitUserInput(m)
	local result = m.waitBar:GetResult()
	DelWaitBar(m.waitBar )
	return result
end

local GetControl = function(m,nType)    --根据物品的类型返回物品的控件ID
    if nType == nil then
		DBGPRINTF("Getcontrol  nType == nil  error ")
	else
		DBGPRINTF("GetControl_______begin".."ntype="..nType)
	end
	if nType == EquipStrongItemType.COMBINE_REQUIRE_TYPE_WEAPON then
		return COMPOSIT_EQUIP_COMBINE_EQUIP
	elseif nType == EquipStrongItemType.COMBINE_REQUIRE_TYPE_MATERIAL then
		return COMPOSIT_EQUIP_COMBINE_STONE
	elseif nType == EquipStrongItemType.COMBINE_REQUIRE_TYPE_STARTITEM  then
		return COMPOSIT_COMBINE_START_ITEM
	elseif nType == EquipStrongItemType.STUD_REQUIRE_TYPE_WEAPON then
		return COMPOSIT_EQUIP_INSET_GOODS
	elseif nType == EquipStrongItemType.STUD_REQUIRE_TYPE_GEM then
		return COMPOSIT_EQUIP_INSET_STONE
	elseif nType == EquipStrongItemType.STUD_REQUIRE_TYPE_STARTITEM then
		return COMPOSIT_INSET_START_ITEM
	elseif nType == EquipStrongItemType.DETACH_REQUIRE_TYPE_WEAPON then
		return	COMPOSIT_EQUIP_DETACH_EQUIP
	elseif nType == EquipStrongItemType.DETACH_REQUIRE_TYPE_DETACH_ITEM then
		return COMPOSIT_EQUIP_BEST_CHARM
	elseif nType == EquipStrongItemType.DETACH_REQUIRE_TYPE_ASSISTENT_ITEM then
		return COMPOSIT_EQUIP_BEST_ITEM
	elseif nType == EquipStrongItemType.DETACH_REQUIRE_TYPE_STARTITEM then
		return COMPOSIT_EQUIP_DETACH_CHARM
	elseif nType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_WEAPON then
		return	COMPOSIT_EQIUP_UPGRADE_GOODS
	elseif nType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_UPDATE_ITEM then
		return COMPOSIT_EQUIP_UPGRADE_PROP
	elseif nType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_ASSISTENT_ITEM then
		return COMPOSIT_EQUIP_UPGRADE_ITEM
	elseif nType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_STARTITEM then
		return COMPOSIT_EQUIP_UPGRADE_CHARM
	else
		DBGPRINTF("GetControl_______error")
		return nil
	end
end

local GetShowControl = function(m,nType)    --根据物品的类型返回显示的控件
    if nType == nil then
		DBGPRINTF("GetShowControl  nType == nil  error ")
	else
		DBGPRINTF("GetShowControl——————end".."ntype="..nType)
	end
	if nType == EquipStrongItemType.COMBINE_REQUIRE_TYPE_WEAPON then
		return COMPOSIT_EQUIP_LEFT_GOODS
	elseif nType == EquipStrongItemType.COMBINE_REQUIRE_TYPE_MATERIAL then
		return COMPOSIT_EQUIP_RIGHT_GOODS
	elseif nType == EquipStrongItemType.STUD_REQUIRE_TYPE_WEAPON then
		return COMPOSIT_EQUIP_LEFT_GOODS
	elseif nType == EquipStrongItemType.STUD_REQUIRE_TYPE_GEM then
		return COMPOSIT_EQUIP_RIGHT_GOODS
	elseif nType == EquipStrongItemType.DETACH_REQUIRE_TYPE_WEAPON then
		return	COMPOSIT_EQUIP_LEFT_GOODS
	elseif nType == EquipStrongItemType.DETACH_REQUIRE_TYPE_DETACH_ITEM then
		return COMPOSIT_EQUIP_RIGHT_GOODS
--	elseif nType == EquipStrongItemType.DETACH_REQUIRE_TYPE_ASSISTENT_ITEM then
--		return COMPOSIT_EQUIP_DOWN_GOODS
	elseif nType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_WEAPON then
		return	COMPOSIT_EQUIP_LEFT_GOODS
	elseif nType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_UPDATE_ITEM then
		return COMPOSIT_EQUIP_RIGHT_GOODS
--	elseif nType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_ASSISTENT_ITEM then
--		return COMPOSIT_EQUIP_DOWN_GOODS
	elseif nType == EquipStrongItemType.COMBINE_REQUIRE_TYPE_STARTITEM  then
		return COMPOSIT_EQUIP_DOWN_GOODS
	elseif nType == EquipStrongItemType.STUD_REQUIRE_TYPE_STARTITEM  then
		return COMPOSIT_EQUIP_DOWN_GOODS
	elseif nType == EquipStrongItemType.DETACH_REQUIRE_TYPE_STARTITEM  then
		return COMPOSIT_EQUIP_DOWN_GOODS
	elseif nType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_STARTITEM  then
		return COMPOSIT_EQUIP_DOWN_GOODS
	else
		DBGPRINTF("GetControl_______error")
		return nil
	end
end

local IsStrong = function(m)
	if m.nTab == EquipStrongTab.REQUIRE_UPGRADE then  --升级
		if m:IsItemNull(EquipStrongItemType.UPGRADE_REQUIRE_TYPE_WEAPON) then
			return false
		end

		if m:IsItemNull(EquipStrongItemType.UPGRADE_REQUIRE_TYPE_UPDATE_ITEM) then
			return false
		end
		
		if m:IsHaveRunItem() == false then
			return false
	    end
	
		if m:IsMoneyEnough() == false then
			return false
		end
		
		if m:IsUpgradeItemEnough() == false then
			return false
		end
		return true
	elseif m.nTab == EquipStrongTab.REQUIRE_STUD_GEM then  --镶嵌
		if m:IsItemNull(EquipStrongItemType.STUD_REQUIRE_TYPE_WEAPON) then
			return false
		end

		if m:IsItemNull(EquipStrongItemType.STUD_REQUIRE_TYPE_GEM) then
			return false
		end

		if m:IsHaveRunItem() == false then
			return false
	    end
	
		if m:IsMoneyEnough() == false then
			return false
		end
		
		return true

	elseif m.nTab == EquipStrongTab.REQUIRE_DETACH_GEM then --分离
		if m:IsItemNull(EquipStrongItemType.DETACH_REQUIRE_TYPE_WEAPON) then
			return false
		end

		if m:IsItemNull(EquipStrongItemType.DETACH_REQUIRE_TYPE_DETACH_ITEM) then
			return false
		end

		if m:IsHaveRunItem() == false then
			return false
	    end
	
		if m:IsMoneyEnough() == false then
			return false
		end
		return true
	elseif m.nTab == EquipStrongTab.REQUIRE_COMBINE then    --合成
		if m:IsItemNull(EquipStrongItemType.COMBINE_REQUIRE_TYPE_WEAPON) then
			return false
		end

		if m:IsItemNull(EquipStrongItemType.COMBINE_REQUIRE_TYPE_MATERIAL) then
			return false
		end

		if m:IsHaveRunItem() == false then
			return false
	    end
	
		if m:IsMoneyEnough() == false then
			return false
		end

		return true
	else

	end
end


local UpdateMoney = function(m)
	local strMoney = m:GetMoney()      ---跟新描述区域
	UI_Engine.SetText(m.formIndex, COMPOSIT_MONEY ,strMoney)
end

local UpdateDecribe = function(m , nType)
	local strDesc = m:UpdateDescriptionClient(nType)      ---跟新描述区域
	UI_Engine.SetText(m.formIndex, COMPOSIT_EQUIP_EXPLAIN ,strDesc)
end

local UpdateItem = function ( m,nType)    ---更新图标
	local control = GetControl(m,nType)
	local showcontrol = GetShowControl(m,nType)
	local img ,nSN = m:OnUpdateItem( nType )
	local strShow = m:GetShowName(nType)    --根据枚举获取本物品的字符串
	
	if img ~= nil then   --设置变灰图片
		if nType == EquipStrongItemType.COMBINE_REQUIRE_TYPE_STARTITEM  or 
			nType == EquipStrongItemType.STUD_REQUIRE_TYPE_STARTITEM   or
			nType == EquipStrongItemType.DETACH_REQUIRE_TYPE_STARTITEM or 
			nType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_STARTITEM    then  --合成启动道具
			if m:IsHaveRunItem() == false then
					--设置变灰图片	
				UI_Engine.SetSurfaceImg(m.formIndex, control, img,  0, 0,true)
			else
				UI_Engine.SetSurfaceImg( m.formIndex, control, img )  --设置
			end	
		elseif nType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_UPDATE_ITEM then		 --升级-物品
			if m:IsUpgradeItemEnough() == false then
					--设置变灰图片
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
	
	if strShow ~= nil then                                ---跟新显示区域
		if showcontrol ~= nil then 
			UI_Engine.SetText( m.formIndex, showcontrol, strShow)
		end
	else
		if showcontrol ~= nil then
			UI_Engine.SetText( m.formIndex, showcontrol, "")
		end
	end
	
end

local UpdateMenu = function(m)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2785,false) --添加
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_ADDITEM,false) --清除按钮
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_RIGHT_2,false) --购买
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2396,false)   --详细
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_RIGHT_3,false)  --强化
	
	if m:IsItemNull(m.nSelectType) == false then
		UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2396,true)   --详细
	end

	if IsStrong(m) == true then
		DBGPRINTF("sbgy")
		UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_RIGHT_3,true)  --强化
	end
	
	if m.nSelectType == EquipStrongItemType.COMBINE_REQUIRE_TYPE_WEAPON then     --合成-装备
		if m:IsItemNull(m.nSelectType) == false then
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_ADDITEM,true)  
		else
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2785,true)  
		end
	elseif m.nSelectType == EquipStrongItemType.COMBINE_REQUIRE_TYPE_MATERIAL then  --合成-材料
		if m:IsItemNull(m.nSelectType) == false then
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_ADDITEM,true)  
		else
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2785,true)  
		end
	elseif m.nSelectType == EquipStrongItemType.COMBINE_REQUIRE_TYPE_STARTITEM  then  --合成启动道具
	
	elseif m.nSelectType == EquipStrongItemType.STUD_REQUIRE_TYPE_WEAPON then      --镶嵌--装备
		if m:IsItemNull(m.nSelectType) == false then
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_ADDITEM,true)  
		else
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2785,true)  
		end
	elseif m.nSelectType == EquipStrongItemType.STUD_REQUIRE_TYPE_GEM then           --镶嵌--宝石
		if m:IsItemNull(m.nSelectType) == false then
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_ADDITEM,true)  
		else
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2785,true)  
		end
	elseif m.nSelectType == EquipStrongItemType.STUD_REQUIRE_TYPE_STARTITEM  then         --镶嵌——启动道具

	elseif m.nSelectType == EquipStrongItemType.DETACH_REQUIRE_TYPE_WEAPON then     --分离--装备
		if m:IsItemNull(m.nSelectType) == false then
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_ADDITEM,true)  
		else
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2785,true)  
		end
	elseif m.nSelectType == EquipStrongItemType.DETACH_REQUIRE_TYPE_DETACH_ITEM then  --分离--物品
		if m:IsItemNull(m.nSelectType) == false then
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_ADDITEM,true)  
		else
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2785,true)  
		end
	elseif m.nSelectType == EquipStrongItemType.DETACH_REQUIRE_TYPE_STARTITEM  then         --分离-启动道具

	elseif m.nSelectType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_WEAPON then           --升级-装备
		if m:IsItemNull(m.nSelectType) == false then
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_ADDITEM,true)  
		else
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2785,true)  
		end
	elseif m.nSelectType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_UPDATE_ITEM then		 --升级-物品
		UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_RIGHT_2,true) --购买
	elseif m.nSelectType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_STARTITEM  then            --升级-启动道具

	elseif m.nSelectType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_ASSISTENT_ITEM then   --升级-道具
		if m:IsItemNull(m.nSelectType) == false then
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_ADDITEM,true)  
		else
			UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2785,true)  
		end
	end
end



local RefreshEquip = function ( m, nTab )         --刷新

	if nTab == EquipStrongTab.REQUIRE_UPGRADE then
		UpdateItem(m,EquipStrongItemType.UPGRADE_REQUIRE_TYPE_WEAPON)
		UpdateItem(m,EquipStrongItemType.UPGRADE_REQUIRE_TYPE_UPDATE_ITEM)
		UpdateItem(m,EquipStrongItemType.UPGRADE_REQUIRE_TYPE_ASSISTENT_ITEM)
		UpdateItem(m,EquipStrongItemType.UPGRADE_REQUIRE_TYPE_STARTITEM)
	elseif nTab == EquipStrongTab.REQUIRE_STUD_GEM then
		UpdateItem(m,EquipStrongItemType.STUD_REQUIRE_TYPE_WEAPON)
		UpdateItem(m,EquipStrongItemType.STUD_REQUIRE_TYPE_GEM)
		UpdateItem(m,EquipStrongItemType.STUD_REQUIRE_TYPE_STARTITEM)
	elseif nTab == EquipStrongTab.REQUIRE_DETACH_GEM then
		UpdateItem(m,EquipStrongItemType.DETACH_REQUIRE_TYPE_WEAPON)
		UpdateItem(m,EquipStrongItemType.DETACH_REQUIRE_TYPE_DETACH_ITEM)
		UpdateItem(m,EquipStrongItemType.DETACH_REQUIRE_TYPE_ASSISTENT_ITEM)
		UpdateItem(m,EquipStrongItemType.DETACH_REQUIRE_TYPE_STARTITEM)
	elseif nTab == EquipStrongTab.REQUIRE_COMBINE then
		UpdateItem(m,EquipStrongItemType.COMBINE_REQUIRE_TYPE_WEAPON)
		UpdateItem(m,EquipStrongItemType.COMBINE_REQUIRE_TYPE_MATERIAL)
		UpdateItem(m,EquipStrongItemType.COMBINE_REQUIRE_TYPE_STARTITEM)
	else
	end
	
	UpdateMoney(m)
	UpdateDecribe(m,m.nSelectType)
	UpdateMenu(m)
end

local AddItem = function(m, vSelect , nSn, nNum) --添加物品

	if m:IsItemLock(vSelect) then
		m:ClearItem(m.nSelectType)
		WarnUser(m,"物品已经锁定")
		return false
	else
		m:IsAddItem(m.nSelectType, vSelect ,nSn, nNum )       --添加物品
		return true
	end

end

local SelectItem = function(m,selectType)
	m.nSelectType = selectType
	UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_1,0)
	UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_2,0)
	UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_3,0)
	UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_4,0)
	if selectType == EquipStrongItemType.COMBINE_REQUIRE_TYPE_WEAPON then     --合成-装备
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_1,1)
			RefreshEquip(m, EquipStrongTab.REQUIRE_COMBINE) --刷新
	elseif selectType == EquipStrongItemType.COMBINE_REQUIRE_TYPE_MATERIAL then  --合成-材料
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_2,1)
			RefreshEquip(m, EquipStrongTab.REQUIRE_COMBINE) --刷新
	elseif selectType == EquipStrongItemType.COMBINE_REQUIRE_TYPE_STARTITEM  then  --合成启动道具
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_3,1)
			RefreshEquip(m, EquipStrongTab.REQUIRE_COMBINE) --刷新
	elseif selectType == EquipStrongItemType.STUD_REQUIRE_TYPE_WEAPON then      --镶嵌--装备
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_1,1)
			RefreshEquip(m, EquipStrongTab.REQUIRE_STUD_GEM) --刷新
	elseif selectType == EquipStrongItemType.STUD_REQUIRE_TYPE_GEM then           --镶嵌--宝石
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_2,1)
			RefreshEquip(m, EquipStrongTab.REQUIRE_STUD_GEM) --刷新
	elseif selectType == EquipStrongItemType.STUD_REQUIRE_TYPE_STARTITEM  then         --镶嵌——启动道具
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_3,1)
			RefreshEquip(m, EquipStrongTab.REQUIRE_STUD_GEM) --刷新
	elseif selectType == EquipStrongItemType.DETACH_REQUIRE_TYPE_WEAPON then     --分离--装备
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_1,1)
			RefreshEquip(m, EquipStrongTab.REQUIRE_DETACH_GEM) --刷新
	elseif selectType == EquipStrongItemType.DETACH_REQUIRE_TYPE_DETACH_ITEM then  --分离--物品
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_2,1)
			RefreshEquip(m, EquipStrongTab.REQUIRE_DETACH_GEM) --刷新
	elseif selectType == EquipStrongItemType.DETACH_REQUIRE_TYPE_STARTITEM  then         --分离-启动道具
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_3,1)
			RefreshEquip(m, EquipStrongTab.REQUIRE_DETACH_GEM) --刷新
	elseif selectType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_WEAPON then           --升级-装备
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_1,1)
			RefreshEquip(m, EquipStrongTab.REQUIRE_UPGRADE) --刷新
	elseif selectType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_UPDATE_ITEM then		 --升级-物品
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_2,1)
			RefreshEquip(m, EquipStrongTab.REQUIRE_UPGRADE) --刷新
	elseif selectType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_STARTITEM  then            --升级-启动道具
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_3,1)
			RefreshEquip(m, EquipStrongTab.REQUIRE_UPGRADE) --刷新
	elseif selectType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_ASSISTENT_ITEM then   --升级-道具
			UI_Engine.SetState(m.formIndex ,COMPOSIT_SIGN_4,1)
			RefreshEquip(m, EquipStrongTab.REQUIRE_UPGRADE) --刷新
	end
	
end

local UseItem = function(m)

	if m:IsAlreadySend() then    --判断是否正在发生请求
		return
	end
	
	if m:IsItemNull(m.nSelectType) then
			--如果物品栏为空  --添加 向下执行
	else
			--如果物品栏不为空  信息
		--UpdateDecribe(m,m.nSelectType)
		--获得这两个参数 打开显示信息界面
		return
	end

	if m.nSelectType == EquipStrongItemType.COMBINE_REQUIRE_TYPE_WEAPON then     --合成-装备
		local pfun_weapon = m:FuncCombineEquipFilter_lua()  --获取打开背包的指针
		m.package = NewPackage(m,pfun_weapon, m)           --打开背包

		if m.package == nil then
			WarnUser(m, "背包打开失败 没有装备")
			return
		end

		m.package:WaitUserInput(m)
		local vSelect = m.package:GetSelectItem()
		local nSn, nNum = m.package:GetSelectSimpleItem()
		DelPackage(m.package )
		AddItem(m, vSelect ,nSn, nNum) -- 添加物品
		RefreshEquip(m, EquipStrongTab.REQUIRE_COMBINE) --刷新
	elseif m.nSelectType == EquipStrongItemType.COMBINE_REQUIRE_TYPE_MATERIAL then  --合成-材料
		local pfun_material = m:FuncCombineItemFilter_lua()  --获取打开背包的指针
		m.package = NewPackage(m,pfun_material, m)           --打开背包

		if m.package == nil then
			WarnUser(m, "背包打开失败，没有合成材料")
			return
		end
		m.package:WaitUserInput(m)
		local vSelect = m.package:GetSelectItem()
		local nSn, nNum = m.package:GetSelectSimpleItem()
		DelPackage(m.package )
		AddItem(m, vSelect ,nSn, nNum) -- 添加物品
		RefreshEquip(m, EquipStrongTab.REQUIRE_COMBINE) --刷新

	elseif m.nSelectType == EquipStrongItemType.STUD_REQUIRE_TYPE_WEAPON then      --镶嵌--装备
		local pFun_weapon1 = m:FuncStudEquipFilter_lua()  --获取打开背包的指针
		m.package = NewPackage(m,pFun_weapon1, m)           --打开背包

		if m.package == nil then
			WarnUser(m, "背包打开失败，没有装备")
			return
		end

		m.package:WaitUserInput(m)
		local vSelect = m.package:GetSelectItem()
		local nSn, nNum = m.package:GetSelectSimpleItem()
		DelPackage(m.package )
		AddItem(m, vSelect ,nSn, nNum) -- 添加物品
		RefreshEquip(m, EquipStrongTab.REQUIRE_STUD_GEM) --刷新

	elseif m.nSelectType == EquipStrongItemType.STUD_REQUIRE_TYPE_GEM then           --镶嵌--宝石
		local pfun_gem = m:FuncStudItemFilter_lua()  --获取打开背包的指针
		m.package = NewPackage(m, pfun_gem, m)           --打开背包

		if m.package == nil then
			WarnUser(m, "背包打开失败，没有宝石")
			return
		end

		m.package:WaitUserInput(m)
		local vSelect = m.package:GetSelectItem()
		local nSn, nNum = m.package:GetSelectSimpleItem()
		DelPackage(m.package )
		AddItem(m, vSelect ,nSn, nNum) -- 添加物品
		RefreshEquip(m, EquipStrongTab.REQUIRE_STUD_GEM) --刷新

	elseif m.nSelectType == EquipStrongItemType.DETACH_REQUIRE_TYPE_WEAPON then     --分离--装备
		local pfun_weapon2 = m:FuncDetachGemFilter_lua()  --获取打开背包的指针
		m.package = NewPackage(m,pfun_weapon2, m)           --打开背包

		if m.package == nil then
			WarnUser(m, "没有装备")
			return
		end

		m.package:WaitUserInput(m)
		local vSelect = m.package:GetSelectItem()
		local nSn, nNum = m.package:GetSelectSimpleItem()
		DelPackage(m.package )
		AddItem(m, vSelect ,nSn, nNum) -- 添加物品
		RefreshEquip(m, EquipStrongTab.REQUIRE_DETACH_GEM) --刷新

	elseif m.nSelectType == EquipStrongItemType.DETACH_REQUIRE_TYPE_DETACH_ITEM then  --分离--物品
		local plist_item = m:GetOpenPageList_Gem()  --获取打开背包的列表指针
		m.package = NewPackage(m,PackageMode.MODE_SELECT, plist_item)           --打开背包

		if m.package ==nil then
			if QueryUser(m, "背包里面没有此物品是否购买？") == MsgBox.ECODE_YES then
				m:BuyDetachItem()
			end
		else
			m.package:WaitUserInput(m)
			local vSelect = m.package:GetSelectItem()
			local nSn, nNum = m.package:GetSelectSimpleItem()
			DelPackage(m.package )
			AddItem(m, vSelect ,nSn, nNum) -- 添加物品
		end
		RefreshEquip(m, EquipStrongTab.REQUIRE_DETACH_GEM) --刷新

	elseif m.nSelectType == EquipStrongItemType.DETACH_REQUIRE_TYPE_ASSISTENT_ITEM then  --分离--道具
		local plist_ass = m:GetOPenPageList_GemAssis()  --获取打开背包的列表指针
		m.package = NewPackage(m,PackageMode.MODE_SELECT, plist_ass)           --打开背包

		if m.package == nil then
			if QueryUser(m,"分离道具没有是否购买？") == MsgBox.ECODE_YES then
				m:BuyAssistentItem()
			end
			
		else
			m.package:WaitUserInput(m)
			local vSelect = m.package:GetSelectItem()
			local nSn, nNum = m.package:GetSelectSimpleItem()
			DelPackage(m.package )
			AddItem(m, vSelect ,nSn, nNum) -- 添加物品
		end
		RefreshEquip(m, EquipStrongTab.REQUIRE_DETACH_GEM) --刷新

	elseif m.nSelectType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_WEAPON then           --升级-装备
		local pfun_weapon3 = m:FuncUpgradeEquipFilter_lua()  --获取打开背包的指针
		m.package = NewPackage(m,pfun_weapon3, m)           --打开背包

		if m.package == nil then
			WarnUser(m, "没有装备")
			return
		end
		m.package:WaitUserInput(m)
		local vSelect = m.package:GetSelectItem()
		local nSn, nNum = m.package:GetSelectSimpleItem()
		DelPackage(m.package )
		AddItem(m, vSelect ,nSn, nNum) -- 添加物品
		RefreshEquip(m, EquipStrongTab.REQUIRE_UPGRADE) --刷新

	elseif m.nSelectType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_UPDATE_ITEM then		 --升级-物品
	--	local pfun_item2 = m:FuncUpgradeItemFilter_lua()  --获取打开背包的指针
	--	m.package = NewPackage(m,pfun_item2, m)           --打开背包

	--	if m.package == nil then
	--		WarnUser(m, "package open fail,buy")
	--		return
	--	end

	--	m.package:WaitUserInput(m)
	--	local vSelect = m.package:GetSelectItem()
	--	local nSn, nNum = m.package:GetSelectSimpleItem()
	--	DelPackage(m.package )
	--	AddItem(m, vSelect ,nSn, nNum) -- 添加物品
	--	RefreshEquip(m, EquipStrongTab.REQUIRE_UPGRADE) --刷新

	elseif m.nSelectType == EquipStrongItemType.UPGRADE_REQUIRE_TYPE_ASSISTENT_ITEM then   --升级-道具
		local plist_ass2 = m:GetOpenPageList()  --获取打开背包的列表指针
		m.package = NewPackage(m,PackageMode.MODE_SELECT, plist_ass2)           --打开背包

		if m.package == nil then
			if QueryUser(m,"升级道具没有是否点击购买？") == MsgBox.ECODE_YES then
				m:BuyAssistentItem()
			end
			
		else
			m.package:WaitUserInput(m)
			local vSelect = m.package:GetSelectItem()
			local nSn, nNum = m.package:GetSelectSimpleItem()
			DelPackage(m.package )
			AddItem(m, vSelect ,nSn, nNum) -- 添加物品
		end
		RefreshEquip(m, EquipStrongTab.REQUIRE_UPGRADE) --刷新

	else
		RefreshEquip(m, m.nTab) --刷新
		return
	end
	UpdateDecribe(m,selectType)
	DBGPRINTF("UseItem ____end")
end

local Strong = function(m,nTab)            --强化按钮

	if nTab == EquipStrongTab.REQUIRE_UPGRADE then  --升级
		if m:IsItemNull(EquipStrongItemType.UPGRADE_REQUIRE_TYPE_WEAPON) then
			WarnUser(m,"装备不存在")
			return
		end

		if m:IsItemNull(EquipStrongItemType.UPGRADE_REQUIRE_TYPE_UPDATE_ITEM) then
			WarnUser(m,"物品不存在")
			return
		end
		
		if m:IsHaveRunItem() == false then
			WarnUser(m,"没有启动道具")
			return 
	    end
	
		if m:IsMoneyEnough() == false then
			WarnUser(m,"金额不够")
			return 
		end
		
		if m:IsUpgradeItemEnough() == false then
			WarnUser(m,"升级宝石数量不够用")
			return 
		end
		
		--if m:CanUpgrade() ~= true then
		--	WarnUser(m,"装备不能够升级")
		--	return
		--end
		local name,time = m:GetWaitInfo()
		if WaitBar(m,name ,time) == 3 then
				m:DoSendUpgradeRequest()         --发送请求
		end


		RefreshEquip(m,EquipStrongTab.REQUIRE_UPGRADE )--更新


	elseif nTab == EquipStrongTab.REQUIRE_STUD_GEM then  --镶嵌
		if m:IsItemNull(EquipStrongItemType.STUD_REQUIRE_TYPE_WEAPON) then
			WarnUser(m,"镶嵌装备不存在")
			return
		end

		if m:IsItemNull(EquipStrongItemType.STUD_REQUIRE_TYPE_GEM) then
			WarnUser(m,"宝石不存在")
			return
		end

		if m:IsHaveRunItem() == false then
			WarnUser(m,"启动道具不够")
			return 
	    end
	
		if m:IsMoneyEnough() == false then
			WarnUser(m,"金额不够")
			return 
		end
		
		if m:IsLevel() ~= true then
			WarnUser(m,"等级不够")
			return
		end

		if m:GemCanbePutInEqu() ~= true  then
			WarnUser(m,"不能够镶嵌")
			return
		end

		local name,time = m:GetWaitInfo()
		if WaitBar(m,name ,time) == 3 then
			m:DoSendStudRequest()       --发送请求
		end


		RefreshEquip(m,EquipStrongTab.REQUIRE_STUD_GEM )--更新

	elseif nTab == EquipStrongTab.REQUIRE_DETACH_GEM then --分离
		if m:IsItemNull(EquipStrongItemType.DETACH_REQUIRE_TYPE_WEAPON) then
			WarnUser(m,"分离装备不存在")
			return
		end

		if m:IsItemNull(EquipStrongItemType.DETACH_REQUIRE_TYPE_DETACH_ITEM) then
			WarnUser(m,"分离道具不存在")
			return
		end

		if m:IsHaveRunItem() == false then
			WarnUser(m,"启动道具不够")
			return 
	    end
	
		if m:IsMoneyEnough() == false then
			WarnUser(m,"金额不够")
			return 
		end
		
		if m:CanBeDetach() == false then
			WarnUser(m,"不能分离，对应的武器凹槽中没有宝石")
			return
		end


		local name,time = m:GetWaitInfo()
		if WaitBar(m,name ,time) == 3 then
			m:DoSendDetachRequest()         --发送请求
		end
		
		RefreshEquip(m,EquipStrongTab.REQUIRE_DETACH_GEM )

	elseif nTab == EquipStrongTab.REQUIRE_COMBINE then    --合成
		if m:IsItemNull(EquipStrongItemType.COMBINE_REQUIRE_TYPE_WEAPON) then
			WarnUser(m,"合成装备不存在")
			return
		end

		if m:IsItemNull(EquipStrongItemType.COMBINE_REQUIRE_TYPE_MATERIAL) then
			WarnUser(m,"合成物品不存在")
			return
		end

		if m:IsHaveRunItem() == false then
			WarnUser(m,"启动道具不够")
			return 
	    end
	
		if m:IsMoneyEnough() == false then
			WarnUser(m,"金额不够")
			return 
		end
		
		if m:IsEquipSuit(EquipStrongItemType.COMBINE_REQUIRE_TYPE_WEAPON) == true then
			WarnUser(m,"装备是套装，不能合成")
			return
		end

		if m:IsLevel() == false then
			WarnUser(m,"装备需求等级小于材料需求等级，不能合成")
			return
		end

		local itemPer = m:IsCombineItemPer(EquipStrongItemType.COMBINE_REQUIRE_TYPE_MATERIAL)
		if itemPer == nil then
			WarnUser("error")
			return
		elseif itemPer then     --是前置材料
			if m:IsCombinePer() then  --是否已经有前置材料
				WarnUser(m,"已经有前置材料")
				return
			end
		else					 --是后置材料
			if m:IsCombineNext() then  --是否已经有前置材料
				WarnUser(m,"已经有后置材料")
				return
			end

		end
		
		


		local name,time = m:GetWaitInfo()
		if WaitBar(m,name ,time) == 3 then
			m:DoSendCombineRequest()           --发送请求
		end
		
		RefreshEquip(m,EquipStrongTab.REQUIRE_DETACH_GEM )
	else

	end

end
FORM_EQUIP_UPGRADE.C50843_OnLoad = function( m )
local  nShowType = m:GetShowType()
m:Clear()

UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_UPGRADE,false)
UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_STONE_ADD,false)
UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_STONE_DETACH,false)
UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_COMBINE,false)
if nShowType == EquipStrongTab.REQUIRE_ALL then
	m:ChangeTab(EquipStrongTab.REQUIRE_UPGRADE)
	m.nTab = EquipStrongTab.REQUIRE_UPGRADE
	m.nSelectType = EquipStrongItemType.UPGRADE_REQUIRE_TYPE_WEAPON
	UI_Engine.SetFormTab( m.formIndex, 0 )

	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_UPGRADE,true)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_STONE_ADD,true)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_STONE_DETACH,true)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_EQUIP_COMBINE,true)
	UI_Engine.SetText(m.formIndex ,COMPOSIT_EQUIP_PLAYERNAME,"装备强化")

elseif nShowType == EquipStrongTab.REQUIRE_UPGRADE then
	m:ChangeTab(EquipStrongTab.REQUIRE_UPGRADE)
	m.nTab = EquipStrongTab.REQUIRE_UPGRADE
	m.nSelectType = EquipStrongItemType.UPGRADE_REQUIRE_TYPE_WEAPON
	UI_Engine.SetFormTab( m.formIndex, 0 )
	UI_Engine.SetText(m.formIndex ,COMPOSIT_EQUIP_PLAYERNAME,"装备升级")
	
elseif nShowType == EquipStrongTab.REQUIRE_STUD_GEM then
	m:ChangeTab(EquipStrongTab.REQUIRE_STUD_GEM)
	m.nTab = EquipStrongTab.REQUIRE_STUD_GEM
	m.nSelectType = EquipStrongItemType.STUD_REQUIRE_TYPE_WEAPON
	UI_Engine.SetFormTab( m.formIndex, 1)
	UI_Engine.SetText(m.formIndex ,COMPOSIT_EQUIP_PLAYERNAME,"装备镶嵌")
	
elseif nShowType == EquipStrongTab.REQUIRE_DETACH_GEM then
	m:ChangeTab(EquipStrongTab.REQUIRE_DETACH_GEM)
	m.nTab = EquipStrongTab.REQUIRE_DETACH_GEM
	m.nSelectType = EquipStrongItemType.DETACH_REQUIRE_TYPE_WEAPON
	UI_Engine.SetFormTab( m.formIndex, 2)
	UI_Engine.SetText(m.formIndex ,COMPOSIT_EQUIP_PLAYERNAME,"装备分离")
	
elseif nShowType == EquipStrongTab.REQUIRE_COMBINE then
	m:ChangeTab(EquipStrongTab.REQUIRE_COMBINE)
	m.nTab = EquipStrongTab.REQUIRE_COMBINE
	m.nSelectType = EquipStrongItemType.COMBINE_REQUIRE_TYPE_WEAPON
	UI_Engine.SetFormTab( m.formIndex, 3)
	UI_Engine.SetText(m.formIndex ,COMPOSIT_EQUIP_PLAYERNAME,"装备合成")
	
end

SelectItem(m,m.nSelectType)
end
FORM_EQUIP_UPGRADE.C50843_OnClick = function( m )
DBGPRINTF("upgrade____begin")
if m:IsAlreadySend() then    --判断是否正在发生请求
	return
end
m:Clear()
m:ChangeTab(EquipStrongTab.REQUIRE_UPGRADE)
m.nTab = EquipStrongTab.REQUIRE_UPGRADE
m.nSelectType = EquipStrongItemType.UPGRADE_REQUIRE_TYPE_WEAPON
UI_Engine.SetFormTab( m.formIndex, 0 )
RefreshEquip(m,EquipStrongTab.REQUIRE_UPGRADE)
DBGPRINTF("upgrade____end")
end



FORM_EQUIP_UPGRADE.C50844_OnClick = function( m )
DBGPRINTF("stud___begin")
if m:IsAlreadySend() then    --判断是否正在发生请求
	return
end
m:Clear()
m:ChangeTab(EquipStrongTab.REQUIRE_STUD_GEM)
m.nTab = EquipStrongTab.REQUIRE_STUD_GEM
m.nSelectType = EquipStrongItemType.STUD_REQUIRE_TYPE_WEAPON
UI_Engine.SetFormTab( m.formIndex, 1 )
RefreshEquip(m,EquipStrongTab.REQUIRE_STUD_GEM)
DBGPRINTF("studend____end")
end
FORM_EQUIP_UPGRADE.C50845_OnClick = function( m )
DBGPRINTF("detach ______begin")
if m:IsAlreadySend() then    --判断是否正在发生请求
	return
end
m:Clear()
m:ChangeTab(EquipStrongTab.REQUIRE_DETACH_GEM)
m.nTab = EquipStrongTab.REQUIRE_DETACH_GEM
m.nSelectType = EquipStrongItemType.DETACH_REQUIRE_TYPE_WEAPON
UI_Engine.SetFormTab( m.formIndex, 2 )
RefreshEquip(m,EquipStrongTab.REQUIRE_DETACH_GEM)
DBGPRINTF("detach ______end")
end
FORM_EQUIP_UPGRADE.C50846_OnClick = function( m )
DBGPRINTF("combine ________begin")
if m:IsAlreadySend() then    --判断是否正在发生请求
	return
end
m:Clear()
m:ChangeTab(EquipStrongTab.REQUIRE_COMBINE)
m.nTab = EquipStrongTab.REQUIRE_COMBINE
m.nSelectType = EquipStrongItemType.COMBINE_REQUIRE_TYPE_WEAPON
UI_Engine.SetFormTab( m.formIndex, 3 )
RefreshEquip(m,EquipStrongTab.REQUIRE_COMBINE)
DBGPRINTF("combine ________end")

end
FORM_EQUIP_UPGRADE.C52785_OnClick = function( m )
UseItem(m)
end
FORM_EQUIP_UPGRADE.C50847_OnClick = function( m )
DBGPRINTF("clean menubar -- begin")
if m:IsAlreadySend() then    --判断是否正在发生请求
	return
end
m:ClearItem(m.nSelectType)  --清除当前选择项
DBGPRINTF("clean menubar  cearl")
if m.nTab == nil then
	DBGPRINTF("nTab is nil")
else
	DBGPRINTF("nTab ="..m.nTab)
	RefreshEquip(m, m.nTab)            ---刷新
end
DBGPRINTF("clean menubar  --end")
end
FORM_EQUIP_UPGRADE.C50868_OnClick = function( m )
if m:IsAlreadySend() then    --判断是否正在发生请求
	return
end
--此购买只能购买升级的物品

if m:IsItemNull(EquipStrongItemType.UPGRADE_REQUIRE_TYPE_WEAPON )then
	WarnUser(m, "请先添加升级的装备")
	return 
end
	if m:BuyUpgradeItem() then   --如果是人民币就挂起
		m:WaitUserInput(m)
	end

	m.SelectNumBox = NewNumSel(m, "请选择数量", 1, 1, 30)
	m.SelectNumBox:WaitUserInput(m)
	local nNumSel = m.SelectNumBox:GetResult()
	DelNumSel(m.SelectNumBox)
	
	if nNumSel == -1 then
		return 
	end
	
	if QueryUser(m, "是否购买？") == MsgBox.ECODE_YES  then
		m:SendBuyUpdradeItem(nNumSel)
	end

	

end
FORM_EQUIP_UPGRADE.C52396_OnClick = function( m )
if m:IsAlreadySend() then    --判断是否正在发生请求
	return
end		
local name, pInfo = m:GetItemDescribe(m.nSelectType)
if pInfo == nil then
	DBGPRINTF("PiNFO is nil")
end
if name ~= nil and pInfo ~= nil  then
	m.info = NewInfo(m,name,pInfo)
	m.info:WaitUserInput(m)
	DelInfo(m.info)
end
--UpdateDecribe(m,selectType)
--获得这两个参数 打开显示信息界面
end
FORM_EQUIP_UPGRADE.C50869_OnLoad = function( m )
m.bDraw = false

local  nShowType = m:GetShowType()
if nShowType == EquipStrongTab.REQUIRE_ALL then
	UI_Engine.SetText(m.formIndex ,COMPOSIT_EQUIP_RIGHT_3,"装备强化")

elseif nShowType == EquipStrongTab.REQUIRE_UPGRADE then
	UI_Engine.SetText(m.formIndex ,COMPOSIT_EQUIP_RIGHT_3,"升级")
elseif nShowType == EquipStrongTab.REQUIRE_STUD_GEM then
	UI_Engine.SetText(m.formIndex ,COMPOSIT_EQUIP_RIGHT_3,"镶嵌")
elseif nShowType == EquipStrongTab.REQUIRE_DETACH_GEM then
	UI_Engine.SetText(m.formIndex ,COMPOSIT_EQUIP_RIGHT_3,"分离")
	
elseif nShowType == EquipStrongTab.REQUIRE_COMBINE then
	UI_Engine.SetText(m.formIndex ,COMPOSIT_EQUIP_RIGHT_3,"合成")
end
end
FORM_EQUIP_UPGRADE.C50869_OnClick = function( m )
DBGPRINTF("strong_____begin")
if m:IsAlreadySend() then    --判断是否正在发生请求
	return
end
Strong(m,m.nTab)
m.bDraw = true 
DBGPRINTF("strong_____end")
end
FORM_EQUIP_UPGRADE.C50869_OnDraw = function( m )
if m.bDraw == true then
	if m:IsUpdateItem() then
		RefreshEquip(m, m.nTab)
		m.bDraw = false
	end
end
end
FORM_EQUIP_UPGRADE.C52752_OnClick = function( m )
DBGPRINTF("exit _______begin")
if m:IsAlreadySend() then    --判断是否正在发生请求
	return
end
m:InputFinished()
m:Close()
DBGPRINTF("exit _______end")
end
FORM_EQUIP_UPGRADE.C50848_OnClick = function( m )
DBGPRINTF("exit _______begin")
if m:IsAlreadySend() then    --判断是否正在发生请求
	return
end
m:InputFinished()
m:Close()
DBGPRINTF("exit _______end")
end
FORM_EQUIP_UPGRADE.C50860_OnClick = function( m )

--UseItem(m,EquipStrongItemType.UPGRADE_REQUIRE_TYPE_WEAPON)
SelectItem(m,EquipStrongItemType.UPGRADE_REQUIRE_TYPE_WEAPON)
end
FORM_EQUIP_UPGRADE.C50861_OnClick = function( m )
SelectItem(m,EquipStrongItemType.UPGRADE_REQUIRE_TYPE_UPDATE_ITEM)
end
FORM_EQUIP_UPGRADE.C52036_OnClick = function( m )
SelectItem(m,EquipStrongItemType.UPGRADE_REQUIRE_TYPE_ASSISTENT_ITEM)
end
FORM_EQUIP_UPGRADE.C50862_OnClick = function( m )
SelectItem(m,EquipStrongItemType.UPGRADE_REQUIRE_TYPE_STARTITEM)
end
FORM_EQUIP_UPGRADE.C50870_OnClick = function( m )
SelectItem(m,EquipStrongItemType.STUD_REQUIRE_TYPE_WEAPON)
end
FORM_EQUIP_UPGRADE.C50871_OnClick = function( m )
SelectItem(m,EquipStrongItemType.STUD_REQUIRE_TYPE_GEM)
end
FORM_EQUIP_UPGRADE.C52040_OnClick = function( m )
SelectItem(m,EquipStrongItemType.STUD_REQUIRE_TYPE_STARTITEM)
end
FORM_EQUIP_UPGRADE.C50976_OnClick = function( m )
SelectItem(m,EquipStrongItemType.DETACH_REQUIRE_TYPE_WEAPON)
end
FORM_EQUIP_UPGRADE.C50975_OnClick = function( m )
SelectItem(m,EquipStrongItemType.DETACH_REQUIRE_TYPE_DETACH_ITEM)
end
FORM_EQUIP_UPGRADE.C52035_OnClick = function( m )
SelectItem(m,EquipStrongItemType.DETACH_REQUIRE_TYPE_ASSISTENT_ITEM)
end
FORM_EQUIP_UPGRADE.C50977_OnClick = function( m )
SelectItem(m,EquipStrongItemType.DETACH_REQUIRE_TYPE_STARTITEM)
end
FORM_EQUIP_UPGRADE.C50982_OnClick = function( m )
SelectItem(m,EquipStrongItemType.COMBINE_REQUIRE_TYPE_WEAPON)
end
FORM_EQUIP_UPGRADE.C50983_OnClick = function( m )
SelectItem(m,EquipStrongItemType.COMBINE_REQUIRE_TYPE_MATERIAL)
end
FORM_EQUIP_UPGRADE.C52042_OnClick = function( m )
SelectItem(m,EquipStrongItemType.COMBINE_REQUIRE_TYPE_STARTITEM)
end
