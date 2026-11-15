FORM_BUSINESS= { }
FORM_BUSINESS.Main = function( m )
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
local SetListText = function(m,nIndex,composit)
	local nStatus,img,name,strEndTime,color= m:GetListText(m.offset + nIndex)
	if nStatus == false then
		UI_Engine.SetSurfaceImg( m.formIndex, composit, img ,0 )
		UI_Engine.SetText(m.formIndex,composit,name,1,color)
		UI_Engine.SetText(m.formIndex,composit,strEndTime,2,color)
		--UI_Engine.SetText(m.formIndex,composit,"开始",3,color)
	else
		UI_Engine.SetSurfaceImg( m.formIndex, composit, img ,0 )
		UI_Engine.SetText(m.formIndex,composit,name,1)
		UI_Engine.SetText(m.formIndex,composit,strEndTime,2)
		--UI_Engine.SetText(m.formIndex,composit,"结束",3)
	end

end
FORM_BUSINESS.C52640_OnClick = function( m )
local name, pinfo = m:LookUp(m.userSelectItem)
if name ~= nil and pinfo ~= nil  then
	m.info = NewInfo(m,name,pinfo)
	m.info:WaitUserInput(m)
	DelInfo(m.info)
end

end
FORM_BUSINESS.C52641_OnClick = function( m )
m:Close()
end
FORM_BUSINESS.C52764_OnClick = function( m )
m:Close()
end
FORM_BUSINESS.C52652_OnUpdate = function( m )
SetListText(m,0,COMPOSIT_2652)
end
FORM_BUSINESS.C52651_OnUpdate = function( m )
SetListText(m,1,COMPOSIT_2651)
end
FORM_BUSINESS.C52650_OnUpdate = function( m )
SetListText(m,2,COMPOSIT_2650)
end
FORM_BUSINESS.C52649_OnUpdate = function( m )
SetListText(m,3,COMPOSIT_2649)
end
FORM_BUSINESS.C52648_OnUpdate = function( m )
SetListText(m,4,COMPOSIT_2648)
end
FORM_BUSINESS.C52647_OnUpdate = function( m )
SetListText(m,5,COMPOSIT_2647)
end
FORM_BUSINESS.C52646_OnUpdate = function( m )
SetListText(m,6,COMPOSIT_2646)
end
FORM_BUSINESS.C52645_OnUpdate = function( m )
SetListText(m,7,COMPOSIT_2645)
end
