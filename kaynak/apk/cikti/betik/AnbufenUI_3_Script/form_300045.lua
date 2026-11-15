NEW_FORM_DEPOSIT_IPHONE= { }
NEW_FORM_DEPOSIT_IPHONE.Main = function( m )
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
NEW_FORM_DEPOSIT_IPHONE.C50855_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex,3)
end
NEW_FORM_DEPOSIT_IPHONE.C50855_OnClick = function( m )
DelDepositIOS(m)
end
function ShowMsg(m,result)
UI_Engine.SetText(m.formIndex ,UI3_COMPOSIT_DEPOSIT_IPHONE_SHUOMING,result,0)
end

local DrawList = function(m, id, offset)
	local img, name, price = m:OnUpdateList(offset)
	if img ~= nil then
		UI_Engine.SetSurfaceImg( m.formIndex, id, img )
		UI_Engine.SetText( m.formIndex, id, name, 1)
		UI_Engine.SetText( m.formIndex, id, price, 2 )
	end
end

local Click = function(m, index)
	local img,str,info,sn = m:GetItemInfo(index)
	if img ~= nil then
		m.info = NewItemInfo(m, img, str, info, sn)
		m.info:WaitUserInput(m)
		local ret = m.info:GetResult()
		DelItemInfo(m.info)
		if ret == 2 then
			m:OnClick(index)
		end
	end
end
NEW_FORM_DEPOSIT_IPHONE.C50848_OnClick = function( m )
Click(m, m.userSelectItem)
end
NEW_FORM_DEPOSIT_IPHONE.C50848_OnUpdate = function( m )
DrawList(m,UI3_COMPOSIT_DEPOSIT_IPHONE_1,m.offset)
end
NEW_FORM_DEPOSIT_IPHONE.C50849_OnClick = function( m )
Click(m, m.userSelectItem)

end
NEW_FORM_DEPOSIT_IPHONE.C50849_OnUpdate = function( m )
DrawList(m,UI3_COMPOSIT_DEPOSIT_IPHONE_2,m.offset+1 )
end
NEW_FORM_DEPOSIT_IPHONE.C50850_OnClick = function( m )
Click(m, m.userSelectItem)


end
NEW_FORM_DEPOSIT_IPHONE.C50850_OnUpdate = function( m )
DrawList(m,UI3_COMPOSIT_DEPOSIT_IPHONE_3,m.offset+2 )
end
NEW_FORM_DEPOSIT_IPHONE.C50851_OnClick = function( m )
Click(m, m.userSelectItem)


end
NEW_FORM_DEPOSIT_IPHONE.C50851_OnUpdate = function( m )
DrawList(m,UI3_COMPOSIT_DEPOSIT_IPHONE_4,m.offset+3 )
end
NEW_FORM_DEPOSIT_IPHONE.C50852_OnClick = function( m )
Click(m, m.userSelectItem)




end
NEW_FORM_DEPOSIT_IPHONE.C50852_OnUpdate = function( m )
DrawList( m, UI3_COMPOSIT_DEPOSIT_IPHONE_5, m.offset+4 )
end
NEW_FORM_DEPOSIT_IPHONE.C50853_OnClick = function( m )
Click(m, m.userSelectItem)





end
NEW_FORM_DEPOSIT_IPHONE.C50853_OnUpdate = function( m )
DrawList( m, UI3_COMPOSIT_DEPOSIT_IPHONE_6, m.offset+5 )
end
NEW_FORM_DEPOSIT_IPHONE.C50854_OnClick = function( m )
Click(m, m.userSelectItem)






end
NEW_FORM_DEPOSIT_IPHONE.C50854_OnUpdate = function( m )
DrawList( m, UI3_COMPOSIT_DEPOSIT_IPHONE_7, m.offset+6 )
end
