NEW_FORM_HELP= { }
NEW_FORM_HELP.Main = function( m )
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
NEW_FORM_HELP.C50397_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_HELP.C50397_OnClick = function( m )
DelHelp(m)

end
NEW_FORM_HELP.C50390_OnClick = function( m )
m:OnClickList(m.offset)
local name, ptr =m:Detail()
if name ~= nil then
	m.info = NewInfo(m, name, ptr)
end



end
NEW_FORM_HELP.C50390_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_390,num,0)
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_390,name,1)

end

end
NEW_FORM_HELP.C50391_OnClick = function( m )
m:OnClickList(m.offset+1)
local name, ptr =m:Detail()
if name ~= nil then
	m.info = NewInfo(m, name, ptr)
end



end
NEW_FORM_HELP.C50391_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset+1)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_391,num,0)
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_391,name,1)

end


end
NEW_FORM_HELP.C50392_OnClick = function( m )
m:OnClickList(m.offset+2)
local name, ptr =m:Detail()
if name ~= nil then
	m.info = NewInfo(m, name, ptr)
end



end
NEW_FORM_HELP.C50392_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset+2)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_392,num,0)
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_392,name,1)

end


end
NEW_FORM_HELP.C50393_OnClick = function( m )
m:OnClickList(m.offset+3)
local name, ptr =m:Detail()
if name ~= nil then
	m.info = NewInfo(m, name, ptr)
end



end
NEW_FORM_HELP.C50393_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset+3)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_393,num,0)
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_393,name,1)

end


end
NEW_FORM_HELP.C50394_OnClick = function( m )
m:OnClickList(m.offset+4)
local name, ptr =m:Detail()
if name ~= nil then
	m.info = NewInfo(m, name, ptr)
end

end
NEW_FORM_HELP.C50394_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset+4)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_394,num,0)
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_394,name,1)

end


end
NEW_FORM_HELP.C50396_OnClick = function( m )
m:OnClickList(m.offset+5)
local name, ptr =m:Detail()
if name ~= nil then
	m.info = NewInfo(m, name, ptr)
end


end
NEW_FORM_HELP.C50396_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset+5)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_396,num,0)
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_396,name,1)

end


end
NEW_FORM_HELP.C50395_OnClick = function( m )
m:OnClickList(m.offset+6)
local name, ptr =m:Detail()
if name ~= nil then
	m.info = NewInfo(m, name, ptr)
end


end
NEW_FORM_HELP.C50395_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset+6)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_395,num,0)
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_395,name,1)

end


end
NEW_FORM_HELP.C50399_OnClick = function( m )
m:OnClickList(m.offset+7)
local name, ptr =m:Detail()
if name ~= nil then
	m.info = NewInfo(m, name, ptr)
end



end
NEW_FORM_HELP.C50399_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset+7)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_399,num,0)
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_399,name,1)

end



end
