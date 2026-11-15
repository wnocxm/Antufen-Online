FORM_SKILLTREE= { }
FORM_SKILLTREE.Main = function( m )
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
FORM_SKILLTREE.C52693_OnClick = function( m )
m:SaveShortCutData()
m:InputFinished()
DelSkillTree(m)
end
local QueryUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local HideControl = function(m)
	for i = 0, 21 do
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_SKILL_11+i, false)
	end
end

local WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_CANCEL)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local DrawSkill = function(m, nID, nType)
	local img,gray = m:GetDrawInfo(nID, nType)
	if nil == img then
		return false
	else
		if gray== false then
			DBGPRINTF("val of gray is false")
			UI_Engine.SetSurfaceImg(m.formIndex, nID, img, 0, 0, true)
		else
			DBGPRINTF("val of gray is true")
			UI_Engine.SetSurfaceImg(m.formIndex, nID, img)
		end
		return true
	end
end

local UpdateList = function(m)
	DrawSkill(m, COMPOSIT_SKILL_11, 1)
	DrawSkill(m, COMPOSIT_SKILL_12, 2)
	DrawSkill(m, COMPOSIT_SKILL_13, 3)
	DrawSkill(m, COMPOSIT_SKILL_21, 1)
	DrawSkill(m, COMPOSIT_SKILL_22, 2)
	DrawSkill(m, COMPOSIT_SKILL_23, 3)
	DrawSkill(m, COMPOSIT_SKILL_31, 1)
	DrawSkill(m, COMPOSIT_SKILL_32, 2)
	DrawSkill(m, COMPOSIT_SKILL_33, 3)
	DrawSkill(m, COMPOSIT_SKILL_41, 1)
	DrawSkill(m, COMPOSIT_SKILL_42, 2)
	DrawSkill(m, COMPOSIT_SKILL_43, 3)
	DrawSkill(m, COMPOSIT_SKILL_51, 1)
	DrawSkill(m, COMPOSIT_SKILL_52, 2)
	DrawSkill(m, COMPOSIT_SKILL_53, 3)
	DrawSkill(m, COMPOSIT_SKILL_61, 1)
	DrawSkill(m, COMPOSIT_SKILL_62, 2)
	DrawSkill(m, COMPOSIT_SKILL_63, 3)
	DrawSkill(m, COMPOSIT_SKILL_71, 1)
	DrawSkill(m, COMPOSIT_SKILL_72, 3)
	DrawSkill(m, COMPOSIT_SKILL_73, 3)
end

local SetControl = function(m, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2586, mode)
	if true == mode then
		if true == m:CanShortCut() then
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_1712, true)
		else
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_1712, false)
		end
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1712, false)
	end
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_SKILLTREE_ENSURE, mode)
end

function OnClick(m, ctlID) -- 点击技能图标
	local n_CurSel = m:OnClickSkill(ctlID)
	m.title, m.info = m:OnDrawHelp()
	m.text = m:GetContent()
	UI_Engine.SetText(m.formIndex, COMPOSIT_SKILLTREE_HELP, m.text)
	DBGPRINTF("luaInfo:ID of control is:"..ctlID)
	--if m.bDraw == true then
	--UI_Engine.SetText(m.formIndex, COMPOSIT_SKILLTREE_HELP, "")
	--end
	SetControl(m, true)
end

function UpgradeInfo(m) -- 确定技能是否满足升级条件
	local b_isHaveSP, sz_text = m:IsHaveSkillPoint()
	if false == b_isHaveSP then
		UI_Engine.SetText(m.formIndex, COMPOSIT_SKILLTREE_HELP, sz_text)
		return false
	end
	
	if true == m:IsNeedReqSkillTree() then
		if true == m:IsNotUpgradeReqTree(m) then -- 如果没学前置技能树
			return false
		else
			local b_isTotal, sz_text = m:IsAccReqSkillTreeTotal(m)
			if false == b_isTotal then 
				UI_Engine.SetText(m.formIndex, COMPOSIT_SKILLTREE_HELP, sz_text)
				return false
			end
		end
	end
	
	if false == m:IsNeedReqSkill() then 
		if false == m:IsAccPeopleLevel() then
			return false
		end
	else -- 有前置技能
		local b_result, sz_text = m:IsExistSkillBook()
		if false == b_result then
			return false
		else 
			if false == m:IsAccPeopleLevel() then
				return false
			end
		end
	end
	
	return true
