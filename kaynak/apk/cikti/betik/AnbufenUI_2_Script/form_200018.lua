NEW_FORM_NEW_CHAT= { }
NEW_FORM_NEW_CHAT.Main = function( m )
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
NEW_FORM_NEW_CHAT.C50454_OnLoad = function( m )
m.tab = 0
m.bPaste = false
end
local QueryUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_OK)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local SetTabState = function(m)
	UI_Engine.SetState(m.formIndex, UI2_COMPOSIT_433 , 0)
	UI_Engine.SetState(m.formIndex, UI2_COMPOSIT_434 , 0)
	UI_Engine.SetState(m.formIndex, UI2_COMPOSIT_435 , 0)
	UI_Engine.SetState(m.formIndex, UI2_COMPOSIT_436 , 0)
	UI_Engine.SetState(m.formIndex, UI2_COMPOSIT_437 , 0)
	UI_Engine.SetState(m.formIndex, UI2_COMPOSIT_871, 0)
	if m.tab == WorldChannel.AFFICHE_CHANNEL_TEAM then
		UI_Engine.SetState(m.formIndex, UI2_COMPOSIT_436 , 1)
	elseif m.Tab == WorldChannel.AFFICHE_CHANNEL_WORLD then
		UI_Engine.SetState(m.formIndex, UI2_COMPOSIT_433 , 1)
	elseif m.Tab == WorldChannel.AFFICHE_CHANNEL_AREA then
		UI_Engine.SetState(m.formIndex, UI2_COMPOSIT_434 , 1)
	elseif m.Tab == WorldChannel.AFFICHE_CHANNEL_AROUND then
		UI_Engine.SetState(m.formIndex, UI2_COMPOSIT_435 , 1)
	elseif m.Tab == WorldChannel.AFFICHE_CHANNEL_UNION then
		UI_Engine.SetState(m.formIndex, UI2_COMPOSIT_437 , 1)
	end
end

local Copy = function(m)
	m:Copy()
	m:Paste()
	m.bPaste = true
end

local HideMenu = function(m, mode)
	local reverse = false
	if mode == true then
		reverse = false
	else
		reverse = true
	end
	for i = 0, 7 do
		local id = UI2_COMPOSIT_443 + i
		UI_Engine.SetVisible(m.formIndex, id, mode)
	end
	UI_Engine.SetVisible(m.formIndex, id, mode)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_453, mode)
	UI_Engine.SetVisible(m.formIndex, UI2_COMPOSIT_452, mode)
end

local DoMenu = function(m, index)
	local type = m:GetMenuType(index)
	if nil == type then
		return
	end
	if type == Chat.MENU_SINGLE_CHAT then
		m:SingleChat(m.userSelectItem)
	elseif type == Chat.MENU_PLAYER_INFO then
		m:OpenPlayerInfo()
	elseif type == Chat.MENU_INVATE_TEAM then
		m:InviteTeam()
	elseif type == Chat.MENU_INVITE_DEAL then
		m:InviteDeal()
	elseif type == Chat.MENU_ADD_FIREND then
		m:AddFriend()
	elseif type == Chat.MENU_ADD_BLACK then
		m:AddBlack()
	elseif type == Chat.MENU_COPY then
		Copy(m)
	end
end
NEW_FORM_NEW_CHAT.C50452_OnClick = function( m )
m:GetMenuType(100)
m:SetSel()
end
NEW_FORM_NEW_CHAT.C50451_OnClick = function( m )
m:Close()
end
NEW_FORM_NEW_CHAT.C50450_OnClick = function( m )
DoMenu(m, 6)
end
NEW_FORM_NEW_CHAT.C50449_OnClick = function( m )
DoMenu(m, 5)
end
NEW_FORM_NEW_CHAT.C50448_OnClick = function( m )
DoMenu(m, 4)
end
NEW_FORM_NEW_CHAT.C50447_OnClick = function( m )
DoMenu(m, 3)
end
NEW_FORM_NEW_CHAT.C50446_OnClick = function( m )
DoMenu(m, 2)
end
NEW_FORM_NEW_CHAT.C50445_OnClick = function( m )
DoMenu(m, 1)
end
NEW_FORM_NEW_CHAT.C50444_OnClick = function( m )
DoMenu(m, 0)
end
NEW_FORM_NEW_CHAT.C50442_OnClick = function( m )
m.Face = NewFace(m)
m.Face :WaitUserInput(m)
local result = m.Face :GetSel()
DelFace(m.Face )

if result ~= -1 then
	m:SetFaceInput(result)
	m.bPaste = true
end
end
NEW_FORM_NEW_CHAT.C50441_OnClick = function( m )
m:OnClickSendMsg()
UI_Engine.SetText(m.formIndex,UI2_COMPOSIT_439,"")
end
NEW_FORM_NEW_CHAT.C50439_OnClick = function( m )
local userInput = m:GetUserInput()
m.InputBox = OpenInputBox(m,userInput ,100)
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
m:SetUserInput(result)
local text = m:GetBubbleDisplay()
CurrentControl.SetTextWithFaceIcon(text )
end
NEW_FORM_NEW_CHAT.C50439_OnDraw = function( m )
if m.bPaste == true then
	local text = m:GetBubbleDisplay()
	CurrentControl.SetTextWithFaceIcon(text )
	m.bPaste = false
end
end
NEW_FORM_NEW_CHAT.C50433_OnClick = function( m )
if m:SetTab(WorldChannel.AFFICHE_CHANNEL_WORLD) then
	m.tab = WorldChannel.AFFICHE_CHANNEL_WORLD
	UI_Engine.SetFormTab(m.formIndex, 0)
end
end
NEW_FORM_NEW_CHAT.C50434_OnClick = function( m )
if m:SetTab(WorldChannel.AFFICHE_CHANNEL_AREA) then
	m.tab = WorldChannel.AFFICHE_CHANNEL_AREA
	UI_Engine.SetFormTab(m.formIndex, 0)
end
end
NEW_FORM_NEW_CHAT.C50435_OnClick = function( m )
if m:SetTab(WorldChannel.AFFICHE_CHANNEL_AROUND) then
	m.tab = WorldChannel.AFFICHE_CHANNEL_AROUND
	UI_Engine.SetFormTab(m.formIndex, 0)
end
end
NEW_FORM_NEW_CHAT.C50436_OnLoseFocus = function( m )
SetTabState(m)
end
NEW_FORM_NEW_CHAT.C50436_OnClick = function( m )
if m:SetTab(WorldChannel.AFFICHE_CHANNEL_TEAM) then
	m.tab = WorldChannel.AFFICHE_CHANNEL_TEAM
	UI_Engine.SetFormTab(m.formIndex, 0)
else
	SetTabState(m)
	--WarnUser(m, STR_NO_TEAM)
end
end
NEW_FORM_NEW_CHAT.C50437_OnLoseFocus = function( m )
SetTabState(m)
end
NEW_FORM_NEW_CHAT.C50437_OnClick = function( m )
if m:SetTab(WorldChannel.AFFICHE_CHANNEL_UNION) then
	m.tab = WorldChannel.AFFICHE_CHANNEL_UNION
	UI_Engine.SetFormTab(m.formIndex, 0)
else
	SetTabState(m)
	--WarnUser(m, R_STRING_UNION_MAIN_ERR_NO_UNION)
end
end
NEW_FORM_NEW_CHAT.C50871_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 1)
m:SetSysMsg()
end
NEW_FORM_NEW_CHAT.C50431_OnLoad = function( m )
HideMenu(m, false)
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_NEW_CHAT.C50431_OnDraw = function( m )
m:DrawTitle()
end
