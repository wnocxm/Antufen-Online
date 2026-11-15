FORM_PHONEBIND= { }
FORM_PHONEBIND.Main = function( m )
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
FORM_PHONEBIND.C52118_OnClick = function( m )
--m.MsgBox = NewMsgBox(m, "Hello___!", MsgBox.MODE_YESNO)
--m.MsgBox:WaitUserInput(m)
--local result = m.MsgBox:GetResult()
--DelMsgBox(m.MsgBox)

--if result==MsgBox.ECODE_YES then
m.channel = NewSMSChannel(m)
m.channel:WaitUserInput(m)
local result = m.channel:GetResult()
DelSMSChannel(m.channel)

m:OnBind(result)

--end
--m.PlayerInfo = NewPlayerInfo(m)
end
FORM_PHONEBIND.C52742_OnClick = function( m )
DelPhoneBind(m)
end
FORM_PHONEBIND.C52743_OnClick = function( m )
m:Onclick(m.userSelectItem)
end
FORM_PHONEBIND.C52743_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset)
UI_Engine.SetText(formIndex,COMPOSIT_PBDLIST0,str,0)
end
FORM_PHONEBIND.C52113_OnClick = function( m )
m:Onclick(m.userSelectItem)
end
FORM_PHONEBIND.C52113_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+1)
UI_Engine.SetText(formIndex,COMPOSIT_PBDLIST1,str,0)
end
FORM_PHONEBIND.C52112_OnClick = function( m )
m:Onclick(m.userSelectItem)
end
FORM_PHONEBIND.C52112_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+2)
UI_Engine.SetText(formIndex,COMPOSIT_PBDLIST2,str,0)
end
FORM_PHONEBIND.C52111_OnClick = function( m )
m:Onclick(m.userSelectItem)
end
FORM_PHONEBIND.C52111_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+3)
UI_Engine.SetText(formIndex,COMPOSIT_PBDLIST3,str,0)
end
FORM_PHONEBIND.C52110_OnClick = function( m )
m:Onclick(m.userSelectItem)
end
FORM_PHONEBIND.C52110_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+4)
UI_Engine.SetText(formIndex,COMPOSIT_PBDLIST4,str,0)
end
FORM_PHONEBIND.C52136_OnClick = function( m )
m:Onclick(m.userSelectItem)
end
FORM_PHONEBIND.C52136_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+5)
UI_Engine.SetText(formIndex,COMPOSIT_PBDLIST5,str,0)
end
FORM_PHONEBIND.C52740_OnClick = function( m )
m:Onclick(m.userSelectItem)
end
FORM_PHONEBIND.C52740_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+6)
UI_Engine.SetText(formIndex,COMPOSIT_PBDLIST6,str,0)
end
FORM_PHONEBIND.C52739_OnClick = function( m )
m:Onclick(m.userSelectItem)
end
FORM_PHONEBIND.C52739_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+7)
UI_Engine.SetText(formIndex,COMPOSIT_PBDLIST7,str,0)
end
