FORM_UNION= { }
FORM_UNION.Main = function( m )
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
FORM_UNION.C52483_OnLoad = function( m )
m.isOnline = 0
m.curBuild = 0
m.formType = 0
m.build = 0
m.skill = 0
m.tab = 0
m.text = ""
end
local QueryUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local SetMemberText = function(m, offset, ctlID)   -- 显示会员函数
	local name, job, level, online = m:GetMemberInfo(offset)
	UI_Engine.SetText(m.formIndex, ctlID, name, 0)
	UI_Engine.SetText(m.formIndex, ctlID, job, 1)
	UI_Engine.SetText(m.formIndex, ctlID, level, 2)
	UI_Engine.SetText(m.formIndex, ctlID, online, 3)
end

local LUA_SetChairman = function(m, ctlID)	-- 设置会长
	local name = UI_Engine.GetText(m.formIndex, ctlID)
	m:GetUserClicked(name)
	m:SetChairman()
end

local LUA_SetCDR2 = function(m, ctlID)		-- 设置副会长
	local name = UI_Engine.GetText(m.formIndex, ctlID)
	m:GetUserClicked(name)
	m:SetCDR2()
end

local LUA_SetSolon = function(m, ctlID)		-- 设置议员
	local name = UI_Engine.GetText(m.formIndex, ctlID)
	m:GetUserClicked(name)
	m:SetSolon()
end

local LUA_KickMember = function(m, ctlID)	-- 踢人	
	local name = UI_Engine.GetText(m.formIndex, ctlID)
	m:GetUserClicked(name)
	m:KickMember()
end

local UpdateText = function(m, offset, ctlID)    -- 控件更新中调用此接口
	if 0 == m.isOnline then
		SetMemberText(m, offset, ctlID)   
	else
		local name, job, level, online = m:ShowOnline(offset)
		UI_Engine.SetText(m.formIndex, ctlID, name, 0)
		UI_Engine.SetText(m.formIndex, ctlID, job, 1)
		UI_Engine.SetText(m.formIndex, ctlID, level, 2)
		UI_Engine.SetText(m.formIndex, ctlID, online, 3)
	end
end

local SetControlMode = function(m, mode)
	if true == mode then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2788,true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2789,true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2790,true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2791,true)
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2788,false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2789,false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2790,false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2791,false)
	end
end

local SetBuildText = function(m, type)		-- 设置建设界面文本
	local level = m:GetLevel(type)
	local memberCount = m:GetMemberCount()
	local Total = m:GetTotalBuild(type)
	local exp = m:GetExp(type)
	local fame = m:GetFame()
	local name = m:GetBuildingName(type)

	if 1 == type then
		UI_Engine.SetText(m.formIndex, COMPOSIT_1794, name)
		UI_Engine.SetText(m.formIndex, COMPOSIT_1795, level)
		UI_Engine.SetText(m.formIndex, COMPOSIT_1796, Total)
		UI_Engine.SetText(m.formIndex, COMPOSIT_1797, exp)
	else
		UI_Engine.SetText(m.formIndex, COMPOSIT_1763, level)
		UI_Engine.SetText(m.formIndex, COMPOSIT_1768,memberCount)
		UI_Engine.SetText(m.formIndex, COMPOSIT_1764, Total)
		UI_Engine.SetText(m.formIndex, COMPOSIT_1765, exp)
		UI_Engine.SetText(m.formIndex, COMPOSIT_1766,fame)
		UI_Engine.SetText(m.formIndex, COMPOSIT_1767, name)
	end
end

local SetSkill = function(m)
	local img, level
	img , level , m.skillHelp = m:GetSkillInfo(0)
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_1799, img)
	UI_Engine.SetText(m.formIndex, COMPOSIT_1805, level)

	img , level , m.skillHelp = m:GetSkillInfo(1)
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_1800, img)
	UI_Engine.SetText(m.formIndex, COMPOSIT_1806, level)

	img , level , m.skillHelp = m:GetSkillInfo(2)
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_1801, img)
	UI_Engine.SetText(m.formIndex, COMPOSIT_1809, level)

	img , level , m.skillHelp = m:GetSkillInfo(3)
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_1803, img)
	UI_Engine.SetText(m.formIndex, COMPOSIT_1808, level)

	img , level , m.skillHelp = m:GetSkillInfo(4)
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_1802, img)
	UI_Engine.SetText(m.formIndex, COMPOSIT_1807, level)
