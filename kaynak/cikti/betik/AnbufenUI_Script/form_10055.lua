FORM_BATTLE_LIST= { }
FORM_BATTLE_LIST.Main = function( m )
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

local UpData = function(m)
	DBGPRINTF("UpData begin  ..........")
	local strTitle = m:GetTitle()
	if strTitle == nil then
		DBGPRINTF("UpData strTitle .....is null")
		UI_Engine.SetText( m.formIndex, COMPOSIT_1491, "")
	else
		UI_Engine.SetText( m.formIndex, COMPOSIT_1491, strTitle )
	end

	local strSelBattle = m:GetSelBattle()
	if strSelBattle == nil then
		DBGPRINTF("UpData strSelBattle .....is null")
		UI_Engine.SetText( m.formIndex, COMPOSIT_1531, "")
	else
		UI_Engine.SetText( m.formIndex, COMPOSIT_1531, strSelBattle )
	end
	
	local strSelSide = m:GetSelSide()
	if strSelSide == nil then
		DBGPRINTF("UpData strSelSide .....is null")
		UI_Engine.SetText( m.formIndex, COMPOSIT_1532, "")
	else
		UI_Engine.SetText( m.formIndex, COMPOSIT_1532, strSelSide )
	end
	
	local strSignupNumA = m:GetSignupNum(0)
	if strSignupNumA == nil then
		DBGPRINTF("UpData strSignupNumAAAA .....is null")
		UI_Engine.SetText( m.formIndex, COMPOSIT_1520, "")
	else
		UI_Engine.SetText( m.formIndex, COMPOSIT_1520, strSignupNumA )
	end

	local strSignupNumB = m:GetSignupNum(1)
	if strSignupNumB == nil then
		DBGPRINTF("UpData strSignupNumBBBB .....is null")
		UI_Engine.SetText( m.formIndex, COMPOSIT_1528, "")
	else
		UI_Engine.SetText( m.formIndex, COMPOSIT_1528, strSignupNumB )
	end
	
	local strTeamA = m:GetTeam(0)
	if strTeamA == nil then
		DBGPRINTF("UpData strTeamAAAAAAA .....is null")
		UI_Engine.SetText( m.formIndex, COMPOSIT_1521, "")
	else
		UI_Engine.SetText( m.formIndex, COMPOSIT_1521, strTeamA )
	end
	
	local strTeamB = m:GetTeam(1)
	if strTeamB == nil then
		DBGPRINTF("UpData strTeamBBBBBB .....is null")
		UI_Engine.SetText( m.formIndex, COMPOSIT_1529, "")
	else
		UI_Engine.SetText( m.formIndex, COMPOSIT_1529, strTeamB )
	end
	
	local strCampA = m:GetCamp(0)
	if strCampA == nil then
		DBGPRINTF("UpData strCampAAAAA .....is null")
		UI_Engine.SetText( m.formIndex, COMPOSIT_1522, "")
	else
		UI_Engine.SetText( m.formIndex, COMPOSIT_1522, strCampA )
	end
	
	local strCampB = m:GetCamp(1)
	if strCampB == nil then
		DBGPRINTF("UpData strCampBBBBBB .....is null")
		UI_Engine.SetText( m.formIndex, COMPOSIT_1530, "")
	else
		UI_Engine.SetText( m.formIndex, COMPOSIT_1530, strCampB )
	end
	
	local strDescribe = m:GetDescribe()
	if strDescribe == nil then
		DBGPRINTF("UpData strDescribe .....is null")
		UI_Engine.SetText( m.formIndex, COMPOSIT_1490, "")
	else
		UI_Engine.SetText( m.formIndex, COMPOSIT_1490, strDescribe )
	end
	
	local strBattleNum = m:GetBattleNum()
	if strBattleNum == nil then
		DBGPRINTF("UpData strBattleNum .....is null")
		UI_Engine.SetText( m.formIndex, COMPOSIT_1519, "")
	else
		UI_Engine.SetText( m.formIndex, COMPOSIT_1519, strBattleNum )
	end
	
	if m:IsCanLookUp(m) == true then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_1487 , true)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_1487 , false)
	end
	
	if m:IsCanJoin(m) == true then
		UI_Engine.SetText(m.formIndex,COMPOSIT_1486 , "报名")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_1486 , "取消报名")
	end

end
FORM_BATTLE_LIST.C51502_OnLoad = function( m )
DBGPRINTF("Onload begin")
m.bDraw = false
end
FORM_BATTLE_LIST.C51502_OnDraw = function( m )

if m.bDraw == false then
	if m:IsDraw() == true then
		DBGPRINTF("OnDraw begin OK")
		UpData(m)
		DBGPRINTF("OnDraw UpData   end")
		m.bDraw = true
	end
end
end
FORM_BATTLE_LIST.C51486_OnClick = function( m )
if m:IsCanJoin(m) == true then
	--点击的是报名
	local bJoin, strJoin = m:Join()
	if bJoin == nil then
		return 
	end
	if bJoin == false then
		WarnUser(strJoin)
		return 
	end
	m:Close()
else
	--点击的取消报名
	m:CancelJoin()
	m:Close()
end
end
FORM_BATTLE_LIST.C51487_OnClick = function( m )
if m:IsCanLookUp() then
	local  stInfo = m:GetSelBattleInfo()
	local nCamp = m:GetSide()

	if stInfo == nil or nCamp == nil then
		return 
	end
	NewBattleInfo(m, stInfo ,nCamp)
end
end
FORM_BATTLE_LIST.C51488_OnClick = function( m )
DBGPRINTF("exit")
m:InputFinished()
m:Close()
end
FORM_BATTLE_LIST.C51495_OnClick = function( m )
m:SetSel(0)
UpData(m)
end
FORM_BATTLE_LIST.C51494_OnClick = function( m )
m:SetSel(1)
UpData(m)
end
FORM_BATTLE_LIST.C51497_OnClick = function( m )
m:SetSide(0)
UpData(m)
end
FORM_BATTLE_LIST.C51496_OnClick = function( m )
m:SetSide(1)
UpData(m)
end
