FORM_EQUIP_LOCK_FORM= { }
FORM_EQUIP_LOCK_FORM.Main = function( m )
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

local GetControl = function(m,nType)    --根据物品的类型返回物品的控件ID
	
	if nType == ItemLockType.REQUIRE_ITEM_TYPE_LOCK then
		return COMPOSIT_ITEM_LOCK
	elseif nType == ItemLockType.REQUIRE_ITEM_TYPE_UNLOCK then
		return COMPOSIT_ITEM_UN_LOCK
	else
		DBGPRINTF("GetControl_______error")
		return nil
	end
end

local GetShowControl = function(m,nType)    --根据物品的类型返回显示的控件
	
	if nType == ItemLockType.REQUIRE_ITEM_TYPE_LOCK then
		return COMPOSIT_EQUIP_LOCK_NAME
	elseif nType == ItemLockType.REQUIRE_ITEM_TYPE_UNLOCK then
		return COMPOSIT_EQUIP_LOCK_NAME
	else
		return nil
	end
end


local UpdateItem = function ( m,nType)    ---更新图标
	DBGPRINTF("UpdateItem_______begin")
	local control = GetControl(m,nType)
	local showcontrol = GetShowControl(m,nType)
	local img ,nSN = m:GetItemImg( nType )
	local strShow = m:GetShowName(nType)    --根据枚举获取本物品的字符串
	
	if img ~= nil then
		UI_Engine.SetSurfaceImg( m.formIndex, control, img ,0,0,false,nSN )
	else	
		UI_Engine.SetSurfaceImg( m.formIndex, control, nil )
	end
	
	if strShow ~= nil then                                ---跟新显示区域   
		UI_Engine.SetText( m.formIndex, showcontrol, strShow)
	else
		UI_Engine.SetText( m.formIndex, showcontrol, "")
	end
	
	local strDesc = m:UpdateDescriptionClient(nType)      ---跟新描述区域
	if strDesc ~= nil then
		UI_Engine.SetText(m.formIndex, COMPOSIT_EQUIP_LOCK_DETAIL ,strDesc)
	else 
		UI_Engine.SetText(m.formIndex, COMPOSIT_EQUIP_LOCK_DETAIL ,"")
	end
end

local RefreshEquip = function ( m, nTab )         --刷新

	DBGPRINTF("RefreshEquip  begin")
	if nTab == ItemLockTab.REQUIRE_LOCK then
		UpdateItem(m,ItemLockType.REQUIRE_ITEM_TYPE_LOCK)
	elseif nTab == ItemLockTab.REQUIRE_UN_LOCK then
		UpdateItem(m,ItemLockType.REQUIRE_ITEM_TYPE_UNLOCK)
	else
	
	end
end

local AddItem = function(m, vSelect) --添加物品
	if m:IsLock(vSelect) then
		m:ClearItem(m.nSelectType)
		WarnUser(m,"物品已经加锁")
		return false
	else
		m:AddItem(m.nSelectType, vSelect)       --添加物品
	end
	return true
end

local UseItem = function(m,selectType)
	m.nSelectType = selectType
	if m:IsItemNull(m.nSelectType) then
			--如果物品栏为空  --添加 向下执行
	else
		--获得这两个参数 打开显示信息界面
		return
	end
	
	if selectType == ItemLockType.REQUIRE_ITEM_TYPE_LOCK then     --
		local pfun_lock = m:FuncLockItemFilter_lua()  --获取打开背包的指针
			DBGPRINTF("User_pfun_lock___end")
		m.package = NewPackage(m,pfun_lock, m)           --打开背包
		if m.package == nil then
			WarnUser(m, "背包没有打开 没有装备")
			return
		end

		m.package:WaitUserInput(m)
		local vSelect = m.package:GetSelectItem()
		DelPackage(m.package )
		if vSelect == nil then
			return 
		end
		AddItem(m, vSelect) -- 添加物品
		RefreshEquip(m, ItemLockTab.REQUIRE_LOCK) --刷新
		
	elseif selectType == ItemLockType.REQUIRE_ITEM_TYPE_UNLOCK then  --
		local pfun_nulock = m:FuncLockItemFilter_lua()  --获取打开背包的指针
		m.package = NewPackage(m,pfun_nulock, m)           --打开背包

		if m.package == nil then
			WarnUser(m, "背包没有打开没有要解锁的装备")
			return
		end
		m.package:WaitUserInput(m)
		local vSelect = m.package:GetSelectItem()
		DelPackage(m.package )
		if vSelect == nil then
			return 
		end
                        m:AddItem(m.nSelectType, vSelect)       --添加物品

		RefreshEquip(m, ItemLockTab.REQUIRE_UN_LOCK) --刷新
		
	else
		return 
	end
	
