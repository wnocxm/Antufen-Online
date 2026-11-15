NEW_FORM_ROLETITLE= { }
NEW_FORM_ROLETITLE.Main = function( m )
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
NEW_FORM_ROLETITLE.C50044_OnClick = function( m )
DelTitle(m)
end
local SetTabListText = function(m,nIndex,composit)

	local name,img = m:GetDrawInfo(m.offset + nIndex)
	UI_Engine.SetText(m.formIndex,composit,name,1)
	if m:IsCurTitle(m.offset + nIndex) == true then
		UI_Engine.SetSurfaceImg(m.formIndex, composit, img,0)
	else
		UI_Engine.SetText(m.formIndex,composit,"",0)
	end
end
local OnClick = function(m)
local Decribe,Decribe_1 = m:GetDiscribe(m.userSelectItem)
m.info = NewItemInfo(m,Decribe_1,Decribe)
m.info:WaitUserInput(m)
local ret = m.info:GetResult()
DelItemInfo(m.info)
if ret == 2 then
	m:OnSelect(m.userSelectItem)
	UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_45)
end
end
NEW_FORM_ROLETITLE.C50045_OnClick = function( m )
OnClick(m)

end
NEW_FORM_ROLETITLE.C50045_OnUpdate = function( m )
SetTabListText(m,0,UI3_COMPOSIT_45)
end
NEW_FORM_ROLETITLE.C50046_OnClick = function( m )
OnClick(m)
end
NEW_FORM_ROLETITLE.C50046_OnUpdate = function( m )
SetTabListText(m,1,UI3_COMPOSIT_46)
end
NEW_FORM_ROLETITLE.C50047_OnClick = function( m )
OnClick(m)
end
NEW_FORM_ROLETITLE.C50047_OnUpdate = function( m )
SetTabListText(m,2,UI3_COMPOSIT_47)
end
NEW_FORM_ROLETITLE.C50048_OnClick = function( m )
OnClick(m)
end
NEW_FORM_ROLETITLE.C50048_OnUpdate = function( m )
SetTabListText(m,3,UI3_COMPOSIT_48)
end
NEW_FORM_ROLETITLE.C50049_OnClick = function( m )
OnClick(m)
end
NEW_FORM_ROLETITLE.C50049_OnUpdate = function( m )
SetTabListText(m,4,UI3_COMPOSIT_49)
end
NEW_FORM_ROLETITLE.C50050_OnClick = function( m )
OnClick(m)
end
NEW_FORM_ROLETITLE.C50050_OnUpdate = function( m )
SetTabListText(m,5,UI3_COMPOSIT_50)
end
NEW_FORM_ROLETITLE.C50822_OnClick = function( m )
OnClick(m)
end
NEW_FORM_ROLETITLE.C50822_OnUpdate = function( m )
SetTabListText(m,6,UI3_COMPOSIT_822)
end