end

local OnClickSkill = function(m, nSel)
	local img, level
	img , level , m.skillHelp = m:GetSkillInfo(nSel)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_1788, true)
	if true == m:CanShortCut() then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1787, true)
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1787, false)
	end
	UI_Engine.SetText(m.formIndex, COMPOSIT_1173, m.skillHelp)
	m.text = m.skillHelp
	OnClickTab(m)
end

local SetCountrybute = function(m, nID, offset)
	local name, duty, bute = m:GetMemberCountrybute(offset)
	UI_Engine.SetText(m.formIndex, nID, name, 0)
	UI_Engine.SetText(m.formIndex, nID, duty, 1)
	UI_Engine.SetText(m.formIndex, nID, bute, 2)
end

local SetLog = function(m, nID, offset)
	local time, log = m:UpdateLog(offset)
	UI_Engine.SetText(m.formIndex, nID, time, 0)
	UI_Engine.SetText(m.formIndex, nID, log, 1)
end

local GetInput = function(m)		-- 创建输入框
	m.InputBox = OpenInputBox(m,"",70)
	m.InputBox :WaitUserInput(m)
	local result = m.InputBox :GetResult()
	return result
end

local SetTabListText = function(m,nIndex,composit)
	local text , color= m:DrawOtherInfo(m.offset + nIndex)
	if text== nil then
		DBGPRINTF("SetTabListText  text= null")
		UI_Engine.SetText(m.formIndex,composit,"")
	else
		UI_Engine.SetText(m.formIndex,composit,text , 0,color)
	end
end

local ClickList = function(m, ctlID)
	local name = UI_Engine.GetText(m.formIndex, ctlID)
	m.id, m.duty = m:GetUserClicked(name)
	if m.id ~= nil then
		DBGPRINTF("m.id = "..m.id)
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_SOCIATY_KICK, false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2481, false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1208, false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2394, false)
	end
	local me,myduty = m:GetDutyInfo()
	if me ~= nil then
		DBGPRINTF("selfid "..me)
	end
	if m.id == me then		--点到自己了
		return false
	else
		if nil ~= m.id then
			if -1 == m.duty then
				UI_Engine.SetText(m.formIndex, COMPOSIT_2791, "设为正式")
				return true
			elseif 1 == m.duty then
				UI_Engine.SetText(m.formIndex, COMPOSIT_2791, "设为见习")
				return true
			else
				UI_Engine.SetText(m.formIndex, COMPOSIT_2791, "设为见习")
				return true
			end
		end
	end
end

local SetForm = function(m)
	local me,myduty = m:GetDutyInfo()
	if nil ~= me then
		if -1 == myduty then
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_SOCIATY_KICK, false)
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_2481, false)
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_1208, false)
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_2394, false)
		elseif 1 == myduty then
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_SOCIATY_KICK, false)
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_2481, false)
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_1208, false)
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_2394, false)
		elseif 2 == myduty then
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_SOCIATY_KICK, true)
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_2481, true)
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_1208, false)
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_2394, false)
		elseif 3 == myduty then
			if m.id == me then	-- 设置权限不可对自己操作
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_SOCIATY_KICK, false)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2481, true)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_1208, false)
			else
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_SOCIATY_KICK, true)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2481, true)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_1208, true)
			end
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_2394, true)
		elseif 4 == myduty then
			if m.id == me then
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_SOCIATY_KICK, false)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2481, false)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_1208, false)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2482, false)
			else
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_SOCIATY_KICK, true)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2481, false)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_1208, true)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2482, false)
			end
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_2394, true)
		end
		if m.id == nil then
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_SOCIATY_KICK, false)
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_1208, false)
		end
	end
end

