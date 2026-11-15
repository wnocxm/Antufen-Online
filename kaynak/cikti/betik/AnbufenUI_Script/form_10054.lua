FORM_BATTLE_QUERY= { }
FORM_BATTLE_QUERY.Main = function( m )
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

local SetTab1ListText = function(m,nIndex,composit)
	DBGPRINTF("SetTab1ListText begin ")
	local name = m:GetBattleList(m.offset + nIndex)
	local status = m:GetBattleStatus(m.offset + nIndex)
	DBGPRINTF("SetTab1ListText  nIndex = "..m.offset+nIndex)
	if name == nil then
		DBGPRINTF("SetTab1ListText  name is null")
		UI_Engine.SetText(m.formIndex,composit,"",0)
		UI_Engine.SetText(m.formIndex,composit,"",1)
		UI_Engine.SetText(m.formIndex,composit,"",2)
	else
		DBGPRINTF("SetTab1ListText  name is "..name)
		UI_Engine.SetText(m.formIndex,composit,m.offset + nIndex,0)
		UI_Engine.SetText(m.formIndex,composit,name,1)
		if status == nil then
			UI_Engine.SetText(m.formIndex,composit,"",2)
		else
			if status > 0 then
				UI_Engine.SetText(m.formIndex,composit,"（已报名）",2)
			else
				UI_Engine.SetText(m.formIndex,composit,"",2)
			end
		end
	end
end

local SetTab2ListText = function(m,nIndex,composit)
	DBGPRINTF("SetTab2ListText begin ")
	local name = m:GetBattleList(m.offset + nIndex)
	DBGPRINTF("SetTab2ListText  nIndex = "..m.offset+nIndex)
	if name == nil then
		DBGPRINTF("SetTab2ListText  name = null")
		UI_Engine.SetText(m.formIndex,composit,"",0)
		UI_Engine.SetText(m.formIndex,composit,"",1)
		UI_Engine.SetText(m.formIndex,composit,"",2)
	else
		DBGPRINTF("SetTab2ListText  name = "..name)
		UI_Engine.SetText(m.formIndex,composit,m.offset + nIndex,0)
		UI_Engine.SetText(m.formIndex,composit,name,1)
		UI_Engine.SetText(m.formIndex,composit,"",2)
	end
end

local upDataDescribe = function(m)
	local strDescribe = m:GetDescribe(m.userSelectItem)
	if strDescribe == nil then
		DBGPRINTF("upDataDescribe  strDescribe = nil ")
		UI_Engine.SetText(m.formIndex,COMPOSIT_1410,"")
	else
		DBGPRINTF("upDataDescribe  strDescribe = "..strDescribe)
		UI_Engine.SetText(m.formIndex,COMPOSIT_1410,strDescribe)
	end
end

local upDataButton = function(m)
	local nTab = m:GetTab()
	if nTab == BattleQueryTab.BATTLE_TAB_LIST then
			UI_Engine.SetVisible(m.formIndex , COMPOSIT_1414, true)
			UI_Engine.SetVisible(m.formIndex , COMPOSIT_1415, true)
			local status = m:GetCurBattleStatus()
			if status == nil then
				DBGPRINTF("upDataButton status= nil")
			else
				DBGPRINTF("upDataButton status= "..status)
			end
			if status ~= 0 then
				UI_Engine.SetText(m.formIndex,COMPOSIT_1415,"报名")
			elseif status == BattleStatus.BATTLE_STATUS_PREPARE or status == BattleStatus.BATTLE_STATUS_START then
				UI_Engine.SetText(m.formIndex,COMPOSIT_1415,"取消报名")
			else
				UI_Engine.SetVisible(m.formIndex , COMPOSIT_1415, false)
			end
			
	elseif nTab == BattleQueryTab.BATTLE_TAB_HELP then
			UI_Engine.SetVisible(m.formIndex , COMPOSIT_1414, false)
			UI_Engine.SetVisible(m.formIndex , COMPOSIT_1415, false)
	end
end

local UpData = function(m,nTab)
if nTab == BattleQueryTab.BATTLE_TAB_LIST then
            DBGPRINTF("upData begin  tab list")
	UI_Engine.UpdateList(m.formIndex ,COMPOSIT_1424)
            DBGPRINTF("upData begin  tab list   .. updatalist")
	upDataDescribe(m)
            DBGPRINTF("upData begin  tab list   .. upDataDescribe")
	upDataButton(m)
            DBGPRINTF("upData begin  tab list   .. upDataButton")
elseif nTab == BattleQueryTab.BATTLE_TAB_HELP then
           DBGPRINTF("upData begin  tab help   .. upData.....")
	UI_Engine.UpdateList(m.formIndex ,COMPOSIT_1432)
	DBGPRINTF("upData begin  tab help   .. UpdateList.....")
	upDataDescribe(m)
	DBGPRINTF("upData begin  tab help   .. upDataDescribe.....")
	upDataButton(m)
	DBGPRINTF("upData begin  tab help   .. upDataButton.....")
