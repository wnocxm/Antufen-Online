NEW_FORM_PETEQUIPINFO= { }
NEW_FORM_PETEQUIPINFO.Main = function( m )
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

local SetInfo = function(m)
	local img, name, quality = m:GetDrawInfo()
	if img ~= nil then
		UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_177, img)
		UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_178, name)
		UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_179, quality)
	end
end

local EquipOn = function(m)
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
	m:Close()
end
NEW_FORM_PETEQUIPINFO.C50181_OnClick = function( m )
EquipOn(m)
end
NEW_FORM_PETEQUIPINFO.C50180_OnClick = function( m )
m:PetEquipTakeOff()
m:Close()
end
NEW_FORM_PETEQUIPINFO.C50176_OnClick = function( m )
m:Close()
end
NEW_FORM_PETEQUIPINFO.C50175_OnLoad = function( m )
SetInfo(m)
end