local SetDuty = function(m, mode)
	local me,myduty = m:GetDutyInfo()
	local duty = m:GetSelDuty(m.userSelectItem)
	if nil ~= me then
		if 3 == 	myduty then
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_2790, mode)
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_2791, mode)
		elseif 4 == myduty then
			if 4 == duty then
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2788, false)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2789, mode)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2790, mode)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2791, mode)
			elseif 3 == duty then
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2788, mode)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2789, false)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2790, mode)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2791, mode)
			elseif 2 == duty then
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2788, mode)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2789, mode)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2790, false)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2791, mode)
				if false == m:IsAddCDR2(m.userSelectItem) then
					UI_Engine.SetVisible(m.formIndex, COMPOSIT_2789, false)
				end
			else
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2788, mode)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2789, mode)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2790, mode)
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2791, mode)
				if false == m:IsAddCDR2(m.userSelectItem) then
					UI_Engine.SetVisible(m.formIndex, COMPOSIT_2789, false)
				end
			end
		end
		m:SetMenu(m.userSelectItem)
	end
end

--快捷栏
local UpdateShotrCutItem = function(m,nIndex,control)
	local img = m:GetShortCutIcon(nIndex)
	UI_Engine.SetSurfaceImg( m.formIndex, control, img )
end

local UpdateShotrCut = function(m)
	UpdateShotrCutItem(m,0,COMPOSIT_2585)
	UpdateShotrCutItem(m,1,COMPOSIT_2584)
	UpdateShotrCutItem(m,2,COMPOSIT_2583)
	UpdateShotrCutItem(m,3,COMPOSIT_2582)
	UpdateShotrCutItem(m,4,COMPOSIT_2581)
	UpdateShotrCutItem(m,5,COMPOSIT_2580)
end

local SetShortCutVisible = function(m , bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2586,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2587,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2588,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2589,bDarw)
	
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2580,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2581,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2582,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2583,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2584,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2585,bDarw)
end


local AddShortCut = function(m , nIndex)
	if m.userDragItem == nil then
		return 
	end
	if m.bCheck then
		if m:CanShortCut() == false  then
			WarnUser(m,"无法设置快捷键")
			return 
		end
	end
	m:SetShortCutItem(nIndex, m.userDragItem)
	
	UpdateShotrCut(m)
end



local SetShortTabState=function(m,nIndex)
	if nIndex == 0 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_2586,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_2586,0)
	end
	
	if nIndex == 1 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_2587,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_2587,0)
	end
	
	if nIndex == 2 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_2588,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_2588,0)
	end
	
	if nIndex == 3 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_2589,1)
	else
		UI_Engine.SetState(m.formIndex,COMPOSIT_2589,0)
	end
end

local OnDragShortCut = function(m, nIndex)
	m:GetSel(nIndex)
	m.userDragItem = m:GetShortCutSelectItem()
	m.bCheck = true    --是否检查
end

local DrawButton = function(m)
	if m.bDraw == false then
		m.bDraw = true
		SetShortCutVisible(m, true)
		SetShortTabState(m,0)
		m:LoadShortCutData()
		UpdateShotrCut(m)
		UI_Engine.SetText(m.formIndex, COMPOSIT_1173, "")
	else
		m.bDraw = false
		SetShortCutVisible(m, false)
		m:SaveShortCutData()
		UI_Engine.SetText(m.formIndex, COMPOSIT_1173, m.text)
	end
end

function OnClickTab(m) -- 点击标签
	SetShortCutVisible(m, false)
	UI_Engine.SetText(m.formIndex, COMPOSIT_1173, m.text)
end
FORM_UNION.C52394_OnClick = function( m )
local notice = GetInput(m)
m:ModifyNotice(notice)
end
FORM_UNION.C52368_OnClick = function( m )
m.pack = NewPackage(m, 3)
if nil == m.pack then
	m:Donate()
else
	m.pack:WaitUserInput(m)
	DelPackage(m.pack)
end
end
FORM_UNION.C52482_OnClick = function( m )
local ret = QueryUser(m, "确定离开公会?")
if MsgBox.ECODE_YES == ret then
	m:LeaveUnion()
	m:InputFinished()
end
end
FORM_UNION.C52481_OnClick = function( m )
local ret = QueryUser(m, "确定要辞去公会职务?")
if MsgBox.ECODE_YES == ret then
	m:Resign()
