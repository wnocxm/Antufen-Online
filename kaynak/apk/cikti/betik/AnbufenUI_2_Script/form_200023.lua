NEW_FORM_NEWDEAL= { }
NEW_FORM_NEWDEAL.Main = function( m )
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
local WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_OK)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

function IsAdd(m, n_beginLoop, n_endLoop)
	for n = UI2_COMPOSIT_634, UI2_COMPOSIT_641 do
		local nItemIndex = n - UI2_COMPOSIT_634
		if m:IsMineItemExist(nItemIndex) == false then
			return nItemIndex
		end
	end
		return -1
end

function UpdateIcon(m, ncount)
	for nLoop = 0, ncount do
		local ctlID = nLoop + UI2_COMPOSIT_634
		local ptrImg ,sn, num= m:GetMineImgIcon(nLoop)
		UI_Engine.SetSurfaceImg(m.formIndex, ctlID, ptrImg,0,0,false,sn)
		if num ~= nil then
			CurrentControl.SetItemCount(num)
		end
	end
	UI_Engine.SetStateNull(m.formIndex)
end

function ClickSelf(m, nIndex)
	if m:IsMineItemExist(nIndex) then
		local img, str, info, sn = m:Detail(nIndex)
		if img ~=nil then
			if sn ~= nil then
				m.info = NewItemInfo(m, img, str, info, sn)
				m.info:WaitUserInput(m)
				local ret = m.info:GetResult()
				DelItemInfo(m.info)
				if ret == 2 then
					m:DesMineDeal(nIndex)
				end
			else
				m.pet = NewPetComplex(m, img, 1)
				m.pet:WaitUserInput(m)
				local ret = m.pet:GetResult()
				DelPetComplex(m.pet)
				if ret == 1 then
					m:DesMineDeal(UI2_COMPOSIT_634)
				end
			end
		end
	end
end

function UpdateOtherIcon(m, ncount)
	for nLoop = 0, ncount do
		local ctlID = nLoop + UI2_COMPOSIT_652
		local ptrImg,sn,num = m:GetOtherImgIcon(nLoop)
		UI_Engine.SetSurfaceImg(m.formIndex, ctlID, ptrImg,0,0,false,sn)
		DBGPRINTF("======formIndex = "..m.formIndex)
		if num ~= nil then
			CurrentControl.SetItemCount(num)
		else
			CurrentControl.SetItemCount(0)
		end
	end
	UI_Engine.SetStateNull(m.formIndex)
end

-- 点击对方交易界面道具栏位
function ClickOthers(m, nIndex)
	if m:IsOtherItemExist(nIndex) then
		nIndex = nIndex + 100
		local img, str, info, sn = m:Detail(nIndex)
		if img ~=nil then
			if sn ~= nil then
				m.info = NewItemInfo(m, img, str, info, sn)
				m.info:WaitUserInput(m)
				DelItemInfo(m.info)
				UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_652)
			else
				m.pet = NewPetComplex(m, img, 1, false)
				m.pet:WaitUserInput(m)
				DelItemInfo(m.pet)
				UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_652)
			end
		end
	end
end


function SetOtherButtonText(m, ncount)
   if  ncount==0 then
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_662, true)
		UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_895, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_665, true)
		UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_896, false)
   elseif ncount==1 then
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_662, false)
		UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_895, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_665, true)
		UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_896, false)
   elseif ncount==2 then
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_662, false)
		UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_895, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_665, false)
		UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_896, true)
   end
end

function SetMyButtonText(m, ncount)
   if  ncount==0 then
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_646, true)
		UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_897, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_647, true)
		UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_898, false)
   elseif ncount==1 then
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_646, false)
		UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_897, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_647, true)
		UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_898, false)
   elseif ncount==2 then
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_646, false)
		UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_897, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_647, false)
		UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_898, true)
   end
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
		m.SelectNumBox = NewNumSel(m, STR_COMBINE_NUMBER, 1, 1, nNum)
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


function IsSelectGoods(m, ptrItem)
	--DBGPRINTF("lua_info:value of ptrItem = "..ptrItem)
	if m:IsBindItem(ptrItem) then
		WarnUser(m, STR_ITEM_BINDED)
		return false
	else
		if m:IsLockItem(ptrItem) then
			WarnUser(m, STRING_ITEM_LOCK)
			return false
		else
			if m:IsEquipItem(ptrItem) then
				if m:IsEquipHardness(ptrItem) then
					WarnUser(m, STRING_ITEM_DEAL_HARDNESS)
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

