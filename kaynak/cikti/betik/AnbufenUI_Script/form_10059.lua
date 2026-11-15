FORM_TASK_SHOW= { }
FORM_TASK_SHOW.Main = function( m )
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




local SetTabListText = function(m,nIndex,composit)
	DBGPRINTF("SetTab1ListText begin ==="..composit)
	local strName,strPrice = m:GetListText(m.offset + nIndex)

	if strName == nil then
		UI_Engine.SetText(m.formIndex,composit,"",0)
		DBGPRINTF("SetTab1ListText strName ===null" )
	else
		UI_Engine.SetText(m.formIndex,composit,strName,0)
		DBGPRINTF("SetTab1ListText strName "..strName )
	end

	if strPrice == nil then
		UI_Engine.SetText(m.formIndex,composit,"",1)
		DBGPRINTF("SetTab1ListText strPrice===null")
	else
		UI_Engine.SetText(m.formIndex,composit,strPrice,1)
		DBGPRINTF("SetTab1ListText strPrice"..strPrice)
	end

end

local upDataDescribe = function(m)
	local strDescribe = m:GetDescribe(m.userSelectItem)
	if strDescribe == nil then
		DBGPRINTF("upDataDescribe  strDescribe = nil ")
		UI_Engine.SetText(m.formIndex,COMPOSIT_1597,"")
	else
		DBGPRINTF("upDataDescribe  strDescribe = "..strDescribe)
		UI_Engine.SetText(m.formIndex,COMPOSIT_1597,strDescribe)
	end
end

local UpData = function(m,nTab)
	if nTab == CustomTaskTab.TAB_ALL then
		DBGPRINTF("nTab == TAB_ALL  ")
		UI_Engine.UpdateList(m.formIndex ,COMPOSIT_1615)
		UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1604,false)
	elseif nTab == CustomTaskTab.TAB_ACCEPTED then
		UI_Engine.UpdateList(m.formIndex ,COMPOSIT_1623)
		UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1604,true)
		DBGPRINTF("nTab == TAB_ACCEPTED  ")
	elseif nTab == CustomTaskTab.TAB_MY then
		DBGPRINTF("nTab == TAB_MY  ")
		UI_Engine.UpdateList(m.formIndex ,COMPOSIT_1631)
		UI_Engine.SetVisible(m.formIndex ,COMPOSIT_1604,true)
	end
	
	local strTitle = m:GetTitle()
	if strTitle  ==nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_1607,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_1607,strTitle )
	end
	
	upDataDescribe(m)
	
end
FORM_TASK_SHOW.C51607_OnLoad = function( m )
DBGPRINTF("Onload tab Info AAAA")
m:SetSel(m.userSelectItem)
m:SetTab(CustomTaskTab.TAB_ALL)
UI_Engine.SetFormTab( m.formIndex, 0 )
m.bDraw = false
DBGPRINTF("Onload tab Info AAAA    endend")
end
FORM_TASK_SHOW.C51607_OnDraw = function( m )
--if m.bDraw == false then
--	if m:IsDraw() == true then
--		DBGPRINTF("OnDraw begin OK")
--		UpData(m , m:GetTab())
--		DBGPRINTF("OnDraw UpData   end")
--		m.bDraw = true
--	end
--end
end
FORM_TASK_SHOW.C51601_OnClick = function( m )
DBGPRINTF("Onload tab Info AAAA")
m:SetSel(m.userSelectItem)
m:SetTab(CustomTaskTab.TAB_ALL)
UI_Engine.SetFormTab( m.formIndex, 0 )
UpData(m , CustomTaskTab.TAB_ALL)
DBGPRINTF("Onload tab Info AAAA    endend")
end
FORM_TASK_SHOW.C51600_OnClick = function( m )
DBGPRINTF("Onload tab Info BBB")
m:SetSel(m.userSelectItem)
m:SetTab(CustomTaskTab.TAB_ACCEPTED)
UI_Engine.SetFormTab( m.formIndex, 1)
UpData(m , CustomTaskTab.TAB_ACCEPTED)

DBGPRINTF("Onload tab Info BBB    endend")
end
FORM_TASK_SHOW.C51599_OnClick = function( m )
DBGPRINTF("Onload tab Info cCCCC")
m:SetSel(m.userSelectItem)
m:SetTab(CustomTaskTab.TAB_MY)
UI_Engine.SetFormTab( m.formIndex, 2)
UpData(m , CustomTaskTab.TAB_MY)
DBGPRINTF("Onload tab Info CCC    endend")
end
FORM_TASK_SHOW.C51602_OnClick = function( m )

local strViewTask = m:GetViewTask(m.userSelectItem)
WarnUser(m,strViewTask )
end
FORM_TASK_SHOW.C51603_OnClick = function( m )
local nTab = m:GetTab()

if nTab == CustomTaskTab.TAB_ALL then
	if m:CanGetTask(m.userSelectItem) == false then
		WarnUser(m,"not submit task")
		return 
	end
	
	if m:IsMyTask(m.userSelectItem) == false then
		WarnUser(m,"Task is my")
		return 
	end
	
	if m:IsPKMyTask(m.userSelectItem) == false then
		WarnUser(m,"Task is Pk my Task")
		return 
	end
	
	m:SendAcceptCusTaskMsg(m.userSelectItem)
