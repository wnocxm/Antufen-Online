NEW_FORM_DEPOSIT_QUERY= { }
NEW_FORM_DEPOSIT_QUERY.Main = function( m )
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
NEW_FORM_DEPOSIT_QUERY.C50805_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)

end
NEW_FORM_DEPOSIT_QUERY.C50805_OnClick = function( m )
DBGPRINTF("exit")
m:InputFinished()
m:Close()
DelDepositQuery(m)

end
local QueryUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_OK)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local UpDate = function(m)
	local nSyear, nSmon, nEyear, nEmon = m:GetTimeValue()
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_793,nSyear)
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_796,nSmon)
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_800,nEyear)
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_803,nEmon)
end

NEW_FORM_DEPOSIT_QUERY.C50804_OnLoad = function( m )
UpDate(m)
end
NEW_FORM_DEPOSIT_QUERY.C50804_OnClick = function( m )
if m:IsQuery()  == false then
WarnUser(m,UI_Engine.GetLuaStr(STR_DEPOSIT_DATE_WRONG))
return 
end
m:Query()

end
NEW_FORM_DEPOSIT_QUERY.C50802_OnClick = function( m )
m:SetEMon(1)
UpDate(m)

end
NEW_FORM_DEPOSIT_QUERY.C50801_OnClick = function( m )
m:SetEMon(0)
UpDate(m)

end
NEW_FORM_DEPOSIT_QUERY.C50799_OnClick = function( m )
m:SetEYear(1)
UpDate(m)

end
NEW_FORM_DEPOSIT_QUERY.C50798_OnClick = function( m )
m:SetEYear(0)
UpDate(m)

end
NEW_FORM_DEPOSIT_QUERY.C50795_OnClick = function( m )
m:SetSMon(1)
UpDate(m)

end
NEW_FORM_DEPOSIT_QUERY.C50794_OnClick = function( m )
m:SetSMon(0)
UpDate(m)

end
NEW_FORM_DEPOSIT_QUERY.C50792_OnClick = function( m )
m:SetSYear(1)
UpDate(m)

end
NEW_FORM_DEPOSIT_QUERY.C50791_OnClick = function( m )
m:SetSYear(0)
UpDate(m)

end
