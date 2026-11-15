FORM_STORE= { }
FORM_STORE.Main = function( m )
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
FORM_STORE.C52701_OnClick = function( m )
m:Cancel()
end
local SelectQuantity = function( m )
	local num = m:GetSelNumber()
	local type = m:GetShopType()
	if 0 == type then
		if num == 1 then
			m.Quantity = 1
		else
			m.SelectNumBox = NewNumSel(m, "Select Number", num, 1, num)
			m.SelectNumBox:WaitUserInput(m)
			m.Quantity = m.SelectNumBox:GetResult()
			DelNumSel(m.SelectNumBox)
		end
	else
		m.SelectNumBox = NewNumSel(m, "Select Number", 1, 1, 10)
		m.SelectNumBox:WaitUserInput(m)
		m.Quantity = m.SelectNumBox:GetResult()
		DelNumSel(m.SelectNumBox)
	end
end

local ResetTabs = function( m )
	--[[UI_Engine.SetState(m.formIndex, COMPOSIT_STORE_TAB0, 0)
	UI_Engine.SetState(m.formIndex, COMPOSIT_STORE_TAB1, 0)
	UI_Engine.SetState(m.formIndex, COMPOSIT_STORE_TAB2, 0)
	UI_Engine.SetState(m.formIndex, COMPOSIT_STORE_TAB3, 0)--]]
end
FORM_STORE.C50752_OnClick = function( m )
SelectQuantity( m )
m:Sell( m.Quantity )

end
FORM_STORE.C50753_OnClick = function( m )

local name, ptr =m:Detail()
m.info = NewInfo(m, name, ptr)
end
FORM_STORE.C50755_OnClick = function( m )

m:RepairAll()
end
FORM_STORE.C50515_OnClick = function( m )
ResetTabs( m )
local  formIndex=m:OnClickTab(0)

UI_Engine.SetFormTab(formIndex,0)
UI_Engine.UpdateList(formIndex,  COMPOSIT_STORE_TAB0_LIST1)
end
FORM_STORE.C50516_OnClick = function( m )
ResetTabs( m )
local  formIndex=m:OnClickTab(1)

UI_Engine.SetFormTab(formIndex,1)
UI_Engine.UpdateList(formIndex,  COMPOSIT_STORE_TAB1_LIST1)
end
FORM_STORE.C50517_OnClick = function( m )
ResetTabs( m )
local  formIndex=m:OnClickTab(2)

UI_Engine.SetFormTab(formIndex,2)
UI_Engine.UpdateList(formIndex,  COMPOSIT_STORE_TAB2_LIST2)
end
FORM_STORE.C50518_OnClick = function( m )
ResetTabs( m )
local  formIndex=m:OnClickTab(3)

UI_Engine.SetFormTab(formIndex,3)
UI_Engine.UpdateList(formIndex,  COMPOSIT_STORE_TAB3_LIST1)
end
FORM_STORE.C50756_OnClick = function( m )
m:Repair()
end
FORM_STORE.C50509_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50509_OnUpdate = function( m )
m:UpdateList(m.offset,COMPOSIT_STORE_TAB0_LIST0,0)
end
FORM_STORE.C50510_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50510_OnUpdate = function( m )
m:UpdateList(m.offset+1,COMPOSIT_STORE_TAB0_LIST1,0)
end
FORM_STORE.C50511_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50511_OnUpdate = function( m )
m:UpdateList(m.offset+2,COMPOSIT_STORE_TAB0_LIST2,0)
end
FORM_STORE.C50512_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50512_OnUpdate = function( m )
m:UpdateList(m.offset+3,COMPOSIT_STORE_TAB0_LIST3,0)
end
FORM_STORE.C50513_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50513_OnDraw = function( m )


end
FORM_STORE.C50513_OnUpdate = function( m )
m:UpdateList(m.offset+4,COMPOSIT_STORE_TAB0_LIST4,0)
end
FORM_STORE.C50514_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50514_OnDraw = function( m )


end
FORM_STORE.C50514_OnUpdate = function( m )
m:UpdateList(m.offset+5,COMPOSIT_STORE_TAB0_LIST5,0)
end
FORM_STORE.C50743_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50743_OnUpdate = function( m )
m:UpdateList(m.offset+6,COMPOSIT_STORE_TAB0_LIST6,0)
end
FORM_STORE.C50744_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50744_OnUpdate = function( m )
m:UpdateList(m.offset+7,COMPOSIT_STORE_TAB0_LIST7,0)
end
FORM_STORE.C50751_OnClick = function( m )
SelectQuantity( m )
m:Buy(m.Quantity)
end
FORM_STORE.C50520_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50520_OnUpdate = function( m )
m:UpdateList(m.offset,COMPOSIT_STORE_TAB1_LIST0,1)
end
FORM_STORE.C50521_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50521_OnDraw = function( m )


