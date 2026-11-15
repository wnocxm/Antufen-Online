FORM_BATTLE_INFO= { }
FORM_BATTLE_INFO.Main = function( m )
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
local SetTabListText = function(m,nIndex,composit)
	DBGPRINTF("SetTab1ListText begin ")
	local strLv = m:GetLv(m.offset + nIndex)
	local strJob = m:GetJob(m.offset + nIndex)
	local strName = m:GetName(m.offset + nIndex)
	
	DBGPRINTF("SetTab1ListText  nIndex = "..m.offset+nIndex)
	if strLv == nil then
		UI_Engine.SetText(m.formIndex,composit,"",0)
	else
		UI_Engine.SetText(m.formIndex,composit,strLv,0)
	end
	
	if strJob == nil then
		UI_Engine.SetText(m.formIndex,composit,"",1)
	else
		UI_Engine.SetText(m.formIndex,composit,strJob,1)
	end
	
	if strName == nil then
		UI_Engine.SetText(m.formIndex,composit,"",2)
	else
		UI_Engine.SetText(m.formIndex,composit,strName,2)
	end
	
end
FORM_BATTLE_INFO.C51536_OnLoad = function( m )
DBGPRINTF("Onload tab Info AAAA")
m:SetSel(m.userSelectItem)
m:SetTab(BattleInfoTab.BATTLE_TAB_INFOA)
UI_Engine.SetFormTab( m.formIndex, 0 )
DBGPRINTF("Onload tab Info AAAA    endend")
end
FORM_BATTLE_INFO.C51536_OnClick = function( m )
DBGPRINTF("click tab Info AAAA")
m:SetSel(m.userSelectItem)
m:SetTab(BattleInfoTab.BATTLE_TAB_INFOA)
UI_Engine.SetFormTab( m.formIndex, 0 )
DBGPRINTF("click tab Info AAAA    endend")
end
FORM_BATTLE_INFO.C51535_OnClick = function( m )
DBGPRINTF("click tab Info BBBB")
m:SetSel(m.userSelectItem)
m:SetTab(BattleInfoTab.BATTLE_TAB_INFOB)
UI_Engine.SetFormTab( m.formIndex, 1 )
DBGPRINTF("click tab Info BBBB   endend")
end
FORM_BATTLE_INFO.C51537_OnLoad = function( m )
local strTitle = m:GetTitle()
if strTitle  == nil then
UI_Engine.SetText(m.formIndex,COMPOSIT_1537,"" )
else
UI_Engine.SetText(m.formIndex,COMPOSIT_1537,strTitle )
end

end
FORM_BATTLE_INFO.C51559_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_BATTLE_INFO.C51559_OnUpdate = function( m )
DBGPRINTF("SetTab1ListText ok")
SetTabListText(m,0,COMPOSIT_1559)
DBGPRINTF("SetTab1ListText end")
end
FORM_BATTLE_INFO.C51558_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_BATTLE_INFO.C51558_OnUpdate = function( m )
SetTabListText(m,1,COMPOSIT_1558)
end
FORM_BATTLE_INFO.C51557_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_BATTLE_INFO.C51557_OnUpdate = function( m )
SetTabListText(m,2,COMPOSIT_1557)
end
FORM_BATTLE_INFO.C51556_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_BATTLE_INFO.C51556_OnUpdate = function( m )
SetTabListText(m,3,COMPOSIT_1556)
end
FORM_BATTLE_INFO.C51555_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_BATTLE_INFO.C51555_OnUpdate = function( m )
SetTabListText(m,4,COMPOSIT_1555)
end
FORM_BATTLE_INFO.C51554_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_BATTLE_INFO.C51554_OnUpdate = function( m )
SetTabListText(m,5,COMPOSIT_1554)
end
FORM_BATTLE_INFO.C51553_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_BATTLE_INFO.C51553_OnUpdate = function( m )
SetTabListText(m,6,COMPOSIT_1553)
end
FORM_BATTLE_INFO.C51542_OnClick = function( m )
DBGPRINTF("exit")
m:InputFinished()
m:Close()
DelBattleInfo(m)
end
FORM_BATTLE_INFO.C51566_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_BATTLE_INFO.C51566_OnUpdate = function( m )
SetTabListText(m,0,COMPOSIT_1566)
end
FORM_BATTLE_INFO.C51565_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_BATTLE_INFO.C51565_OnUpdate = function( m )
SetTabListText(m,1,COMPOSIT_1565)
end
FORM_BATTLE_INFO.C51564_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_BATTLE_INFO.C51564_OnUpdate = function( m )
SetTabListText(m,2,COMPOSIT_1564)
end
FORM_BATTLE_INFO.C51563_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_BATTLE_INFO.C51563_OnUpdate = function( m )
SetTabListText(m,3,COMPOSIT_1563)
end
FORM_BATTLE_INFO.C51562_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_BATTLE_INFO.C51562_OnUpdate = function( m )
SetTabListText(m,4,COMPOSIT_1562)
end
FORM_BATTLE_INFO.C51561_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_BATTLE_INFO.C51561_OnUpdate = function( m )
SetTabListText(m,5,COMPOSIT_1561)
end
FORM_BATTLE_INFO.C51560_OnClick = function( m )
m:SetSel(m.userSelectItem)
end
FORM_BATTLE_INFO.C51560_OnUpdate = function( m )
SetTabListText(m,6,COMPOSIT_1560)
end
