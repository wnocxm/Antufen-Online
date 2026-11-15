NEW_FORM_SHOPINFO= { }
NEW_FORM_SHOPINFO.Main = function( m )
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
NEW_FORM_SHOPINFO.C50370_OnLoad = function( m )
m.Quantity = 0
end
NEW_FORM_SHOPINFO.C50370_OnClick = function( m )
m:Close()
end
local SelectQuantity = function( m )
	local num = m:GetSelNumber()
	if num == -1 then -- 空指针，直接返回
	m.Quantity = -1
	return 
	end
	local type = m:GetShopType()
	if 0 == type then
		if num == 1 then
			m.Quantity = 1
		else
			m.SelectNumBox = NewNumSel(m, STR_SELECTNUMBER_TYPE_SELL, num, 1, num)
			m.SelectNumBox:WaitUserInput(m)
			m.Quantity = m.SelectNumBox:GetResult()
			DelNumSel(m.SelectNumBox)
		end
	elseif type == -1 then
		return
	else
		m.SelectNumBox = NewNumSel(m, STR_SELECTNUMBER_TYPE_BUY, 1, 1, 30)
		m.SelectNumBox:WaitUserInput(m)
		m.Quantity = m.SelectNumBox:GetResult()
		DelNumSel(m.SelectNumBox)
	end
end
NEW_FORM_SHOPINFO.C50369_OnClick = function( m )
SelectQuantity( m )
m:OnBuy(m.Quantity)
m:Close()
end