end
end
FORM_UNION.C52788_OnClick = function( m )
m:SetChairman(m.userSelectItem)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2788, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2789, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2790, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2791, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2792, false)
end
FORM_UNION.C52789_OnClick = function( m )
m:SetCDR2(m.userSelectItem)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2788, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2789, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2790, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2791, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2792, false)
end
FORM_UNION.C52790_OnClick = function( m )
m:SetSolon(m.userSelectItem)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2788, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2789, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2790, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2791, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2792, false)
end
FORM_UNION.C52791_OnClick = function( m )
m:SetFormal(m.userSelectItem)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2788, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2789, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2790, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2791, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2792, false)
end
FORM_UNION.C52792_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2788, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2789, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2790, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2791, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2792, false)
end
FORM_UNION.C51213_OnClick = function( m )
DBGPRINTF("lua_info:clicked offset = 0")
end
FORM_UNION.C51214_OnClick = function( m )
m.curBuild = 0
DBGPRINTF("lua_info:clicked offset = 1")
end
FORM_UNION.C51214_OnUpdate = function( m )
local name = m:GetBuildingString(0)
local lv = m:GetLevel(0)
local total = m:GetTotalBuild(0)

UI_Engine.SetText(m.formIndex, COMPOSIT_1214, name, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_1214, "人数", 1)
UI_Engine.SetText(m.formIndex, COMPOSIT_1214, lv, 2)
UI_Engine.SetText(m.formIndex, COMPOSIT_1214, total, 3)
end
FORM_UNION.C51215_OnClick = function( m )
m.curBuild = 1
DBGPRINTF("lua_info:clicked offset = 2")
end
FORM_UNION.C51215_OnUpdate = function( m )
local name = m:GetBuildingString(1)
local lv = m:GetLevel(1)
local total = m:GetTotalBuild(1)

UI_Engine.SetText(m.formIndex, COMPOSIT_1215, name, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_1215, "技能", 1)
UI_Engine.SetText(m.formIndex, COMPOSIT_1215, lv, 2)
UI_Engine.SetText(m.formIndex, COMPOSIT_1215, total, 3)
end
FORM_UNION.C51216_OnClick = function( m )
DBGPRINTF("lua_info:clicked offset = 3")
m.curBuild = 2
end
FORM_UNION.C51216_OnUpdate = function( m )
local name = m:GetBuildingString(2)
local lv = m:GetLevel(2)
local total = m:GetTotalBuild(2)

UI_Engine.SetText(m.formIndex, COMPOSIT_1216, name, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_1216, "任务", 1)
UI_Engine.SetText(m.formIndex, COMPOSIT_1216, lv, 2)
UI_Engine.SetText(m.formIndex, COMPOSIT_1216, total, 3)
end
FORM_UNION.C51251_OnClick = function( m )
DBGPRINTF("lua_info:clicked offset = 4")
end
FORM_UNION.C51159_OnClick = function( m )
m:GetFormType(0)
m.tab = 0
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_1196, "成员")
UI_Engine.UpdateList(m.formIndex, COMPOSIT_1203)
local str = m:GetMaxMember()
m.text = str
UI_Engine.SetText(m.formIndex, COMPOSIT_1173, str, 0)
OnClickTab(m)
end
FORM_UNION.C51160_OnClick = function( m )
m:GetFormType(1)
m.tab = 1
UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetText(m.formIndex, COMPOSIT_1196, "建设")
UI_Engine.UpdateList(m.formIndex, COMPOSIT_1215)
local str = m:GetMoney()
m.text = str
UI_Engine.SetText(m.formIndex, COMPOSIT_1173, str, 0)
OnClickTab(m)
end
FORM_UNION.C51161_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 2)
m.tab = 2
UI_Engine.SetText(m.formIndex, COMPOSIT_1196, "贡献")
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2359)
local str = m:GetMoney()
m.text = str
UI_Engine.SetText(m.formIndex, COMPOSIT_1173, str, 0)
OnClickTab(m)
end
FORM_UNION.C51162_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 3)
m.tab = 3
UI_Engine.SetText(m.formIndex, COMPOSIT_1196, "其它")
OnClickTab(m)
UI_Engine.SetText(m.formIndex, COMPOSIT_1173, "", 0)
end
FORM_UNION.C51163_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 4)
m.tab = 4
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2387)
UI_Engine.SetText(m.formIndex, COMPOSIT_1196, "日志")
OnClickTab(m)
UI_Engine.SetText(m.formIndex, COMPOSIT_1173, "", 0)
end
FORM_UNION.C51164_OnLoad = function( m )
UI_Engine.SetText(m.formIndex, COMPOSIT_SOCIATY_ONLINE, "显示在线")

