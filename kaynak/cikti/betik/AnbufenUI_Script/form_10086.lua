FORM_SHORTCUT_V5= { }
FORM_SHORTCUT_V5.Main = function( m )
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
FORM_SHORTCUT_V5.C52355_OnLoad = function( m )
m.id = COMPOSIT_2168
end
FORM_SHORTCUT_V5.C52355_OnClick = function( m )
 m:OnSelClick()
end
local ClickGrid = function(m, index)
	m:OnItemPenEvent(index)
	--[[UI_Engine.SetState(m.formIndex,m.id, 1)
	local town = m:IsCurScene()
	if false == town then
		m:UseInTown(index)
	else
		local ret = m:UseOutTown(index)
		if nil ~= ret then
			CurrentControl.SetCoolDown(ret)
			UI_Engine.UpdateList(m.formIndex, COMPOSIT_2495)
		end
	end
	--]]
end
		
FORM_SHORTCUT_V5.C52354_OnClick = function( m )
m:OnFocClick()
end
FORM_SHORTCUT_V5.C52498_OnClick = function( m )
--m:OnItemPenEvent(5)
ClickGrid(m,5)
end
FORM_SHORTCUT_V5.C52498_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,5,COMPOSIT_2498)
end
FORM_SHORTCUT_V5.C52497_OnClick = function( m )
--m:OnItemPenEvent(4)
ClickGrid(m,4)
end
FORM_SHORTCUT_V5.C52497_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,4,COMPOSIT_2497)
end
FORM_SHORTCUT_V5.C52496_OnClick = function( m )
--m:OnItemPenEvent(3)
ClickGrid(m,3)
end
FORM_SHORTCUT_V5.C52496_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,3,COMPOSIT_2496)
end
FORM_SHORTCUT_V5.C52495_OnClick = function( m )
--m:OnItemPenEvent(2)
ClickGrid(m,2)
end
FORM_SHORTCUT_V5.C52495_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,2,COMPOSIT_2495)
end
FORM_SHORTCUT_V5.C52495_OnUpdate = function( m )
CurrentControl.SetItemCount(0)
local x,y=m:GetSurface()
m:DrawShortCut(x,y,2,COMPOSIT_2495)
local ret = m:GetNum(2)
local state = m:GetState(2)
local town = m:IsCurScene()
if false == town then
	CurrentControl.SetItemCount(-1)
	CurrentControl.SetActive(true)
else
	if ret > 1 then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
	if true == state then
		CurrentControl.SetActive(false)
	else
		CurrentControl.SetActive(true)
	end
end
end
FORM_SHORTCUT_V5.C52494_OnClick = function( m )
--m:OnItemPenEvent(1)
ClickGrid(m,1)
end
FORM_SHORTCUT_V5.C52494_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,1,COMPOSIT_2494)
end
FORM_SHORTCUT_V5.C52493_OnClick = function( m )
ClickGrid(m,0)
--m:OnItemPenEvent(0)
end
FORM_SHORTCUT_V5.C52493_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,0,COMPOSIT_2493)
end
FORM_SHORTCUT_V5.C52175_OnClick = function( m )
m:OnClickGameMenu()
end
FORM_SHORTCUT_V5.C52174_OnClick = function( m )
m:ChatClick()
end
FORM_SHORTCUT_V5.C52173_OnClick = function( m )
m:TabClick(3)
m.id = COMPOSIT_2173
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2495)
UI_Engine.SetState(m.formIndex,COMPOSIT_2168,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_2171,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_2172,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_2173,1)

end
FORM_SHORTCUT_V5.C52172_OnClick = function( m )
m:TabClick(2)
m.id = COMPOSIT_2172
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2495)
UI_Engine.SetState(m.formIndex,COMPOSIT_2168,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_2171,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_2172,1)
UI_Engine.SetState(m.formIndex,COMPOSIT_2173,0)

end
FORM_SHORTCUT_V5.C52171_OnClick = function( m )
m:TabClick(1)
m.id = COMPOSIT_2171
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2495)
UI_Engine.SetState(m.formIndex,COMPOSIT_2168,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_2171,1)
UI_Engine.SetState(m.formIndex,COMPOSIT_2172,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_2173,0)

end
FORM_SHORTCUT_V5.C52168_OnLoad = function( m )
UI_Engine.SetState(m.formIndex,COMPOSIT_2168,1)
UI_Engine.SetState(m.formIndex,COMPOSIT_2171,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_2172,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_2173,0)
end
FORM_SHORTCUT_V5.C52168_OnClick = function( m )
m:TabClick(0)
m.id = COMPOSIT_2168
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2495)
UI_Engine.SetState(m.formIndex,COMPOSIT_2168,1)
UI_Engine.SetState(m.formIndex,COMPOSIT_2171,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_2172,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_2173,0)
end