end
FORM_STORE.C50521_OnUpdate = function( m )
m:UpdateList(m.offset+1,COMPOSIT_STORE_TAB1_LIST1,1)
end
FORM_STORE.C50522_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50522_OnDraw = function( m )



end
FORM_STORE.C50522_OnUpdate = function( m )
m:UpdateList(m.offset+2,COMPOSIT_STORE_TAB1_LIST2,1)
end
FORM_STORE.C50523_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50523_OnDraw = function( m )



end
FORM_STORE.C50523_OnUpdate = function( m )
m:UpdateList(m.offset+3,COMPOSIT_STORE_TAB1_LIST3,1)
end
FORM_STORE.C50524_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50524_OnDraw = function( m )



end
FORM_STORE.C50524_OnUpdate = function( m )
m:UpdateList(m.offset+4,COMPOSIT_STORE_TAB1_LIST4,1)
end
FORM_STORE.C50525_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50525_OnDraw = function( m )



end
FORM_STORE.C50525_OnUpdate = function( m )
m:UpdateList(m.offset+5,COMPOSIT_STORE_TAB1_LIST5,1)
end
FORM_STORE.C50745_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50745_OnUpdate = function( m )
m:UpdateList(m.offset+6,COMPOSIT_STORE_TAB1_LIST6,1)
end
FORM_STORE.C50746_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50746_OnUpdate = function( m )
m:UpdateList(m.offset+7,COMPOSIT_STORE_TAB1_LIST7,1)
end
FORM_STORE.C50527_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50527_OnDraw = function( m )



end
FORM_STORE.C50527_OnUpdate = function( m )
m:UpdateList(m.offset,COMPOSIT_STORE_TAB2_LIST0,2)
end
FORM_STORE.C50528_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50528_OnDraw = function( m )



end
FORM_STORE.C50528_OnUpdate = function( m )
m:UpdateList(m.offset+1,COMPOSIT_STORE_TAB2_LIST1,2)
end
FORM_STORE.C50529_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50529_OnUpdate = function( m )
m:UpdateList(m.offset+2,COMPOSIT_STORE_TAB2_LIST2,2)
end
FORM_STORE.C50530_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50530_OnDraw = function( m )




end
FORM_STORE.C50530_OnUpdate = function( m )
m:UpdateList(m.offset+3,COMPOSIT_STORE_TAB2_LIST3,2)
end
FORM_STORE.C50531_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50531_OnDraw = function( m )




end
FORM_STORE.C50531_OnUpdate = function( m )
m:UpdateList(m.offset+4,COMPOSIT_STORE_TAB2_LIST4,2)
end
FORM_STORE.C50532_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50532_OnDraw = function( m )




end
FORM_STORE.C50532_OnUpdate = function( m )
m:UpdateList(m.offset+5,COMPOSIT_STORE_TAB2_LIST5,2)
end
FORM_STORE.C50747_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50747_OnUpdate = function( m )
m:UpdateList(m.offset+6,COMPOSIT_STORE_TAB2_LIST6,2)
end
FORM_STORE.C50748_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50748_OnUpdate = function( m )
m:UpdateList(m.offset+7,COMPOSIT_STORE_TAB2_LIST7,2)
end
FORM_STORE.C50534_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50534_OnDraw = function( m )




end
FORM_STORE.C50534_OnUpdate = function( m )
m:UpdateList(m.offset,COMPOSIT_STORE_TAB3_LIST0,3)
end
FORM_STORE.C50535_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50535_OnDraw = function( m )





end
FORM_STORE.C50535_OnUpdate = function( m )
m:UpdateList(m.offset+1,COMPOSIT_STORE_TAB3_LIST1,3)
end
FORM_STORE.C50536_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50536_OnUpdate = function( m )
m:UpdateList(m.offset+2,COMPOSIT_STORE_TAB3_LIST2,3)
end
FORM_STORE.C50537_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50537_OnDraw = function( m )





end
FORM_STORE.C50537_OnUpdate = function( m )
m:UpdateList(m.offset+3,COMPOSIT_STORE_TAB3_LIST3,3)
end
FORM_STORE.C50538_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50538_OnDraw = function( m )





end
FORM_STORE.C50538_OnUpdate = function( m )
m:UpdateList(m.offset+4,COMPOSIT_STORE_TAB3_LIST4,3)
end
FORM_STORE.C50539_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50539_OnDraw = function( m )





end
FORM_STORE.C50539_OnUpdate = function( m )
m:UpdateList(m.offset+5,COMPOSIT_STORE_TAB3_LIST5,3)
end
FORM_STORE.C50749_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50749_OnUpdate = function( m )
m:UpdateList(m.offset+6,COMPOSIT_STORE_TAB3_LIST6,3)
end
FORM_STORE.C50750_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
FORM_STORE.C50750_OnUpdate = function( m )
m:UpdateList(m.offset+7,COMPOSIT_STORE_TAB3_LIST7,3)
end
