FORM_SYSTEM_SET= { }
FORM_SYSTEM_SET.Main = function( m )
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

local ReSetItemSate = function(m, composit , itemtype)     --根据控件状态设置系统选项        
	if itemtype == SystemItem.SYSTEMSET_ITEM_PLAYERNAME then
		local nValue = UI_Engine.GetState(m.formIndex,composit )
		if nValue ==1  then 
			nValue = 3
		end
		m:SetItemState(itemtype , nValue)
	else
		local nValue = UI_Engine.GetState(m.formIndex,composit )
		m:SetItemState(itemtype , nValue)
	end
end

local ReSetControlSate = function(m,composit , itemtype)  --根据系统选项设置控件状态
	if itemtype == SystemItem.SYSTEMSET_ITEM_PLAYERNAME then
		local nValue = m:GetItemState(itemtype)
		if nValue >0 then
			nValue = 1
		end
		UI_Engine.SetState(m.formIndex, composit, nValue)
	else
		local nValue = m:GetItemState(itemtype)
		UI_Engine.SetState(m.formIndex, composit, nValue)
	end
end

local SetAnvItem = function(m, composit, itemtype)
	local name = m:GetAdvItemState(itemtype)
	UI_Engine.SetText(m.formIndex, composit, name)
end


local SaveAll = function(m)            --保存全部根据控件状态设置全部系统选项
	ReSetItemSate(m, COMPOSIT_1310, SystemItem.SYSTEMSET_ITEM_PLAYERNAME)
	ReSetItemSate(m, COMPOSIT_1315, SystemItem.SYSTEMSET_ITEM_PLAYERTITLE)
	ReSetItemSate(m, COMPOSIT_1314, SystemItem.SYSTEMSET_ITEM_PLAYERUNION)
	ReSetItemSate(m, COMPOSIT_1313, SystemItem.SYSTEMSET_ITEM_PETNAME)
	ReSetItemSate(m, COMPOSIT_1312, SystemItem.SYSTEMSET_ITEM_NPCNAME)
	ReSetItemSate(m, COMPOSIT_1311, SystemItem.SYSTEMSET_ITEM_BLOODBAR)
	ReSetItemSate(m, COMPOSIT_1316, SystemItem.SYSTEMSET_ITEM_MAP)
	ReSetItemSate(m, COMPOSIT_1317, SystemItem.SYSTEMSET_ITEM_WORLDCHAT)
	ReSetItemSate(m, COMPOSIT_1318, SystemItem.SYSTEMSET_ITEM_AREACHAT)
	ReSetItemSate(m, COMPOSIT_1319, SystemItem.SYSTEMSET_ITEM_AROUNDCHAT)
	ReSetItemSate(m, COMPOSIT_1320, SystemItem.SYSTEMSET_ITEM_TEAMCHAT)
	ReSetItemSate(m, COMPOSIT_1321, SystemItem.SYSTEMSET_ITEM_UNIONCHAT)
end