-- 点击自己交易界面道具栏位
function ClickMine(m, nIndex)
	if m:IsMineItemExist(nIndex) then
		m:DesMineDeal(nIndex)
		return false
	else
		while true do
			local ptrPack = m:FuncDealFilter_lua()
			m.Pack = NewSelectBag(m, ptrPack)
			m.Pack:WaitUserInput(m)
			local SelectItem = m.Pack:GetSelectItem()
			if SelectItem == nil then
				DelSelectBag(m.Pack)
			else
				if IsSelectGoods(m, SelectItem) == false then
					DelSelectBag(m.Pack)
				elseif IsSelectGoods(m, SelectItem) == true then
					local  result = ManageNum(m, SelectItem)
					DBGPRINTF("lua_info:ret of ManageNum is:"..result)
					if result == -1 then
						DelSelectBag(m.Pack)
					elseif result == -2 then
						DelSelectBag(m.Pack)
					else
						local n_count = IsAdd(m, UI2_COMPOSIT_634, UI2_COMPOSIT_641)
						DBGPRINTF("lua_info:value of n_count = "..n_count)
						if -1 == n_count then
							DelSelectBag(m.Pack)
							return false
						end
						m:IncMineItemDeal(SelectItem,  result)
						local ptrIcon = m:GetMineImgIcon(n_count)
						local imgPos = n_count + UI2_COMPOSIT_634
						UpdateIcon(m, 7)
						DelSelectBag(m.Pack)

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
	m.Pack = NewSelectBag(m, ptrPack,ptrPack2)
	if m.Pack == nil then
		WarnUser(m, STR_HAVE_NO_MATH_ITEM)
		return
	end
	m.Pack:WaitUserInput(m)
	local SelectItem = m.Pack:GetSelectItem()
	local nSn,nNum= m.Pack:GetSelectSimpleItem()--liao
	--DBGPRINTF("the value of SelectItem is:"..SelectItem)
	local exit = m.Pack:GetExitCode()
	if 0 == exit then
		DelSelectBag(m.Pack)
		return
	end
	if SelectItem ~= nil then
		local  result = ManageNum(m, SelectItem,nNum)
		if -1 == result then
			DelSelectBag(m.Pack)
			return false
		elseif result == -2 then
			DelSelectBag(m.Pack)
			return false
		else
			local n_count = IsAdd(m, UI2_COMPOSIT_634, UI2_COMPOSIT_641)
			DBGPRINTF("lua_info:value of n_count = "..n_count)
			if -1 == n_count then
				DelSelectBag(m.Pack)
				return false
			end
			m:IncMineItemDeal(SelectItem,  result,nSn,nNum)
			local ptrIcon = m:GetMineImgIcon(n_count)
			local imgPos = n_count + UI2_COMPOSIT_634
			UpdateIcon(m, 7)
			DelSelectBag(m.Pack)
		end
	else
		if nSn == 0 then
			DelSelectBag(m.Pack)
			WarnUser(m, STR_HAVE_NO_MATH_ITEM)
			return
		else
			local n_count = IsAdd(m, UI2_COMPOSIT_634, UI2_COMPOSIT_641)
			DBGPRINTF("lua_info:value of n_count = "..n_count)
			if -1 == n_count then
				DelSelectBag(m.Pack)
				return false
			end
			if nNum == 1 then
				m:IncMineItemDeal(1,  1,nSn,nNum)
				local ptrIcon = m:GetMineImgIcon(n_count)
				local imgPos = n_count + UI2_COMPOSIT_634
				UpdateIcon(m, 7)
				DelSelectBag(m.Pack)
			else
				m.SelectNumBox = NewNumSel(m, STR_COMBINE_NUMBER, 1, 1, nNum)
				m.SelectNumBox:WaitUserInput(m)
				local  Quantity = m.SelectNumBox:GetResult()
				DelNumSel(m.SelectNumBox)
				m:IncMineItemDeal(1,  Quantity,nSn,Quantity)
				local ptrIcon = m:GetMineImgIcon(n_count)
				local imgPos = n_count + UI2_COMPOSIT_634
				UpdateIcon(m, 7)
				DelSelectBag(m.Pack)
			end
		end
	end
end

