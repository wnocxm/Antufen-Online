FORM_HELP= { }
FORM_HELP.Main = function( m )
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
FORM_HELP.C52929_OnClick = function( m )
DelHelp(m)
end
FORM_HELP.C52928_OnClick = function( m )
m:OnClickList(m.offset)

end
FORM_HELP.C52928_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,COMPOSIT_2928,num,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2928,name,1)

end
end
FORM_HELP.C52927_OnClick = function( m )
m:OnClickList(m.offset +1)

end
FORM_HELP.C52927_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset + 1)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,COMPOSIT_2927,num,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2927,name,1)

end
end
FORM_HELP.C52926_OnClick = function( m )
m:OnClickList(m.offset +2)
end
FORM_HELP.C52926_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset + 2)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,COMPOSIT_2926,num,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2926,name,1)

end
end
FORM_HELP.C52925_OnClick = function( m )
m:OnClickList(m.offset +3)
end
FORM_HELP.C52925_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset + 3)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,COMPOSIT_2925,num,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2925,name,1)

end
end
FORM_HELP.C52924_OnClick = function( m )
m:OnClickList(m.offset +4)
end
FORM_HELP.C52924_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset + 4)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,COMPOSIT_2924,num,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2924,name,1)

end
end
FORM_HELP.C52923_OnClick = function( m )
m:OnClickList(m.offset +5)
end
FORM_HELP.C52923_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset + 5)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,COMPOSIT_2923,num,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2923,name,1)

end
end
FORM_HELP.C52922_OnClick = function( m )
m:OnClickList(m.offset +6)
end
FORM_HELP.C52922_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset + 6)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,COMPOSIT_2922,num,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2922,name,1)

end
end
FORM_HELP.C52921_OnClick = function( m )
m:OnClickList(m.offset +7)
end
FORM_HELP.C52921_OnUpdate = function( m )
local num ,name = m:GetDrawInfo(m.offset + 7)
if nil == num then

else
	UI_Engine.SetText(m.formIndex,COMPOSIT_2921,num,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2921,name,1)

end
end
FORM_HELP.C52920_OnClick = function( m )
local name, ptr =m:Detail()
if name ~= nil then
	m.info = NewInfo(m, name, ptr)
end
end
