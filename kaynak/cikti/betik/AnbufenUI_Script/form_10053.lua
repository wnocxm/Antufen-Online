FORM_CONSIGNMENT= { }
FORM_CONSIGNMENT.Main = function( m )
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
FORM_CONSIGNMENT.C51380_OnLoad = function( m )
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1385, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1388, false)
end
local WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_CANCEL)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local SetControlMode = function(m, mode)
	if true == mode then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1447, true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1386, true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1456, false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1309, false)
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1447, false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1386, false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1456, true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1309, true)
	end
end
-- 更新列表控件
-- 参数：m：类本身。 type：装备或道具。offset：列表控件偏移。 ctlID：控件ID
local UpdateList = function(m, type, offset, ctlID)
	local img, name, level, strong, price = m:GetDrawInfo(type, offset)
	
	UI_Engine.SetSurfaceImg(m.formIndex, ctlID, img, 0)
	UI_Engine.SetText(m.formIndex, ctlID, name, 1)
	UI_Engine.SetText(m.formIndex, ctlID, level, 2)
	UI_Engine.SetText(m.formIndex, ctlID, strone, 3)
	UI_Engine.SetText(m.formIndex, ctlID, price, 4)
end

local SellMine = function(m)
	local ptr = m:GetFilter()
	m.Pack = NewPackage(m, ptr)
	if nil == m.Pack then
		WarnUser(m, "没有合适的寄售物品！")
		return false
	end
	m.Pack:WaitUserInput(m)
	local SelectItem = m.Pack:GetSelectItem()

	if SelectItem == nil then
		DelPackage(m.Pack)
		return false
	end
	
	m.SelectNumBox = NewNumSel(m, "Select Number", 1, 1, 9999999)
	m.SelectNumBox:WaitUserInput(m)
	local  Quantity = m.SelectNumBox:GetResult()
	DelNumSel(m.SelectNumBox)
	
	if 0 > Quantity then
		WarnUser(m, "请输入正确的金额!")
		return false
	else
		m:OnClickSell(SelectItem, Quantity)
		DelPackage(m.Pack)
		return true
	end	
end
FORM_CONSIGNMENT.C51388_OnClick = function( m )
m:OnClickNextPage()
end
FORM_CONSIGNMENT.C51381_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1447, true)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1386, true)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1387, true)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1456, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1409, false)
m:GetShowType(0)
UI_Engine.UpdateList(COMPOSIT_1434)
end
FORM_CONSIGNMENT.C51382_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1447, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1386, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1387, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1456, true)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1409, true)
m:GetShowType(1)
UI_Engine.UpdateList(COMPOSIT_1434)
end
FORM_CONSIGNMENT.C51386_OnClick = function( m )
local ptr = m:GetPointer()
m.search = NewCFSSearch(m, ptr)
m.search:WaitUserInput(m)
DelCFSSearch(m.search)
end
FORM_CONSIGNMENT.C51387_OnClick = function( m )
m:GetCurSel(m.userSelectItem)
m:OnClickBuy()
end
FORM_CONSIGNMENT.C51384_OnClick = function( m )
SellMine(m)
end
FORM_CONSIGNMENT.C51385_OnClick = function( m )
m:OnClickPrePage()
end
FORM_CONSIGNMENT.C51409_OnClick = function( m )
m:GetCurSel(m.userSelectItem)
m:TackBack()
end
FORM_CONSIGNMENT.C52704_OnLoad = function( m )
SetControlMode(m, true)
end
FORM_CONSIGNMENT.C52704_OnClick = function( m )
DelCFSShop(m)
end
FORM_CONSIGNMENT.C51434_OnClick = function( m )
--UI_Engine.UpdateList(m.formIndex, COMPOSIT_1434)
end
FORM_CONSIGNMENT.C51435_OnClick = function( m )
--UI_Engine.UpdateList(m.formIndex, COMPOSIT_1435)
end
FORM_CONSIGNMENT.C51436_OnClick = function( m )
--UI_Engine.UpdateList(m.formIndex, COMPOSIT_1436)
end
FORM_CONSIGNMENT.C51437_OnClick = function( m )
--UI_Engine.UpdateList(m.formIndex, COMPOSIT_1437)
end
FORM_CONSIGNMENT.C51438_OnClick = function( m )
--UI_Engine.UpdateList(m.formIndex, COMPOSIT_1438)
end
FORM_CONSIGNMENT.C51439_OnClick = function( m )
--UI_Engine.UpdateList(m.formIndex, COMPOSIT_1439)
end
FORM_CONSIGNMENT.C51440_OnClick = function( m )
--UI_Engine.UpdateList(m.formIndex, COMPOSIT_1440)
end
FORM_CONSIGNMENT.C52746_OnClick = function( m )
--UI_Engine.UpdateList(m.formIndex, COMPOSIT_2746)
end
FORM_CONSIGNMENT.C51456_OnClick = function( m )
m:GetCurSel(m.userSelectItem)
--local ptr = m:GetPointer()
--m.info = NewInfoForm(m, ptr)
--m.info:WaitUserInput(m)
--DelInfoForm(m.info)

local name, ptr =m:Detail(m.index)
if name ~=nil then
m.info = NewInfo(m, name, ptr)
m.info:WaitUserInput(m)
DelInfo(m.info)
end
end
FORM_CONSIGNMENT.C51447_OnClick = function( m )
m:GetCurSel(m.userSelectItem)
--local ptr = m:GetPointer()
--m.info = NewInfoForm(m, ptr)
--m.info:WaitUserInput(m)
--DelInfoForm(m.info)

local name, ptr =m:Detail(m.index)
if name ~=nil then
m.info = NewInfo(m, name, ptr)
m.info:WaitUserInput(m)
DelInfo(m.info)
end
end
FORM_CONSIGNMENT.C51457_OnClick = function( m )
UI_Engine.UpdateList(m.formIndex, COMPOSIT_1457)
end
FORM_CONSIGNMENT.C51458_OnClick = function( m )
UI_Engine.UpdateList(m.formIndex, COMPOSIT_1458)
end
FORM_CONSIGNMENT.C51459_OnClick = function( m )
UI_Engine.UpdateList(m.formIndex, COMPOSIT_1459)
end
FORM_CONSIGNMENT.C51460_OnClick = function( m )
UI_Engine.UpdateList(m.formIndex, COMPOSIT_1460)
end
FORM_CONSIGNMENT.C51461_OnClick = function( m )
UI_Engine.UpdateList(m.formIndex, COMPOSIT_1461)
end
FORM_CONSIGNMENT.C51462_OnClick = function( m )
UI_Engine.UpdateList(m.formIndex, COMPOSIT_1462)
end
FORM_CONSIGNMENT.C51464_OnClick = function( m )
UI_Engine.UpdateList(m.formIndex, COMPOSIT_1464)
end
FORM_CONSIGNMENT.C52747_OnClick = function( m )
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2747)
end
FORM_CONSIGNMENT.C51379_OnLoad = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1447, true)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1386, true)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1387, true)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1456, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1409, false)
end
