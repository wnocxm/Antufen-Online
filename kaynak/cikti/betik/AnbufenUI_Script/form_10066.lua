FORM_INFO= { }
FORM_INFO.Main = function( m )
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
FORM_INFO.C51761_OnLoad = function( m )
local name = m:GetTitle()
if name == nil then
UI_Engine.SetText(m.formIndex,COMPOSIT_1761,"" )
else
UI_Engine.SetText(m.formIndex,COMPOSIT_1761,name )
end

end
local SetTabListText = function(m,nIndex,composit)
	local text , color= m:GetListText(m.offset + nIndex)
	if text== nil then
		DBGPRINTF("SetTabListText  text= null")
		UI_Engine.SetText(m.formIndex,composit,"")
	else
		UI_Engine.SetText(m.formIndex,composit,text , 0,color)
	end
end
FORM_INFO.C52759_OnClick = function( m )
m:InputFinished()
m:Close()
end
FORM_INFO.C51760_OnUpdate = function( m )
SetTabListText(m,0,COMPOSIT_1760)
end
FORM_INFO.C51759_OnUpdate = function( m )
SetTabListText(m,1,COMPOSIT_1759)
end
FORM_INFO.C51758_OnUpdate = function( m )
SetTabListText(m,2,COMPOSIT_1758)
end
FORM_INFO.C51757_OnUpdate = function( m )
SetTabListText(m,3,COMPOSIT_1757)
end
FORM_INFO.C51756_OnUpdate = function( m )
SetTabListText(m,4,COMPOSIT_1756)
end
FORM_INFO.C51755_OnUpdate = function( m )
SetTabListText(m,5,COMPOSIT_1755)
end
FORM_INFO.C51754_OnUpdate = function( m )
SetTabListText(m,6,COMPOSIT_1754)
end
FORM_INFO.C51753_OnUpdate = function( m )
SetTabListText(m,7,COMPOSIT_1753)
end
FORM_INFO.C51762_OnUpdate = function( m )
SetTabListText(m,8,COMPOSIT_1762)
end
FORM_INFO.C51763_OnUpdate = function( m )
SetTabListText(m,9,COMPOSIT_1763)
end
FORM_INFO.C51764_OnUpdate = function( m )
SetTabListText(m,10,COMPOSIT_1764)
end
FORM_INFO.C51751_OnClick = function( m )
m:InputFinished()
m:Close()
end
