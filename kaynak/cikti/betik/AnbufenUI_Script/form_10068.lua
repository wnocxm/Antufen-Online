FORM_STORE_PAG= { }
FORM_STORE_PAG.Main = function( m )
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
FORM_STORE_PAG.C51836_OnLoad = function( m )
m.bShow  = false
		m:SetTab(StoreTab.TAB_ALL)
		m:SetSel(0)
		m:SetPage(-1)
		m:SetGridNum(25)
end
FORM_STORE_PAG.C51836_OnDraw = function( m )
--if m.bShow  == false then
--	if m:IsShow() then
--		m:SetTab(StoreTab.TAB_ALL)
--		m:SetSel(0)
--		m:SetPage(-1)
--		m:SetGridNum(25)
--		UpDate(m)
--
--		m.bShow  = true
--	end
--end
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

local UpDateDescribe = function(m , nIndex)
	local strDescribe = m:GetDescribe(nIndex)
	if strDescribe == nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_1820,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_1820,strDescribe)
	end
end

local UpDateMoney = function(m)
	local strMoney = m:GetMoney()
	if strMoney == nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_1870,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_1870,strMoney)
	end
end

local UpDateCapacity = function(m )
	local strCapacity = m:GetCapacity()
	if strCapacity == nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_1869,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_1869,strCapacity )
	end
end

local SetTabListText = function(m,nIndex,composit)
	local img ,nSN= m:GetItem(nIndex)
	if img == nil then
		UI_Engine.SetClientEmpty( m.formIndex, composit )
	else
		UI_Engine.SetSurfaceImg( m.formIndex, composit, img, 0, 0, false,  nSN )
	end

end

local UpDate = function(m)
	UI_Engine.UpdateList(m.formIndex ,COMPOSIT_1863)
	UpDateDescribe(m,0)
	UpDateMoney(m)
	UpDateCapacity(m)

end



FORM_STORE_PAG.C51869_OnLoad = function( m )
--是否有密码
if m:IsNeedPwd() then
	m.InputBox = NewInputBox(m,"请输入密码：" , 1,"",12)
	m.InputBox:WaitUserInput(m)
	local pwd = m.InputBox:GetInput()
	local exit = m.InputBox:ExitType()
	DelInputBox(m.InputBox)
	
	if exit == 0 then
		m:Close(m.formIndex)
		m:InputFinished()
		return 
	end
	
	m:SendQueryStoreMsg(0,pwd)
	m:SetStrInput(pwd)
	m:WaitUserInput(m)
	
	local query = m:GetQuery(pwd)
	
	if query == 1 then
		--成功进入仓库
	UpDate(m)
	else
		--密码错误
		WarnUser(m,"密码有误")
		m:Close(m.formIndex)
		m:InputFinished()

		return 
	end


else
	m:SendQueryStoreMsg(-1, "")
	--m:SetStrInput(pwd)
	m:WaitUserInput(m)
	
	local query = m:GetQuery(pwd)
	
	if query == 1 then
		--成功进入仓库
	UpDate(m)
	else
		--密码错误
		WarnUser(m,"密码有误")
		m:Close(m.formIndex)
		m:InputFinished()

		return 
	end


end
end
FORM_STORE_PAG.C51869_OnDraw = function( m )
--
end
FORM_STORE_PAG.C51828_OnLoad = function( m )


end
FORM_STORE_PAG.C51828_OnClick = function( m )
m:SetTab(StoreTab.TAB_ALL)
m:SetSel(0)
m.userSelectItem = 0
m:SetPage(-1)
UpDate(m)

end
FORM_STORE_PAG.C51827_OnClick = function( m )
m:SetTab(StoreTab.TAB_EQUIP)
m:SetSel(0)
m.userSelectItem = 0
m:SetPage(-1)
UpDate(m)

end
FORM_STORE_PAG.C51826_OnClick = function( m )
m:SetTab(StoreTab.TAB_CONSUME)
m:SetSel(0)
m.userSelectItem = 0
m:SetPage(-1)
UpDate(m)
end
FORM_STORE_PAG.C51825_OnClick = function( m )
m:SetTab(StoreTab.TAB_NORMAL)
m:SetSel(0)
m.userSelectItem = 0
m:SetPage(-1)
UpDate(m)