end
FORM_UNION.C51164_OnClick = function( m )
if 0 == m.isOnline then
	m.isOnline = 1
	UI_Engine.SetText(m.formIndex, COMPOSIT_SOCIATY_ONLINE, "显示全部")
else
	m.isOnline = 0
	UI_Engine.SetText(m.formIndex, COMPOSIT_SOCIATY_ONLINE, "显示在线")

end
UI_Engine.UpdateList(m.formIndex, COMPOSIT_1202)
end
FORM_UNION.C51165_OnClick = function( m )
m:KickMember(m.userSelectItem)
end
FORM_UNION.C51208_OnClick = function( m )
SetDuty(m, true)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2792, true)
end
FORM_UNION.C52757_OnClick = function( m )
m:SaveShortCutData()
m:InputFinished()
end
FORM_UNION.C51195_OnClick = function( m )
m.Money = NewMoneyForm(m)
m.Money:WaitUserInput(m)
local ret = m.Money:GetResult()
DelMoneyForm(m.Money)

if ret ~= -1 then
	m:SendBuildMessage(m.curBuild, ret)
end

end
FORM_UNION.C51192_OnClick = function( m )
if 1 == m.curBuild then
	UI_Engine.SetFormTab(m.formIndex, 6)
	SetBuildText(m, m.curBuild)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_1787, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_1788, false)
	--OnClickSkill(m, 0)
else
	UI_Engine.SetFormTab(m.formIndex, 5)
	SetBuildText(m, m.curBuild)
end
end
FORM_UNION.C52589_OnClick = function( m )
m:SetShortCutTab(3)
SetShortTabState(m,3)
UpdateShotrCut(m)
end
FORM_UNION.C52588_OnClick = function( m )
m:SetShortCutTab(2)
SetShortTabState(m,2)
UpdateShotrCut(m)
end
FORM_UNION.C52587_OnClick = function( m )
m:SetShortCutTab(1)
SetShortTabState(m,1)
UpdateShotrCut(m)
end
FORM_UNION.C52586_OnClick = function( m )
m:SetShortCutTab(0)
SetShortTabState(m,0)
UpdateShotrCut(m)
end
FORM_UNION.C52585_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(0)
m.bCheck = false    --是否检查
end
FORM_UNION.C52585_OnDrop = function( m )
AddShortCut(m, 0)
end
FORM_UNION.C52584_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(1)
m.bCheck = false    --是否检查
end
FORM_UNION.C52584_OnDrop = function( m )
AddShortCut(m, 1)
end
FORM_UNION.C52583_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(2)
m.bCheck = false    --是否检查
end
FORM_UNION.C52583_OnDrop = function( m )
AddShortCut(m, 2)
end
FORM_UNION.C52582_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(3)
m.bCheck = false    --是否检查
end
FORM_UNION.C52582_OnDrop = function( m )
AddShortCut(m, 3)
end
FORM_UNION.C52581_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(4)
m.bCheck = false    --是否检查
end
FORM_UNION.C52581_OnDrop = function( m )
AddShortCut(m, 4)
end
FORM_UNION.C52580_OnDrag = function( m )
m.userDragItem = m:GetShortCutItem(5)
m.bCheck = false    --是否检查
end
FORM_UNION.C52580_OnDrop = function( m )
AddShortCut(m, 5)
end
FORM_UNION.C51201_OnFocus = function( m )
ClickList(m, COMPOSIT_1201)
SetForm(m)
end
FORM_UNION.C51201_OnClick = function( m )
m.ctlID = COMPOSIT_1201
SetForm(m)
ClickList(m, m.ctlID)
end
FORM_UNION.C51201_OnUpdate = function( m )
--[[UI_Engine.SetText(m.formIndex, COMPOSIT_1201, "昵称", 0)
DBGPRINTF("lua_info:Set title OK")
UI_Engine.SetText(m.formIndex, COMPOSIT_1201, "职业", 1)
UI_Engine.SetText(m.formIndex, COMPOSIT_1201, "等级", 2)
UI_Engine.SetText(m.formIndex, COMPOSIT_1201, "状态", 3)
--]]

