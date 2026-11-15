NEW_FORM_CASHINFO= { }
NEW_FORM_CASHINFO.Main = function( m )
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
NEW_FORM_CASHINFO.C50323_OnClick = function( m )
m:Close()
end
local QueryUser = function(m, str)            --是否对话框
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

local OnBuy = function(m)
	m.SelectNumBox = NewNumSel(m, STR_SELECTNUMBER_TYPE_BUY, 1, 1, 30)
	m.SelectNumBox:WaitUserInput(m)
	local  ret = m.SelectNumBox:GetResult()
	DelNumSel(m.SelectNumBox)
	if -1 ~= ret then
		local str, b = m:GetConfirmStr(ret)
		if b == false then
			WarnUser(m, str)
			return
		end
	else
		DBGPRINTF("have money") 
		m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
		m.MsgBox:WaitUserInput(m)
		local result = m.MsgBox:GetResult()
		DelMsgBox(m.MsgBox)

		if MsgBox.ECODE_YES == result then
			m:OnBuy(ret)
		end
	end
end
NEW_FORM_CASHINFO.C50321_OnClick = function( m )
m.SelectNumBox = NewNumSel(m, STR_COMBINE_NUMBER, 1, 1, 30)
m.SelectNumBox:WaitUserInput(m)
local  ret = m.SelectNumBox:GetResult()
DelNumSel(m.SelectNumBox)
if -1 ~= ret then
	local str, b = m:GetConfirmStr(ret)
	if b == false then
		if MsgBox.ECODE_YES == QueryUser(m, str) then
			if m:VersionAppstore() then
				NewDepositIOS(m)
			else
				NewDepositV8(m)
			end
		end
		return
	elseif MsgBox.ECODE_YES == QueryUser(m, str) then
		m:OnBuy(ret)
	end
end
m:Close()
end
