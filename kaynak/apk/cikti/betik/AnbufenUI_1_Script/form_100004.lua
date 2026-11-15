NEW_FORM_LIVESKILL= { }
NEW_FORM_LIVESKILL.Main = function( m )
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

local WarnUser = function(m, str)             --单项对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_CANCEL)
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

local SetListText = function(m,nIndex,composit)
	local img,name,leave = m:GetSkillInfo(m.offset + nIndex)
	UI_Engine.SetSurfaceImg( m.formIndex, composit, img ,0 )
	UI_Engine.SetText(m.formIndex,composit,name,1)
	UI_Engine.SetText(m.formIndex,composit,leave,2)
	--[
	if name ~= nil then
		UI_Engine.SetVisible(m.formIndex,composit,true)
		UI_Engine.SetSurfaceImg( m.formIndex, composit, img ,0 )
		UI_Engine.SetText(m.formIndex,composit,name,1)
		UI_Engine.SetText(m.formIndex,composit,leave,2)
	else
		UI_Engine.SetVisible(m.formIndex,composit,false)
	end
	--]
end

local ClickMenu = function(m,nType)
	if nType == LiveSkillMenu.E_MENU_USE then
		local nType1 = m:ProfessionType()
		if nType1 == ProfessionType.EGathering then
			return 
		elseif nType1 == ProfessionType.EProduction then
			local vFormula,size = m:GetFormulaForSkill()
			if size == 0 then
				WarnUser(m,STR_NOHAVE_FORMULA)
			else
				m.Popup = NewPopUpForm(m, vFormula)
				m.Popup :WaitUserInput(m)
				local nSelect = m.Popup:GetResult()
				DelPopUpForm(m.Popup )
				if nSelect ~= -1 then
					m:SetSelTemp(nSelect)
					local img,str,pinfo,sn = m:GetFormulaInfo(nSelect)
					m.info = NewItemInfo(m,img,str,pinfo,sn)
					m.info:WaitUserInput(m)
					local exit = m.info:GetResult()
					DelItemInfo(m.info)
					if exit ~= 0 then
						m:Production()
					end
				end
			end
			
		elseif nType1 == ProfessionType.ESplit then   --分解
			local bEnough = m:IsNeedItemEnough()
			if bEnough == false then
				return 
			end
			local itemMgr ,fun = m:GetCreateAdvSelect()
			m.package = NewSelectBag(m, itemMgr,fun)
			
			--m.package = NewPackage(m,fun , m)           --打开背包

			if m.package == nil then
				WarnUser(m, STR_NOHAVE_SPLITITEM)
				return
			end
			
			m.package:WaitUserInput(m)
			local vSelect = m.package:GetSelectItem()
			local nSn, nNum = m.package:GetSelectSimpleItem()
			DelPackage(m.package )
			m:OnPackageClose(vSelect ,nSn,nNum)
		end
	elseif nType == LiveSkillMenu.E_MENU_SETKEY then --快捷栏
		local shortcutinfo = m:MakeShortCutInfo()
		m.ShortCut = NewSetShortcut(m,shortcutinfo)
		m.ShortCut:WaitUserInput(m)
		DelSetShortcut(m.ShortCut)
		return 
	elseif nType == LiveSkillMenu.E_MENU_REGAIN then  --取消遗忘
		m:Regain()
	elseif nType == LiveSkillMenu.E_MENU_FORGET then		--遗忘
		if QueryUser(m,STR_ISFORGET_LIVESKILL) == MsgBox.ECODE_YES then
			m:Forget()
		end
	elseif nType == LiveSkillMenu.E_MENU_PRODUCTION then   --生产
		--m:Production()
		return
	end
	
	m:SetSel(m.userSelectItem)
	UI_Engine.UpdateList(m.formIndex ,UI1_COMPOSIT_LIVESKILL_1)
end

local ShowInfo = function(m)
	m:SetSel(m.userSelectItem)
	local img,str,pinfo,sn = m:GetInfo()
	m.info = NewItemInfo(m,img,str,pinfo,sn)
	m.info:WaitUserInput(m)
	local exit = m.info:GetResult()
	DelItemInfo(m.info)
	local MenuIndex = exit - 1
	if MenuIndex  < 0 then
		return
	end
	local nType = m:DoMenu(MenuIndex)
	ClickMenu(m,nType)
end
NEW_FORM_LIVESKILL.C50083_OnClick = function( m )
m:Close(-1)
m:InputFinished()
end
NEW_FORM_LIVESKILL.C50075_OnClick = function( m )
ShowInfo(m)
end
NEW_FORM_LIVESKILL.C50075_OnUpdate = function( m )
SetListText(m,0,UI1_COMPOSIT_LIVESKILL_0)
end
NEW_FORM_LIVESKILL.C50076_OnClick = function( m )
ShowInfo(m)
end
NEW_FORM_LIVESKILL.C50076_OnUpdate = function( m )
SetListText(m,1,UI1_COMPOSIT_LIVESKILL_1)
end
NEW_FORM_LIVESKILL.C50077_OnClick = function( m )
ShowInfo(m)
end
NEW_FORM_LIVESKILL.C50077_OnUpdate = function( m )
SetListText(m,2,UI1_COMPOSIT_LIVESKILL_2)
end
NEW_FORM_LIVESKILL.C50078_OnClick = function( m )
ShowInfo(m)
end
NEW_FORM_LIVESKILL.C50078_OnUpdate = function( m )
SetListText(m,3,UI1_COMPOSIT_LIVESKILL_3)
end
NEW_FORM_LIVESKILL.C50079_OnClick = function( m )
ShowInfo(m)
end
NEW_FORM_LIVESKILL.C50079_OnUpdate = function( m )
SetListText(m,4,UI1_COMPOSIT_LIVESKILL_4)
end
NEW_FORM_LIVESKILL.C50080_OnClick = function( m )
ShowInfo(m)
end
NEW_FORM_LIVESKILL.C50080_OnUpdate = function( m )
SetListText(m,5,UI1_COMPOSIT_LIVESKILL_5)
end
NEW_FORM_LIVESKILL.C50081_OnClick = function( m )
ShowInfo(m)
end
NEW_FORM_LIVESKILL.C50081_OnUpdate = function( m )
SetListText(m,6,UI1_COMPOSIT_LIVESKILL_6)
end
NEW_FORM_LIVESKILL.C50344_OnClick = function( m )
m:Close(0)
m:InputFinished()
end
NEW_FORM_LIVESKILL.C50345_OnClick = function( m )
m:Close(1)
m:InputFinished()
end
NEW_FORM_LIVESKILL.C50346_OnClick = function( m )
m:Close(2)
m:InputFinished()
end
NEW_FORM_LIVESKILL.C50347_OnClick = function( m )
m:Close(3)
m:InputFinished()
end
NEW_FORM_LIVESKILL.C50348_OnClick = function( m )
m:Close(4)
m:InputFinished()
end
