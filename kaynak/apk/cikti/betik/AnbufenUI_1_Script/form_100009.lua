NEW_FORM_SEARCHPLAYER= { }
NEW_FORM_SEARCHPLAYER.Main = function( m )
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
NEW_FORM_SEARCHPLAYER.C50164_OnLoad = function( m )
m.ID=""
m.name = ""
end
local HideMenu = function(m, mode)

	for i = 0, 5 do
		local id = UI1_COMPOSIT_PLAYER_QUERY_MENU1 + i
		UI_Engine.SetVisible(m.formIndex, id, mode)
	end
	UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_MENUBACK, mode)

	UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_HIDEMENU, mode)

end

local SetTab = function(m,TabIndex)
	if TabIndex == 0 then
		HideMenu(m,false)
		for i = 0,6 do
			local id = UI1_COMPOSIT_PLAYER_QUERY_LIST1 + i
			UI_Engine.SetVisible(m.formIndex, id, false)
		end
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_NAMEINPUT, true)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_IDINPUT, true)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_NAME, true)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_ID, true)	
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_BUTTON2, true)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_BUTTON_LEFT, false)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_BUTTON_RIGHT, false)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_BUTTON_LEFT_NULL, false)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_BUTTON_RIGHT_NULL, false)
		UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_BUTTON2, STR_SEARCH)
	else
		HideMenu(m,true)
		for i = 0, 6 do
			local id = UI1_COMPOSIT_PLAYER_QUERY_LIST1 + i
			UI_Engine.SetVisible(m.formIndex, id, true)
		end
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_MENUBACK, false)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_HIDEMENU, false)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_NAMEINPUT, false)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_IDINPUT, false)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_NAME, false)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_ID, false)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_BUTTON2, false)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_BUTTON_LEFT, true)
		UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_BUTTON_RIGHT, true)
	end
end

local DoSearch = function(m)
	HideMenu(m,false)
	UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_NAMEINPUT, false)
	UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_IDINPUT, false)
	UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_NAME, false)
	UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_ID, false)
	UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_BUTTON1, false)
	UI_Engine.SetVisible(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_BUTTON2, false)

	UI_Engine.SetFormTab(m.formIndex, 1)
	--m:GetUserInput(m.name, m.ID)
	m:SendSearchMsg(0,m.name,m.ID)
end
NEW_FORM_SEARCHPLAYER.C50165_OnClick = function( m )
m.InputBox = OpenInputBox(m,m.name,16)
m.InputBox :WaitUserInput(m)
m.name = m.InputBox :GetResult()


--m.name = GetInput(m, UI1_COMPOSIT_PLAYER_QUERY_NAMEINPUT)
if Tools.JudgeSpecialWord(m.name) then
	WarnUser(m, R_STRING_CANNOT_INPUT_SPECIAL)
	m.name = ""
--	UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_NAMEINPUT, m.name)
end
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_NAMEINPUT, m.name)

end
NEW_FORM_SEARCHPLAYER.C50166_OnClick = function( m )
m.InputBox = OpenInputBox(m,m.ID,16)
m.InputBox :WaitUserInput(m)
m.ID = m.InputBox :GetResult()
--m.ID = GetInput(m, UI1_COMPOSIT_PLAYER_QUERY_IDINPUT)
if false == Tools.IsNumberOnly(m.ID) then
	WarnUser(m, R_STRING_INPUT_NUMBER_ONLY)
	m.ID = 0
--	UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_IDINPUT, m.ID)
end
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_IDINPUT, m.ID)
end
NEW_FORM_SEARCHPLAYER.C50140_OnClick = function( m )
SetTab(m,0)
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_BUTTON2, STR_SEARCH)
HideMenu(m,false)
m:OnClear()
--m:SendSearchMsg(0)
end
NEW_FORM_SEARCHPLAYER.C50141_OnClick = function( m )
SetTab(m,1)
UI_Engine.SetFormTab(m.formIndex, 1)
--UI_Engine.SetText(m.formIndex, COMPOSIT_1275, R_STRING_ONLINE_PLAYER)
--SetControlMode(m, false)
m:SendSearchMsg(1)
end
NEW_FORM_SEARCHPLAYER.C50142_OnLoad = function( m )
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_BUTTON2, STR_SEARCH)
end
NEW_FORM_SEARCHPLAYER.C50142_OnClick = function( m )
local tab = UI_Engine.GetFormTab(m.formIndex)
if tab == 0 then
	DoSearch(m)
