FORM_DEAL= { }
FORM_DEAL.Main = function( m )
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
FORM_DEAL.C52797_OnClick = function( m )
local state=m:Click(1)

SetMyButtonText(m,state)
end
function ClickSelf(m, nIndex) 
	if m:IsMineItemExist(nIndex) then			
		UI_Engine.SetFormTab(m.formIndex,1)	
	else
		UI_Engine.SetFormTab(m.formIndex,0)
	end
m.index=nIndex
end
	

-- 点击侧边"添加 魔法兽"按钮 add by liao
function IsClickAddPet(m)
	m.MsgBox = NewMsgBox(m," 魔法兽交易后会变成未驯化状态.对未驯化魔法兽进行驯化等级会置1,幻化等级不变,是否继续?", MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local ret = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	if  ret == 3 then
		return
	end

	m.Pet = NewPetList(m, 0,1)
	m.Pet:WaitUserInput(m)
	local SelectItem = m.Pet:GetSelectedPet()
	if SelectItem == 0 then
	DelPetList(m.Pet)
	else

		local n_count = IsAdd(m, COMPOSIT_DEAL_MINE_0, COMPOSIT_DEAL_MINE_7)				
		if -1 == n_count then
			DelPetList(m.Pet)
			return false
		end

		m:IncMinePetDeal(SelectItem,  result)
		local ptrIcon = m:GetMineImgIcon(n_count)
		local imgPos = n_count + COMPOSIT_DEAL_MINE_0
		UpdateIcon(m, 7)
		DelPetList(m.Pet)
	
	end	
end

function UpdateOtherIcon(m, ncount) --add by liao
	for nLoop = 0, ncount do
		local ctlID = nLoop +COMPOSIT_DEAL_OTHER_0
		local ptrImg,sn,num = m:GetOtherImgIcon(nLoop)
		UI_Engine.SetSurfaceImg(m.formIndex, ctlID, ptrImg,0,0,false,sn)
		if num ~= nil then
			CurrentControl.SetItemCount(num)
		end
	end
end

function SetOtherButtonText(m, ncount) --add by liao
   if  ncount==0 then
	UI_Engine.SetText(m.formIndex,COMPOSIT_DEAL_OTHER_LOCK,"未锁定")
	UI_Engine.SetText(m.formIndex,COMPOSIT_DEAL_OTHER_CONFIRM,"未确定")
   elseif ncount==1 then
	UI_Engine.SetText(m.formIndex,COMPOSIT_DEAL_OTHER_CONFIRM,"未确定")
	UI_Engine.SetText(m.formIndex,COMPOSIT_DEAL_OTHER_LOCK,"已锁定")
   elseif ncount==2 then
	UI_Engine.SetText(m.formIndex,COMPOSIT_DEAL_OTHER_CONFIRM,"已确定")
	UI_Engine.SetText(m.formIndex,COMPOSIT_DEAL_OTHER_LOCK,"已锁定")
   end
end
function SetMyButtonText(m, ncount) --add by liao
   if  ncount==0 then
	UI_Engine.SetText(m.formIndex,COMPOSIT_DEAL_MY_LOCK,"未锁定")
	UI_Engine.SetText(m.formIndex,COMPOSIT_DEAL_MY_CONFIRM,"未确定")
   elseif ncount==1 then
	UI_Engine.SetText(m.formIndex,COMPOSIT_DEAL_MY_CONFIRM,"未确定")
	UI_Engine.SetText(m.formIndex,COMPOSIT_DEAL_MY_LOCK,"已锁定")
   elseif ncount==2 then
	UI_Engine.SetText(m.formIndex,COMPOSIT_DEAL_MY_CONFIRM,"已确定")
	UI_Engine.SetText(m.formIndex,COMPOSIT_DEAL_MY_LOCK,"已锁定")
   end
end

local WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_CANCEL)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

