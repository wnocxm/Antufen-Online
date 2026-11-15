FORM_HEADIMG= { }
FORM_HEADIMG.Main = function( m )
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
FORM_HEADIMG.C51149_OnLoad = function( m )
UpdateImg(m)
end
FORM_HEADIMG.C51149_OnClick = function( m )
m:GetSelID(0)
m:InputFinished()
end
function SetHeadImg(m, ret, ctlID, index) -- 取得默认头像
	DBGPRINTF("lua_Info:m.ret = "..ret)
	if 0 == ret then
		UI_Engine.SetImg(m.formIndex,ctlID, "Portrait.godat",1000,index,0)
	elseif 1 == ret then
		UI_Engine.SetImg(m.formIndex,ctlID, "Portrait.godat",2000,index,0)
	elseif 2 == ret then 
		UI_Engine.SetImg(m.formIndex,ctlID, "Portrait.godat",3000,index,0)
	else
		UI_Engine.SetImg(m.formIndex,ctlID, "Portrait.godat",4000,index,0)
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

FORM_HEADIMG.C51150_OnClick = function( m )
m:GetSelID(1)
m:InputFinished()
end
FORM_HEADIMG.C51151_OnClick = function( m )
m:GetSelID(2)
m:InputFinished()
end
FORM_HEADIMG.C51152_OnClick = function( m )
m:GetSelID(3)
m:InputFinished()
end
FORM_HEADIMG.C51153_OnClick = function( m )
m:GetSelID(4)
m:InputFinished()
end
FORM_HEADIMG.C51154_OnClick = function( m )
m:GetSelID(5)
m:InputFinished()
end
FORM_HEADIMG.C51155_OnClick = function( m )
m:GetSelID(6)
m:InputFinished()
end
FORM_HEADIMG.C51156_OnLoad = function( m )
UpdateImg(m)
end
FORM_HEADIMG.C51156_OnClick = function( m )
m:GetSelID(7)
m:InputFinished()
end
FORM_HEADIMG.C51156_OnDraw = function( m )
UpdateImg(m)
end