end

local Lock = function(m)            --加锁按钮
	if m:IsItemNull(ItemLockType.REQUIRE_ITEM_TYPE_LOCK) then
		WarnUser(m,"装备不存在")
		return
	end
	
	if m:IsLockProps()  ~= true then                              --是否有加锁道具
		WarnUser(m,"没有加锁道具")
		return 
	end
	
	if m:IsUnLockTime(ItemLockType.REQUIRE_ITEM_TYPE_LOCK) then         --解锁时间换没有到
		WarnUser(m,"解锁时间没有到")
		return 
	end
	
	if m:IsItemLock(ItemLockType.REQUIRE_ITEM_TYPE_LOCK) then        ----是否已经加锁
		WarnUser(m,"装备已经加锁")
		return 
	end
	
	local nMaxCap = m:GetItemMaxCap(ItemLockType.REQUIRE_ITEM_TYPE_LOCK)
	
	if nMaxCap == nil then
		return
	end
	
	if nMaxCap > 1 then                --是否叠加
		WarnUser(m,"此物品不能加锁 叠加")
		return 
	end
	
	m:DoSendLockRequest()             --发送请求
end
local UnLock = function(m)          --解锁按钮
	if m:IsItemNull(ItemLockType.REQUIRE_ITEM_TYPE_UNLOCK) then
		WarnUser(m,"解锁装备不存在")
		return
	end
	
	if m:IsUnLockProps()  ~= true then                              --是否有解锁道具
		WarnUser(m,"没有解锁道具")
		return 
	end
	
	if m:IsUnLockTime(ItemLockType.REQUIRE_ITEM_TYPE_UNLOCK) then         --解锁时间换没有到
		WarnUser(m,"解锁时间没有到")
		return 
	end
	
	if m:IsItemLock(ItemLockType.REQUIRE_ITEM_TYPE_UNLOCK) ~= true then        ----是否已经解锁
		WarnUser(m,"装备没有加锁")
		return 
	end
	
	local nMaxCap = m:GetItemMaxCap(ItemLockType.REQUIRE_ITEM_TYPE_UNLOCK)
	
	if nMaxCap == nil then
		return
	end
	
	if nMaxCap > 1 then                --是否叠加
		WarnUser(m,"此物品不能解锁 叠加")
		return 
	end
	
	m:DoSendUnLockRequest()             --发送请求
end
FORM_EQUIP_LOCK_FORM.C50872_OnLoad = function( m )
DBGPRINTF("tab_OnLoad__lock____begin")
m:Clear()
m.nTab = m:GetTab()

if m.nTab == ItemLockTab.REQUIRE_LOCK then
	m.nSelectType = ItemLockType.REQUIRE_ITEM_TYPE_LOCK
	UI_Engine.SetFormTab( m.formIndex, 0 )
else
	m.nSelectType = ItemLockType.REQUIRE_ITEM_TYPE_UNLOCK
	UI_Engine.SetFormTab( m.formIndex, 1 )
end

