NEW_FORM_CFSSHOP= { }
NEW_FORM_CFSSHOP.Main = function( m )
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
NEW_FORM_CFSSHOP.C50555_OnLoad = function( m )
m.tab = 0
end
local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_OK)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local UpdateText = function(m, id, offset)
	local img, name,level, price, sn, enable, color, bcanuse = m:GetDrawInfo(m.offset + offset)
	UI_Engine.SetSurfaceImg(m.formIndex, id, img, 0, 0, bcanuse, sn)
	UI_Engine.SetText(m.formIndex, id, name, 1)
	UI_Engine.SetText(m.formIndex, id, level, 2)
	UI_Engine.SetText(m.formIndex, id, price, 3)
	UI_Engine.SetText(m.formIndex, id, enable, 4)
	
end

local ClickList = function(m, offset)
	local img, str, info, sn = m:OnClickList(offset)
	if img == nil then
		return
	end
	m.info = NewItemInfo(m, img, str, info, sn)
	m.info:WaitUserInput(m)
	local ret = m.info:GetResult()
	DelItemInfo(m.info)
	if 2 == ret then
		if m.tab == 0 then
			m:OnClickBuy()
		else
			if MsgBox.ECODE_YES == QueryUser(m, STR_SURE_TAKE_BACK) then
				m:TackBack()
			end
		end
	end
end

local SellMine = function(m)
	local ptr = m:GetFilter()
	m.Pack = NewSelectBag(m, ptr)
	if nil == m.Pack then
		WarnUser(m, STR_NO_CFS_TYPE_ITEM)
		return false
	end
	m.Pack:WaitUserInput(m)
	local SelectItem = m.Pack:GetSelectItem()

	if SelectItem == nil then
		DelSelectBag(m.Pack)
		return false
	end
	
	m.SelectNumBox = NewNumSel(m, STR_INPUT_MONEY_PRMOPT, 1, 1, 9999999)
	m.SelectNumBox:WaitUserInput(m)
	local  Quantity = m.SelectNumBox:GetResult()
	DelNumSel(m.SelectNumBox)
	
	if 0 > Quantity then
		DelSelectBag(m.Pack)
		return false
	else
		local str, b = m:GetString(SelectItem, Quantity)
		if false == b then
			WarnUser(m, str)
			DelSelectBag(m.Pack)
			return false
		elseif MsgBox.ECODE_YES == QueryUser(m, str) then
			m:OnClickSell(SelectItem, Quantity)
			DelSelectBag(m.Pack)
			return true
		else
			DelSelectBag(m.Pack)
		end
	end	
end
NEW_FORM_CFSSHOP.C50554_OnClick = function( m )
m:OnSearch()
m.tab = 0
end
NEW_FORM_CFSSHOP.C50552_OnClick = function( m )
m:OnClickMenu(6)
end
NEW_FORM_CFSSHOP.C50551_OnClick = function( m )
m:OnClickMenu(4)
end
NEW_FORM_CFSSHOP.C50550_OnClick = function( m )
m:OnClickMenu(3)
end
NEW_FORM_CFSSHOP.C50549_OnClick = function( m )
m:OnClickMenu(2)
end
NEW_FORM_CFSSHOP.C50548_OnClick = function( m )
m:OnClickMenu(1)
end
NEW_FORM_CFSSHOP.C50547_OnClick = function( m )
m:OnClickMenu(0)
end
NEW_FORM_CFSSHOP.C50539_OnClick = function( m )
SellMine(m)
end
NEW_FORM_CFSSHOP.C50768_OnClick = function( m )
m:OnClickNextPage()
end
NEW_FORM_CFSSHOP.C50767_OnClick = function( m )
m:OnClickPrePage()
end
NEW_FORM_CFSSHOP.C50537_OnClick = function( m )
DelCFSShop(m)
end
NEW_FORM_CFSSHOP.C50530_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CFSSHOP.C50530_OnUpdate = function( m )
UpdateText(m, UI3_COMPOSIT_530, 0)
end
NEW_FORM_CFSSHOP.C50531_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CFSSHOP.C50531_OnUpdate = function( m )
UpdateText(m, UI3_COMPOSIT_531, 1)
end
NEW_FORM_CFSSHOP.C50532_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CFSSHOP.C50532_OnUpdate = function( m )
UpdateText(m, UI3_COMPOSIT_532, 2)
end
NEW_FORM_CFSSHOP.C50533_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CFSSHOP.C50533_OnUpdate = function( m )
UpdateText(m, UI3_COMPOSIT_533, 3)
end
NEW_FORM_CFSSHOP.C50534_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CFSSHOP.C50534_OnUpdate = function( m )
UpdateText(m, UI3_COMPOSIT_534, 4)
end
NEW_FORM_CFSSHOP.C50535_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CFSSHOP.C50535_OnUpdate = function( m )
UpdateText(m, UI3_COMPOSIT_535, 5)
end
NEW_FORM_CFSSHOP.C50536_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CFSSHOP.C50536_OnUpdate = function( m )
UpdateText(m, UI3_COMPOSIT_536, 6)
end
NEW_FORM_CFSSHOP.C50526_OnClick = function( m )
m.tab = 0
m:GetShowType(0)
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_531)
end
NEW_FORM_CFSSHOP.C50527_OnClick = function( m )
m.tab = 1
m:GetShowType(1)
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_531)
end
NEW_FORM_CFSSHOP.C50528_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 1)
m:GetShowType(2)
end
NEW_FORM_CFSSHOP.C50524_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
