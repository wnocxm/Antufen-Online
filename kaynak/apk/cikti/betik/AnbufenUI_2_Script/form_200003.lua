NEW_FORM_PETCOMPLEX= { }
NEW_FORM_PETCOMPLEX.Main = function( m )
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

local GetInput = function(m, ctlID)		-- 创建输入框
	local text = UI_Engine.GetText(m.formIndex, ctlID)
	m.InputBox = OpenInputBox(m,text,16)
	m.InputBox :WaitUserInput(m)
	local result = m.InputBox :GetResult()
	UI_Engine.SetText(m.formIndex, ctlID, result, 0)
	return result
end

local ChangeName = function(m)
	if m:GetMode() ~= 0 then
		return
	end
	local temp = UI_Engine.GetText(m.formIndex, UI2_COMPOSIT_126)
	local newName = GetInput(m, UI2_COMPOSIT_126)
	local special, num = Tools.GetExplain()
	if Tools.JudgeSpecialWord(newName) then
		WarnUser(m, special)
		newName = temp
	end
	local ret = m:ChangePetName(newName)
end

local UpdateIcon = function(m) --更新格子状态
	local num = m:GetGridNum()
	local mode = m:GetMode()
	
	if mode == PetInfo.MODE_IN_TRADE then
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_756, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_757, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_758, false)
		
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_759, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_760, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_761, false)
		
		if 1 == num then
			UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_759, true)
		elseif 2 == num then
			UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_759, true)
			UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_760, true)
		elseif 3 == num then
			UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_759, true)
			UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_760, true)
			UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_761, true)
		end
		return
	end

	if 0 == num then
		DBGPRINTF("show 1")
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_756, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_757, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_758, false)
		
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_759, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_760, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_761, false)
	elseif 1 == num then
		DBGPRINTF("show 2")
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_756, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_757, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_758, false)
		
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_759, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_760, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_761, false)
	elseif 2 == num then
		DBGPRINTF("show 3")
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_756, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_757, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_758, true)
		
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_759, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_760, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_761, false)
	else
		DBGPRINTF("show 3")
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_756, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_757, false)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_758, false)
		
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_759, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_760, true)
		UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_761, true)
	end
end

local BtnClick = function(m)
	local mode = m:GetMode()
	if mode == PetInfo.MODE_IN_TRADE then
		m:SetResult(1)
		m:InputFinished()
	elseif mode == PetInfo.MODE_VIEW_INTRO then
		m:OpenPetEquip()
	else
		local bRet = m:IsTrained()
		if true == bRet then
			-- AI设置
			m.ai = NewAI(m)
			m.ai:WaitUserInput(m)
			local sel, name = m.ai:GetResult()
			local ret = m.ai:GetExit()
			DelAI(m.ai)

			if true == ret then
				m:SetPetAI(sel)
				UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_127, name)
			end
		else
			-- 没驯化过
			m:Train()
			local tag, state = m:InitBtnText()
			UI_Engine.SetText( m.formIndex, UI2_COMPOSIT_127, state)
		end
	end
end

local OnExpand = function(m)
	UpdateIcon(m)
	local num = m:GetGridNum()
	if 3 == num then
		return
	end
	local ptrPack, ptr2 = m:GetFuncFilter()
	m.Pack = NewSelectBag(m, ptrPack, ptr2)
	if nil == m.Pack then
		WarnUser(m, STR_EXPAND_PET_NO_ITEM)
		return
	else
		m.Pack:WaitUserInput(m)
		local item = m.Pack:GetSelectItem()
		local nSn,nNum= m.Pack:GetSelectSimpleItem()
		local code = m.Pack:GetExitCode()
		if code == 0 then 
			DelSelectBag(m.Pack)
			return
		end
		if item ~= nil then
			DBGPRINTF("locate item")
			szExpand = m:MakeExpandString(item)
			if MsgBox.ECODE_YES == QueryUser(m, szExpand) then
				DBGPRINTF("locate item, expand = yes")
				m:ExpandGrid(item)
			end
			DelSelectBag(m.Pack)
			return
		else
			DBGPRINTF("locate SN")
			if nSn==0 then
				DBGPRINTF("locate SN == 0")
				DelSelectBag(m.Pack)
			else
				DBGPRINTF("locate SN != 0")
				szExpand = m:MakeExpandString(nSn)
				if MsgBox.ECODE_YES == QueryUser(m, szExpand) then
					DBGPRINTF("locate SN != 0, expand = yes")
					m:ExpandGrid(nSn)
				end
				DelSelectBag(m.Pack)
			end
		end
	end
	UpdateIcon(m)
end

local OnClickExpand = function(m, index)
	if 0 ~= m:GetMode() then
		m:NewSkillSelect(index)
		return
	end
	local num = m:GetGridNum()
	if index < num then
		m:NewSkillSelect(index)
	else
		OnExpand(m)
	end
end
NEW_FORM_PETCOMPLEX.C50761_OnClick = function( m )
OnClickExpand(m, 2)
end
NEW_FORM_PETCOMPLEX.C50760_OnClick = function( m )
OnClickExpand(m, 1)
end
NEW_FORM_PETCOMPLEX.C50759_OnClick = function( m )
OnClickExpand(m, 0)
end
NEW_FORM_PETCOMPLEX.C50759_OnUpdate = function( m )
UpdateIcon(m)
end
NEW_FORM_PETCOMPLEX.C50758_OnClick = function( m )
OnClickExpand(m, 2)
end
NEW_FORM_PETCOMPLEX.C50757_OnClick = function( m )
OnClickExpand(m, 1)
end
NEW_FORM_PETCOMPLEX.C50756_OnClick = function( m )
OnClickExpand(m, 0)
end
NEW_FORM_PETCOMPLEX.C50756_OnUpdate = function( m )
UpdateIcon(m)
end
NEW_FORM_PETCOMPLEX.C50128_OnClick = function( m )
OnClickExpand(m, -1)
end
NEW_FORM_PETCOMPLEX.C50127_OnClick = function( m )
BtnClick(m)
end
NEW_FORM_PETCOMPLEX.C50124_OnClick = function( m )
local mode = m:GetMode()
if mode == PetInfo.MODE_IN_TRADE then
	m:SetResult(0)
	m:InputFinished()
	m:Close()
else
	m:InputFinished()
	m:Close()
end
end
NEW_FORM_PETCOMPLEX.C50126_OnClick = function( m )
ChangeName(m)
end
NEW_FORM_PETCOMPLEX.C50123_OnLoad = function( m )
local mode, state = m:InitBtnText()
local str = m:GetPetName()
UI_Engine.SetText( m.formIndex, UI2_COMPOSIT_126, str)
if 0 == mode then
	UI_Engine.SetText( m.formIndex, UI2_COMPOSIT_127, state)
elseif 1 == mode then
	UI_Engine.SetText( m.formIndex, UI2_COMPOSIT_127, state)
elseif 2== mode then
	UI_Engine.SetVisible( m.formIndex, UI2_COMPOSIT_127, false )
end
m:GetDrawInfo()
end
NEW_FORM_PETCOMPLEX.C50123_OnDraw = function( m )
m:DrawAni()
end
