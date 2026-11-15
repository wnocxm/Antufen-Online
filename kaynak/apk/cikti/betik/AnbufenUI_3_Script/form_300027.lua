NEW_FORM_SYSTEM_SET= { }
NEW_FORM_SYSTEM_SET.Main = function( m )
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
NEW_FORM_SYSTEM_SET.C50486_OnLoad = function( m )
UI_Engine.SetFormTab( m.formIndex, 0)
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
			nValue = 1
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
	ReSetItemSate(m, UI3_COMPOSIT_523, SystemItem.SYSTEMSET_ITEM_PLAYERNAME)
	ReSetItemSate(m, UI3_COMPOSIT_524, SystemItem.SYSTEMSET_ITEM_PLAYERTITLE)
	ReSetItemSate(m, UI3_COMPOSIT_525, SystemItem.SYSTEMSET_ITEM_PLAYERUNION)
	ReSetItemSate(m, UI3_COMPOSIT_526, SystemItem.SYSTEMSET_ITEM_PETNAME)
	ReSetItemSate(m, UI3_COMPOSIT_527, SystemItem.SYSTEMSET_ITEM_NPCNAME)
	ReSetItemSate(m, UI3_COMPOSIT_528, SystemItem.SYSTEMSET_ITEM_BLOODBAR)
	ReSetItemSate(m, UI3_COMPOSIT_518, SystemItem.SYSTEMSET_ITEM_WORLDCHAT)
	ReSetItemSate(m, UI3_COMPOSIT_519, SystemItem.SYSTEMSET_ITEM_AREACHAT)
	ReSetItemSate(m, UI3_COMPOSIT_520, SystemItem.SYSTEMSET_ITEM_AROUNDCHAT)
	ReSetItemSate(m, UI3_COMPOSIT_521, SystemItem.SYSTEMSET_ITEM_TEAMCHAT)
	ReSetItemSate(m, UI3_COMPOSIT_522, SystemItem.SYSTEMSET_ITEM_UNIONCHAT)
end

local DefaultSetState = function(m)                        --恢复默认设置修改控件状态
	local nTab = m:GetTab()
	if nTab == SystemTab.SYSTEMSET_TAB_SOUNDSET then
	elseif nTab == SystemTab.SYSTEMSET_TAB_PLAYERSHOW then
		ReSetControlSate(m, UI3_COMPOSIT_523, SystemItem.SYSTEMSET_ITEM_PLAYERNAME)
		ReSetControlSate(m, UI3_COMPOSIT_524, SystemItem.SYSTEMSET_ITEM_PLAYERTITLE)
		ReSetControlSate(m, UI3_COMPOSIT_525, SystemItem.SYSTEMSET_ITEM_PLAYERUNION)
		ReSetControlSate(m, UI3_COMPOSIT_526, SystemItem.SYSTEMSET_ITEM_PETNAME)
		ReSetControlSate(m, UI3_COMPOSIT_527, SystemItem.SYSTEMSET_ITEM_NPCNAME)
		ReSetControlSate(m, UI3_COMPOSIT_528, SystemItem.SYSTEMSET_ITEM_BLOODBAR)
	elseif nTab == SystemTab.SYSTEMSET_TAB_UISHOW then

		ReSetControlSate(m, UI3_COMPOSIT_518, SystemItem.SYSTEMSET_ITEM_WORLDCHAT)
		ReSetControlSate(m, UI3_COMPOSIT_519, SystemItem.SYSTEMSET_ITEM_AREACHAT)
		ReSetControlSate(m, UI3_COMPOSIT_520, SystemItem.SYSTEMSET_ITEM_AROUNDCHAT)
		ReSetControlSate(m, UI3_COMPOSIT_521, SystemItem.SYSTEMSET_ITEM_TEAMCHAT)
		ReSetControlSate(m, UI3_COMPOSIT_522, SystemItem.SYSTEMSET_ITEM_UNIONCHAT)
	elseif nTab == SystemTab.SYSTEMSET_TAB_ADVANCED then
		SetAnvItem(m,UI3_COMPOSIT_472,SystemAdvItem.SYSTEMSET_ITEM_PLAYERIMAGE)
		SetAnvItem(m,UI3_COMPOSIT_475,SystemAdvItem.SYSTEMSET_ITEM_PETAPPERENCEMODE)
		SetAnvItem(m,UI3_COMPOSIT_474,SystemAdvItem.SYSTEMSET_ITEM_AVATARMODE)
		SetAnvItem(m,UI3_COMPOSIT_473,SystemAdvItem.SYSTEMSET_ITEM_EFFECTMODE)
		SetAnvItem(m,UI3_COMPOSIT_476,SystemAdvItem.SYSTEMSET_ITEM_PETBUBBLE)
	end