DBGPRINTF("tab_OnLoad__lock____end")
end
FORM_EQUIP_LOCK_FORM.C50872_OnClick = function( m )
DBGPRINTF("tab_lock____begin")
m:Clear()
m:ChangeTab(ItemLockTab.REQUIRE_LOCK)
m.nTab = ItemLockTab.REQUIRE_LOCK
m.nSelectType = ItemLockType.REQUIRE_ITEM_TYPE_LOCK
UI_Engine.SetFormTab( m.formIndex, 0 )
RefreshEquip(m,ItemLockTab.REQUIRE_LOCK)
DBGPRINTF("tab_lock____end")



UI_Engine.SetText( m.formIndex, COMPOSIT_EQUIP_LOCK_LOCK, "加锁")

end
FORM_EQUIP_LOCK_FORM.C50873_OnClick = function( m )
DBGPRINTF("tab_un_lock____begin")
m:Clear()
m:ChangeTab(ItemLockTab.REQUIRE_UN_LOCK)
m.nTab = ItemLockTab.REQUIRE_UN_LOCK
m.nSelectType = ItemLockType.REQUIRE_ITEM_TYPE_UNLOCK
UI_Engine.SetFormTab( m.formIndex, 1 )
RefreshEquip(m,ItemLockTab.REQUIRE_UN_LOCK)
DBGPRINTF("tab_un_lock____end")

UI_Engine.SetText( m.formIndex, COMPOSIT_EQUIP_LOCK_LOCK, "解锁")
end
FORM_EQUIP_LOCK_FORM.C50876_OnClick = function( m )

local name, pInfo = m:GetItemDescribe(m.nSelectType)
if pInfo == nil then
	
end
if name ~= nil and pInfo ~= nil  then
	m.info = NewInfo(m,name,pInfo)
	m.info:WaitUserInput(m)
	DelInfo(m.info)
end

end
FORM_EQUIP_LOCK_FORM.C50877_OnClick = function( m )
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
FORM_EQUIP_LOCK_FORM.C52399_OnLoad = function( m )
if m.nTab == ItemLockTab.REQUIRE_LOCK then
	UI_Engine.SetText( m.formIndex, COMPOSIT_EQUIP_LOCK_LOCK, "加锁")
elseif m.nTab == ItemLockTab.REQUIRE_UN_LOCK then
	UI_Engine.SetText( m.formIndex, COMPOSIT_EQUIP_LOCK_LOCK, "解锁")
else
	
end
end
FORM_EQUIP_LOCK_FORM.C52399_OnClick = function( m )
if m.nTab == ItemLockTab.REQUIRE_LOCK then
	Lock(m)
elseif m.nTab == ItemLockTab.REQUIRE_UN_LOCK then
	UnLock(m)
else
	
end
end
FORM_EQUIP_LOCK_FORM.C52753_OnClick = function( m )

m:InputFinished()
m:Close()
--DelItemLock(m)

end
FORM_EQUIP_LOCK_FORM.C50879_OnClick = function( m )

m:InputFinished()
m:Close()
--DelItemLock(m)

end
FORM_EQUIP_LOCK_FORM.C50985_OnClick = function( m )
DBGPRINTF("OnClick_____lock item ______begin")
UseItem(m,ItemLockType.REQUIRE_ITEM_TYPE_LOCK)
DBGPRINTF("OnClick_____lock item ______end")
end
FORM_EQUIP_LOCK_FORM.C50884_OnClick = function( m )
DBGPRINTF("OnClick_____lock item ______begin")
UseItem(m,ItemLockType.REQUIRE_ITEM_TYPE_UNLOCK)
DBGPRINTF("OnClick_____lock item ______end")
end
FORM_EQUIP_LOCK_FORM.C50883_OnLoad = function( m )
	UI_Engine.SetState(m.formIndex ,COMPOSIT_EQUIP_LOCK_SIGN_1,1)
end
FORM_EQUIP_LOCK_FORM.C50881_OnLoad = function( m )
UI_Engine.SetText( m.formIndex, COMPOSIT_EQUIP_LOCK_PLAYERNAME, "道具保护")

end
