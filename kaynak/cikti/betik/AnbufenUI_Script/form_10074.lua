FORM_SYS_CHAT= { }
FORM_SYS_CHAT.Main = function( m )
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
local SetTabListText = function(m,nIndex,composit)
	local text , color= m:GetListText(m.offset + nIndex)
	if text== nil then
		DBGPRINTF("SetTabListText  text= null")
		UI_Engine.SetText(m.formIndex,composit,"")
	else
		UI_Engine.SetText(m.formIndex,composit,text , 0,color)
	end
end
FORM_SYS_CHAT.C51955_OnClick = function( m )
m:Close()
end
FORM_SYS_CHAT.C52762_OnClick = function( m )
m:Close()
end
FORM_SYS_CHAT.C51953_OnClick = function( m )

m:OpenChat()
m:Close()
end
FORM_SYS_CHAT.C51966_OnUpdate = function( m )
SetTabListText(m,0,COMPOSIT_1966)
end
FORM_SYS_CHAT.C51965_OnUpdate = function( m )
SetTabListText(m,1,COMPOSIT_1965)
end
FORM_SYS_CHAT.C51964_OnUpdate = function( m )
SetTabListText(m,2,COMPOSIT_1964)
end
FORM_SYS_CHAT.C51963_OnUpdate = function( m )
SetTabListText(m,3,COMPOSIT_1963)
end
FORM_SYS_CHAT.C51962_OnUpdate = function( m )
SetTabListText(m,4,COMPOSIT_1962)
end
FORM_SYS_CHAT.C51961_OnUpdate = function( m )
SetTabListText(m,5,COMPOSIT_1961)
end
FORM_SYS_CHAT.C51960_OnUpdate = function( m )
SetTabListText(m,6,COMPOSIT_1960)
end
FORM_SYS_CHAT.C51959_OnUpdate = function( m )
SetTabListText(m,7,COMPOSIT_1959)
end
FORM_SYS_CHAT.C51958_OnUpdate = function( m )
SetTabListText(m,8,COMPOSIT_1958)
end
FORM_SYS_CHAT.C51957_OnUpdate = function( m )
SetTabListText(m,9,COMPOSIT_1957)
end
FORM_SYS_CHAT.C51956_OnUpdate = function( m )
SetTabListText(m,10,COMPOSIT_1956)
end