function IsAdd(m, n_beginLoop, n_endLoop)
	for n = COMPOSIT_DEAL_MINE_0, COMPOSIT_DEAL_MINE_7 do
		local nItemIndex = n - COMPOSIT_DEAL_MINE_0
		if m:IsMineItemExist(nItemIndex) == false then 
			return nItemIndex
		end
	end
		return -1
end
-- 物品数量为1或不为1的情况下
function ManageNum(m, ptrItem,nNum)
	if ptrItem then
		nNum = m:GetVectorCount(ptrItem)
	end
	if  nNum==1 then	-- 为1，添加一项物品
		return 1
	else --弹出数量选择对话框，根据数量决定添加多少
		if nNum==0 then
			nNum=10	
		end	
		m.SelectNumBox = NewNumSel(m, "Select Number", 1, 1, nNum)
		m.SelectNumBox:WaitUserInput(m)
		local  Quantity = m.SelectNumBox:GetResult()
		DelNumSel(m.SelectNumBox)
		DBGPRINTF("lua_info:Deal NumSelect UI")
			if Quantity < 0 then	
				return  -1
			else 
				return  Quantity
			end
	end
end

function UpdateIcon(m, ncount)
	for nLoop = 0, ncount do
		local ctlID = nLoop + COMPOSIT_DEAL_MINE_0
		local ptrImg ,sn, num= m:GetMineImgIcon(nLoop)
		UI_Engine.SetSurfaceImg(m.formIndex, ctlID, ptrImg,0,0,false,sn)
		if num ~= nil then
			CurrentControl.SetItemCount(num)
		end
	end
end

	
function IsSelectGoods(m, ptrItem)
	--DBGPRINTF("lua_info:value of ptrItem = "..ptrItem)
	if m:IsBindItem(ptrItem) then
		WarnUser(m, "物品已绑定，无法交易!")	
		DBGPRINTF("lua_info:物品已绑定")
		return false
	else
		if m:IsLockItem(ptrItem) then
			WarnUser(m, "物品已锁定，无法交易!")
			DBGPRINTF("lua_info:物品已锁定")
			return false
		else
			if m:IsEquipItem(ptrItem) then
				if m:IsEquipHardness(ptrItem) then
					WarnUser(m, "装备无耐久度，无法交易!")
					DBGPRINTF("lua_info:装备无耐久度")
					return false
				else
					return true
				end
			else
				return true
			end
		end
	end
end

-- 点击对方交易界面道具栏位
function ClickOthers(m, nIndex)
	if m:IsOtherItemExist(nIndex) then
		-- 接口未实现
		m.index=nIndex+100
	end
end

-- 点击自己交易界面道具栏位
function ClickMine(m, nIndex) 
	if m:IsMineItemExist(nIndex) then			
		m:DesMineDeal(nIndex)	
		return false
	else
		while true do
			local ptrPack = m:FuncDealFilter_lua()
			m.Pack = NewPackage(m, ptrPack)
			m.Pack:WaitUserInput(m)
			local SelectItem = m.Pack:GetSelectItem()
			if SelectItem == nil then
				DelPackage(m.Pack)
			else
				if IsSelectGoods(m, SelectItem) == false then
					DelPackage(m.Pack)
				elseif IsSelectGoods(m, SelectItem) == true then
					local  result = ManageNum(m, SelectItem)
					DBGPRINTF("lua_info:ret of ManageNum is:"..result)
					if result == -1 then
						DelPackage(m.Pack)
					elseif result == -2 then
						DelPackage(m.Pack)
					else
						local n_count = IsAdd(m, COMPOSIT_DEAL_MINE_0, COMPOSIT_DEAL_MINE_7)
						DBGPRINTF("lua_info:value of n_count = "..n_count)
						if -1 == n_count then
							DelPackage(m.Pack)
							return false
						end
						m:IncMineItemDeal(SelectItem,  result)
						local ptrIcon = m:GetMineImgIcon(n_count)
						local imgPos = n_count + COMPOSIT_DEAL_MINE_0
						UpdateIcon(m, 7)
						DelPackage(m.Pack)
			
						return true
					end
				end
			end
		end
	end
