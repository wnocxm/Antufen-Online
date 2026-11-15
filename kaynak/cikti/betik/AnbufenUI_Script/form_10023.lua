FORM_RELATION= { }
FORM_RELATION.Main = function( m )
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
FORM_RELATION.C52906_OnClick = function( m )
m:OnClick(0)
end
FORM_RELATION.C52905_OnClick = function( m )
m:OnClick(1)
end
FORM_RELATION.C52904_OnClick = function( m )
m:OnClick(2)
end
FORM_RELATION.C52903_OnClick = function( m )
m:OnClick(3)
end
FORM_RELATION.C52902_OnClick = function( m )
m:OnClick(4)
end
FORM_RELATION.C52901_OnClick = function( m )
m:OnClick(5)
end
FORM_RELATION.C52900_OnClick = function( m )
m:OnClick(6)
end
FORM_RELATION.C52694_OnClick = function( m )
if m:IsNew()==1 then--add by liao
DelRelationMenu(m)
else
m:OnClickLRFunction(1)
end
end
FORM_RELATION.C50260_OnClick = function( m )
m:OnClickChat(m.offset)
end
FORM_RELATION.C50260_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM0,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM0,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM0,others,2,ocolor)
end
FORM_RELATION.C50259_OnClick = function( m )
m:OnClickChat(m.offset+1)
--local chatForm = OpenChatForm(....)
--chatForm:WaitUserInput(m)
--CloseChatForm(charForm)

end
FORM_RELATION.C50259_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+1)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM1,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM1,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM1,others,2,ocolor)

end
FORM_RELATION.C50258_OnClick = function( m )
m:OnClickChat(m.offset+2)
end
FORM_RELATION.C50258_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+2)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM2,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM2,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM2,others,2,ocolor)

end
FORM_RELATION.C50257_OnClick = function( m )
m:OnClickChat(m.offset+3)
end
FORM_RELATION.C50257_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+3)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM3,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM3,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM3,others,2,ocolor)

end
FORM_RELATION.C50256_OnClick = function( m )
m:OnClickChat(m.offset+4)
end
FORM_RELATION.C50256_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+4)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM4,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM4,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM4,others,2,ocolor)

end
FORM_RELATION.C50261_OnClick = function( m )
m:OnClickChat(m.offset+5)
end
FORM_RELATION.C50261_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+5)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM5,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM5,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM5,others,2,ocolor)

end
FORM_RELATION.C50810_OnClick = function( m )
m:OnClickChat(m.offset+6)
end
FORM_RELATION.C50810_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+6)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM6,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM6,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM6,others,2,ocolor)
end
FORM_RELATION.C50811_OnClick = function( m )
m:OnClickChat(m.offset+7)
end
FORM_RELATION.C50811_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+7)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM7,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM7,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LIST_ITEM7,others,2,ocolor)
end
FORM_RELATION.C50276_OnClick = function( m )
local formIndex,others=m:SetTabIndex(0)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LVBAR,others,0)
UI_Engine.SetFormTab(m.formIndex, 0)

UI_Engine.UpdateList(formIndex,  COMPOSIT_RELATION_LIST_ITEM1)
end
FORM_RELATION.C50275_OnClick = function( m )
local formIndex,others=m:SetTabIndex(1)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LVBAR,others,0)
UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.UpdateList(formIndex,  COMPOSIT_2875)
end
FORM_RELATION.C50274_OnClick = function( m )
local formIndex,others=m:SetTabIndex(2)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LVBAR,others,0)
UI_Engine.SetFormTab(m.formIndex, 2)
UI_Engine.UpdateList(formIndex,  COMPOSIT_2883)

end
FORM_RELATION.C50273_OnClick = function( m )
local formIndex,others=m:SetTabIndex(3)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LVBAR,others,0)
UI_Engine.SetFormTab(m.formIndex, 3)
UI_Engine.UpdateList(formIndex,  COMPOSIT_2891)
end
FORM_RELATION.C50272_OnClick = function( m )
local formIndex,others=m:SetTabIndex(4)
UI_Engine.SetText(formIndex,COMPOSIT_RELATION_LVBAR,others,0)