-- 点击侧边"添加 魔法兽"按钮 add by liao
function IsClickAddPet(m)
	m.MsgBox = NewMsgBox(m,STR_PET_DEAL_NOTICE, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local ret = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	if  ret == 3 then
		return
	end

	m.Pet = NewSelectBag(m, 1, 1)
	m.Pet:WaitUserInput(m)
	local SelectItem = m.Pet:GetSelectItem()
	if SelectItem == 0 then
	DelSelectBag(m.Pet)
	else

		local n_count = IsAdd(m, UI2_COMPOSIT_634, UI2_COMPOSIT_641)
		if -1 == n_count then
			DelPetList(m.Pet)
			return false
		end

		if true == m:IncMinePetDeal(SelectItem,  result) then
			local ptrIcon = m:GetMineImgIcon(n_count)
			local imgPos = n_count + UI2_COMPOSIT_634
			UpdateIcon(m, 7)
		end
		DelSelectBag(m.Pet)

	end
end
NEW_FORM_NEWDEAL.C50659_OnClick = function( m )
ClickOthers(m, 7)
end
NEW_FORM_NEWDEAL.C50659_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(7)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_659, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
local formIndex,selfChange,otherChange,selfState,otherState,otherMoney,otherchangeIcon,selfchangeIcon=m:GetAllInfo()

UI_Engine.SetText(formIndex,UI2_COMPOSIT_661,otherMoney)
SetMyButtonText(m,selfState)
SetOtherButtonText(m,otherState)
end
NEW_FORM_NEWDEAL.C50658_OnClick = function( m )
ClickOthers(m, 6)
end
NEW_FORM_NEWDEAL.C50658_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(6)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_658, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
local formIndex,selfChange,otherChange,selfState,otherState,otherMoney,otherchangeIcon,selfchangeIcon=m:GetAllInfo()

UI_Engine.SetText(formIndex,UI2_COMPOSIT_661,otherMoney)
SetMyButtonText(m,selfState)
SetOtherButtonText(m,otherState)
end
NEW_FORM_NEWDEAL.C50657_OnClick = function( m )
ClickOthers(m, 5)
end
NEW_FORM_NEWDEAL.C50657_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(5)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_657, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
local formIndex,selfChange,otherChange,selfState,otherState,otherMoney,otherchangeIcon,selfchangeIcon=m:GetAllInfo()

UI_Engine.SetText(formIndex,UI2_COMPOSIT_661,otherMoney)
SetMyButtonText(m,selfState)
SetOtherButtonText(m,otherState)
end
NEW_FORM_NEWDEAL.C50656_OnClick = function( m )
ClickOthers(m, 4)
end
NEW_FORM_NEWDEAL.C50656_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(4)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_656, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
local formIndex,selfChange,otherChange,selfState,otherState,otherMoney,otherchangeIcon,selfchangeIcon=m:GetAllInfo()

UI_Engine.SetText(formIndex,UI2_COMPOSIT_661,otherMoney)
SetMyButtonText(m,selfState)
SetOtherButtonText(m,otherState)
end
NEW_FORM_NEWDEAL.C50655_OnClick = function( m )
ClickOthers(m, 3)
end
NEW_FORM_NEWDEAL.C50655_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(3)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_655, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
local formIndex,selfChange,otherChange,selfState,otherState,otherMoney,otherchangeIcon,selfchangeIcon=m:GetAllInfo()

UI_Engine.SetText(formIndex,UI2_COMPOSIT_661,otherMoney)
SetMyButtonText(m,selfState)
SetOtherButtonText(m,otherState)
end
NEW_FORM_NEWDEAL.C50654_OnClick = function( m )
ClickOthers(m, 2)
end
NEW_FORM_NEWDEAL.C50654_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(2)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_654, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
local formIndex,selfChange,otherChange,selfState,otherState,otherMoney,otherchangeIcon,selfchangeIcon=m:GetAllInfo()

UI_Engine.SetText(formIndex,UI2_COMPOSIT_661,otherMoney)
SetMyButtonText(m,selfState)
SetOtherButtonText(m,otherState)
end
NEW_FORM_NEWDEAL.C50653_OnClick = function( m )
ClickOthers(m, 1)
end
NEW_FORM_NEWDEAL.C50653_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(1)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_653, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
local formIndex,selfChange,otherChange,selfState,otherState,otherMoney,otherchangeIcon,selfchangeIcon=m:GetAllInfo()

UI_Engine.SetText(formIndex,UI2_COMPOSIT_661,otherMoney)
SetMyButtonText(m,selfState)
SetOtherButtonText(m,otherState)
end
NEW_FORM_NEWDEAL.C50652_OnClick = function( m )
ClickOthers(m, 0)
end
NEW_FORM_NEWDEAL.C50652_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetOtherImgIcon(0)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_652, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
local formIndex,selfChange,otherChange,selfState,otherState,otherMoney,otherchangeIcon,selfchangeIcon=m:GetAllInfo()

UI_Engine.SetText(formIndex,UI2_COMPOSIT_661,otherMoney)
SetMyButtonText(m,selfState)
SetOtherButtonText(m,otherState)
end
NEW_FORM_NEWDEAL.C50650_OnClick = function( m )
m:ChatSend(m.Text)
m.Text=""
UI_Engine.SetText(m.formIndex,UI2_COMPOSIT_667,m.Text,0)
end
NEW_FORM_NEWDEAL.C50667_OnClick = function( m )
local text=UI_Engine.GetText(m.formIndex,UI2_COMPOSIT_667)
m.InputBox = OpenInputBox(m,Text,100)
m.InputBox :WaitUserInput(m)
m.Text = m.InputBox :GetResult()
UI_Engine.SetText(m.formIndex,UI2_COMPOSIT_667,m.Text,0)
end
NEW_FORM_NEWDEAL.C50898_OnClick = function( m )
local state=m:Click(1)
SetMyButtonText(m,state)
end
NEW_FORM_NEWDEAL.C50897_OnClick = function( m )
local state=m:Click(0)
SetMyButtonText(m,state)
end
NEW_FORM_NEWDEAL.C50647_OnClick = function( m )
local state=m:Click(1)
SetMyButtonText(m,state)
end
NEW_FORM_NEWDEAL.C50646_OnLoad = function( m )
SetOtherButtonText(m,0)
SetMyButtonText(m,0)
end
NEW_FORM_NEWDEAL.C50646_OnClick = function( m )
local state=m:Click(0)
SetMyButtonText(m,state)
end
NEW_FORM_NEWDEAL.C50671_OnClick = function( m )
IsClickAddPet(m)
end
NEW_FORM_NEWDEAL.C50645_OnClick = function( m )
IsClickAddItem(m)
end
NEW_FORM_NEWDEAL.C50643_OnClick = function( m )
local formIndex,gold,Max =m:GetGold()
m.InputBox = OpenInputBox(m,gold,16)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if false == Tools.IsNumberOnly(result) then
	WarnUser(m, R_STRING_INPUT_NUMBER_ONLY)
	result = gold
	UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_643,result)