end
-- 锁定
function Lock(m)
	if m:GetMineState(0) == DEAL_STATE_FREE then
		m:PlayerChangeDealState(DEAL_STATE_LOCK)
	else	
		if m:GetMineState(0)  == DEAL_STATE_LOCK then
			m:PlayerChangeDealState(DEAL_STATE_FREE)
		end
	end
end

-- 交易
local Confirm = function(m)
	if m:GetMineState(0)  == DEAL_STATE_LOCK then
		if m:GetOtherState(0)  == DEAL_STATE_LOCK then

		end
	end
end

-- 点击侧边"添加物品"按钮
function IsClickAddItem(m)
	local ptrPack,ptrPack2 = m:FuncDealFilter_lua()
	m.Pack = NewPackage(m, ptrPack,ptrPack2)
	m.Pack:WaitUserInput(m)
	local SelectItem = m.Pack:GetSelectItem()
	local nSn,nNum= m.Pack:GetSelectSimpleItem()--liao
	--DBGPRINTF("the value of SelectItem is:"..SelectItem)
	if nSn==0 then
	DelPackage(m.Pack)
	else
		--if  IsSelectGoods(m, SelectItem) == true then
			local  result = ManageNum(m, SelectItem,nNum)
					if -1 == result then
						DelPackage(m.Pack)
						return false
					elseif result == -2 then
						DelPackage(m.Pack)
						return false
					else
						local n_count = IsAdd(m, COMPOSIT_DEAL_MINE_0, COMPOSIT_DEAL_MINE_7)
						DBGPRINTF("lua_info:value of n_count = "..n_count)
						if -1 == n_count then
							DelPackage(m.Pack)
							return false
						end
						m:IncMineItemDeal(SelectItem,  result,nSn,nNum)
						local ptrIcon = m:GetMineImgIcon(n_count)
						local imgPos = n_count + COMPOSIT_DEAL_MINE_0
						UpdateIcon(m, 7)
						DelPackage(m.Pack)
				end	
		--end
	end	
end
FORM_DEAL.C52796_OnLoad = function( m )
SetOtherButtonText(m,0)
SetMyButtonText(m,0)
end
FORM_DEAL.C52796_OnClick = function( m )
local state=m:Click(0)

SetMyButtonText(m,state)
end
FORM_DEAL.C52793_OnClick = function( m )
m:ChatSend(m.Text)
m.Text=""
UI_Engine.SetText(m.formIndex,COMPOSIT_DEAL_CHAT_ME,m.Text,0)
end
FORM_DEAL.C52475_OnClick = function( m )
m:DesMineDeal(m.index)
UI_Engine.SetFormTab(m.formIndex,0)