local DefaultSetState = function(m)                        --恢复默认设置修改控件状态
	local nTab = m:GetTab()
	if nTab == SystemTab.SYSTEMSET_TAB_SOUNDSET then
	elseif nTab == SystemTab.SYSTEMSET_TAB_PLAYERSHOW then
		ReSetControlSate(m, COMPOSIT_1310, SystemItem.SYSTEMSET_ITEM_PLAYERNAME)
		ReSetControlSate(m, COMPOSIT_1315, SystemItem.SYSTEMSET_ITEM_PLAYERTITLE)
		ReSetControlSate(m, COMPOSIT_1314, SystemItem.SYSTEMSET_ITEM_PLAYERUNION)
		ReSetControlSate(m, COMPOSIT_1313, SystemItem.SYSTEMSET_ITEM_PETNAME)
		ReSetControlSate(m, COMPOSIT_1312, SystemItem.SYSTEMSET_ITEM_NPCNAME)
		ReSetControlSate(m, COMPOSIT_1311, SystemItem.SYSTEMSET_ITEM_BLOODBAR)
	elseif nTab == SystemTab.SYSTEMSET_TAB_UISHOW then
		ReSetControlSate(m, COMPOSIT_1316, SystemItem.SYSTEMSET_ITEM_MAP)
		ReSetControlSate(m, COMPOSIT_1317, SystemItem.SYSTEMSET_ITEM_WORLDCHAT)
		ReSetControlSate(m, COMPOSIT_1318, SystemItem.SYSTEMSET_ITEM_AREACHAT)
		ReSetControlSate(m, COMPOSIT_1319, SystemItem.SYSTEMSET_ITEM_AROUNDCHAT)
		ReSetControlSate(m, COMPOSIT_1320, SystemItem.SYSTEMSET_ITEM_TEAMCHAT)
		ReSetControlSate(m, COMPOSIT_1321, SystemItem.SYSTEMSET_ITEM_UNIONCHAT)
	elseif nTab == SystemTab.SYSTEMSET_TAB_ADVANCED then
		SetAnvItem(m,COMPOSIT_2369,SystemAdvItem.SYSTEMSET_ITEM_PLAYERIMAGE)
		SetAnvItem(m,COMPOSIT_2370,SystemAdvItem.SYSTEMSET_ITEM_PETAPPERENCEMODE)
		SetAnvItem(m,COMPOSIT_2371,SystemAdvItem.SYSTEMSET_ITEM_AVATARMODE)
		SetAnvItem(m,COMPOSIT_2372,SystemAdvItem.SYSTEMSET_ITEM_EFFECTMODE)
		SetAnvItem(m,COMPOSIT_2373,SystemAdvItem.SYSTEMSET_ITEM_PETBUBBLE)
	elseif nTab == SystemTab.SYSTEMSET_TAB_OTHER then
		SetAnvItem(m,COMPOSIT_2361,SystemAdvItem.SYSTEMSET_ITEM_SAVEIAP)
	end
end
FORM_SYSTEM_SET.C51299_OnLoad = function( m )
UI_Engine.SetFormTab( m.formIndex, 0)
m:SetTab(SystemTab.SYSTEMSET_TAB_SOUNDSET)
end
FORM_SYSTEM_SET.C51299_OnClick = function( m )
UI_Engine.SetFormTab( m.formIndex, 0)
m:SetTab(SystemTab.SYSTEMSET_TAB_SOUNDSET)
end
FORM_SYSTEM_SET.C51300_OnClick = function( m )
UI_Engine.SetFormTab( m.formIndex, 1)
m:SetTab(SystemTab.SYSTEMSET_TAB_PLAYERSHOW)
end
FORM_SYSTEM_SET.C51301_OnClick = function( m )
UI_Engine.SetFormTab( m.formIndex, 2)
m:SetTab(SystemTab.SYSTEMSET_TAB_UISHOW)
end
FORM_SYSTEM_SET.C52358_OnClick = function( m )
UI_Engine.SetFormTab( m.formIndex, 3)
m:SetTab(SystemTab.SYSTEMSET_TAB_ADVANCED)
end
FORM_SYSTEM_SET.C52359_OnClick = function( m )
UI_Engine.SetFormTab( m.formIndex, 4)
m:SetTab(SystemTab.SYSTEMSET_TAB_OTHER)
end
FORM_SYSTEM_SET.C51302_OnClick = function( m )
m:DefaultSetting()
DefaultSetState(m)
end
FORM_SYSTEM_SET.C51303_OnClick = function( m )
SaveAll(m) 
m:SaveSetting()
WarnUser(m,"保存成功")
end
FORM_SYSTEM_SET.C52696_OnClick = function( m )
DBGPRINTF("exit")
m:InputFinished()
m:Close()
DelSystemSetting(m)
end
FORM_SYSTEM_SET.C51304_OnClick = function( m )
DBGPRINTF("exit")
m:InputFinished()
m:Close()
DelSystemSetting(m)
end
FORM_SYSTEM_SET.C51316_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_MAP)
UI_Engine.SetState(m.formIndex, COMPOSIT_1316, nValue)
end
FORM_SYSTEM_SET.C51317_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_WORLDCHAT)
UI_Engine.SetState(m.formIndex, COMPOSIT_1317, nValue)
end
FORM_SYSTEM_SET.C51318_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_AREACHAT)
UI_Engine.SetState(m.formIndex, COMPOSIT_1318, nValue)
end
FORM_SYSTEM_SET.C51319_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_AROUNDCHAT)
UI_Engine.SetState(m.formIndex, COMPOSIT_1319, nValue)
end
FORM_SYSTEM_SET.C51320_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_TEAMCHAT)
UI_Engine.SetState(m.formIndex, COMPOSIT_1320, nValue)
end
FORM_SYSTEM_SET.C51321_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_UNIONCHAT)
UI_Engine.SetState(m.formIndex, COMPOSIT_1321, nValue)
end
FORM_SYSTEM_SET.C51310_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_PLAYERNAME)
if nValue > 0 then
nValue = 1
end
UI_Engine.SetState(m.formIndex, COMPOSIT_1310, nValue)
end
FORM_SYSTEM_SET.C51310_OnClick = function( m )


