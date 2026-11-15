NEW_FORM_FANTASIZE_PET= { }
NEW_FORM_FANTASIZE_PET.Main = function( m )
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
NEW_FORM_FANTASIZE_PET.C50720_OnLoad = function( m )
m.nTab = 1
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_STUFF_PET_NAME, UI_Engine.GetLuaStr(R_STRING_PET_STUFF))
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_MAIN_PET_NAME, UI_Engine.GetLuaStr(R_STRING_PET_MINE))
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_PET_ITEM_NAME, UI_Engine.GetLuaStr(R_STRING_PETEQUIP_START_ICON))
UI_Engine.SetText(m.formIndex, UI3_COMPOST_714, UI_Engine.GetLuaStr(R_STRING_PETEQUIP_ASSISTENT_ICON))
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_719, UI_Engine.GetLuaStr(R_STRING_START_SUBLIME))
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_719, true)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_738, false)
end
NEW_FORM_FANTASIZE_PET.C50720_OnClick = function( m )
DBGPRINTF("exit ___Close1____begin")
m:InputFinished()
DBGPRINTF("exit ___Close2____can")
m:Close()
DelFantasize(m)
DBGPRINTF("exit ___Close3____end")

end
local WarnUser = function(m, str)             --单项对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_OK)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local WaitBar = function(m,str,time)    --进度条
	m.waitBar = NewWaitBar(m,str,time,0)       
	m.waitBar:WaitUserInput(m)
	local result = m.waitBar:GetResult()
	DelWaitBar(m.waitBar )	
	return result
end
local BeginUnreal = function(m)
	UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_719, true)
	UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_738, false)
		
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_737,"");
	UI_Engine.SetSurfaceImg(m.formIndex,UI3_COMPOSIT_728, nil);
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_719, UI_Engine.GetLuaStr(R_STRING_START_SUBLIME));
end
local BeginF = function(m)
local img, name,ret = m:GetRunItem()
	if ret then
		UI_Engine.SetSurfaceImg(m.formIndex, UI3_COMPOSIT_727, img)
		UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_PET_ITEM_NAME,name)

	else
		UI_Engine.SetSurfaceImg(m.formIndex, UI3_COMPOSIT_727, img,  0, 0,true)
		UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_PET_ITEM_NAME,name,0,-65536)
	end
end
local Opinion = function(m)
local num = m:GetDescribe(m.nSel) 
if num == 0 then
	return false
else
	return true
end
end

local OpenPack = function(m)
	local ptr = m:GetItemPointer()
	m.package = NewSelectBag(m,0, ptr)
	if nil == m.package then
		local ret = QueryUser(m, UI_Engine.GetLuaStr(R_STRING_YESNO_BUY_SHOP))
		if ret == MsgBox.ECODE_YES then
			local cash = m:GetCashPointer()
			NewCashShop(m, cash, 0)
		end
	else 
		m.package:WaitUserInput(m)
		local vSelect = m.package:GetSelectItem()
		local nSN, num = m.package:GetSelectSimpleItem(m)
		DelSelectBag(m.package)
		m:SetItem(nSN, num)
	end
	m:SetBtn()
end
local Order = function(m)
local opinion = Opinion(m)
	if false == opinion then
		 WarnUser(m,UI_Engine.GetLuaStr(R_STRING_BEFORE_PET))
		return false
	end
	return true
