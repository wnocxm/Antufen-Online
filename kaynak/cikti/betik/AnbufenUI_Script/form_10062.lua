FORM_DEPOSIT_QUERY= { }
FORM_DEPOSIT_QUERY.Main = function( m )
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
local QueryUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_CANCEL)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local UpDate = function(m)
	local nSyear, nSmon, nEyear, nEmon = m:GetTimeValue()
	UI_Engine.SetText(m.formIndex,COMPOSIT_1719,nSyear)
	UI_Engine.SetText(m.formIndex,COMPOSIT_1742,nSmon)
	UI_Engine.SetText(m.formIndex,COMPOSIT_1720,nEyear)
	UI_Engine.SetText(m.formIndex,COMPOSIT_1743,nEmon)
end
FORM_DEPOSIT_QUERY.C51722_OnLoad = function( m )
UpDate(m)
end
FORM_DEPOSIT_QUERY.C51715_OnClick = function( m )
m:SetEMon(1)
UpDate(m)
end
FORM_DEPOSIT_QUERY.C51714_OnClick = function( m )
m:SetEYear(1)
UpDate(m)
end
FORM_DEPOSIT_QUERY.C51713_OnClick = function( m )
m:SetEMon(0)
UpDate(m)
end
FORM_DEPOSIT_QUERY.C51712_OnClick = function( m )
m:SetEYear(0)
UpDate(m)
end
FORM_DEPOSIT_QUERY.C51711_OnClick = function( m )
m:SetSMon(1)
UpDate(m)
end
FORM_DEPOSIT_QUERY.C51710_OnClick = function( m )
m:SetSMon(0)
UpDate(m)
end
FORM_DEPOSIT_QUERY.C51709_OnClick = function( m )
m:SetSYear(1)
UpDate(m)
end
FORM_DEPOSIT_QUERY.C51708_OnClick = function( m )
m:SetSYear(0)
UpDate(m)
end
FORM_DEPOSIT_QUERY.C52757_OnClick = function( m )
DBGPRINTF("exit")
m:InputFinished()
m:Close()
DelDepositQuery(m)
end
FORM_DEPOSIT_QUERY.C51707_OnClick = function( m )
DBGPRINTF("exit")
m:InputFinished()
m:Close()
DelDepositQuery(m)
end
FORM_DEPOSIT_QUERY.C51706_OnClick = function( m )
if m:IsQuery()  == false then
WarnUser(m,"日期输入错误")
return 
end
m:Query()

end
