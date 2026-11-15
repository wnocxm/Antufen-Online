FORM_DEPOSIT_IPHONE= { }
FORM_DEPOSIT_IPHONE.Main = function( m )
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
FORM_DEPOSIT_IPHONE.C52806_OnClick = function( m )
DelDepositV8(m)
end
function ShowMsg(m,result)
UI_Engine.SetText(m.formIndex ,COMPOSIT_2797,result,0)
end
FORM_DEPOSIT_IPHONE.C52805_OnClick = function( m )
local strShow = m:OnClickList(m.offset)
end
FORM_DEPOSIT_IPHONE.C52805_OnUpdate = function( m )
local  name,money = m:OnUpdateList(m.offset)
UI_Engine.SetText(m.formIndex,COMPOSIT_2805,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2805,money,1)
end
FORM_DEPOSIT_IPHONE.C52804_OnClick = function( m )
local strShow = m:OnClickList(m.offset+1)
ShowMsg(m,strShow)

end
FORM_DEPOSIT_IPHONE.C52804_OnUpdate = function( m )
local  name,money = m:OnUpdateList(m.offset+1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2804,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2804,money,1)
end
FORM_DEPOSIT_IPHONE.C52803_OnClick = function( m )
local strShow = m:OnClickList(m.offset+2)
ShowMsg(m,strShow)
end
FORM_DEPOSIT_IPHONE.C52803_OnUpdate = function( m )
local  name,money = m:OnUpdateList(m.offset+2)
UI_Engine.SetText(m.formIndex,COMPOSIT_2803,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2803,money,1)
end
FORM_DEPOSIT_IPHONE.C52802_OnClick = function( m )
local strShow = m:OnClickList(m.offset+3)
ShowMsg(m,strShow)
end
FORM_DEPOSIT_IPHONE.C52802_OnUpdate = function( m )
local  name,money = m:OnUpdateList(m.offset+3)
UI_Engine.SetText(m.formIndex,COMPOSIT_2802,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2802,money,1)
end
FORM_DEPOSIT_IPHONE.C52801_OnClick = function( m )
local strShow = m:OnClickList(m.offset+4)
ShowMsg(m,strShow)
end
FORM_DEPOSIT_IPHONE.C52801_OnUpdate = function( m )
local  name,money = m:OnUpdateList(m.offset+4)
UI_Engine.SetText(m.formIndex,COMPOSIT_2801,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2801,money,1)
end
FORM_DEPOSIT_IPHONE.C52800_OnClick = function( m )
local strShow = m:OnClickList(m.offset +5)
ShowMsg(m,strShow)
end
FORM_DEPOSIT_IPHONE.C52800_OnUpdate = function( m )
local  name,money = m:OnUpdateList(m.offset +5)
UI_Engine.SetText(m.formIndex,COMPOSIT_2800,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2800,money,1)
end
FORM_DEPOSIT_IPHONE.C52799_OnClick = function( m )
local strShow = m:OnClickList(m.offset +6)
ShowMsg(m,strShow)
end
FORM_DEPOSIT_IPHONE.C52799_OnUpdate = function( m )
local  name,money = m:OnUpdateList(m.offset +6)
UI_Engine.SetText(m.formIndex,COMPOSIT_2799,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2799,money,1)
end
FORM_DEPOSIT_IPHONE.C52798_OnClick = function( m )
local strShow = m:OnClickList(m.offset)
ShowMsg(m,strShow)
end
FORM_DEPOSIT_IPHONE.C52798_OnUpdate = function( m )
local  name,money = m:OnUpdateList(m.offset +7)
UI_Engine.SetText(m.formIndex,COMPOSIT_2798,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2798,money,1)
end
FORM_DEPOSIT_IPHONE.C52807_OnClick = function( m )
m:OnClick()
end