UI_Engine.SetFormTab(m.formIndex, 4)
UI_Engine.UpdateList(formIndex,  COMPOSIT_2899)
end
FORM_RELATION.C52875_OnClick = function( m )
m:OnClickChat(m.offset)
end
FORM_RELATION.C52875_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset)
UI_Engine.SetText(formIndex,COMPOSIT_2875,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2875,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2875,others,2,ocolor)
end
FORM_RELATION.C52874_OnClick = function( m )
m:OnClickChat(m.offset+1)
end
FORM_RELATION.C52874_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+1)
UI_Engine.SetText(formIndex,COMPOSIT_2874,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2874,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2874,others,2,ocolor)
end
FORM_RELATION.C52873_OnClick = function( m )
m:OnClickChat(m.offset+2)
end
FORM_RELATION.C52873_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+2)
UI_Engine.SetText(formIndex,COMPOSIT_2873,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2873,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2873,others,2,ocolor)
end
FORM_RELATION.C52872_OnClick = function( m )
m:OnClickChat(m.offset+3)
end
FORM_RELATION.C52872_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+3)
UI_Engine.SetText(formIndex,COMPOSIT_2872,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2872,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2872,others,2,ocolor)
end
FORM_RELATION.C52871_OnClick = function( m )
m:OnClickChat(m.offset+4)
end
FORM_RELATION.C52871_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+4)
UI_Engine.SetText(formIndex,COMPOSIT_2871,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2871,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2871,others,2,ocolor)
end
FORM_RELATION.C52870_OnClick = function( m )
m:OnClickChat(m.offset+5)
end
FORM_RELATION.C52870_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+5)
UI_Engine.SetText(formIndex,COMPOSIT_2870,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2870,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2870,others,2,ocolor)
end
FORM_RELATION.C52869_OnClick = function( m )
m:OnClickChat(m.offset+6)
end
FORM_RELATION.C52869_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+6)
UI_Engine.SetText(formIndex,COMPOSIT_2869,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2869,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2869,others,2,ocolor)
end
FORM_RELATION.C52868_OnClick = function( m )
m:OnClickChat(m.offset+7)
end
FORM_RELATION.C52868_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+7)
UI_Engine.SetText(formIndex,COMPOSIT_2868,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2868,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2868,others,2,ocolor)
end
FORM_RELATION.C52883_OnClick = function( m )
m:OnClickChat(m.offset)
end
FORM_RELATION.C52883_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset)
UI_Engine.SetText(formIndex,COMPOSIT_2883,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2883,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2883,others,2,ocolor)
end
FORM_RELATION.C52882_OnClick = function( m )
m:OnClickChat(m.offset+1)
end
FORM_RELATION.C52882_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+1)
UI_Engine.SetText(formIndex,COMPOSIT_2882,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2882,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2882,others,2,ocolor)
end
FORM_RELATION.C52881_OnClick = function( m )
m:OnClickChat(m.offset+2)
end
FORM_RELATION.C52881_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+2)
UI_Engine.SetText(formIndex,COMPOSIT_2881,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2881,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2881,others,2,ocolor)
end
FORM_RELATION.C52880_OnClick = function( m )
m:OnClickChat(m.offset+3)
end
FORM_RELATION.C52880_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+3)
UI_Engine.SetText(formIndex,COMPOSIT_2880,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2880,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2880,others,2,ocolor)
end
FORM_RELATION.C52879_OnClick = function( m )
m:OnClickChat(m.offset+4)
end
FORM_RELATION.C52879_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+4)
UI_Engine.SetText(formIndex,COMPOSIT_2879,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2879,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2879,others,2,ocolor)
end
FORM_RELATION.C52878_OnClick = function( m )
m:OnClickChat(m.offset+5)
end
FORM_RELATION.C52878_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+5)
UI_Engine.SetText(formIndex,COMPOSIT_2878,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2878,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2878,others,2,ocolor)
end
FORM_RELATION.C52877_OnClick = function( m )
m:OnClickChat(m.offset+6)
end
FORM_RELATION.C52877_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+6)
UI_Engine.SetText(formIndex,COMPOSIT_2877,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2877,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2877,others,2,ocolor)
end
FORM_RELATION.C52876_OnClick = function( m )
m:OnClickChat(m.offset+7)
end
FORM_RELATION.C52876_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+7)
UI_Engine.SetText(formIndex,COMPOSIT_2876,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2876,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2876,others,2,ocolor)
end
FORM_RELATION.C52891_OnClick = function( m )
m:OnClickChat(m.offset)
end
FORM_RELATION.C52891_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset)
UI_Engine.SetText(formIndex,COMPOSIT_2891,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2891,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2891,others,2,ocolor)
end
FORM_RELATION.C52890_OnClick = function( m )
m:OnClickChat(m.offset+1)
end
FORM_RELATION.C52890_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+1)
UI_Engine.SetText(formIndex,COMPOSIT_2890,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2890,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2890,others,2,ocolor)
end
FORM_RELATION.C52889_OnClick = function( m )
m:OnClickChat(m.offset+2)
end
FORM_RELATION.C52889_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+2)
UI_Engine.SetText(formIndex,COMPOSIT_2889,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2889,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2889,others,2,ocolor)
end
FORM_RELATION.C52888_OnClick = function( m )
m:OnClickChat(m.offset+3)
end
FORM_RELATION.C52888_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+3)
UI_Engine.SetText(formIndex,COMPOSIT_2888,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2888,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2888,others,2,ocolor)
end
FORM_RELATION.C52887_OnClick = function( m )
m:OnClickChat(m.offset+4)
end
FORM_RELATION.C52887_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+4)
UI_Engine.SetText(formIndex,COMPOSIT_2887,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2887,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2887,others,2,ocolor)
end
FORM_RELATION.C52886_OnClick = function( m )
m:OnClickChat(m.offset+5)
end
FORM_RELATION.C52886_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+5)
UI_Engine.SetText(formIndex,COMPOSIT_2886,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2886,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2886,others,2,ocolor)
end
FORM_RELATION.C52885_OnClick = function( m )
m:OnClickChat(m.offset+6)
end
FORM_RELATION.C52885_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+6)
UI_Engine.SetText(formIndex,COMPOSIT_2885,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2885,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2885,others,2,ocolor)
end
FORM_RELATION.C52884_OnClick = function( m )
m:OnClickChat(m.offset+7)
end
FORM_RELATION.C52884_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+7)
UI_Engine.SetText(formIndex,COMPOSIT_2884,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2884,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2884,others,2,ocolor)
end
FORM_RELATION.C52899_OnClick = function( m )
m:OnClickChat(m.offset)
end
FORM_RELATION.C52899_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset)
UI_Engine.SetText(formIndex,COMPOSIT_2899,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2899,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2899,others,2,ocolor)
end
FORM_RELATION.C52898_OnClick = function( m )
m:OnClickChat(m.offset+1)
end
FORM_RELATION.C52898_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+1)
UI_Engine.SetText(formIndex,COMPOSIT_2898,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2898,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2898,others,2,ocolor)
end
FORM_RELATION.C52897_OnClick = function( m )
m:OnClickChat(m.offset+2)
end
FORM_RELATION.C52897_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+2)
UI_Engine.SetText(formIndex,COMPOSIT_2897,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2897,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2897,others,2,ocolor)
end
FORM_RELATION.C52896_OnClick = function( m )
m:OnClickChat(m.offset+3)
end
FORM_RELATION.C52896_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+3)
UI_Engine.SetText(formIndex,COMPOSIT_2896,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2896,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2896,others,2,ocolor)
end
FORM_RELATION.C52895_OnClick = function( m )
m:OnClickChat(m.offset+4)
end
FORM_RELATION.C52895_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+4)
UI_Engine.SetText(formIndex,COMPOSIT_2895,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2895,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2895,others,2,ocolor)
end
FORM_RELATION.C52894_OnClick = function( m )
m:OnClickChat(m.offset+5)
end
FORM_RELATION.C52894_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+5)
UI_Engine.SetText(formIndex,COMPOSIT_2894,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2894,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2894,others,2,ocolor)
end
FORM_RELATION.C52893_OnClick = function( m )
m:OnClickChat(m.offset+6)
end
FORM_RELATION.C52893_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+6)
UI_Engine.SetText(formIndex,COMPOSIT_2893,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2893,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2893,others,2,ocolor)
end
FORM_RELATION.C52892_OnClick = function( m )
m:OnClickChat(m.offset+7)
end
FORM_RELATION.C52892_OnUpdate = function( m )
local formIndex,name,ncolor,status,scolor,others,ocolor = m:GetRelationInfo(m.offset+7)
UI_Engine.SetText(formIndex,COMPOSIT_2892,name,0,ncolor)
UI_Engine.SetText(formIndex,COMPOSIT_2892,status,1,scolor)
UI_Engine.SetText(formIndex,COMPOSIT_2892,others,2,ocolor)
end