end
FORM_STORE_PAG.C51834_OnClick = function( m )
local nNum = m:GetItemNum(m.userSelectItem)
if nNum == 0 then
	return 
end

if nNum == nil then
return 
end

if nNum > 1 then
m.numSel = NewNumSel(m, "select num" , 1, 1  , nNum )
m.numSel :WaitUserInput(m)
local num = m.numSel:GetResult(m)
DelNumSel(m.numSel)
m:SendTakeItemMsg(m.userSelectItem,num)
else
m:SendTakeItemMsg(m.userSelectItem, nNum)
end

UpDate(m)
end
FORM_STORE_PAG.C51833_OnClick = function( m )
local nMoney = m:GetMoneyNum()
--m.numSel = NewNumSel(m, "select num" , nMoney , 0 , 0 )
--m.numSel :WaitUserInput(m)
--local num = m.numSel:GetResult(m)
--DelNumSel(m.numSel)
--m:SendTakeMoneyMsg(num)
--UpDate(m)


	m.InputBox = NewInputBox(m,"请输入金额：" , 1,"0",10)
	m.InputBox:WaitUserInput(m)
	local num = m.InputBox:GetInput()
	local exit = m.InputBox:ExitType()
	DelInputBox(m.InputBox)
	
	if exit == 0 then
		return 
	end
	--if num > nMoney then
	--	return 
	--end

	m:SendTakeMoneyMsg(num)
	UpDate(m)
end
FORM_STORE_PAG.C51832_OnClick = function( m )
local name , vInfo = m:GetMakeInfo(m.userSelectItem)
if name == nil then
return 
end

if vInfo == nil then
return 
end

m.info = NewInfo(m,name,vInfo )
m.info:WaitUserInput(m)
DelInfo(m.info)

end
FORM_STORE_PAG.C51831_OnClick = function( m )



local nNum = m:GetItemNum(m.userSelectItem)
if nNum == nil then
return 
end

if nNum == 0 then
return 
end

if QueryUser(m,"物品是否销毁 ?")  == false then
	return 
end

if nNum > 1 then
m.numSel = NewNumSel(m, "select num" , 1, 1 , nNum )
m.numSel :WaitUserInput(m)
local num = m.numSel:GetResult(m)
DelNumSel(m.numSel)
m:SendDestroyItemMsg(m.userSelectItem,num)
else
m:SendDestroyItemMsg(m.userSelectItem,nNum)
end

UpDate(m)
end
FORM_STORE_PAG.C51830_OnClick = function( m )
m:OpenPackageStoreMode()

m:Close(m.formIndex)

end
FORM_STORE_PAG.C52758_OnClick = function( m )
m:Close(m.formIndex)
m:InputFinished()

end
FORM_STORE_PAG.C51863_OnFocus = function( m )
m.userSelectItem = 0
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51863_OnUpdate = function( m )
SetTabListText(m,0,COMPOSIT_1863)

local num = m:GetItemNum(0)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51862_OnFocus = function( m )
m.userSelectItem = 1
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51862_OnClick = function( m )
--UpDateDescribe(m,1)
end
FORM_STORE_PAG.C51862_OnUpdate = function( m )
	SetTabListText(m,1,COMPOSIT_1862)
local num = m:GetItemNum(1)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51861_OnFocus = function( m )
m.userSelectItem = 2
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51861_OnClick = function( m )
--UpDateDescribe(m,2)
end
FORM_STORE_PAG.C51861_OnUpdate = function( m )

	SetTabListText(m,2,COMPOSIT_1861)

local num = m:GetItemNum(2)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51860_OnFocus = function( m )
m.userSelectItem = 3
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51860_OnUpdate = function( m )

	SetTabListText(m,3,COMPOSIT_1860)

local num = m:GetItemNum(3)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51859_OnFocus = function( m )
m.userSelectItem = 4
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51859_OnUpdate = function( m )

	SetTabListText(m,4,COMPOSIT_1859)

local num = m:GetItemNum(4)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51858_OnFocus = function( m )
m.userSelectItem = 5
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51858_OnUpdate = function( m )

	SetTabListText(m,5,COMPOSIT_1858)

local num = m:GetItemNum(5)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51857_OnFocus = function( m )
m.userSelectItem = 6
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51857_OnUpdate = function( m )

	SetTabListText(m,6,COMPOSIT_1857)