end

function UpgradeSP(m) -- 升级技能
	if true == UpgradeInfo(m) then
		m:SendModifySkillInfo()
	end
end




---快捷栏
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
--快捷栏
local UpdateShotrCutItem = function(m,nIndex,control)
	local img = m:GetShortCutIcon(nIndex)
	UI_Engine.SetSurfaceImg( m.formIndex, control, img )
end

local UpdateShotrCut = function(m)
	UpdateShotrCutItem(m,0,COMPOSIT_1706)
	UpdateShotrCutItem(m,1,COMPOSIT_1707)
	UpdateShotrCutItem(m,2,COMPOSIT_1708)
	UpdateShotrCutItem(m,3,COMPOSIT_1709)
	UpdateShotrCutItem(m,4,COMPOSIT_1710)
	UpdateShotrCutItem(m,5,COMPOSIT_1711)
end

local SetShortCutVisible = function(m , bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1702,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1703,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1704,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1705,bDarw)
	
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1706,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1707,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1708,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1709,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1710,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1711,bDarw)
end


local AddShortCut = function(m , nIndex)
	if m.userDragItem == nil then
		return 
	end
	if m.bCheck then
		if m:CanShortCut() == false  then
			WarnUser(m,"此技能不能设置快捷栏")
			return 
		end
	end
	m:SetShortCutItem(nIndex, m.userDragItem)
	
	UpdateShotrCut(m)
end



local SetShortTabState=function(m,nIndex)
	if nIndex == 0 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_1702,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_1702,0)
	end
	
	if nIndex == 1 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_1703,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_1703,0)
	end
	
	if nIndex == 2 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_1704,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_1704,0)
	end
	
	if nIndex == 3 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_1705,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_1705,0)
	end
end

local OnDragShortCut = function(m, nIndex)
	m:SelectItem(nIndex)
	m.userDragItem = m:GetShortCutSelectItem()
	m.bCheck = true    --是否检查
end

local DrawSkillNum = function(m, nID)
	local ret = m:GetSkillNum(nID)
	if ret ~= nil then
		DBGPRINTF("ret ="..ret)
		CurrentControl.SetItemCount(ret)
	end
end

FORM_SKILLTREE.C52931_OnClick = function( m )
m:OnClickTab(0)
HideControl(m)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_SKILL_12)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2586, false)
UI_Engine.SetText(m.formIndex, COMPOSIT_SKILLTREE_HELP, "")
SetControl(m, false)
end
FORM_SKILLTREE.C52932_OnClick = function( m )
m:OnClickTab(1)
HideControl(m)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_SKILL_12)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2586, false)
UI_Engine.SetText(m.formIndex, COMPOSIT_SKILLTREE_HELP, "")
SetControl(m, false)
end
FORM_SKILLTREE.C52933_OnClick = function( m )
m:OnClickTab(2)
HideControl(m)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_SKILL_12)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2586, false)
UI_Engine.SetText(m.formIndex, COMPOSIT_SKILLTREE_HELP, "")
SetControl(m, false)
end
FORM_SKILLTREE.C52934_OnClick = function( m )
m:OnClickTab(3)
HideControl(m)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_SKILL_12)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2586, false)
UI_Engine.SetText(m.formIndex, COMPOSIT_SKILLTREE_HELP, "")
SetControl(m, false)
end
FORM_SKILLTREE.C52935_OnClick = function( m )
m:OnClickTab(4)
HideControl(m)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_SKILL_12)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2586, false)
UI_Engine.SetText(m.formIndex, COMPOSIT_SKILLTREE_HELP, "")
SetControl(m, false)
end
FORM_SKILLTREE.C50250_OnClick = function( m )
--m:OnClickLRFunction(0)
--UpgradeSP(m)
m:SendModifySkillInfo()
end
FORM_SKILLTREE.C52586_OnClick = function( m )
local title, info = m:GetHelpStr()
NewInfoText(m, title, info)
end
FORM_SKILLTREE.C52485_OnClick = function( m )
local ret = m:IsCanClear()
if true == ret then
	if MsgBox.ECODE_YES == QueryUser(m, "确定要清洗技能点?") then
		m:ClearSkill()
	end
