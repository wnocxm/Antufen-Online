FORM_ROLETITLE= { }
FORM_ROLETITLE.Main = function( m )
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
FORM_ROLETITLE.C52637_OnLoad = function( m )
	local Decribe = m:GetDiscribe(0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2626,Decribe)
end
local UpDataDecribe = function(m)
	local Decribe = m:GetDiscribe(m.userSelectItem)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2626,Decribe)
end


local SetTabListText = function(m,nIndex,composit)

	local name = m:GetDrawInfo(m.offset + nIndex)
	UI_Engine.SetText(m.formIndex,composit,name,1)
	if m:IsCurTitle(m.offset + nIndex) == true then
		UI_Engine.SetText( m.formIndex, composit, "*" , 0)
	else
		UI_Engine.SetText( m.formIndex, composit, "" , 0)
	end
end

local UpDate = function(m)
	UI_Engine.UpdateList(m.formIndex ,COMPOSIT_2636)
	
	UpDataDecribe(m)
end
FORM_ROLETITLE.C52058_OnClick = function( m )
m:OnSelect(m.userSelectItem)
DelTitle(m)
end
FORM_ROLETITLE.C52754_OnClick = function( m )
DelTitle(m)
end
FORM_ROLETITLE.C52627_OnClick = function( m )
DelTitle(m)
end
FORM_ROLETITLE.C52636_OnClick = function( m )
UpDataDecribe(m)
end
FORM_ROLETITLE.C52636_OnUpdate = function( m )
SetTabListText(m,0,COMPOSIT_2636)
end
FORM_ROLETITLE.C52635_OnClick = function( m )
UpDataDecribe(m)
end
FORM_ROLETITLE.C52635_OnUpdate = function( m )
SetTabListText(m,1,COMPOSIT_2635)
end
FORM_ROLETITLE.C52634_OnClick = function( m )
UpDataDecribe(m)
end
FORM_ROLETITLE.C52634_OnUpdate = function( m )
SetTabListText(m,2,COMPOSIT_2634)
end
FORM_ROLETITLE.C52633_OnClick = function( m )
UpDataDecribe(m)
end
FORM_ROLETITLE.C52633_OnUpdate = function( m )
SetTabListText(m,3,COMPOSIT_2633)
end
FORM_ROLETITLE.C52632_OnClick = function( m )
UpDataDecribe(m)
end
FORM_ROLETITLE.C52632_OnUpdate = function( m )
SetTabListText(m,4,COMPOSIT_2632)
end
FORM_ROLETITLE.C52631_OnClick = function( m )
UpDataDecribe(m)
end
FORM_ROLETITLE.C52631_OnUpdate = function( m )
SetTabListText(m,5,COMPOSIT_2631)
end
FORM_ROLETITLE.C52630_OnClick = function( m )
UpDataDecribe(m)
end
FORM_ROLETITLE.C52630_OnUpdate = function( m )
SetTabListText(m,6,COMPOSIT_2630)
end
FORM_ROLETITLE.C52629_OnClick = function( m )
UpDataDecribe(m)
end
FORM_ROLETITLE.C52629_OnUpdate = function( m )
SetTabListText(m,7,COMPOSIT_2629)
end
