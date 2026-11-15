FORM_FRIENDLIST= { }
FORM_FRIENDLIST.Main = function( m )
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
local DrawText = function(m, offset, ctlID)
local name = m:GetFriendList(offset)
UI_Engine.SetText(m.formIndex, ctlID, name)
end
FORM_FRIENDLIST.C51877_OnUpdate = function( m )
DrawText(m, m.offset+1, COMPOSIT_1877)
end
FORM_FRIENDLIST.C51878_OnUpdate = function( m )
DrawText(m, m.offset+2, COMPOSIT_1878)

end
FORM_FRIENDLIST.C51879_OnUpdate = function( m )
DrawText(m, m.offset+3, COMPOSIT_1879)
end
FORM_FRIENDLIST.C51880_OnUpdate = function( m )
DrawText(m, m.offset+4, COMPOSIT_1880)
end
FORM_FRIENDLIST.C51881_OnUpdate = function( m )
DrawText(m, m.offset+5, COMPOSIT_1881)
end
FORM_FRIENDLIST.C51882_OnUpdate = function( m )
DrawText(m, m.offset+6, COMPOSIT_1882)
end
FORM_FRIENDLIST.C51873_OnClick = function( m )
if m.userSelectItem ~= nil then
if m.userSelectItem < 0 then
	m:SetName(0)
else
	m:SetName(m.userSelectItem)
end
else
m:SetName(0)
end

m:InputFinished()
end
FORM_FRIENDLIST.C52787_OnClick = function( m )
m:InputFinished()
end
