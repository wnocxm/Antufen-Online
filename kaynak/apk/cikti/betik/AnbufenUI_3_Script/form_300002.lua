NEW_FORM_SHORTCUT= { }
NEW_FORM_SHORTCUT.Main = function( m )
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
local ClickGrid = function(m, index)
	m:OnItemPenEvent(index)
end
NEW_FORM_SHORTCUT.C50033_OnClick = function( m )
m:OnCloseChat()
end
NEW_FORM_SHORTCUT.C50031_OnClick = function( m )
m:OnCloseMap()
end
NEW_FORM_SHORTCUT.C50026_OnDraw = function( m )
m:Update()
end
NEW_FORM_SHORTCUT.C50023_OnClick = function( m )
m:OnMapMenu()

end
NEW_FORM_SHORTCUT.C50022_OnClick = function( m )
m:OnChatMenu()
end
NEW_FORM_SHORTCUT.C50032_OnClick = function( m )
m:ChatClick()
end
NEW_FORM_SHORTCUT.C50825_OnClick = function( m )
m:OnFocClick()
end
NEW_FORM_SHORTCUT.C50021_OnClick = function( m )
m:DoFus()
end
NEW_FORM_SHORTCUT.C50020_OnClick = function( m )
m:DoFus()
end
NEW_FORM_SHORTCUT.C50824_OnClick = function( m )
NewAround(m)

end
NEW_FORM_SHORTCUT.C50019_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,4,UI3_COMPOSIT_19)
end
NEW_FORM_SHORTCUT.C50018_OnClick = function( m )
ClickGrid(m,3)
end
NEW_FORM_SHORTCUT.C50018_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,3,UI3_COMPOSIT_18)
end
NEW_FORM_SHORTCUT.C50017_OnClick = function( m )
ClickGrid(m,2)
end
NEW_FORM_SHORTCUT.C50017_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,2,UI3_COMPOSIT_17)
end
NEW_FORM_SHORTCUT.C50016_OnClick = function( m )
ClickGrid(m,1)
end
NEW_FORM_SHORTCUT.C50016_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,1,UI3_COMPOSIT_16)
end
NEW_FORM_SHORTCUT.C50015_OnClick = function( m )
ClickGrid(m,0)
end
NEW_FORM_SHORTCUT.C50015_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,0,UI3_COMPOSIT_15)
end
NEW_FORM_SHORTCUT.C50014_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,-1,UI3_COMPOSIT_14)
end
NEW_FORM_SHORTCUT.C50030_OnClick = function( m )
--m:OnSelClick()
m:OnClickGameMenu()
end
NEW_FORM_SHORTCUT.C50029_OnClick = function( m )
--m:OnFocClick()
end
NEW_FORM_SHORTCUT.C50863_OnClick = function( m )
m:TabClick(0)
UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_15)
end
NEW_FORM_SHORTCUT.C50864_OnClick = function( m )
m:TabClick(1)
UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_15)
end
NEW_FORM_SHORTCUT.C50865_OnClick = function( m )
m:TabClick(2)
UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_15)
end
NEW_FORM_SHORTCUT.C50866_OnClick = function( m )
m:TabClick(3)
UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_15)
end
