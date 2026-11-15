NEW_FORM_HEADIMG= { }
NEW_FORM_HEADIMG.Main = function( m )
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
NEW_FORM_HEADIMG.C50002_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_HEADIMG.C50002_OnClick = function( m )
m:InputFinished()
end
function SetHeadImg(m, ret, ctlID, index) -- 取得默认头像
	DBGPRINTF("lua_Info:m.ret = "..ret)
	if 0 == ret then
		UI_Engine.SetImg(m.formIndex,ctlID, "Portrait.godat",1001+index,0,0)
	elseif 1 == ret then
		UI_Engine.SetImg(m.formIndex,ctlID, "Portrait.godat",2001+index,0,0)
	elseif 2 == ret then 
		UI_Engine.SetImg(m.formIndex,ctlID, "Portrait.godat",3001+index,0,0)
	else
		UI_Engine.SetImg(m.formIndex,ctlID, "Portrait.godat",4001+index,0,0)
	end
end

function UpdateImg(m)
	local sel = m:GetUserSelImg()
	SetHeadImg(m, sel, COMPOSIT_HEADIMG1, 0)
	SetHeadImg(m, sel, COMPOSIT_HEADIMG2, 1)
	SetHeadImg(m, sel, COMPOSIT_HEADIMG3, 2)
	SetHeadImg(m, sel, COMPOSIT_HEADIMG4, 3)
	SetHeadImg(m, sel, COMPOSIT_HEADIMG5, 4)
	SetHeadImg(m, sel, COMPOSIT_HEADIMG6, 5)
	SetHeadImg(m, sel, COMPOSIT_HEADIMG7, 6)
	SetHeadImg(m, sel, COMPOSIT_HEADIMG8, 7)
end
NEW_FORM_HEADIMG.C50010_OnClick = function( m )
m:GetSelID(7)
m:InputFinished()
end
NEW_FORM_HEADIMG.C50009_OnClick = function( m )
m:GetSelID(6)
m:InputFinished()
end
NEW_FORM_HEADIMG.C50008_OnClick = function( m )
m:GetSelID(5)
m:InputFinished()
end
NEW_FORM_HEADIMG.C50007_OnClick = function( m )
m:GetSelID(4)
m:InputFinished()
end
NEW_FORM_HEADIMG.C50006_OnClick = function( m )
m:GetSelID(3)
m:InputFinished()
end
NEW_FORM_HEADIMG.C50005_OnClick = function( m )
m:GetSelID(2)
m:InputFinished()
end
NEW_FORM_HEADIMG.C50004_OnClick = function( m )
m:GetSelID(1)
m:InputFinished()
end
NEW_FORM_HEADIMG.C50003_OnClick = function( m )
m:GetSelID(0)
m:InputFinished()
end
NEW_FORM_HEADIMG.C50001_OnLoad = function( m )
local tx, ty, bx, by = UI_Engine.GetClientRect(m.formIndex, UI3_COMPOSIT_11)
UI_Engine.SetContainerRect(m.formIndex, COMPOSIT_HEADIMG1, tx, ty, bx, by)
UI_Engine.SetEnableMove(m.formIndex, COMPOSIT_HEADIMG1, true)
UpdateImg(m)
end
