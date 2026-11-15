NEW_FORM_BUSINESS= { }
NEW_FORM_BUSINESS.Main = function( m )
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
NEW_FORM_BUSINESS.C50305_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_BUSINESS.C50305_OnClick = function( m )
m:Close()

end
local SetListText = function(m,nIndex,composit)
	local nStatus,img,name,strEndTime,color= m:GetListText(m.offset + nIndex)
	if nStatus == false then
		UI_Engine.SetSurfaceImg( m.formIndex, composit, img ,0 )
		UI_Engine.SetText(m.formIndex,composit,name,1,color)
		UI_Engine.SetText(m.formIndex,composit,strEndTime,2,color)
	else
		UI_Engine.SetSurfaceImg( m.formIndex, composit, img ,0 )
		UI_Engine.SetText(m.formIndex,composit,name,1)
		UI_Engine.SetText(m.formIndex,composit,strEndTime,2)
	end

end
local OnClickList= function(m)
local name, pinfo = m:LookUp(m.userSelectItem)
if name ~= nil and pinfo ~= nil  then
	m.info = NewInfo(m,name,pinfo)
	m.info:WaitUserInput(m)
	DelInfo(m.info)
end
end
NEW_FORM_BUSINESS.C50298_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_BUSINESS.C50298_OnUpdate = function( m )
SetListText(m,0,UI3_COMPOSIT_298)

end
NEW_FORM_BUSINESS.C50299_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_BUSINESS.C50299_OnUpdate = function( m )
SetListText(m,1,UI3_COMPOSIT_299)
end
NEW_FORM_BUSINESS.C50300_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_BUSINESS.C50300_OnUpdate = function( m )
SetListText(m,2,UI3_COMPOSIT_300)
end
NEW_FORM_BUSINESS.C50301_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_BUSINESS.C50301_OnUpdate = function( m )
SetListText(m,3,UI3_COMPOSIT_301)
end
NEW_FORM_BUSINESS.C50302_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_BUSINESS.C50302_OnUpdate = function( m )
SetListText(m,4,UI3_COMPOSIT_302)
end
NEW_FORM_BUSINESS.C50303_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_BUSINESS.C50303_OnUpdate = function( m )
SetListText(m,5,UI3_COMPOSIT_303)
end
NEW_FORM_BUSINESS.C50304_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_BUSINESS.C50304_OnUpdate = function( m )
SetListText(m,6,UI3_COMPOSIT_304)
end