else
	WarnUser(m, "缺少洗点道具!")
end
	
end
FORM_SKILLTREE.C51712_OnLoad = function( m )
m.bDraw = false
SetShortCutVisible(m, false)
end
FORM_SKILLTREE.C51712_OnClick = function( m )
--[[if m.bDraw == false then
	m.bDraw = true
	SetShortCutVisible(m, true)
	SetShortTabState(m,0)
	m:LoadShortCutData()
	UpdateShotrCut(m)
	UI_Engine.SetText(m.formIndex, COMPOSIT_SKILLTREE_HELP, "")
else
	m.bDraw = false
	SetShortCutVisible(m, false)
	m:SaveShortCutData()
	UI_Engine.SetText(m.formIndex, COMPOSIT_SKILLTREE_HELP, m.text)
end
--]]
if true == m:CanShortCut() then
	m.userDragItem = m:GetShortCutSelectItem()
	m.setShortcut = NewSetShortcut(m, m.userDragItem)
	m.setShortcut:WaitUserInput(m)
	DelSetShortcut(m.setShortcut)
end
	
end
FORM_SKILLTREE.C51702_OnClick = function( m )
m:SetShortCutTab(0)
SetShortTabState(m,0)
UpdateShotrCut(m)
end
FORM_SKILLTREE.C51703_OnClick = function( m )
m:SetShortCutTab(1)
SetShortTabState(m,1)
UpdateShotrCut(m)
end
FORM_SKILLTREE.C51704_OnClick = function( m )
m:SetShortCutTab(2)
SetShortTabState(m,2)
UpdateShotrCut(m)
end
FORM_SKILLTREE.C51705_OnClick = function( m )
m:SetShortCutTab(3)
SetShortTabState(m,3)
UpdateShotrCut(m)
end
FORM_SKILLTREE.C51706_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(0)
m.bCheck = false    --是否检查
end
FORM_SKILLTREE.C51706_OnDrop = function( m )
AddShortCut(m, 0)
end
FORM_SKILLTREE.C51707_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(1)
m.bCheck = false    --是否检查
end
FORM_SKILLTREE.C51707_OnDrop = function( m )
AddShortCut(m,1)
end
FORM_SKILLTREE.C51708_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(2)
m.bCheck = false    --是否检查
end
FORM_SKILLTREE.C51708_OnDrop = function( m )
AddShortCut(m, 2)
end
FORM_SKILLTREE.C51709_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(3)
m.bCheck = false    --是否检查
end
FORM_SKILLTREE.C51709_OnDrop = function( m )
AddShortCut(m, 3)
end
FORM_SKILLTREE.C51710_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(4)
m.bCheck = false    --是否检查
end
FORM_SKILLTREE.C51710_OnDrop = function( m )
AddShortCut(m, 4)
end
FORM_SKILLTREE.C51711_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(5)
m.bCheck = false    --是否检查
end
FORM_SKILLTREE.C51711_OnDrop = function( m )
AddShortCut(m, 5)
end
FORM_SKILLTREE.C50844_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_11)
end
FORM_SKILLTREE.C50844_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_11)
end
FORM_SKILLTREE.C50844_OnUpdate = function( m )
local ret,draw = m:GetSkillNum(COMPOSIT_SKILL_11)
if ret ~= nil then
	if draw then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw then
		CurrentControl.SetItemCount(0)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50845_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_12)

end
FORM_SKILLTREE.C50845_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_12)
end
FORM_SKILLTREE.C50845_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_12)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50846_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_13)
end
FORM_SKILLTREE.C50846_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_13)
end
FORM_SKILLTREE.C50846_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_13)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50847_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_21)