end
FORM_SYSTEM_SET.C51310_OnDraw = function( m )


end
FORM_SYSTEM_SET.C51315_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_PLAYERTITLE)
UI_Engine.SetState(m.formIndex, COMPOSIT_1315, nValue)
end
FORM_SYSTEM_SET.C51314_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_PLAYERUNION)
UI_Engine.SetState(m.formIndex, COMPOSIT_1314, nValue)
end
FORM_SYSTEM_SET.C51313_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_PETNAME)
UI_Engine.SetState(m.formIndex, COMPOSIT_1313, nValue)
end
FORM_SYSTEM_SET.C51312_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_NPCNAME)
UI_Engine.SetState(m.formIndex, COMPOSIT_1312, nValue)
end
FORM_SYSTEM_SET.C51311_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_BLOODBAR)
UI_Engine.SetState(m.formIndex, COMPOSIT_1311, nValue)
end
FORM_SYSTEM_SET.C51309_OnDraw = function( m )

local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_MUSIC)
nValue = nValue / 10
if nValue <0 then
nValue = 0
end
if nValue > 10 then
nValue = 10
end

DBGPRINTF("setState++++++------"..nValue)
UI_Engine.SetState(m.formIndex , COMPOSIT_1309 , nValue)

end
FORM_SYSTEM_SET.C51308_OnDraw = function( m )



end
FORM_SYSTEM_SET.C51307_OnDraw = function( m )

local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_SOUND)
nValue = nValue / 10
if nValue <0 then
nValue = 0
end
if nValue > 10 then
nValue = 10
end

UI_Engine.SetState(m.formIndex , COMPOSIT_1307 , nValue )
end
FORM_SYSTEM_SET.C51309_OnClick = function( m )
local  nMin = m:GetItemState(SystemItem.SYSTEMSET_ITEM_MUSIC)
if nMin/10 >10 then
m:SetItemState(SystemItem.SYSTEMSET_ITEM_MUSIC , 100)
end
if nMin/10 < 0 then
m:SetItemState(SystemItem.SYSTEMSET_ITEM_MUSIC, 0)
end
if nMin/10 == 0 then
return 
end
DBGPRINTF("SetItemState<<<<<<<<"..nMin )
m:SetItemState(SystemItem.SYSTEMSET_ITEM_MUSIC , nMin - 10)
end
FORM_SYSTEM_SET.C51308_OnClick = function( m )
local  nMin = m:GetItemState(SystemItem.SYSTEMSET_ITEM_SOUND)
if nMin/10 >10 then
m:SetItemState(SystemItem.SYSTEMSET_ITEM_SOUND , 100)
end
if nMin/10 < 0 then
m:SetItemState(SystemItem.SYSTEMSET_ITEM_SOUND , 0)
end
if nMin/10 == 0 then
return 
end

m:SetItemState(SystemItem.SYSTEMSET_ITEM_SOUND , nMin - 10)

end
FORM_SYSTEM_SET.C51307_OnClick = function( m )
local  nMax = m:GetItemState(SystemItem.SYSTEMSET_ITEM_MUSIC)
if nMax /10 >10 then
m:SetItemState(SystemItem.SYSTEMSET_ITEM_MUSIC , 100)
end
if nMax /10 < 0 then
m:SetItemState(SystemItem.SYSTEMSET_ITEM_MUSIC , 0)
end
if nMax /10 == 10 then
return 
end
DBGPRINTF("SetItemState>>>>>>>>"..nMax )
m:SetItemState(SystemItem.SYSTEMSET_ITEM_MUSIC , nMax + 10)
end
FORM_SYSTEM_SET.C51306_OnClick = function( m )
local  nMax = m:GetItemState(SystemItem.SYSTEMSET_ITEM_SOUND)
if nMax /10 >10 then
m:SetItemState(SystemItem.SYSTEMSET_ITEM_SOUND , 100)
end
if nMax /10 < 0 then
m:SetItemState(SystemItem.SYSTEMSET_ITEM_SOUND , 0)
end
if nMax /10 == 10 then
return 
end