local num = m:GetItemNum(6)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51856_OnFocus = function( m )
m.userSelectItem = 7
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51856_OnUpdate = function( m )

	SetTabListText(m,7,COMPOSIT_1856)

local num = m:GetItemNum(7)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51855_OnFocus = function( m )
m.userSelectItem = 8
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51855_OnUpdate = function( m )

	SetTabListText(m,8,COMPOSIT_1855)

local num = m:GetItemNum(8)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51854_OnFocus = function( m )
m.userSelectItem = 9
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51854_OnUpdate = function( m )

	SetTabListText(m,9,COMPOSIT_1854)

local num = m:GetItemNum(9)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51853_OnFocus = function( m )
m.userSelectItem = 10
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51853_OnUpdate = function( m )

	SetTabListText(m,10,COMPOSIT_1853)

local num = m:GetItemNum(10)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51852_OnFocus = function( m )
m.userSelectItem = 11
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51852_OnUpdate = function( m )

	SetTabListText(m,11,COMPOSIT_1852)

local num = m:GetItemNum(11)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51851_OnFocus = function( m )
m.userSelectItem = 12
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51851_OnUpdate = function( m )

	SetTabListText(m,12,COMPOSIT_1851)

local num = m:GetItemNum(12)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51850_OnFocus = function( m )
m.userSelectItem = 13
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51850_OnUpdate = function( m )

	SetTabListText(m,13,COMPOSIT_1850)

local num = m:GetItemNum(13)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51849_OnFocus = function( m )
m.userSelectItem = 14
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51849_OnUpdate = function( m )

	SetTabListText(m,14,COMPOSIT_1849)

local num = m:GetItemNum(14)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51848_OnFocus = function( m )
m.userSelectItem = 15
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51848_OnUpdate = function( m )

	SetTabListText(m,15,COMPOSIT_1848)

local num = m:GetItemNum(15)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51847_OnFocus = function( m )
m.userSelectItem = 16
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51847_OnUpdate = function( m )

	SetTabListText(m,16,COMPOSIT_1847)

local num = m:GetItemNum(16)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51846_OnFocus = function( m )
m.userSelectItem = 17
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51846_OnUpdate = function( m )

	SetTabListText(m,17,COMPOSIT_1846)

local num = m:GetItemNum(17)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51845_OnFocus = function( m )
m.userSelectItem = 18
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51845_OnUpdate = function( m )

	SetTabListText(m,18,COMPOSIT_1845)

local num = m:GetItemNum(18)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51844_OnFocus = function( m )
m.userSelectItem = 19
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51844_OnUpdate = function( m )

	SetTabListText(m,19,COMPOSIT_1844)

local num = m:GetItemNum(19)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51841_OnFocus = function( m )
m.userSelectItem = 20
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51841_OnUpdate = function( m )

	SetTabListText(m,20,COMPOSIT_1841)

local num = m:GetItemNum(20)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51840_OnFocus = function( m )
m.userSelectItem = 21
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51840_OnUpdate = function( m )

	SetTabListText(m,21,COMPOSIT_1840)

local num = m:GetItemNum(21)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51839_OnFocus = function( m )
m.userSelectItem = 22
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51839_OnUpdate = function( m )

	SetTabListText(m,22,COMPOSIT_1839)

local num = m:GetItemNum(22)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51838_OnFocus = function( m )
m.userSelectItem = 23
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51838_OnUpdate = function( m )

	SetTabListText(m,23,COMPOSIT_1838)

local num = m:GetItemNum(23)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C51837_OnFocus = function( m )
m.userSelectItem = 24
UpDateDescribe(m,m.userSelectItem)
end
FORM_STORE_PAG.C51837_OnUpdate = function( m )

	SetTabListText(m,24,COMPOSIT_1837)
local num = m:GetItemNum(24)

if num > 1 then
	CurrentControl.SetItemCount(num )
else
	CurrentControl.SetItemCount(-1 )
end
end
FORM_STORE_PAG.C52119_OnClick = function( m )
m:OnExpand()
end
FORM_STORE_PAG.C51843_OnClick = function( m )
 m:SetPage(1)

UpDate(m)
end
FORM_STORE_PAG.C51842_OnClick = function( m )
 m:SetPage(0)

UpDate(m)
end