--SetMemberText(m, m.offset, COMPOSIT_1201) 
UpdateText(m, m.offset, COMPOSIT_1201) 
end
FORM_UNION.C51202_OnClick = function( m )
m.ctlID = COMPOSIT_1202
SetForm(m)
ClickList(m, m.ctlID)
end
FORM_UNION.C51202_OnUpdate = function( m )
--SetMemberText(m, m.offset+1, COMPOSIT_1202) 
UpdateText(m, m.offset+1, COMPOSIT_1202)
ClickList(m, m.ctlID)
SetForm(m)
end
FORM_UNION.C51203_OnClick = function( m )
m.ctlID = COMPOSIT_1203
SetForm(m)
ClickList(m, m.ctlID)
end
FORM_UNION.C51203_OnUpdate = function( m )
--SetMemberText(m, m.offset+2, COMPOSIT_1203) 
UpdateText(m, m.offset+2, COMPOSIT_1203) 
end
FORM_UNION.C51204_OnClick = function( m )
m.ctlID = COMPOSIT_1204
SetForm(m)
ClickList(m, m.ctlID)
end
FORM_UNION.C51204_OnUpdate = function( m )
--SetMemberText(m, m.offset+3, COMPOSIT_1204) 
UpdateText(m, m.offset+3, COMPOSIT_1204) 
end
FORM_UNION.C51205_OnClick = function( m )
m.ctlID = COMPOSIT_1205
SetForm(m)
ClickList(m, m.ctlID)
end
FORM_UNION.C51205_OnUpdate = function( m )
--SetMemberText(m, m.offset+4, COMPOSIT_1205) 
UpdateText(m, m.offset+4, COMPOSIT_1205)
end
FORM_UNION.C51206_OnClick = function( m )
m.ctlID = COMPOSIT_1206
SetForm(m)
ClickList(m, m.ctlID)
end
FORM_UNION.C51206_OnUpdate = function( m )
SetMemberText(m, m.offset+5, COMPOSIT_1206) 
UpdateText(m, m.offset+5, COMPOSIT_1206)
end
FORM_UNION.C51207_OnClick = function( m )
m.ctlID = COMPOSIT_1207
SetForm(m)
ClickList(m, m.ctlID)
end
FORM_UNION.C51207_OnUpdate = function( m )
--SetMemberText(m, m.offset + 6, COMPOSIT_1207)
UpdateText(m, m.offset + 6, COMPOSIT_1207)
end
FORM_UNION.C51781_OnClick = function( m )
local name, ptr = m:GetHelpPtr(m.curBuild)
m.info = NewInfo(m, name, ptr)
end
FORM_UNION.C51788_OnClick = function( m )
m:UpSkill(m.skill)
SetSkill(m)
OnClickTab(m)
end
FORM_UNION.C51787_OnLoad = function( m )
m.bDraw = false
SetShortCutVisible(m, false)
end
FORM_UNION.C51787_OnClick = function( m )
--DrawButton(m)
if true == m:CanShortCut() then
	m.userDragItem = m:GetShortCutSelectItem()
	m.setShortcut = NewSetShortcut(m, m.userDragItem)
	m.setShortcut:WaitUserInput(m)
	DelSetShortcut(m.setShortcut)
end

