FORM_SEARCHPLAYER= { }
FORM_SEARCHPLAYER.Main = function( m )
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
FORM_SEARCHPLAYER.C52946_OnLoad = function( m )
m.ID=""
m.name = ""
end
FORM_SEARCHPLAYER.C52946_OnClick = function( m )
m:OnClick(5)
end
FORM_SEARCHPLAYER.C52945_OnClick = function( m )
m:OnClick(4)
end
FORM_SEARCHPLAYER.C52944_OnClick = function( m )
m:OnClick(3)
end
FORM_SEARCHPLAYER.C52943_OnClick = function( m )
m:OnClick(2)
end
FORM_SEARCHPLAYER.C52942_OnClick = function( m )
m:OnClick(1)
end
FORM_SEARCHPLAYER.C52941_OnClick = function( m )
m:OnClick(0)
end
FORM_SEARCHPLAYER.C52759_OnClick = function( m )
m:Next()
end
FORM_SEARCHPLAYER.C52578_OnClick = function( m )
m:Click(m.offset)
end
FORM_SEARCHPLAYER.C52578_OnUpdate = function( m )
local name,str = m:GetSearchResult(m.offset)
UI_Engine.SetText(m.formIndex, COMPOSIT_2578, name, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_2578, str, 1)

end
FORM_SEARCHPLAYER.C52579_OnClick = function( m )
m:Click(m.offset + 1)
end
FORM_SEARCHPLAYER.C52579_OnUpdate = function( m )
local name,str = m:GetSearchResult(m.offset+1)
UI_Engine.SetText(m.formIndex, COMPOSIT_2579, name, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_2579, str, 1)
end
FORM_SEARCHPLAYER.C52580_OnClick = function( m )
m:Click(m.offset + 2)
end
FORM_SEARCHPLAYER.C52580_OnUpdate = function( m )
local name,str= m:GetSearchResult(m.offset+2)
UI_Engine.SetText(m.formIndex, COMPOSIT_2580, name, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_2580, str, 1)
end
FORM_SEARCHPLAYER.C52581_OnClick = function( m )
m:Click(m.offset + 3)
end
FORM_SEARCHPLAYER.C52581_OnUpdate = function( m )
local name ,str= m:GetSearchResult(m.offset+3)
UI_Engine.SetText(m.formIndex, COMPOSIT_2581, name, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_2581, str, 1)

end
FORM_SEARCHPLAYER.C52582_OnClick = function( m )
m:Click(m.offset + 4)
end
FORM_SEARCHPLAYER.C52582_OnUpdate = function( m )
local name,str = m:GetSearchResult(m.offset+4)
UI_Engine.SetText(m.formIndex, COMPOSIT_2582, name, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_2582, str, 1)

end
FORM_SEARCHPLAYER.C52583_OnClick = function( m )
m:Click(m.offset + 5)
end
FORM_SEARCHPLAYER.C52583_OnUpdate = function( m )
local name,str = m:GetSearchResult(m.offset+5)
UI_Engine.SetText(m.formIndex, COMPOSIT_2583, name, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_2583, str, 1)

end
FORM_SEARCHPLAYER.C52584_OnClick = function( m )
m:Click(m.offset + 6)
end
FORM_SEARCHPLAYER.C52584_OnUpdate = function( m )
local name ,str= m:GetSearchResult(m.offset+6)
UI_Engine.SetText(m.formIndex, COMPOSIT_2584, name, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_2584, str, 1)
end
FORM_SEARCHPLAYER.C52749_OnClick = function( m )
m:Click(m.offset + 7)
end
FORM_SEARCHPLAYER.C52749_OnUpdate = function( m )
local name ,str= m:GetSearchResult(m.offset+7)
UI_Engine.SetText(m.formIndex, COMPOSIT_2749, name, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_2749, str, 1)
end
FORM_SEARCHPLAYER.C51259_OnClick = function( m )
m.InputBox = OpenInputBox(m,m.name,16)
m.InputBox :WaitUserInput(m)
m.name = m.InputBox :GetResult()


--m.name = GetInput(m, COMPOSIT_1259)
if Tools.JudgeSpecialWord(m.name) then
	WarnUser(m, "输入不合法, 请重新输入!")
	m.name = ""
--	UI_Engine.SetText(m.formIndex, COMPOSIT_1259, m.name)
end
UI_Engine.SetText(m.formIndex, COMPOSIT_1259, m.name)

end
FORM_SEARCHPLAYER.C52758_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 1)
--m:GetUserInput(m.name, m.ID)
m:SendSearchMsg(0,m.name,m.ID)
end
FORM_SEARCHPLAYER.C51260_OnClick = function( m )
m.InputBox = OpenInputBox(m,m.ID,16)
m.InputBox :WaitUserInput(m)
m.ID = m.InputBox :GetResult()
--m.ID = GetInput(m, COMPOSIT_1260)
if false == Tools.IsNumberOnly(m.ID) then
	WarnUser(m, "仅接受数字输入!")
	m.ID = 0
--	UI_Engine.SetText(m.formIndex, COMPOSIT_1260, m.ID)
end
UI_Engine.SetText(m.formIndex, COMPOSIT_1260, m.ID)

end
FORM_SEARCHPLAYER.C51258_OnLoad = function( m )
UI_Engine.SetText(m.formIndex, COMPOSIT_1258, "搜索玩家")
end
FORM_SEARCHPLAYER.C52738_OnClick = function( m )
--m:InputFinished()

DelSearchPlayer(m)
end
FORM_SEARCHPLAYER.C51283_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_1258, "搜索玩家")
m:OnClear()
--m:SendSearchMsg(0)
end
FORM_SEARCHPLAYER.C51284_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetText(m.formIndex, COMPOSIT_1275, "在线玩家")
--SetControlMode(m, false)
m:SendSearchMsg(1)
end
