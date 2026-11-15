FORM_SETSHORTCUT= { }
FORM_SETSHORTCUT.Main = function( m )
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
FORM_SETSHORTCUT.C53005_OnClick = function( m )
m:InputFinished()
end
local SetGridImg = function(m, nIndex, composit)
	local img = m:GetIcon(nIndex)
	UI_Engine.SetSurfaceImg(m.formIndex, composit, img)
end

local UpdateImg = function(m)
	SetGridImg(m, 0, COMPOSIT_2994)
	SetGridImg(m, 1, COMPOSIT_2995)
	SetGridImg(m, 2, COMPOSIT_2996)
	SetGridImg(m, 3, COMPOSIT_2997)
	SetGridImg(m, 4, COMPOSIT_2998)
	SetGridImg(m, 5, COMPOSIT_2999)
end
FORM_SETSHORTCUT.C53004_OnClick = function( m )
m:OnClickOK()
m:InputFinished()
end
FORM_SETSHORTCUT.C53003_OnClick = function( m )
m:OnSelGroup(4)
UpdateImg(m)
end
FORM_SETSHORTCUT.C53002_OnClick = function( m )
m:OnSelGroup(3)
UpdateImg(m)
end
FORM_SETSHORTCUT.C53001_OnClick = function( m )
m:OnSelGroup(2)
UpdateImg(m)
end
FORM_SETSHORTCUT.C53000_OnClick = function( m )
m:OnSelGroup(1)
UpdateImg(m)
end
FORM_SETSHORTCUT.C52999_OnClick = function( m )
m:OnClickGrid(5)
end
FORM_SETSHORTCUT.C52998_OnClick = function( m )
m:OnClickGrid(4)
end
FORM_SETSHORTCUT.C52997_OnClick = function( m )
m:OnClickGrid(3)
end
FORM_SETSHORTCUT.C52996_OnClick = function( m )
m:OnClickGrid(2)
end
FORM_SETSHORTCUT.C52995_OnClick = function( m )
m:OnClickGrid(1)
end
FORM_SETSHORTCUT.C52994_OnClick = function( m )
m:OnClickGrid(0)
end
FORM_SETSHORTCUT.C52993_OnLoad = function( m )
UpdateImg(m)
end
