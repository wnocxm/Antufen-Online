FORM_SHORTCUT= { }
FORM_SHORTCUT.Main = function( m )
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
FORM_SHORTCUT.C52356_OnClick = function( m )
m:OnSelClick()
end
local ClickGrid = function(m, index)
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
m:OnItemPenEvent(index)
end
FORM_SHORTCUT.C52758_OnClick = function( m )
m:ChatClick()
end
FORM_SHORTCUT.C52759_OnClick = function( m )
m:OnClickGameMenu()
end
FORM_SHORTCUT.C52357_OnClick = function( m )
m:OnFocClick()
end
FORM_SHORTCUT.C52644_OnClick = function( m )
ClickGrid(m,5)
end
FORM_SHORTCUT.C52644_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,5,COMPOSIT_2644)
end
FORM_SHORTCUT.C52643_OnClick = function( m )
ClickGrid(m,4)
end
FORM_SHORTCUT.C52643_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,4,COMPOSIT_2643)
end
FORM_SHORTCUT.C52642_OnClick = function( m )
ClickGrid(m,3)
end
FORM_SHORTCUT.C52642_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,3,COMPOSIT_2642)
end
FORM_SHORTCUT.C52641_OnClick = function( m )
ClickGrid(m,2)
end
FORM_SHORTCUT.C52641_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,2,COMPOSIT_2641)
end
FORM_SHORTCUT.C52640_OnClick = function( m )
ClickGrid(m,1)
end
FORM_SHORTCUT.C52640_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,1,COMPOSIT_2640)
end
FORM_SHORTCUT.C52639_OnClick = function( m )
ClickGrid(m,0)
end
FORM_SHORTCUT.C52639_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,0,COMPOSIT_2639)
end
FORM_SHORTCUT.C50656_OnLoad = function( m )
m.id = COMPOSIT_SHORTCUT_TAB1
end
FORM_SHORTCUT.C50656_OnClick = function( m )
m:TabClick(0)
m.id = COMPOSIT_SHORTCUT_TAB1
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2642)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB1,1)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB2,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB3,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB4,0)
end
FORM_SHORTCUT.C50660_OnClick = function( m )
m:TabClick(1)
m.id = COMPOSIT_SHORTCUT_TAB2
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2642)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB1,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB2,1)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB3,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB4,0)
end
FORM_SHORTCUT.C50659_OnClick = function( m )
m:TabClick(2)
m.id = COMPOSIT_SHORTCUT_TAB3
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2642)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB1,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB2,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB3,1)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB4,0)
end
FORM_SHORTCUT.C50657_OnClick = function( m )
m:TabClick(3)
m.id = COMPOSIT_SHORTCUT_TAB4
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2642)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB1,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB2,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB3,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB4,1)
end
FORM_SHORTCUT.C52745_OnClick = function( m )
m:DoFus()
end
FORM_SHORTCUT.C52746_OnClick = function( m )
m:DoFus()
end