else
end
end
FORM_BATTLE_QUERY.C51412_OnLoad = function( m )
m:SetSel(m.userSelectItem)
m:SetTab(BattleQueryTab.BATTLE_TAB_LIST)
UI_Engine.SetFormTab( m.formIndex, 0 )
UpData(m, BattleQueryTab.BATTLE_TAB_LIST)
end
FORM_BATTLE_QUERY.C51412_OnClick = function( m )
DBGPRINTF("click tab battle list")
m:SetSel(m.userSelectItem)
m:SetTab(BattleQueryTab.BATTLE_TAB_LIST)
UI_Engine.SetFormTab( m.formIndex, 0 )
UpData(m, BattleQueryTab.BATTLE_TAB_LIST)
end
FORM_BATTLE_QUERY.C51413_OnClick = function( m )
DBGPRINTF("click tab battle help")
m:SetSel(m.userSelectItem)
m:SetTab(BattleQueryTab.BATTLE_TAB_HELP)
UI_Engine.SetFormTab( m.formIndex, 1 )
UpData(m , BattleQueryTab.BATTLE_TAB_HELP)
end
FORM_BATTLE_QUERY.C51414_OnClick = function( m )
m:OpenBattleLookUp(m.userSelectItem)
end
FORM_BATTLE_QUERY.C51415_OnClick = function( m )
	local nTab = m:GetTab()
	if nTab == BattleQueryTab.BATTLE_TAB_LIST then
		local status = m:GetCurBattleStatus()
		if status ~= 0 then
			m:BattleJoin()
		elseif status == BattleStatus.BATTLE_STATUS_PREPARE or status == BattleStatus.BATTLE_STATUS_START then
			m:CancelJoin()
		else
			
		end
	elseif nTab == BattleQueryTab.BATTLE_TAB_HELP then

	end
end
FORM_BATTLE_QUERY.C51416_OnClick = function( m )
DBGPRINTF("exit")
m:InputFinished()
m:Close()
--DelBattleQuery(m)
end
FORM_BATTLE_QUERY.C51424_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_LIST)
end
FORM_BATTLE_QUERY.C51424_OnUpdate = function( m )
DBGPRINTF("SetTab1ListText ok")
SetTab1ListText(m,0,COMPOSIT_1424)
DBGPRINTF("SetTab1ListText end")
end
FORM_BATTLE_QUERY.C51423_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_LIST)
end
FORM_BATTLE_QUERY.C51423_OnUpdate = function( m )
DBGPRINTF("SetTab1ListText ok2")
DBGPRINTF("SetTab1ListText OKOKOKOKK")
SetTab1ListText(m,1,COMPOSIT_1423)
DBGPRINTF("SetTab1ListText end")
end
FORM_BATTLE_QUERY.C51422_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_LIST)
end
FORM_BATTLE_QUERY.C51422_OnUpdate = function( m )
SetTab1ListText(m,2,COMPOSIT_1422)
DBGPRINTF("SetTab1ListText ok3")
DBGPRINTF("SetTab1ListText end")
end
FORM_BATTLE_QUERY.C51421_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_LIST)
end
FORM_BATTLE_QUERY.C51421_OnUpdate = function( m )
SetTab1ListText(m,3,COMPOSIT_1421)
end
FORM_BATTLE_QUERY.C51420_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_LIST)
end
FORM_BATTLE_QUERY.C51420_OnUpdate = function( m )
SetTab1ListText(m,4,COMPOSIT_1420)
end
FORM_BATTLE_QUERY.C51419_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_LIST)
end
FORM_BATTLE_QUERY.C51419_OnUpdate = function( m )
SetTab1ListText(m,5,COMPOSIT_1419)
end
FORM_BATTLE_QUERY.C51418_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_LIST)
end
FORM_BATTLE_QUERY.C51418_OnUpdate = function( m )
SetTab1ListText(m,6,COMPOSIT_1418)
end
FORM_BATTLE_QUERY.C51417_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_LIST)
end
FORM_BATTLE_QUERY.C51417_OnUpdate = function( m )
SetTab1ListText(m,7,COMPOSIT_1417)
end
FORM_BATTLE_QUERY.C51432_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_HELP)
end
FORM_BATTLE_QUERY.C51432_OnUpdate = function( m )
DBGPRINTF("SetTab2ListText ok")
SetTab2ListText(m,0,COMPOSIT_1432)
end
FORM_BATTLE_QUERY.C51431_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_HELP)
end
FORM_BATTLE_QUERY.C51431_OnUpdate = function( m )
SetTab2ListText(m,1,COMPOSIT_1431)
end
FORM_BATTLE_QUERY.C51430_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_HELP)
end
FORM_BATTLE_QUERY.C51430_OnUpdate = function( m )
SetTab2ListText(m,2,COMPOSIT_1430)
end
FORM_BATTLE_QUERY.C51429_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_HELP)
end
FORM_BATTLE_QUERY.C51429_OnUpdate = function( m )
SetTab2ListText(m,3,COMPOSIT_1429)
end
FORM_BATTLE_QUERY.C51428_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_HELP)
end
FORM_BATTLE_QUERY.C51428_OnUpdate = function( m )
SetTab2ListText(m,4,COMPOSIT_1428)
end
FORM_BATTLE_QUERY.C51427_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_HELP)
end
FORM_BATTLE_QUERY.C51427_OnUpdate = function( m )
SetTab2ListText(m,5,COMPOSIT_1427)
end
FORM_BATTLE_QUERY.C51426_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_HELP)
end
FORM_BATTLE_QUERY.C51426_OnUpdate = function( m )
SetTab2ListText(m,6,COMPOSIT_1426)
end
FORM_BATTLE_QUERY.C51425_OnClick = function( m )
m:SetSel(m.userSelectItem)
UpData(m,BattleQueryTab.BATTLE_TAB_HELP)
end
FORM_BATTLE_QUERY.C51425_OnUpdate = function( m )
SetTab2ListText(m,7,COMPOSIT_1425)
end