end	
local OnSel = function(m)
local opinion = Opinion(m)
	if opinion == false then
		if 0 == m.nSel then
			local NoPet = m:GetUserSel(m.nSel) 
			if NoPet  == true then
				m.petUI = NewSelectBag(m,1)
				m.petUI:WaitUserInput(m)
				m.MainPet = m.petUI:GetSelectItem()
				if m.MainPet ~= nil then
					DelSelectBag(m.petUI)
					local Get = m:OnClickSel(m.MainPet)
					if Get ==1 then	
						local num = m:DetectPet (1)
						if num ~= 1 then		
							BeginF(m)
							m:GetDrawInfo()
							BeginUnreal(m)
						end
					end
				end
			else
				WarnUser(m,UI_Engine.GetLuaStr(STR_ONOPEN_PET_PACKAGE))
			end	
		elseif 1 == m.nSel then
			m.nSel = 0
			local order = Order(m)
			if order == true then
				m.nSel = 1
				m:GetUserSel(m.nSel)
				m.petUI = NewSelectBag(m,1)
				m.petUI:WaitUserInput(m)
				m.StuffPet = m.petUI:GetSelectItem()
				DelSelectBag(m.petUI)
				local Get = m:OnClickSel(m.StuffPet)
				if Get ==1 then	
					local num = m:DetectPet(2)
					if num ~= 1 then
						m:GetDrawInfo()
					end
				end
			end
		elseif 2 == m.nSel then
			m:GetUserSel(m.nSel)
			OpenPack(m)
			m:GetDrawInfo()
		end
	else
		m:GetUserSel(m.nSel)
		if 3 == m.nSel then
			m.nSel = 0
			local opinion = Opinion(m)
				if false == opinion then
					WarnUser(m,UI_Engine.GetLuaStr(R_STRING_BEFORE_PET))
				else
					local img, name,ret = m:GetRunItem()
					if ret == true then
						local m_String,m_info,nSN=m:LookDetail()
						m.info = NewItemInfo(m,img,m_String,m_info,nSN)
						m.info:WaitUserInput(m)
						DelItemInfo(m.info)
					else
						local m_String,m_info=m:LookDetail()
						m.info = NewItemInfo(m,img,m_String,m_info)
						m.info:WaitUserInput(m)
						DelItemInfo(m.info)
					end
				end
		elseif 2 == m.nSel then
			local m_String,m_info,img,nSN=m:LookDetail()
			m.info = NewItemInfo(m,img,m_String,m_info,nSN)
			m.info:WaitUserInput(m)
			local ret = m.info:GetResult()
			DelItemInfo(m.info)
			if ret == 2 then
				m:GetUserSel(m.nSel)
				m:UnLoad()
			end
		elseif 4 == m.nSel then
			local petInfo = m:LookDetail()
			if petInfo ~= nil then
				m.pet = NewPetComplex(m, petInfo,2)
				m.pet:WaitUserInput(m)
				DelPetComplex(m.pet)
			end
		else
			local petInfo = m:LookDetail()
			if petInfo ~= nil then
			m.pet = NewPetComplex(m, petInfo , 1)
				m.pet:WaitUserInput(m)
				local ret = m.pet:GetResult()
				DelPetComplex(m.pet)
				if ret == 1 then
					m:GetUserSel(m.nSel)
					m:UnLoad()
				end
			end
		end
	end
end
NEW_FORM_FANTASIZE_PET.C50736_OnClick = function( m )
local cash = m:GetCashPointer()
NewCashShop(m, cash, 0)

end
NEW_FORM_FANTASIZE_PET.C50719_OnClick = function( m )
local num = m:BeginFantasize(m.nTab)
local img, name,ret = m:GetRunItem()
if ret then
	if num ~= 1 then  
		local str, time = m:GetWatFantasize()
		if 4 ~=	WaitBar(m,str,time) then
			m:BeginFantasize(m.nTab,1)
		end
	end
end
end
NEW_FORM_FANTASIZE_PET.C50738_OnClick = function( m )
local opinion = m:BeginFantasize(m.nTab,2)
if opinion ~= 1 then
BeginF(m)
end



end
NEW_FORM_FANTASIZE_PET.C50697_OnClick = function( m )
m.nSel = 0
OnSel(m)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_724, 1)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_725, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_727, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_726, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_728, 0)


end
NEW_FORM_FANTASIZE_PET.C50698_OnClick = function( m )
m.nSel = 1
OnSel(m)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_724, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_725, 1)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_727, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_726, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_728, 0)

end
NEW_FORM_FANTASIZE_PET.C50699_OnClick = function( m )
m.nSel = 2
OnSel(m)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_724, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_725, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_727, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_726, 1)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_728, 0)

end
NEW_FORM_FANTASIZE_PET.C50700_OnClick = function( m )
m.nSel = 3
OnSel(m)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_724, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_725, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_727, 1)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_726, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_728, 0)



end
NEW_FORM_FANTASIZE_PET.C50701_OnClick = function( m )
m.nSel = 4
OnSel(m)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_724, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_725, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_727, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_726, 0)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_728, 1)
end
NEW_FORM_FANTASIZE_PET.C50696_OnLoad = function( m )
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_PET_ITEM_NAME, UI_Engine.GetLuaStr(R_STRING_PETEQUIP_START_ICON))
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_STUFF_PET_NAME, UI_Engine.GetLuaStr(R_STRING_PET_STUFF))
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_MAIN_PET_NAME, UI_Engine.GetLuaStr(R_STRING_PET_MINE))
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_714, UI_Engine.GetLuaStr(R_STRING_PETEQUIP_ASSISTENT_ICON))

end