end
FORM_SKILLTREE.C50847_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_21)
end
FORM_SKILLTREE.C50847_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_21)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50848_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_22)

end
FORM_SKILLTREE.C50848_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_22)
end
FORM_SKILLTREE.C50848_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_22)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50849_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_23)

end
FORM_SKILLTREE.C50849_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_23)
end
FORM_SKILLTREE.C50849_OnUpdate = function( m )
UpdateList(m)
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_23)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50850_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_31)

end
FORM_SKILLTREE.C50850_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_31)
end
FORM_SKILLTREE.C50850_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_31)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50851_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_32)

end
FORM_SKILLTREE.C50851_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_32)
end
FORM_SKILLTREE.C50851_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_32)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50852_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_33)

end
FORM_SKILLTREE.C50852_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_33)
end
FORM_SKILLTREE.C50852_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_33)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50853_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_41)

end
FORM_SKILLTREE.C50853_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_41)
end
FORM_SKILLTREE.C50853_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_41)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50854_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_42)

end
FORM_SKILLTREE.C50854_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_42)
end
FORM_SKILLTREE.C50854_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_42)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50855_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_43)

end
FORM_SKILLTREE.C50855_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_43)
end
FORM_SKILLTREE.C50855_OnUpdate = function( m )
local ret,draw = m:GetSkillNum(COMPOSIT_SKILL_43)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50856_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_51)

end
FORM_SKILLTREE.C50856_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_51)
end
FORM_SKILLTREE.C50856_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_51)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50857_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_52)

end
FORM_SKILLTREE.C50857_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_52)
end
FORM_SKILLTREE.C50857_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_52)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50858_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_53)

end
FORM_SKILLTREE.C50858_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_53)
end
FORM_SKILLTREE.C50858_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_53)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50859_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_61)

end
FORM_SKILLTREE.C50859_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_61)
end
FORM_SKILLTREE.C50859_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_61)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50860_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_62)

end
FORM_SKILLTREE.C50860_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_62)
end
FORM_SKILLTREE.C50860_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_62)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50861_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_63)
end
FORM_SKILLTREE.C50861_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_63)
end
FORM_SKILLTREE.C50861_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_63)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50862_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_71)

end
FORM_SKILLTREE.C50862_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_71)
end
FORM_SKILLTREE.C50862_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_71)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50863_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_72)
end
FORM_SKILLTREE.C50863_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_72)
end
FORM_SKILLTREE.C50863_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_72)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50864_OnClick = function( m )
OnClick(m, COMPOSIT_SKILL_73)

end
FORM_SKILLTREE.C50864_OnDrag = function( m )
OnDragShortCut(m,COMPOSIT_SKILL_73)
end
FORM_SKILLTREE.C50864_OnUpdate = function( m )
local ret, draw = m:GetSkillNum(COMPOSIT_SKILL_73)
if ret ~= nil then
	if draw== true then
		CurrentControl.SetItemCount(ret)
	else
		CurrentControl.SetItemCount(-1)
	end
else
	if draw== true then
		CurrentControl.SetItemCount(-1)
	else
		CurrentControl.SetItemCount(-1)
	end
end
end
FORM_SKILLTREE.C50307_OnDraw = function( m )
local point = m:OnDrawSkillPoint()
UI_Engine.SetText(m.formIndex,COMPOSIT_SKILLTREE_POINTUP,point,0)
end
FORM_SKILLTREE.C50866_OnLoad = function( m )
local tx, ty, bx, by = UI_Engine.GetClientRect(m.formIndex, COMPOSIT_SKILLTREE_RECT)
UI_Engine.SetContainerRect(m.formIndex, COMPOSIT_SKILL_11, tx, ty, bx, by)
UI_Engine.SetEnableMove(m.formIndex, COMPOSIT_SKILL_11, true)
end
FORM_SKILLTREE.C50842_OnLoad = function( m )
HideControl(m)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_SKILL_12)
SetControl(m, false)
end
