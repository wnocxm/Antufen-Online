FORM_CHAT= { }
FORM_CHAT.Main = function( m )
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
FORM_CHAT.C51943_OnLoad = function( m )
m.bDrawFunction = false
local title = m:GetTitle() 
UI_Engine.SetText(m.formIndex,COMPOSIT_TITLE,title)
end

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

local SetTabVisible = function(m , bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_TAB_WORLD,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_TAB_AREA,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_TAB_ARUOND,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_TAB_TEAM,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_TAB_UNION,bDarw)
	UI_Engine.SetVisible(m.formIndex ,COMPOSIT_2777,bDarw)
end

local SetFunctionVisible = function(m , bDarw)
	m.bDrawFunction = bDarw
	--UI_Engine.SetVisible(m.formIndex ,COMPOSIT_PLAY_INFO,bDarw)
	--UI_Engine.SetVisible(m.formIndex ,COMPOSIT_ADD_FRIEND,bDarw)
	--UI_Engine.SetVisible(m.formIndex ,COMPOSIT_ADD_ITEM,bDarw)
	--UI_Engine.SetVisible(m.formIndex ,COMPOSIT_ADD_DEAL,bDarw)
	--UI_Engine.SetVisible(m.formIndex ,COMPOSIT_ADD_BLACK,bDarw)
	--UI_Engine.SetVisible(m.formIndex ,COMPOSIT_PRIVATE,bDarw)
	--UI_Engine.SetVisible(m.formIndex ,COMPOSIT_FULL_INFO,bDarw)
end

local UpDataPaste = function(m)
	if m:CanPaste() then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_PASTE,true)
	else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_PASTE,false)
	end
end

local UpDataTitle = function(m)
	local title = m:GetTitle() 
	UI_Engine.SetText(m.formIndex,COMPOSIT_TITLE,title)
end


local SetTabState = function(m)
	UI_Engine.SetState(m.formIndex, COMPOSIT_TAB_WORLD , 0)
	UI_Engine.SetState(m.formIndex, COMPOSIT_TAB_AREA , 0)
	UI_Engine.SetState(m.formIndex, COMPOSIT_TAB_ARUOND , 0)
	UI_Engine.SetState(m.formIndex, COMPOSIT_TAB_TEAM , 0)
	UI_Engine.SetState(m.formIndex, COMPOSIT_TAB_UNION , 0)
	if m.Tab == WorldChannel.AFFICHE_CHANNEL_TEAM then
		UI_Engine.SetState(m.formIndex, COMPOSIT_TAB_TEAM , 1)
	elseif m.Tab == WorldChannel.AFFICHE_CHANNEL_WORLD then
		UI_Engine.SetState(m.formIndex, COMPOSIT_TAB_WORLD , 1)
	elseif m.Tab == WorldChannel.AFFICHE_CHANNEL_AREA then
		UI_Engine.SetState(m.formIndex, COMPOSIT_TAB_AREA , 1)
	elseif m.Tab == WorldChannel.AFFICHE_CHANNEL_AROUND then
		UI_Engine.SetState(m.formIndex, COMPOSIT_TAB_ARUOND , 1)
	elseif m.Tab == WorldChannel.AFFICHE_CHANNEL_UNION then
		UI_Engine.SetState(m.formIndex, COMPOSIT_TAB_UNION , 1)
	end
	
end
FORM_CHAT.C51944_OnLoad = function( m )
if m:GetChannelTab() == ChatChannel.WCHAT_CHANNEL_AFFICHE then
SetTabVisible(m, true)
m.Tab = WorldChannel.AFFICHE_CHANNEL_WORLD
else
SetTabVisible(m, false)
end
end
FORM_CHAT.C51944_OnClick = function( m )
SetFunctionVisible(m, false)

if m:SetTab(WorldChannel.AFFICHE_CHANNEL_WORLD) then
	m.Tab = WorldChannel.AFFICHE_CHANNEL_WORLD
	UI_Engine.UpdateList(m.formIndex, COMPOSIT_LIST_0)
	UpDataTitle(m)
else
	WarnUser(m,"Not OPen world")
