FORM_COMBINE= { }
FORM_COMBINE.Main = function( m )
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
FORM_COMBINE.C52852_OnLoad = function( m )
local title = m:OnClickTab(0)
UI_Engine.SetText(m.formIndex,COMPOSIT_TITLE,title,0)

local strShow = m:OnClickList(0)
ShowDes(m,strShow)
end
function ShowDes(m,result)
UI_Engine.SetText(m.formIndex ,COMPOSIT_2831,result,0)
end
FORM_COMBINE.C52834_OnClick = function( m )
local MaxNum = m:OnClick()
if MaxNum == 0 then

elseif MaxNum > 1 then
	m.SelectNumBox = NewNumSel(m, "Select Number", 1, 1, MaxNum)
	m.SelectNumBox:WaitUserInput(m)
	local  Quantity = m.SelectNumBox:GetResult()
	DelNumSel(m.SelectNumBox)

	m:Send(Quantity)
elseif MaxNum == 1 then
 	m:Send(1)
end
end
FORM_COMBINE.C52828_OnClick = function( m )
local name, ptr =m:Detail()
if name ~= nil then
	m.info = NewInfo(m, name, ptr)
end
end
FORM_COMBINE.C52835_OnClick = function( m )
DelCombine(m)
end
FORM_COMBINE.C52826_OnClick = function( m )
local title = m:OnClickTab(0)
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2843)
UI_Engine.SetText(m.formIndex,COMPOSIT_TITLE,title,0)

local strShow = m:OnClickList(0)
ShowDes(m,strShow)
end
FORM_COMBINE.C52827_OnClick = function( m )
local title = m:OnClickTab(1)
UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2851)
UI_Engine.SetText(m.formIndex,COMPOSIT_TITLE,title,0)

local strShow = m:OnClickList(0)
ShowDes(m,strShow)
end
FORM_COMBINE.C52843_OnClick = function( m )
local strShow = m:OnClickList(m.offset)
end
FORM_COMBINE.C52843_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2843, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2843,name,1)

end
end
FORM_COMBINE.C52842_OnClick = function( m )
local strShow = m:OnClickList(m.offset+1)
ShowDes(m,strShow)

end
FORM_COMBINE.C52842_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset+1)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2842, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2842,name,1)

end
end
FORM_COMBINE.C52841_OnClick = function( m )
local strShow = m:OnClickList(m.offset+2)
ShowDes(m,strShow)
end
FORM_COMBINE.C52841_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset+2)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2841, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2841,name,1)

end
end
FORM_COMBINE.C52840_OnClick = function( m )
local strShow = m:OnClickList(m.offset+3)
ShowDes(m,strShow)
end
FORM_COMBINE.C52840_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset+3)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2840, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2840,name,1)

end
end
FORM_COMBINE.C52839_OnClick = function( m )
local strShow = m:OnClickList(m.offset+4)
ShowDes(m,strShow)
end
FORM_COMBINE.C52839_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset+4)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2839, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2839,name,1)

end
end
FORM_COMBINE.C52838_OnClick = function( m )
local strShow = m:OnClickList(m.offset+5)
ShowDes(m,strShow)
end
FORM_COMBINE.C52838_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset+5)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2838, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2838,name,1)

end
end
FORM_COMBINE.C52837_OnClick = function( m )
local strShow = m:OnClickList(m.offset+6)
ShowDes(m,strShow)
end
FORM_COMBINE.C52837_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset+6)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2837, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2837,name,1)

end
end
FORM_COMBINE.C52836_OnClick = function( m )
local strShow = m:OnClickList(m.offset+7)
ShowDes(m,strShow)
end
FORM_COMBINE.C52836_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset+7)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2836, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2836,name,1)

end
end
FORM_COMBINE.C52851_OnClick = function( m )
local strShow = m:OnClickList(m.offset)
ShowDes(m,strShow)
end
FORM_COMBINE.C52851_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2851, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2851,name,1)

end
end
FORM_COMBINE.C52850_OnClick = function( m )
local strShow = m:OnClickList(m.offset+1)
ShowDes(m,strShow)
end
FORM_COMBINE.C52850_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset+1)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2850, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2850,name,1)

end
end
FORM_COMBINE.C52849_OnClick = function( m )
local strShow = m:OnClickList(m.offset+2)
ShowDes(m,strShow)
end
FORM_COMBINE.C52849_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset+2)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2849, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2849,name,1)

end
end
FORM_COMBINE.C52848_OnClick = function( m )
local strShow = m:OnClickList(m.offset+3)
ShowDes(m,strShow)
end
FORM_COMBINE.C52848_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset+3)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2848, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2848,name,1)

end
end
FORM_COMBINE.C52847_OnClick = function( m )
local strShow = m:OnClickList(m.offset+4)
ShowDes(m,strShow)
end
FORM_COMBINE.C52847_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset+4)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2847, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2847,name,1)

end
end
FORM_COMBINE.C52846_OnClick = function( m )
local strShow = m:OnClickList(m.offset+5)
ShowDes(m,strShow)
end
FORM_COMBINE.C52846_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset+5)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2846, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2846,name,1)

end
end
FORM_COMBINE.C52845_OnClick = function( m )
local strShow = m:OnClickList(m.offset+6)
ShowDes(m,strShow)
end
FORM_COMBINE.C52845_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset+6)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2845, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2845,name,1)

end
end
FORM_COMBINE.C52844_OnClick = function( m )
local strShow = m:OnClickList(m.offset+7)
ShowDes(m,strShow)
end
FORM_COMBINE.C52844_OnUpdate = function( m )
local img ,name = m:GetDrawInfo(m.offset+7)
if nil == img then

else
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2844, img,0)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2844,name,1)

end
end