end
FORM_DEAL.C50967_OnClick = function( m )
local text=UI_Engine.GetText(m.formIndex,COMPOSIT_DEAL_CHAT_ME)
m.InputBox = OpenInputBox(m,Text,100)
m.InputBox :WaitUserInput(m)
m.Text = m.InputBox :GetResult()
UI_Engine.SetText(m.formIndex,COMPOSIT_DEAL_CHAT_ME,m.Text,0)
end
FORM_DEAL.C50964_OnLoad = function( m )
UI_Engine.SetText(formIndex,COMPOSIT_DEAL_MY_GOLD,0,0)
end
FORM_DEAL.C50964_OnClick = function( m )
local formIndex,gold,Max =m:GetGold()
m.InputBox = OpenInputBox(m,gold,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if false == Tools.IsNumberOnly(result) then
	WarnUser(m, "仅接受数字输入!")
	result = gold
	UI_Engine.SetText(m.formIndex, COMPOSIT_DEAL_MY_GOLD,result)
end
result=tonumber(result)
if result<0 or result>Max then --防止刷钱
	result=Max
end

m:SetGold(result)
UI_Engine.SetText(formIndex,COMPOSIT_DEAL_MY_GOLD,result,0)
end
FORM_DEAL.C50946_OnClick = function( m )
--ClickMine(m, 7)
ClickSelf(m, 7) 

end
FORM_DEAL.C50946_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(7)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_MINE_7, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end

end
FORM_DEAL.C50945_OnClick = function( m )
--ClickMine(m, 6)
ClickSelf(m, 6) 
end
FORM_DEAL.C50945_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(6)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_MINE_6, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end


		


FORM_DEAL.C50944_OnClick = function( m )
--ClickMine(m, 5)
ClickSelf(m, 5) 
end
FORM_DEAL.C50944_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(5)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_MINE_5, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
FORM_DEAL.C50943_OnClick = function( m )
--ClickMine(m, 4)
ClickSelf(m, 4) 
end
FORM_DEAL.C50943_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(4)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_MINE_4, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
FORM_DEAL.C50942_OnClick = function( m )
--ClickMine(m, 3)
ClickSelf(m, 3) 
end
FORM_DEAL.C50942_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(3)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_MINE_3, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
FORM_DEAL.C50941_OnClick = function( m )
--ClickMine(m, 2)
ClickSelf(m, 2) 
end
FORM_DEAL.C50941_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(2)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_MINE_2, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
FORM_DEAL.C50940_OnClick = function( m )
--ClickMine(m, 1)
ClickSelf(m, 1) 
end
FORM_DEAL.C50940_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(1)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_MINE_1, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
FORM_DEAL.C50939_OnClick = function( m )
--ClickMine(m, 0)
ClickSelf(m, 0) 
end
FORM_DEAL.C50939_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(0)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_MINE_0, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
FORM_DEAL.C50938_OnClick = function( m )
ClickOthers(m,7)
end
FORM_DEAL.C50938_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(7)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_OTHER_7, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
FORM_DEAL.C50937_OnClick = function( m )
ClickOthers(m,6)
end
FORM_DEAL.C50937_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(6)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_OTHER_6, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
FORM_DEAL.C50936_OnClick = function( m )
ClickOthers(m,5)
end
FORM_DEAL.C50936_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(5)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_OTHER_5, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
FORM_DEAL.C50935_OnClick = function( m )
ClickOthers(m,4)
end
FORM_DEAL.C50935_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(4)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_OTHER_4, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
end
end
FORM_DEAL.C50934_OnClick = function( m )
ClickOthers(m,3)
end
FORM_DEAL.C50934_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(3)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_OTHER_3, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
FORM_DEAL.C50933_OnClick = function( m )
ClickOthers(m,2)
end
FORM_DEAL.C50933_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(2)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_OTHER_2, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
FORM_DEAL.C50932_OnClick = function( m )
ClickOthers(m,1)
end
FORM_DEAL.C50932_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(1)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_OTHER_1, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
FORM_DEAL.C50931_OnClick = function( m )
ClickOthers(m,0)
end
FORM_DEAL.C50931_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(0)
--if ptrImg ~= nil then
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_DEAL_OTHER_0, ptrImg,0,0,false,nsn)
--end
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
local formIndex,selfChange,otherChange,selfState,otherState,otherMoney,otherchangeIcon,selfchangeIcon=m:GetAllInfo()

UI_Engine.SetText(formIndex,COMPOSIT_DEAL_OTHER_GOLD,otherMoney)
--[[
if otherchangeIcon==1 then
 UpdateOtherIcon(m, 7)
end

if selfchangeIcon==1 then
 UpdateIcon(m, 7)
end
--]]
SetMyButtonText(m,selfState)
SetOtherButtonText(m,otherState)






end
FORM_DEAL.C50922_OnClick = function( m )
m:CancelDeal(0)
end
FORM_DEAL.C50921_OnClick = function( m )
IsClickAddPet(m)
end
FORM_DEAL.C50920_OnClick = function( m )
IsClickAddItem(m)
end
FORM_DEAL.C50919_OnClick = function( m )
local name, ptr =m:Detail(m.index)
if name ~=nil then
m.info = NewInfo(m, name, ptr)
end
end
