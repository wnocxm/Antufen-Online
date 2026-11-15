FORM_DEPOSIT_LIST= { }
FORM_DEPOSIT_LIST.Main = function( m )
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
local SetTabListText = function(m,nIndex,composit)
	local date,money = m:GetListText(m.offset + nIndex)
	if date == nil then
		DBGPRINTF("SetTab2ListText  name = null")
		UI_Engine.SetText(m.formIndex,composit,"",0)
		UI_Engine.SetText(m.formIndex,composit,"",1)
		UI_Engine.SetText(m.formIndex,composit,"",2)
	else
		UI_Engine.SetText(m.formIndex,composit,m.offset + nIndex,0)
		UI_Engine.SetText(m.formIndex,composit,date,1)
		UI_Engine.SetText(m.formIndex,composit,money,2)
	end
end
FORM_DEPOSIT_LIST.C51706_OnClick = function( m )
m:InputFinished()
m:Close()
end
FORM_DEPOSIT_LIST.C52758_OnClick = function( m )
m:InputFinished()
m:Close()
end
FORM_DEPOSIT_LIST.C51737_OnLoad = function( m )
local name = m:GetDescribe(0)
if name == nil then
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,"" )
else
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,name )
end

end
FORM_DEPOSIT_LIST.C51737_OnClick = function( m )
local name = m:GetDescribe(m.userSelectItem)
if name == nil then
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,"" )
else
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,name )
end

end
FORM_DEPOSIT_LIST.C51737_OnUpdate = function( m )
SetTabListText(m,0,COMPOSIT_1737)
end
FORM_DEPOSIT_LIST.C51736_OnClick = function( m )
local name = m:GetDescribe(m.userSelectItem)
if name == nil then
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,"" )
else
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,name )
end

end
FORM_DEPOSIT_LIST.C51736_OnUpdate = function( m )
SetTabListText(m,1,COMPOSIT_1736)
end
FORM_DEPOSIT_LIST.C51735_OnClick = function( m )
local name = m:GetDescribe(m.userSelectItem)
if name == nil then
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,"" )
else
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,name )
end

end
FORM_DEPOSIT_LIST.C51735_OnUpdate = function( m )
SetTabListText(m,2,COMPOSIT_1735)
end
FORM_DEPOSIT_LIST.C51734_OnClick = function( m )
local name = m:GetDescribe(m.userSelectItem)
if name == nil then
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,"" )
else
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,name )
end

end
FORM_DEPOSIT_LIST.C51734_OnUpdate = function( m )
SetTabListText(m,3,COMPOSIT_1734)
end
FORM_DEPOSIT_LIST.C51733_OnClick = function( m )
local name = m:GetDescribe(m.userSelectItem)
if name == nil then
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,"" )
else
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,name )
end

end
FORM_DEPOSIT_LIST.C51733_OnUpdate = function( m )
SetTabListText(m,4,COMPOSIT_1733)
end
FORM_DEPOSIT_LIST.C51732_OnClick = function( m )
local name = m:GetDescribe(m.userSelectItem)
if name == nil then
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,"" )
else
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,name )
end

end
FORM_DEPOSIT_LIST.C51732_OnUpdate = function( m )
SetTabListText(m,5,COMPOSIT_1732)
end
FORM_DEPOSIT_LIST.C51731_OnClick = function( m )
local name = m:GetDescribe(m.userSelectItem)
if name == nil then
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,"" )
else
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,name )
end

end
FORM_DEPOSIT_LIST.C51731_OnUpdate = function( m )
SetTabListText(m,6,COMPOSIT_1731)
end
FORM_DEPOSIT_LIST.C52757_OnClick = function( m )
local name = m:GetDescribe(m.userSelectItem)
if name == nil then
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,"" )
else
UI_Engine.SetText(m.formIndex,COMPOSIT_1707,name )
end

end
FORM_DEPOSIT_LIST.C52757_OnUpdate = function( m )
SetTabListText(m,6,COMPOSIT_2757)
end