end
FORM_UNION.C51799_OnClick = function( m )
OnClickSkill(m, 0)
m.skill = 0
end
FORM_UNION.C51799_OnDrag = function( m )
OnDragShortCut(m,0)
end
FORM_UNION.C51800_OnClick = function( m )
OnClickSkill(m, 1)
m.skill = 1
end
FORM_UNION.C51800_OnDrag = function( m )
OnDragShortCut(m,1)
end
FORM_UNION.C51801_OnClick = function( m )
OnClickSkill(m, 2)
m.skill = 2
end
FORM_UNION.C51801_OnDrag = function( m )
OnDragShortCut(m,2)
end
FORM_UNION.C51803_OnClick = function( m )
OnClickSkill(m, 3)
m.skill = 3
end
FORM_UNION.C51803_OnDrag = function( m )
OnDragShortCut(m,3)
end
FORM_UNION.C51802_OnClick = function( m )
OnClickSkill(m, 4)
m.skill = 4
end
FORM_UNION.C51802_OnDrag = function( m )
OnDragShortCut(m,4)
end
FORM_UNION.C51804_OnClick = function( m )
OnClickSkill(m, 5)
m.skill = 5
end
FORM_UNION.C51804_OnDrag = function( m )
OnDragShortCut(m,5)
end
FORM_UNION.C52397_OnUpdate = function( m )
SetTabListText(m, 0, COMPOSIT_2397)
end
FORM_UNION.C52398_OnUpdate = function( m )
SetTabListText(m, 1, COMPOSIT_2398)
end
FORM_UNION.C52399_OnUpdate = function( m )
SetTabListText(m, 2, COMPOSIT_2399)
end
FORM_UNION.C52400_OnUpdate = function( m )
SetTabListText(m, 3, COMPOSIT_2400)
end
FORM_UNION.C52401_OnUpdate = function( m )
SetTabListText(m, 4, COMPOSIT_2401)
end
FORM_UNION.C52402_OnUpdate = function( m )
SetTabListText(m,5 , COMPOSIT_2402)
end
FORM_UNION.C52403_OnUpdate = function( m )
SetTabListText(m, 6, COMPOSIT_2403)
end
FORM_UNION.C52404_OnUpdate = function( m )
SetTabListText(m, 7, COMPOSIT_2404)
end
FORM_UNION.C52405_OnUpdate = function( m )
SetTabListText(m, 8, COMPOSIT_2405)
end
FORM_UNION.C52406_OnUpdate = function( m )
SetTabListText(m, 9, COMPOSIT_2406)
end
FORM_UNION.C52358_OnUpdate = function( m )
SetCountrybute(m, COMPOSIT_2358, m.offset)
end
FORM_UNION.C52359_OnUpdate = function( m )
SetCountrybute(m, COMPOSIT_2359, m.offset+1)
end
FORM_UNION.C52360_OnUpdate = function( m )
SetCountrybute(m, COMPOSIT_2360, m.offset+2)
end
FORM_UNION.C52361_OnUpdate = function( m )
SetCountrybute(m, COMPOSIT_2361, m.offset+3)
end
FORM_UNION.C52362_OnUpdate = function( m )
SetCountrybute(m, COMPOSIT_2362, m.offset+4)
end
FORM_UNION.C52363_OnUpdate = function( m )
SetCountrybute(m, COMPOSIT_2363, m.offset+5)
end
FORM_UNION.C52364_OnUpdate = function( m )
SetCountrybute(m, COMPOSIT_2364, m.offset+7)
end
FORM_UNION.C52365_OnUpdate = function( m )
SetCountrybute(m, COMPOSIT_2365, m.offset+8)
end
FORM_UNION.C52385_OnUpdate = function( m )
SetLog(m, COMPOSIT_2385, m.offset)
end
FORM_UNION.C52386_OnUpdate = function( m )
SetLog(m, COMPOSIT_2386, m.offset+1)
end
FORM_UNION.C52387_OnUpdate = function( m )
SetLog(m, COMPOSIT_2387, m.offset+2)
end
FORM_UNION.C52388_OnUpdate = function( m )
SetLog(m, COMPOSIT_2388, m.offset+3)
end
FORM_UNION.C52389_OnUpdate = function( m )
SetLog(m, COMPOSIT_2389, m.offset+4)
end
FORM_UNION.C52390_OnUpdate = function( m )
SetLog(m, COMPOSIT_2390, m.offset+5)
end
FORM_UNION.C51172_OnLoad = function( m )
SetSkill(m)
ClickList(m, COMPOSIT_1201)
SetForm(m)
local str = m:GetMaxMember()
UI_Engine.SetText(m.formIndex, COMPOSIT_1173, str, 0)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_SOCIATY_KICK, false)
UI_Engine.SetVisible(m.formIndex, 1208, false)
end