end

NEW_FORM_SYSTEM_SET.C50487_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_SYSTEM_SET.C50487_OnClick = function( m )
SaveAll(m) 
m:SaveSetting()
m:InputFinished()
m:Close()
DelSystemSetting(m)

end
NEW_FORM_SYSTEM_SET.C50484_OnClick = function( m )
m:DefaultSetting()
DefaultSetState(m)

end
NEW_FORM_SYSTEM_SET.C50535_OnDraw = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_SOUND)
nValue = nValue / 10
if nValue <0 then
nValue = 0
end
if nValue > 10 then
nValue = 10
end
DBGPRINTF("setState++++++------"..nValue)
UI_Engine.SetState(m.formIndex , UI3_COMPOSIT_535 , nValue)


end
NEW_FORM_SYSTEM_SET.C50536_OnDraw = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_MUSIC)
nValue = nValue / 10
if nValue <0 then
nValue = 0
end
if nValue > 10 then
nValue = 10
end

DBGPRINTF("setState++++++------"..nValue)
UI_Engine.SetState(m.formIndex , UI3_COMPOSIT_536 , nValue)

end
NEW_FORM_SYSTEM_SET.C50529_OnClick = function( m )
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
NEW_FORM_SYSTEM_SET.C50530_OnClick = function( m )
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
NEW_FORM_SYSTEM_SET.C50531_OnClick = function( m )
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
NEW_FORM_SYSTEM_SET.C50532_OnClick = function( m )
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
NEW_FORM_SYSTEM_SET.C50518_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_WORLDCHAT)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_518, nValue)


end
NEW_FORM_SYSTEM_SET.C50519_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_AREACHAT)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_519, nValue)


end
NEW_FORM_SYSTEM_SET.C50520_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_AROUNDCHAT)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_520, nValue)


end
NEW_FORM_SYSTEM_SET.C50521_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_TEAMCHAT)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_521, nValue)


end
NEW_FORM_SYSTEM_SET.C50522_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_UNIONCHAT)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_522, nValue)


end
NEW_FORM_SYSTEM_SET.C50523_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_PLAYERNAME)
if nValue > 0 then
nValue = 1
end
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_523, nValue)





end
NEW_FORM_SYSTEM_SET.C50524_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_PLAYERTITLE)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_524, nValue)


end
NEW_FORM_SYSTEM_SET.C50525_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_PLAYERUNION)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_525, nValue)


end
NEW_FORM_SYSTEM_SET.C50526_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_PETNAME)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_526, nValue)

end
NEW_FORM_SYSTEM_SET.C50527_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_NPCNAME)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_527, nValue)


end
NEW_FORM_SYSTEM_SET.C50528_OnLoad = function( m )
local nValue = m:GetItemState(SystemItem.SYSTEMSET_ITEM_BLOODBAR)
UI_Engine.SetState(m.formIndex, UI3_COMPOSIT_528, nValue)


end
NEW_FORM_SYSTEM_SET.C50472_OnLoad = function( m )
SetAnvItem(m,UI3_COMPOSIT_472,SystemAdvItem.SYSTEMSET_ITEM_PLAYERIMAGE)

end
NEW_FORM_SYSTEM_SET.C50473_OnLoad = function( m )
SetAnvItem(m,UI3_COMPOSIT_473,SystemAdvItem.SYSTEMSET_ITEM_PETAPPERENCEMODE)

