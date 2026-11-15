FORM_LIVESKILL= { }
FORM_LIVESKILL.Main = function( m )
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
end

local UpDateDecribe = function(m)
	local Decribe = m:GetDescribe(m.userSelectItem)
	UI_Engine.SetText(m.formIndex,COMPOSIT_1903,Decribe)
end

local UpDateTitle = function(m)
	if m:IsFormula() then
		UI_Engine.SetText(m.formIndex,COMPOSIT_2626,"配方")
		UI_Engine.SetText(m.formIndex,COMPOSIT_2625,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_2626,"生活技能")
		UI_Engine.SetText(m.formIndex,COMPOSIT_2625,"等级")
	end
end

local UpDateExit = function(m)
	if m:IsFormula() then
		UI_Engine.SetText(m.formIndex,COMPOSIT_1908,"返回")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_1908,"退出")
	end
end

local UpDateMenu = function(m)
	local name,name1,name2,name3 = m:GetMenu()
	if name ~= nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_2504,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_2504,name)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_2504,false)
	end
	
	if name1 ~= nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_2500,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_2500,name1)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_2500,false)
	end
	
	if name2 ~= nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_1907,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_1907,name2)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_1907,false)
	end
	
	if name3 == nil then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_2501,false)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_2501,true)
		UI_Engine.SetText(m.formIndex,COMPOSIT_2501,name3)
	end

end

local ClickMenu = function(m,nType)
	if nType == LiveSkillMenu.E_MENU_USE then
		local nType1 = m:ProfessionType()
		if nType1 == ProfessionType.EGathering then
			return 
		elseif nType1 == ProfessionType.EProduction then
			m:GetFormulaForSkill()
			m:SetFormula(true)
			m:SetSelTemp(m.userSelectItem)
		elseif nType1 == ProfessionType.ESplit then   --分解
			local bEnough = m:IsNeedItemEnough()
			if bEnough == false then
				return 
			end
			local itemMgr ,fun = m:GetCreateAdvSelect()
			
			m.package = NewPackage(m,fun , m)           --打开背包

			if m.package == nil then
				WarnUser(m, "没有需要分解的物品")
				return
			end
			
			m.package:WaitUserInput(m)
			local vSelect = m.package:GetSelectItem()
			local nSn, nNum = m.package:GetSelectSimpleItem()
			DelPackage(m.package )
			m:OnPackageClose(vSelect ,nSn,nNum)
		end
		
	elseif nType == LiveSkillMenu.E_MENU_SETKEY then --快捷栏  没有这个功能
		return 
	elseif nType == LiveSkillMenu.E_MENU_REGAIN then  --取消遗忘
		m:Regain()
	elseif nType == LiveSkillMenu.E_MENU_FORGET then		--遗忘
		if QueryUser(m,"是否将此技能遗忘") == MsgBox.ECODE_YES then
			m:Forget()
		end
	elseif nType == LiveSkillMenu.E_MENU_PRODUCTION then   --生产
		m:Production()
	elseif nType == LiveSkillMenu.E_MENU_DETAIL then       --详细
		local name, pinfo = m:GetInfo()
		if name ~= nil and pinfo ~= nil  then
			m.info = NewInfo(m,name,pinfo)
			m.info:WaitUserInput(m)
			DelInfo(m.info)
		end
	end
	
	m:SetSel(m.userSelectItem)
	UI_Engine.UpdateList(m.formIndex ,COMPOSIT_2634)
	UpDateTitle(m)
	UpDateDecribe(m)
	UpDateMenu(m)
	UpDateExit(m)
end
FORM_LIVESKILL.C52755_OnClick = function( m )
if m:IsFormula() then
	m:SetFormula(false)
	m:SetSel(m.userSelectItem)
	UpDateDecribe(m)
	UpDateMenu(m)
	UpDateTitle(m)
	UI_Engine.ResetList(m.formIndex)
	UI_Engine.UpdateList(m.formIndex ,COMPOSIT_2634)
	UpDateExit(m)
else
	DelLiveSkill(m)
end
end
FORM_LIVESKILL.C52625_OnLoad = function( m )
UpDateDecribe(m)
UpDateTitle(m)
m:SetSel(m.userSelectItem)
UpDateMenu(m)

end
FORM_LIVESKILL.C52634_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpDateDecribe(m)
UpDateMenu(m)
end
FORM_LIVESKILL.C52634_OnUpdate = function( m )
SetListText(m,0,COMPOSIT_2634)
end
FORM_LIVESKILL.C52633_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpDateDecribe(m)
UpDateMenu(m)
end
FORM_LIVESKILL.C52633_OnUpdate = function( m )
SetListText(m,1,COMPOSIT_2633)
end
FORM_LIVESKILL.C52632_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpDateDecribe(m)
UpDateMenu(m)
end
FORM_LIVESKILL.C52632_OnUpdate = function( m )
SetListText(m,2,COMPOSIT_2632)
end
FORM_LIVESKILL.C52631_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpDateDecribe(m)
UpDateMenu(m)
end
FORM_LIVESKILL.C52631_OnUpdate = function( m )
SetListText(m,3,COMPOSIT_2631)
end
FORM_LIVESKILL.C52630_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpDateDecribe(m)
UpDateMenu(m)
end
FORM_LIVESKILL.C52630_OnUpdate = function( m )
SetListText(m,4,COMPOSIT_2630)
end
FORM_LIVESKILL.C52629_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpDateDecribe(m)
UpDateMenu(m)
end
FORM_LIVESKILL.C52629_OnUpdate = function( m )
SetListText(m,5,COMPOSIT_2629)
end
FORM_LIVESKILL.C52628_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpDateDecribe(m)
UpDateMenu(m)
end
FORM_LIVESKILL.C52628_OnUpdate = function( m )
SetListText(m,6,COMPOSIT_2628)
end
FORM_LIVESKILL.C52627_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpDateDecribe(m)
UpDateMenu(m)
end
FORM_LIVESKILL.C52627_OnUpdate = function( m )
SetListText(m,7,COMPOSIT_2627)
end
FORM_LIVESKILL.C52504_OnClick = function( m )
local nType = m:DoMenu(0)
ClickMenu(m,nType)

end
FORM_LIVESKILL.C52500_OnClick = function( m )

local nType = m:DoMenu(1)
ClickMenu(m,nType)
end
FORM_LIVESKILL.C51907_OnClick = function( m )
local nType = m:DoMenu(2)
ClickMenu(m,nType)
end
FORM_LIVESKILL.C52501_OnClick = function( m )
local nType = m:DoMenu(3)
ClickMenu(m,nType)
end