end
result=tonumber(result)
if result<0 or result>Max then --防止刷钱
	result=Max
end

m:SetGold(result)
UI_Engine.SetText(formIndex,UI2_COMPOSIT_643,result,0)

end
NEW_FORM_NEWDEAL.C50641_OnClick = function( m )
ClickSelf(m, 7)
end
NEW_FORM_NEWDEAL.C50641_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(7)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_641, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
NEW_FORM_NEWDEAL.C50640_OnClick = function( m )
ClickSelf(m, 6)
end
NEW_FORM_NEWDEAL.C50640_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(6)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_640, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
NEW_FORM_NEWDEAL.C50639_OnClick = function( m )
ClickSelf(m, 5)
end
NEW_FORM_NEWDEAL.C50639_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(5)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_639, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
NEW_FORM_NEWDEAL.C50638_OnClick = function( m )
ClickSelf(m, 4)
end
NEW_FORM_NEWDEAL.C50638_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(4)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_638, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
NEW_FORM_NEWDEAL.C50637_OnClick = function( m )
ClickSelf(m, 3) 
end
NEW_FORM_NEWDEAL.C50637_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(3)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_637, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
NEW_FORM_NEWDEAL.C50636_OnClick = function( m )
ClickSelf(m, 2) 
end
NEW_FORM_NEWDEAL.C50636_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(2)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_636, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
NEW_FORM_NEWDEAL.C50635_OnClick = function( m )
ClickSelf(m, 1) 
end
NEW_FORM_NEWDEAL.C50635_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(1)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_635, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
NEW_FORM_NEWDEAL.C50634_OnClick = function( m )
ClickSelf(m, 0) 
end
NEW_FORM_NEWDEAL.C50634_OnUpdate = function( m )
local ptrImg,nsn,num = m:GetMineImgIcon(0)
UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_634, ptrImg,0,0,false,nsn)
if num ~= nil then
	CurrentControl.SetItemCount(num)
else
	CurrentControl.SetItemCount(-1)

end
end
NEW_FORM_NEWDEAL.C50631_OnClick = function( m )
m:CancelDeal(0)
end