end
NEW_FORM_SYSTEM_SET.C50474_OnLoad = function( m )
SetAnvItem(m,UI3_COMPOSIT_474,SystemAdvItem.SYSTEMSET_ITEM_AVATARMODE)

end
NEW_FORM_SYSTEM_SET.C50475_OnLoad = function( m )
SetAnvItem(m,UI3_COMPOSIT_475,SystemAdvItem.SYSTEMSET_ITEM_EFFECTMODE)

end
NEW_FORM_SYSTEM_SET.C50476_OnLoad = function( m )
SetAnvItem(m,UI3_COMPOSIT_476,SystemAdvItem.SYSTEMSET_ITEM_PETBUBBLE)

end
NEW_FORM_SYSTEM_SET.C50461_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_PLAYERIMAGE,1)
		SetAnvItem(m,UI3_COMPOSIT_472,SystemAdvItem.SYSTEMSET_ITEM_PLAYERIMAGE)


end
NEW_FORM_SYSTEM_SET.C50460_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_PLAYERIMAGE,0)
		SetAnvItem(m,UI3_COMPOSIT_472,SystemAdvItem.SYSTEMSET_ITEM_PLAYERIMAGE)
end
NEW_FORM_SYSTEM_SET.C50464_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_PETAPPERENCEMODE,1)
		SetAnvItem(m,UI3_COMPOSIT_473,SystemAdvItem.SYSTEMSET_ITEM_PETAPPERENCEMODE)

end
NEW_FORM_SYSTEM_SET.C50462_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_PETAPPERENCEMODE,0)
		SetAnvItem(m,UI3_COMPOSIT_473,SystemAdvItem.SYSTEMSET_ITEM_PETAPPERENCEMODE)


end
NEW_FORM_SYSTEM_SET.C50467_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_AVATARMODE,1)
SetAnvItem(m,UI3_COMPOSIT_474,SystemAdvItem.SYSTEMSET_ITEM_AVATARMODE)

end
NEW_FORM_SYSTEM_SET.C50466_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_AVATARMODE,0)
SetAnvItem(m,UI3_COMPOSIT_474,SystemAdvItem.SYSTEMSET_ITEM_AVATARMODE)

end
NEW_FORM_SYSTEM_SET.C50469_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_EFFECTMODE,1)
		SetAnvItem(m,UI3_COMPOSIT_475,SystemAdvItem.SYSTEMSET_ITEM_EFFECTMODE)


end
NEW_FORM_SYSTEM_SET.C50468_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_EFFECTMODE,0)
		SetAnvItem(m,UI3_COMPOSIT_475,SystemAdvItem.SYSTEMSET_ITEM_EFFECTMODE)



end
NEW_FORM_SYSTEM_SET.C50471_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_PETBUBBLE,1)
		SetAnvItem(m,UI3_COMPOSIT_476,SystemAdvItem.SYSTEMSET_ITEM_PETBUBBLE)

end
NEW_FORM_SYSTEM_SET.C50470_OnClick = function( m )
m:SetAdvItemState(SystemAdvItem.SYSTEMSET_ITEM_PETBUBBLE,0)
		SetAnvItem(m,UI3_COMPOSIT_476,SystemAdvItem.SYSTEMSET_ITEM_PETBUBBLE)


end
NEW_FORM_SYSTEM_SET.C50455_OnClick = function( m )
UI_Engine.SetFormTab( m.formIndex, 0)
m:SetTab(SystemTab.SYSTEMSET_TAB_SOUNDSET)

end
NEW_FORM_SYSTEM_SET.C50456_OnClick = function( m )
UI_Engine.SetFormTab( m.formIndex, 1)
m:SetTab(SystemTab.SYSTEMSET_TAB_PLAYERSHOW)

end
NEW_FORM_SYSTEM_SET.C50457_OnClick = function( m )
UI_Engine.SetFormTab( m.formIndex, 2)
m:SetTab(SystemTab.SYSTEMSET_TAB_UISHOW)

end
NEW_FORM_SYSTEM_SET.C50458_OnClick = function( m )
UI_Engine.SetFormTab( m.formIndex, 3)
m:SetTab(SystemTab.SYSTEMSET_TAB_ADVANCED)

end
