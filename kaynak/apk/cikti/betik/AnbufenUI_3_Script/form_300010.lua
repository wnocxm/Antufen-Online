NEW_FORM_FRIENDLIST= { }
NEW_FORM_FRIENDLIST.Main = function( m )
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
NEW_FORM_FRIENDLIST.C50069_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_FRIENDLIST.C50069_OnClick = function( m )
m:SetName(-1)
m:InputFinished()
m:Close()
end
local DrawText = function(m, offset, ctlID)
local name = m:GetFriendList(offset)
UI_Engine.SetText(m.formIndex, ctlID, name)
end
NEW_FORM_FRIENDLIST.C50071_OnClick = function( m )
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
m:Close()
end
NEW_FORM_FRIENDLIST.C50071_OnUpdate = function( m )
DrawText(m, m.offset, UI3_COMPOSIT_71)
end
NEW_FORM_FRIENDLIST.C50072_OnClick = function( m )
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
m:Close()
end
NEW_FORM_FRIENDLIST.C50072_OnUpdate = function( m )
DrawText(m, m.offset+1, UI3_COMPOSIT_72)
end
NEW_FORM_FRIENDLIST.C50073_OnClick = function( m )
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
m:Close()
end
NEW_FORM_FRIENDLIST.C50073_OnUpdate = function( m )
DrawText(m, m.offset+2, UI3_COMPOSIT_73)
end
NEW_FORM_FRIENDLIST.C50074_OnClick = function( m )
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
m:Close()
end
NEW_FORM_FRIENDLIST.C50074_OnUpdate = function( m )
DrawText(m, m.offset+3, UI3_COMPOSIT_74)
end
NEW_FORM_FRIENDLIST.C50075_OnClick = function( m )
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
m:Close()
end
NEW_FORM_FRIENDLIST.C50075_OnUpdate = function( m )
DrawText(m, m.offset+4, UI3_COMPOSIT_75)
end
NEW_FORM_FRIENDLIST.C50076_OnClick = function( m )
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
m:Close()
end
NEW_FORM_FRIENDLIST.C50076_OnUpdate = function( m )
DrawText(m, m.offset+5, UI3_COMPOSIT_76)
end
