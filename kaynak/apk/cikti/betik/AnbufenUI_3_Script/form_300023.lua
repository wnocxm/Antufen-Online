NEW_FORM_DEPOSIT_LIST= { }
NEW_FORM_DEPOSIT_LIST.Main = function( m )
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
NEW_FORM_DEPOSIT_LIST.C50379_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_DEPOSIT_LIST.C50379_OnClick = function( m )
m:InputFinished()
m:Close()

end
local SetTabListText = function(m,nIndex,composit)
	local date,money = m:GetListText(m.offset + nIndex)
	if date == nil then
		DBGPRINTF("SetTab2ListText  name = null")
		UI_Engine.SetText(m.formIndex,composit,"",0)
		UI_Engine.SetText(m.formIndex,composit,"",1)
		UI_Engine.SetText(m.formIndex,composit,"",2)
	else
		UI_Engine.SetText(m.formIndex,composit,m.offset + nIndex+1,0)
		UI_Engine.SetText(m.formIndex,composit,date,1)
		UI_Engine.SetText(m.formIndex,composit,money,2)
	end
end

NEW_FORM_DEPOSIT_LIST.C50372_OnLoad = function( m )
local name = m:GetDescribe(0)
if name == nil then
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,"" )
else
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,name )
end


end
NEW_FORM_DEPOSIT_LIST.C50372_OnClick = function( m )
local name = m:GetDescribe(m.userSelectItem)
if name == nil then
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,"" )
else
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,name )
end


end
NEW_FORM_DEPOSIT_LIST.C50372_OnUpdate = function( m )
SetTabListText(m,0,UI3_COMPOSIT_372)

end
NEW_FORM_DEPOSIT_LIST.C50373_OnClick = function( m )
local name = m:GetDescribe(m.userSelectItem)
if name == nil then
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,"" )
else
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,name )
end



end
NEW_FORM_DEPOSIT_LIST.C50373_OnUpdate = function( m )
SetTabListText(m,1,UI3_COMPOSIT_373)
end
NEW_FORM_DEPOSIT_LIST.C50374_OnClick = function( m )
local name = m:GetDescribe(m.userSelectItem)
if name == nil then
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,"" )
else
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,name )
end



end
NEW_FORM_DEPOSIT_LIST.C50374_OnUpdate = function( m )
SetTabListText(m,2,UI3_COMPOSIT_374)
end
NEW_FORM_DEPOSIT_LIST.C50375_OnClick = function( m )
local name = m:GetDescribe(m.userSelectItem)
if name == nil then
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,"" )
else
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,name )
end



end
NEW_FORM_DEPOSIT_LIST.C50375_OnUpdate = function( m )
SetTabListText(m,3,UI3_COMPOSIT_375)
end
NEW_FORM_DEPOSIT_LIST.C50376_OnClick = function( m )
local name = m:GetDescribe(m.userSelectItem)
if name == nil then
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,"" )
else
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,name )
end



end
NEW_FORM_DEPOSIT_LIST.C50376_OnUpdate = function( m )
SetTabListText(m,4,UI3_COMPOSIT_376)
end
NEW_FORM_DEPOSIT_LIST.C50377_OnClick = function( m )
local name = m:GetDescribe(m.userSelectItem)
if name == nil then
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,"" )
else
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,name )
end



end
NEW_FORM_DEPOSIT_LIST.C50377_OnUpdate = function( m )
SetTabListText(m,5,UI3_COMPOSIT_377)
end
NEW_FORM_DEPOSIT_LIST.C50378_OnClick = function( m )
local name = m:GetDescribe(m.userSelectItem)
if name == nil then
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,"" )
else
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_367,name )
end



end
NEW_FORM_DEPOSIT_LIST.C50378_OnUpdate = function( m )
SetTabListText(m,6,UI3_COMPOSIT_378)
end