end

end
FORM_CHAT.C51941_OnClick = function( m )
SetFunctionVisible(m, false)

if m:SetTab(WorldChannel.AFFICHE_CHANNEL_AREA) then
	m.Tab = WorldChannel.AFFICHE_CHANNEL_AREA
	UpDataTitle(m)
	UI_Engine.UpdateList(m.formIndex, COMPOSIT_LIST_0)
else
WarnUser(m,"Not OPen area")
end
end
FORM_CHAT.C51940_OnClick = function( m )
SetFunctionVisible(m, false)

if m:SetTab(WorldChannel.AFFICHE_CHANNEL_AROUND) then
	m.Tab = WorldChannel.AFFICHE_CHANNEL_AROUND
	UpDataTitle(m)
	UI_Engine.UpdateList(m.formIndex, COMPOSIT_LIST_0)
else
	WarnUser(m,"Not OPen around")
end

end
FORM_CHAT.C51939_OnClick = function( m )
SetFunctionVisible(m, false)

if m:SetTab(WorldChannel.AFFICHE_CHANNEL_TEAM) then
	m.Tab = WorldChannel.AFFICHE_CHANNEL_TEAM
	UpDataTitle(m)
	UI_Engine.UpdateList(m.formIndex, COMPOSIT_LIST_0)
else
	WarnUser(m,"你没有组队")
	SetTabState(m)
end

end
FORM_CHAT.C51938_OnClick = function( m )
SetFunctionVisible(m, false)

if m:SetTab(WorldChannel.AFFICHE_CHANNEL_UNION) then
	m.Tab = WorldChannel.AFFICHE_CHANNEL_UNION
	UpDataTitle(m)
	UI_Engine.UpdateList(m.formIndex, COMPOSIT_LIST_0)

else
	WarnUser(m,"没有加入公会")
	SetTabState(m)
end

end
FORM_CHAT.C51948_OnClick = function( m )

if m:IsSelectMine(m.userSelectItem) then
	WarnUser(m,"无法打开自己的资料")
	return 
end

if m:CanQueryInfo(m.userSelectItem) == false then
	WarnUser(m,"无法打开此玩家资料")
	return 
end

m:OpenPlayerInfo(m.userSelectItem)
SetFunctionVisible(m, false)
m:Close()



end
FORM_CHAT.C51947_OnClick = function( m )
if m:IsSelectMine(m.userSelectItem) then
	WarnUser(m,"不能添加自己为好友")
	return 
end

if m:CanAddFriend(m.userSelectItem) == false then
	WarnUser(m,"不能添加好友")
	return 
end

m:AddFriend(m.userSelectItem)
SetFunctionVisible(m, false)
end
FORM_CHAT.C51946_OnClick = function( m )

if m:IsSelectMine(m.userSelectItem) then
	WarnUser(m,"不能加组队自己")
	return 
end

if m:CanInviteTeam(m.userSelectItem) == false then
	WarnUser(m,"不能够组队")
	return 
end

m:InviteTeam(m.userSelectItem)
SetFunctionVisible(m, false)
end
FORM_CHAT.C51945_OnClick = function( m )
if m:IsSelectMine(m.userSelectItem) then
	WarnUser(m,"不能与自己交易")
	return 
end

if m:CanInviteTrade(m.userSelectItem) == false then
	WarnUser(m,"不能够交易")
	return 
end

m:InviteDeal(m.userSelectItem)
SetFunctionVisible(m, false)
m:Close()
end
FORM_CHAT.C52018_OnClick = function( m )

if m:IsSelectMine(m.userSelectItem) then
	WarnUser(m,"不能加自己为黑名单")
	return 
end

if m:CanAddBlack(m.userSelectItem) == false then
	WarnUser(m,"不能够加黑名单")
	return 
end

m:AddBlack(m.userSelectItem)
SetFunctionVisible(m, false)
end
FORM_CHAT.C51968_OnLoad = function( m )
if m:GetChannelTab() == ChatChannel.WCHAT_CHANNEL_AFFICHE then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_PRIVATE,true)
else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_PRIVATE,false)
end
end
FORM_CHAT.C51968_OnClick = function( m )

