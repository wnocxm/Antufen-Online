FORM_UPDATE= { }
FORM_UPDATE.Main = function( m )
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
		UI_Engine.SetText(m.formIndex,composit,"")
	else
		UI_Engine.SetText(m.formIndex,composit,text , 0,color)
	end
end
FORM_UPDATE.C50024_OnClick = function( m )

m:OnClick(1)
--m.PlayerInfo = NewPlayerInfo(m)
end
FORM_UPDATE.C50023_OnClick = function( m )
m:OnClick(0)

end
FORM_UPDATE.C52273_OnUpdate = function( m )
SetTabListText(m,0,COMPOSIT_2273)
--UI_Engine.SetText(0,COMPOSIT_2273,"fffff")
end
FORM_UPDATE.C52272_OnUpdate = function( m )
SetTabListText(m,1,COMPOSIT_2272)
end
FORM_UPDATE.C52271_OnUpdate = function( m )
SetTabListText(m,2,COMPOSIT_2271)
end
FORM_UPDATE.C52270_OnUpdate = function( m )
SetTabListText(m,3,COMPOSIT_2270)
end
FORM_UPDATE.C52269_OnUpdate = function( m )
SetTabListText(m,4,COMPOSIT_2269)
end
FORM_UPDATE.C52268_OnUpdate = function( m )
SetTabListText(m,5,COMPOSIT_2268)
end
FORM_UPDATE.C52267_OnUpdate = function( m )
SetTabListText(m,6,COMPOSIT_2267)
end
FORM_UPDATE.C52266_OnUpdate = function( m )
SetTabListText(m,7,COMPOSIT_2266)
end
FORM_UPDATE.C52265_OnUpdate = function( m )
SetTabListText(m,8,COMPOSIT_2265)
end