else
	m:Next()
end

end
NEW_FORM_SEARCHPLAYER.C50338_OnClick = function( m )
m:Next()
end
NEW_FORM_SEARCHPLAYER.C50337_OnClick = function( m )
m:Last()
end
NEW_FORM_SEARCHPLAYER.C50157_OnClick = function( m )
m:OnClick(0)
end
NEW_FORM_SEARCHPLAYER.C50158_OnClick = function( m )
m:OnClick(1)
end
NEW_FORM_SEARCHPLAYER.C50159_OnClick = function( m )
m:OnClick(2)
end
NEW_FORM_SEARCHPLAYER.C50160_OnClick = function( m )
m:OnClick(3)
end
NEW_FORM_SEARCHPLAYER.C50161_OnClick = function( m )
m:OnClick(4)
end
NEW_FORM_SEARCHPLAYER.C50162_OnClick = function( m )
m:OnClick(5)
end
NEW_FORM_SEARCHPLAYER.C50163_OnClick = function( m )
HideMenu(m,false)
end
NEW_FORM_SEARCHPLAYER.C50156_OnClick = function( m )
DelSearchPlayer(m)
end
NEW_FORM_SEARCHPLAYER.C50167_OnClick = function( m )
m:Click(m.offset + 0)
end
NEW_FORM_SEARCHPLAYER.C50167_OnUpdate = function( m )
local name,str= m:GetSearchResult(m.offset+0)
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_LIST1, name, 0)
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_LIST1, str, 1)
end
NEW_FORM_SEARCHPLAYER.C50168_OnClick = function( m )
m:Click(m.offset + 1)
end
NEW_FORM_SEARCHPLAYER.C50168_OnUpdate = function( m )
local name,str= m:GetSearchResult(m.offset+1)
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_LIST2, name, 0)
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_LIST2, str, 1)
end
NEW_FORM_SEARCHPLAYER.C50169_OnClick = function( m )
m:Click(m.offset + 2)
end
NEW_FORM_SEARCHPLAYER.C50169_OnUpdate = function( m )
local name,str= m:GetSearchResult(m.offset+2)
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_LIST3, name, 0)
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_LIST3, str, 1)
end
NEW_FORM_SEARCHPLAYER.C50170_OnClick = function( m )
m:Click(m.offset + 3)
end
NEW_FORM_SEARCHPLAYER.C50170_OnUpdate = function( m )
local name,str= m:GetSearchResult(m.offset+3)
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_LIST4, name, 0)
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_LIST4, str, 1)
end
NEW_FORM_SEARCHPLAYER.C50171_OnClick = function( m )
m:Click(m.offset + 4)
end
NEW_FORM_SEARCHPLAYER.C50171_OnUpdate = function( m )
local name,str= m:GetSearchResult(m.offset+4)
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_LIST5, name, 0)
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_LIST5, str, 1)
end
NEW_FORM_SEARCHPLAYER.C50172_OnClick = function( m )
m:Click(m.offset + 5)
end
NEW_FORM_SEARCHPLAYER.C50172_OnUpdate = function( m )
local name,str= m:GetSearchResult(m.offset+5)
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_LIST6, name, 0)
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_LIST6, str, 1)
end
NEW_FORM_SEARCHPLAYER.C50173_OnClick = function( m )
m:Click(m.offset + 6)
end
NEW_FORM_SEARCHPLAYER.C50173_OnUpdate = function( m )
local name,str= m:GetSearchResult(m.offset+6)
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_LIST7, name, 0)
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_PLAYER_QUERY_LIST7, str, 1)
end