end
end
FORM_TASK_SHOW.C51633_OnClick = function( m )
local nTab = m:GetTab()

if nTab == CustomTaskTab.TAB_ACCEPTED then
	if m:IsSubmitTask(m.userSelectItem) == false then
		WarnUser(m,"this task not  ready")
		return 
	end
	
	m:SendSubmitCusTaskMsg(m.userSelectItem)
end
end
FORM_TASK_SHOW.C51604_OnClick = function( m )
local nTab = m:GetTab()

if nTab == CustomTaskTab.TAB_ALL then
	return 
end

 if QueryUser(m,"are you sure delete") then
	m:DelTask(m.userSelectItem)
	if nTab == CustomTaskTab.TAB_ACCEPTED then
		UpData(m,CustomTaskTab.TAB_ACCEPTED)
	end
 end
end
FORM_TASK_SHOW.C51605_OnClick = function( m )
if m:CanMakeTask() == false then
	WarnUser(m,"make error")
end
local taskMgr = m:GetTaskMgr()

m.TaskPK= NewMkTaskPK(m, taskMgr )
m.TaskPK:WaitUserInput(m)
local data = m.TaskPK:GetTaskData()
if data ~= nil then
	m:SendGreateCusTaskMsg(data)
end
DelMkTaskPK(m.TaskPK)


end
FORM_TASK_SHOW.C51615_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51615_OnUpdate = function( m )
SetTabListText(m,0,COMPOSIT_1615)
end
FORM_TASK_SHOW.C51614_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51614_OnUpdate = function( m )
SetTabListText(m,1,COMPOSIT_1614)
end
FORM_TASK_SHOW.C51613_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51613_OnUpdate = function( m )
SetTabListText(m,2,COMPOSIT_1613)
end
FORM_TASK_SHOW.C51612_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51612_OnUpdate = function( m )
SetTabListText(m,3,COMPOSIT_1612)
end
FORM_TASK_SHOW.C51611_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51611_OnUpdate = function( m )
SetTabListText(m,4,COMPOSIT_1611)
end
FORM_TASK_SHOW.C51610_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51610_OnUpdate = function( m )
SetTabListText(m,5,COMPOSIT_1610)
end
FORM_TASK_SHOW.C51609_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51609_OnUpdate = function( m )
SetTabListText(m,6,COMPOSIT_1609)
end
FORM_TASK_SHOW.C51608_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51608_OnUpdate = function( m )
SetTabListText(m,7,COMPOSIT_1608)
end
FORM_TASK_SHOW.C51606_OnClick = function( m )
DBGPRINTF("exit")
m:InputFinished()
m:Close()
end
FORM_TASK_SHOW.C51623_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51623_OnUpdate = function( m )
SetTabListText(m,0,COMPOSIT_1623)
end
FORM_TASK_SHOW.C51622_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51622_OnUpdate = function( m )
SetTabListText(m,1,COMPOSIT_1622)
end
FORM_TASK_SHOW.C51621_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51621_OnUpdate = function( m )
SetTabListText(m,2,COMPOSIT_1621)
end
FORM_TASK_SHOW.C51620_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51620_OnUpdate = function( m )
SetTabListText(m,3,COMPOSIT_1620)
end
FORM_TASK_SHOW.C51619_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51619_OnUpdate = function( m )
SetTabListText(m,4,COMPOSIT_1619)
end
FORM_TASK_SHOW.C51618_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51618_OnUpdate = function( m )
SetTabListText(m,5,COMPOSIT_1618)
end
FORM_TASK_SHOW.C51617_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51617_OnUpdate = function( m )
SetTabListText(m,6,COMPOSIT_1617)
end
FORM_TASK_SHOW.C51616_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51616_OnUpdate = function( m )
SetTabListText(m,7,COMPOSIT_1616)
end
FORM_TASK_SHOW.C51631_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51631_OnUpdate = function( m )
SetTabListText(m,0,COMPOSIT_1631)
end
FORM_TASK_SHOW.C51630_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51630_OnUpdate = function( m )
SetTabListText(m,1,COMPOSIT_1630)
end
FORM_TASK_SHOW.C51629_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51629_OnUpdate = function( m )
SetTabListText(m,2,COMPOSIT_1629)
end
FORM_TASK_SHOW.C51628_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51628_OnUpdate = function( m )
SetTabListText(m,3,COMPOSIT_1628)
end
FORM_TASK_SHOW.C51627_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51627_OnUpdate = function( m )
SetTabListText(m,4,COMPOSIT_1627)
end
FORM_TASK_SHOW.C51626_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51626_OnUpdate = function( m )
SetTabListText(m,5,COMPOSIT_1626)
end
FORM_TASK_SHOW.C51625_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51625_OnUpdate = function( m )
SetTabListText(m,6,COMPOSIT_1625)
end
FORM_TASK_SHOW.C51624_OnClick = function( m )
m:SetSel(m.userSelectItem)
upDataDescribe(m)
end
FORM_TASK_SHOW.C51624_OnUpdate = function( m )
SetTabListText(m,7,COMPOSIT_1624)
end