m:SetItemState(SystemItem.SYSTEMSET_ITEM_SOUND , nMax + 10)
end
FORM_SYSTEM_SET.C52383_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_PETBUBBLE,1)
		SetAnvItem(m,COMPOSIT_2373,SystemAdvItem.SYSTEMSET_ITEM_PETBUBBLE)
end
FORM_SYSTEM_SET.C52382_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_EFFECTMODE,1)
		SetAnvItem(m,COMPOSIT_2372,SystemAdvItem.SYSTEMSET_ITEM_EFFECTMODE)

end
FORM_SYSTEM_SET.C52381_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_AVATARMODE,1)

SetAnvItem(m,COMPOSIT_2371,SystemAdvItem.SYSTEMSET_ITEM_AVATARMODE)
end
FORM_SYSTEM_SET.C52380_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_PETAPPERENCEMODE,1)
		SetAnvItem(m,COMPOSIT_2370,SystemAdvItem.SYSTEMSET_ITEM_PETAPPERENCEMODE)

end
FORM_SYSTEM_SET.C52379_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_PLAYERIMAGE,1)
		SetAnvItem(m,COMPOSIT_2369,SystemAdvItem.SYSTEMSET_ITEM_PLAYERIMAGE)

end
FORM_SYSTEM_SET.C52378_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_PETBUBBLE,0)
SetAnvItem(m,COMPOSIT_2373,SystemAdvItem.SYSTEMSET_ITEM_PETBUBBLE)
end
FORM_SYSTEM_SET.C52377_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_EFFECTMODE,0)
		SetAnvItem(m,COMPOSIT_2372,SystemAdvItem.SYSTEMSET_ITEM_EFFECTMODE)
end
FORM_SYSTEM_SET.C52376_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_AVATARMODE,0)
SetAnvItem(m,COMPOSIT_2371,SystemAdvItem.SYSTEMSET_ITEM_AVATARMODE)
end
FORM_SYSTEM_SET.C52375_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_PETAPPERENCEMODE,0)
SetAnvItem(m,COMPOSIT_2370,SystemAdvItem.SYSTEMSET_ITEM_PETAPPERENCEMODE)
end
FORM_SYSTEM_SET.C52374_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_PLAYERIMAGE,0)
SetAnvItem(m,COMPOSIT_2369,SystemAdvItem.SYSTEMSET_ITEM_PLAYERIMAGE)
end
FORM_SYSTEM_SET.C52373_OnLoad = function( m )
SetAnvItem(m,COMPOSIT_2373,SystemAdvItem.SYSTEMSET_ITEM_PETBUBBLE)
end
FORM_SYSTEM_SET.C52372_OnLoad = function( m )
		SetAnvItem(m,COMPOSIT_2372,SystemAdvItem.SYSTEMSET_ITEM_EFFECTMODE)
end
FORM_SYSTEM_SET.C52371_OnLoad = function( m )
SetAnvItem(m,COMPOSIT_2371,SystemAdvItem.SYSTEMSET_ITEM_AVATARMODE)
end
FORM_SYSTEM_SET.C52370_OnLoad = function( m )
SetAnvItem(m,COMPOSIT_2370,SystemAdvItem.SYSTEMSET_ITEM_PETAPPERENCEMODE)
end
FORM_SYSTEM_SET.C52369_OnLoad = function( m )
SetAnvItem(m,COMPOSIT_2369,SystemAdvItem.SYSTEMSET_ITEM_PLAYERIMAGE)
end
FORM_SYSTEM_SET.C52363_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_SAVEIAP,1)
SetAnvItem(m,COMPOSIT_2361,SystemAdvItem.SYSTEMSET_ITEM_SAVEIAP)
end
FORM_SYSTEM_SET.C52362_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_SAVEIAP,0)
SetAnvItem(m,COMPOSIT_2361,SystemAdvItem.SYSTEMSET_ITEM_SAVEIAP)
end
FORM_SYSTEM_SET.C52361_OnLoad = function( m )
SetAnvItem(m,COMPOSIT_2361,SystemAdvItem.SYSTEMSET_ITEM_SAVEIAP)
end
FORM_SYSTEM_SET.C52360_OnLoad = function( m )
local name = m:GetNetName()
UI_Engine.SetText(m.formIndex, COMPOSIT_2360, name)

end
FORM_SYSTEM_SET.C52812_OnClick = function( m )
m:ClearImage()
end
