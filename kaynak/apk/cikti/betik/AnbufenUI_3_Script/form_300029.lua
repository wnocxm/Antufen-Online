NEW_FORM_UNION_CREATE= { }
NEW_FORM_UNION_CREATE.Main = function( m )
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
NEW_FORM_UNION_CREATE.C50549_OnLoad = function( m )
DBGPRINTF("lua_info:new form created")
m.unionName = ""
m.name = ""
m.begin = false
local describe = m:Init()
--UI_Engine.SetText(m.formIndex, COMPOSIT_1314, "创建公会")
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_624, describe, 0)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_839, false)

end
local GetInput = function(m, ctlID)		-- 创建输入框
	local text = UI_Engine.GetText(m.formIndex, ctlID)
	m.InputBox = OpenInputBox(m,text,16)
	m.InputBox :WaitUserInput(m)
	local result = m.InputBox :GetResult()
	UI_Engine.SetText(m.formIndex, ctlID, result, 0)
	return result
end
local UpdateText = function(m, offset, ctlID)
	if true == m.begin then
		local unionName, memberCount, fame, chairmanName = m:GetUnionList(offset)
		UI_Engine.SetText(m.formIndex, ctlID, unionName, 0)
		UI_Engine.SetText(m.formIndex, ctlID, memberCount, 1)
		UI_Engine.SetText(m.formIndex, ctlID, fame, 2)
		UI_Engine.SetText(m.formIndex, ctlID, chairmanName, 3)
	end
end
NEW_FORM_UNION_CREATE.C50550_OnClick = function( m )
local mode = m:GetMode()
if 0 == mode then
	DelUnionCreate(m)
else
	m:InputFinished()
end

end
NEW_FORM_UNION_CREATE.C50641_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_640, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_635, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_636, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_637, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_638, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_639, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_633, false)
UI_Engine.SetLevel(m.formIndex, 2)
end
NEW_FORM_UNION_CREATE.C50642_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetLevel(m.formIndex, 2)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_839, false)
end
NEW_FORM_UNION_CREATE.C50635_OnClick = function( m )
m:OnClickMenu(1, m.userSelectItem)

end
NEW_FORM_UNION_CREATE.C50636_OnClick = function( m )
m:OnClickMenu(2, m.userSelectItem)

end
NEW_FORM_UNION_CREATE.C50637_OnClick = function( m )
m:OnClickMenu(3, m.userSelectItem)

end
NEW_FORM_UNION_CREATE.C50638_OnClick = function( m )
m:OnClickMenu(4, m.userSelectItem)

end
NEW_FORM_UNION_CREATE.C50639_OnClick = function( m )
m:OnClickMenu(5, m.userSelectItem)

end
NEW_FORM_UNION_CREATE.C50640_OnClick = function( m )
if m:HideMenu() then
	return
else
	m:OnApply()
end

end
NEW_FORM_UNION_CREATE.C50625_OnClick = function( m )
m:SetButton(m.userSelectItem)
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_UNION_CREATE.C50625_OnUpdate = function( m )
UpdateText(m, m.offset, UI3_COMPOSIT_625)
end
NEW_FORM_UNION_CREATE.C50626_OnClick = function( m )
m:SetButton(m.userSelectItem)
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_UNION_CREATE.C50626_OnUpdate = function( m )
UpdateText(m, m.offset+1, UI3_COMPOSIT_626)
end
NEW_FORM_UNION_CREATE.C50627_OnClick = function( m )
m:SetButton(m.userSelectItem)
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_UNION_CREATE.C50627_OnUpdate = function( m )
UpdateText(m, m.offset+2, UI3_COMPOSIT_627)
end
NEW_FORM_UNION_CREATE.C50628_OnClick = function( m )
m:SetButton(m.userSelectItem)
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_UNION_CREATE.C50628_OnUpdate = function( m )
UpdateText(m, m.offset+3, UI3_COMPOSIT_628)
end
NEW_FORM_UNION_CREATE.C50629_OnClick = function( m )
m:SetButton(m.userSelectItem)
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_UNION_CREATE.C50629_OnUpdate = function( m )
UpdateText(m, m.offset+4, UI3_COMPOSIT_629)
end
NEW_FORM_UNION_CREATE.C50630_OnClick = function( m )
m:SetButton(m.userSelectItem)
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_UNION_CREATE.C50630_OnUpdate = function( m )
UpdateText(m, m.offset+5, UI3_COMPOSIT_630)
end
NEW_FORM_UNION_CREATE.C50631_OnClick = function( m )
m:SetButton(m.userSelectItem)
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_UNION_CREATE.C50631_OnUpdate = function( m )
UpdateText(m, m.offset+6, UI3_COMPOSIT_631)

end
NEW_FORM_UNION_CREATE.C50547_OnClick = function( m )
m:CreateUnion(m.unionName)
local text = m:GetDescribeInfo()
UI_Engine.SetLevel(m.formIndex, 2)
--UI_Engine.SetText(m.formIndex, COMPOSIT_1312, text, 0)


end
NEW_FORM_UNION_CREATE.C50622_OnClick = function( m )
m.name = GetInput(m, UI3_COMPOSIT_622)
if Tools.JudgeSpecialWord(m.name) then
	WarnUser(m, UI_Engine.GetLuaStr(R_STRING_NO_LEGAL))
	m.name = ""
	UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_622, m.name)
end

end
NEW_FORM_UNION_CREATE.C50623_OnClick = function( m )
m.offset = 1
m:QueryAllUnions(m.name)
UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_622, "")
--UI_Engine.SetText(m.formIndex, COMPOSIT_1356, "")
m.begin  = true
m.name = ""
UI_Engine.SetFormTab(m.formIndex, 3)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_640, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_635, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_636, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_637, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_638, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_639, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_633, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_839, true)
UI_Engine.SetLevel(m.formIndex, 2)

end
NEW_FORM_UNION_CREATE.C50543_OnClick = function( m )
m.unionName = GetInput(m, UI3_COMPOSIT_543)
if Tools.JudgeSpecialWord(m.unionName) then
	WarnUser(m, UI_Engine.GetLuaStr(R_STRING_NO_LEGAL))
	m.unionName = ""
	UI_Engine.SetText(m.formIndex, UI3_COMPOSIT_543, m.unionName)
end

end
