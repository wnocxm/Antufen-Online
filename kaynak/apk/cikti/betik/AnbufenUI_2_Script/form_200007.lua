NEW_FORM_PETEQUIP= { }
NEW_FORM_PETEQUIP.Main = function( m )
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

local OnClick = function(m, sel)
	local ret = m:IsEquipExist(sel)
	if false == ret then
		local ptr = m:GetFuncFilter()
		m.bag = NewSelectBag(m, ptr, m)
		if m.bag == nil then
			WarnUser(m, STR_NO_EQUIP)
			return
		end
		m.bag:WaitUserInput(m)
		local vSelec = m.bag:GetSelectItem()
		local code = m.bag:GetExitCode()
		if code == 0 then
			DelSelectBag(m.bag)
			return
		end
		DelSelectBag(m.bag)
		
		local strBind = m:CheckEquipBind(vSelec)
		if strBind == nil then
			m:PetEquipTakeOn(vSelec)
		else
			if MsgBox.ECODE_YES == QueryUser(m, strBind) then
				m:PetEquipTakeOn(vSelec)
			end
		end
	else
		m:OnClick()
	end
	m:DrawPetEquip()
end
NEW_FORM_PETEQUIP.C50174_OnClick = function( m )
m:Close()
end
NEW_FORM_PETEQUIP.C50173_OnClick = function( m )
OnClick(m, 4)
end
NEW_FORM_PETEQUIP.C50172_OnClick = function( m )
OnClick(m, 3)
end
NEW_FORM_PETEQUIP.C50171_OnClick = function( m )
OnClick(m, 2)
end
NEW_FORM_PETEQUIP.C50170_OnClick = function( m )
OnClick(m, 1)
end
NEW_FORM_PETEQUIP.C50169_OnClick = function( m )
OnClick(m, 0)
end
NEW_FORM_PETEQUIP.C50167_OnLoad = function( m )
m:GetDrawInfo()
end
