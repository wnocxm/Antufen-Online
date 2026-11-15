NEW_FORM_SETSHORTCUT= { }
NEW_FORM_SETSHORTCUT.Main = function( m )
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
local SetGridImg = function(m, nIndex, composit)
	local img = m:GetIcon(nIndex)
	UI_Engine.SetSurfaceImg(m.formIndex, composit, img)
end

local UpdateImg = function(m)
	for i = 0, 5 do
		SetGridImg(m, 0, UI2_COMPOSIT_215)	
	end
end
NEW_FORM_SETSHORTCUT.C50857_OnClick = function( m )
m:OnClickOK()
m:InputFinished()
end
NEW_FORM_SETSHORTCUT.C50848_OnClick = function( m )
m:OnClickGrid(3)
end
NEW_FORM_SETSHORTCUT.C50847_OnClick = function( m )
m:OnClickGrid(2)
end
NEW_FORM_SETSHORTCUT.C50846_OnClick = function( m )
m:OnClickGrid(1)
end
NEW_FORM_SETSHORTCUT.C50845_OnClick = function( m )
m:OnClickGrid(0)
end
NEW_FORM_SETSHORTCUT.C50840_OnClick = function( m )
m:OnClickGrid(3)
end
NEW_FORM_SETSHORTCUT.C50840_OnDraw = function( m )
m:DrawIcon(3, UI2_COMPOSIT_840)
end
NEW_FORM_SETSHORTCUT.C50839_OnClick = function( m )
m:OnClickGrid(2)
end
NEW_FORM_SETSHORTCUT.C50839_OnDraw = function( m )
m:DrawIcon(2, UI2_COMPOSIT_839)
end
NEW_FORM_SETSHORTCUT.C50838_OnClick = function( m )
m:OnClickGrid(1)
end
NEW_FORM_SETSHORTCUT.C50838_OnDraw = function( m )
m:DrawIcon(1, UI2_COMPOSIT_838)
end
NEW_FORM_SETSHORTCUT.C50837_OnClick = function( m )
m:OnClickGrid(0)
end
NEW_FORM_SETSHORTCUT.C50837_OnDraw = function( m )
m:DrawIcon(0, UI2_COMPOSIT_837)
end
NEW_FORM_SETSHORTCUT.C50836_OnDraw = function( m )
m:DrawIcon(-1, UI2_COMPOSIT_836)
end
NEW_FORM_SETSHORTCUT.C50833_OnDraw = function( m )
m:Update()
end