if m:IsSelectMine(m.userSelectItem) then
	WarnUser(m,"不能和自己聊天")
	return 
end

if m:CanChat(m.userSelectItem) == false then
	WarnUser(m,"不能够聊天")
	return 
end

m:SingleChat(m.userSelectItem)
SetFunctionVisible(m, false)
end
FORM_CHAT.C51942_OnClick = function( m )
local   strtitle , strInfo = m:FullDisplay(m.userSelectItem) 

if strtitle ~=nil then
	NewInfoText(m, strtitle , strInfo )
end

SetFunctionVisible(m, false)
end
FORM_CHAT.C52789_OnClick = function( m )
if UI_Engine.GetState(m.formIndex,COMPOSIT_CHAT_INPUTRECT) == 0 then
	m:Copy(1,m.userSelectItem)
else
	m:Copy(0,0)
end

UpDataPaste(m)
end
FORM_CHAT.C52788_OnLoad = function( m )
UpDataPaste(m)

m.bPaste = false
end
FORM_CHAT.C52788_OnClick = function( m )
m:Paste()
local userInput = m:GetUserInput()
--UI_Engine.SetText(m.formIndex,COMPOSIT_CHAT_INPUTRECT,userInput )
m.bPaste = true

end
FORM_CHAT.C50241_OnClick = function( m )
m.Face = NewFace(m)
m.Face :WaitUserInput(m)
local result = m.Face :GetSel()
DelFace(m.Face )

m:SetFaceInput(result)
m.bPaste = true
--local text = m:GetBubbleDisplay()
--CurrentControl.SetTextWithFaceIcon(text )
--local userInput = m:GetUserInput()
--UI_Engine.SetText(m.formIndex,COMPOSIT_CHAT_INPUTRECT,userInput )

end
FORM_CHAT.C52786_OnClick = function( m )
m:OnClickSendMsg()
UI_Engine.SetText(m.formIndex,COMPOSIT_CHAT_INPUTRECT,"")
UI_Engine.UpdateList(m.formIndex, COMPOSIT_LIST_0)
end
FORM_CHAT.C52021_OnClick = function( m )
SetFunctionVisible(m, false)
local userInput = m:GetUserInput()
m.InputBox = OpenInputBox(m,userInput ,100)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserInput(result)
local text = m:GetBubbleDisplay()
--UI_Engine.SetText(m.formIndex,COMPOSIT_CHAT_INPUTRECT,text)
CurrentControl.SetTextWithFaceIcon(text )


end
FORM_CHAT.C52021_OnDraw = function( m )

if m.bPaste == true then
	local text = m:GetBubbleDisplay()
	CurrentControl.SetTextWithFaceIcon(text )
	m.bPaste = false
end
end
FORM_CHAT.C52756_OnClick = function( m )
m:Close()
end
FORM_CHAT.C50239_OnClick = function( m )
m:Close()
end
FORM_CHAT.C52023_OnClick = function( m )
SetFunctionVisible(m, false)
UI_Engine.SetState(m.formIndex,COMPOSIT_CHAT_INPUTRECT, 0)

DBGPRINTF("userSelectItem = "..m.userSelectItem)
DBGPRINTF("offset = "..m.offset)
end
FORM_CHAT.C52023_OnUpdate = function( m )

	local strName = m:GetListText(m.offset + 0)

	if strName == nil then
		CurrentControl.SetTextWithFaceIcon(nil)
		DBGPRINTF("SetTab1ListText strName ===null" )
	else
		CurrentControl.SetTextWithFaceIcon(strName)
		DBGPRINTF("SetTab1ListText strName ok ")
	end
end
FORM_CHAT.C52024_OnClick = function( m )
SetFunctionVisible(m, false)
UI_Engine.SetState(m.formIndex,COMPOSIT_CHAT_INPUTRECT, 0)

