NEW_FORM_POPUPFORM= { }
NEW_FORM_POPUPFORM.Main = function( m )
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
NEW_FORM_POPUPFORM.C50051_OnClick = function( m )
m:OnClick(-1)
m:Close()
m:InputFinished()
end
local SetTabListText = function(m,nIndex,composit)
	local text , color= m:GetListText(m.offset + nIndex)
	if text== nil then
		UI_Engine.SetText(m.formIndex,composit,"")
	else
		UI_Engine.SetText(m.formIndex,composit,text , 0,color)
	end
end
NEW_FORM_POPUPFORM.C50050_OnLoad = function( m )
	UI_Engine.UpdateList(m.formIndex ,UI1_COMPOSIT_50)
end
NEW_FORM_POPUPFORM.C50050_OnClick = function( m )
m:OnClick(m.userSelectItem)
m:Close()
end
NEW_FORM_POPUPFORM.C50050_OnUpdate = function( m )
SetTabListText(m,0,UI1_COMPOSIT_50)
end
NEW_FORM_POPUPFORM.C50049_OnClick = function( m )
m:OnClick(m.userSelectItem)
m:Close()
m:InputFinished()
end
NEW_FORM_POPUPFORM.C50049_OnUpdate = function( m )
SetTabListText(m,1,UI1_COMPOSIT_49)
end
NEW_FORM_POPUPFORM.C50048_OnClick = function( m )
m:OnClick(m.userSelectItem)
m:Close()
m:InputFinished()
end
NEW_FORM_POPUPFORM.C50048_OnUpdate = function( m )
SetTabListText(m,2,UI1_COMPOSIT_48)
end
NEW_FORM_POPUPFORM.C50047_OnClick = function( m )
m:OnClick(m.userSelectItem)
m:Close()
m:InputFinished()
end
NEW_FORM_POPUPFORM.C50047_OnUpdate = function( m )
SetTabListText(m,3,UI1_COMPOSIT_47)
end
NEW_FORM_POPUPFORM.C50046_OnClick = function( m )
m:OnClick(m.userSelectItem)
m:Close()
m:InputFinished()
end
NEW_FORM_POPUPFORM.C50046_OnUpdate = function( m )
SetTabListText(m,4,UI1_COMPOSIT_46)
end
NEW_FORM_POPUPFORM.C50045_OnClick = function( m )
m:OnClick(m.userSelectItem)
m:Close()
m:InputFinished()
end
NEW_FORM_POPUPFORM.C50045_OnUpdate = function( m )
SetTabListText(m,5,UI1_COMPOSIT_45)
end