DBGPRINTF("userSelectItem = "..m.userSelectItem)
DBGPRINTF("offset = "..m.offset)
end
FORM_CHAT.C52024_OnUpdate = function( m )
	local strName = m:GetListText(m.offset + 1)

	if strName == nil then
		CurrentControl.SetTextWithFaceIcon(nil)
		DBGPRINTF("SetTab1ListText strName ===null" )
	else
		CurrentControl.SetTextWithFaceIcon(strName)
		DBGPRINTF("SetTab1ListText strName ok ")
	end
end
FORM_CHAT.C52025_OnClick = function( m )
SetFunctionVisible(m, false)
UI_Engine.SetState(m.formIndex,COMPOSIT_CHAT_INPUTRECT, 0)

DBGPRINTF("userSelectItem = "..m.userSelectItem)
DBGPRINTF("offset = "..m.offset)
end
FORM_CHAT.C52025_OnUpdate = function( m )
	local strName = m:GetListText(m.offset + 2)

	if strName == nil then
		CurrentControl.SetTextWithFaceIcon(nil)
		DBGPRINTF("SetTab1ListText strName ===null" )
	else
		CurrentControl.SetTextWithFaceIcon(strName)
				DBGPRINTF("SetTab1ListText strName ok ")
	end
end
FORM_CHAT.C52026_OnClick = function( m )
SetFunctionVisible(m, false)
UI_Engine.SetState(m.formIndex,COMPOSIT_CHAT_INPUTRECT, 0)

DBGPRINTF("userSelectItem = "..m.userSelectItem)
DBGPRINTF("offset = "..m.offset)
end
FORM_CHAT.C52026_OnUpdate = function( m )
	local strName = m:GetListText(m.offset + 3)

	if strName == nil then
		CurrentControl.SetTextWithFaceIcon(nil)
		DBGPRINTF("SetTab1ListText strName ===null" )
	else
		CurrentControl.SetTextWithFaceIcon(strName)
				DBGPRINTF("SetTab1ListText strName ok ")
	end
end
FORM_CHAT.C51937_OnClick = function( m )
SetFunctionVisible(m, false)
UI_Engine.SetState(m.formIndex,COMPOSIT_CHAT_INPUTRECT, 0)

DBGPRINTF("userSelectItem = "..m.userSelectItem)
DBGPRINTF("offset = "..m.offset)
end
FORM_CHAT.C51937_OnUpdate = function( m )
	local strName = m:GetListText(m.offset + 4)

	if strName == nil then
		CurrentControl.SetTextWithFaceIcon(nil)
		DBGPRINTF("SetTab1ListText strName ===null" )
	else
		CurrentControl.SetTextWithFaceIcon(strName)
				DBGPRINTF("SetTab1ListText strName ok ")
	end
end
FORM_CHAT.C51936_OnClick = function( m )
SetFunctionVisible(m, false)
UI_Engine.SetState(m.formIndex,COMPOSIT_CHAT_INPUTRECT, 0)

DBGPRINTF("userSelectItem = "..m.userSelectItem)
DBGPRINTF("offset = "..m.offset)
end
FORM_CHAT.C51936_OnUpdate = function( m )
	local strName = m:GetListText(m.offset + 5)

	if strName == nil then
		CurrentControl.SetTextWithFaceIcon(nil)
		DBGPRINTF("SetTab1ListText strName ===null" )
	else
		CurrentControl.SetTextWithFaceIcon(strName)
				DBGPRINTF("SetTab1ListText strName ok ")
	end
end
FORM_CHAT.C51935_OnClick = function( m )
SetFunctionVisible(m, false)
UI_Engine.SetState(m.formIndex,COMPOSIT_CHAT_INPUTRECT, 0)

DBGPRINTF("userSelectItem = "..m.userSelectItem)
DBGPRINTF("offset = "..m.offset)
end
FORM_CHAT.C51935_OnUpdate = function( m )
	local strName = m:GetListText(m.offset + 6)

	if strName == nil then
		CurrentControl.SetTextWithFaceIcon(nil)
		DBGPRINTF("SetTab1ListText strName ===null" )
	else
		CurrentControl.SetTextWithFaceIcon(strName)
		DBGPRINTF("SetTab1ListText strName ok ")
	end
end
