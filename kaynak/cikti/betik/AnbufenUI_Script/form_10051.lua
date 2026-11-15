FORM_CONSIGNMENT_SEARCH= { }
FORM_CONSIGNMENT_SEARCH.Main = function( m )
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
FORM_CONSIGNMENT_SEARCH.C52705_OnLoad = function( m )
m.cursel = 0
m.name = ""
m:Init()
m.val = 0
end
FORM_CONSIGNMENT_SEARCH.C52705_OnClick = function( m )
m:InputFinished()
end
local SetTypeText = function(m, type, state, ctlID)
	local text = m:MakeConditionString(type, state)
	UI_Engine.SetText(m.formIndex, ctlID, text)
end

local WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_CANCEL)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local GetInput = function(m, ctlID)		-- 创建输入框
	local text = UI_Engine.GetText(m.formIndex, ctlID, 0)
	m.InputBox = OpenInputBox(m,text,16)
	m.InputBox :WaitUserInput(m)
	local result = m.InputBox :GetResult()
	UI_Engine.SetText(m.formIndex,ctlID,result,0)
	return result
end

local OnClickArrow = function(m, type, direction, ctlID)
	local sel = m:OnClickArrow(type, direction)
	SetTypeText(m, type, sel, ctlID)
	return sel
end

local SetViewMode = function(m, mode)
	if mode == true then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1645,true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1399,true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1395,true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1390,true)
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1645,false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1399,false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1395,false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1390,false)
	end
end
FORM_CONSIGNMENT_SEARCH.C51373_OnClick = function( m )
OnClickArrow(m, 4, 0, COMPOSIT_1363)
m:Init()
end
FORM_CONSIGNMENT_SEARCH.C51372_OnClick = function( m )
OnClickArrow(m, 3, 0, COMPOSIT_1362)
end
FORM_CONSIGNMENT_SEARCH.C51371_OnClick = function( m )
OnClickArrow(m, 2, 0, COMPOSIT_1361)
end
FORM_CONSIGNMENT_SEARCH.C51370_OnClick = function( m )
OnClickArrow(m, 1, 0, COMPOSIT_1360)
end
FORM_CONSIGNMENT_SEARCH.C51369_OnClick = function( m )
OnClickArrow(m, 0, 0, COMPOSIT_1359)
end
FORM_CONSIGNMENT_SEARCH.C51368_OnClick = function( m )
OnClickArrow(m, 4, 1, COMPOSIT_1363)

end
FORM_CONSIGNMENT_SEARCH.C51367_OnClick = function( m )
OnClickArrow(m, 3, 1, COMPOSIT_1362)

end
FORM_CONSIGNMENT_SEARCH.C51366_OnClick = function( m )
OnClickArrow(m, 2, 1, COMPOSIT_1361)
end
FORM_CONSIGNMENT_SEARCH.C51365_OnClick = function( m )
OnClickArrow(m, 1, 1, COMPOSIT_1360)
end
FORM_CONSIGNMENT_SEARCH.C51364_OnClick = function( m )
--SetArrow(m, 0, 1)
OnClickArrow(m, 0, 1, COMPOSIT_1359)
end
FORM_CONSIGNMENT_SEARCH.C51357_OnClick = function( m )
m:OnSearch(m.name)
m:InputFinished()
m.name = ""
end
FORM_CONSIGNMENT_SEARCH.C51386_OnClick = function( m )
OnClickArrow(m, 3, 0, COMPOSIT_1378)
end
FORM_CONSIGNMENT_SEARCH.C51385_OnClick = function( m )
OnClickArrow(m, 2, 0, COMPOSIT_1377)

end
FORM_CONSIGNMENT_SEARCH.C51384_OnClick = function( m )
OnClickArrow(m, 1, 0, COMPOSIT_1376)

end
FORM_CONSIGNMENT_SEARCH.C51383_OnClick = function( m )
OnClickArrow(m, 0, 0, COMPOSIT_1375)
end
FORM_CONSIGNMENT_SEARCH.C51382_OnClick = function( m )
OnClickArrow(m, 3, 1, COMPOSIT_1378)
end
FORM_CONSIGNMENT_SEARCH.C51381_OnClick = function( m )
OnClickArrow(m, 2, 1, COMPOSIT_1377)


end
FORM_CONSIGNMENT_SEARCH.C51380_OnClick = function( m )
OnClickArrow(m, 1, 1, COMPOSIT_1376)

end
FORM_CONSIGNMENT_SEARCH.C51379_OnClick = function( m )
OnClickArrow(m, 0, 1, COMPOSIT_1375)
end
FORM_CONSIGNMENT_SEARCH.C51391_OnClick = function( m )
m.name = GetInput(m, COMPOSIT_1391)
end
FORM_CONSIGNMENT_SEARCH.C51399_OnClick = function( m )
OnClickArrow(m, 3, 0, COMPOSIT_1390)
end
FORM_CONSIGNMENT_SEARCH.C51398_OnClick = function( m )
OnClickArrow(m, 2, 0, COMPOSIT_1389)
end
FORM_CONSIGNMENT_SEARCH.C51397_OnClick = function( m )
OnClickArrow(m, 1, 0, COMPOSIT_1388)

end
FORM_CONSIGNMENT_SEARCH.C51396_OnClick = function( m )
m.val = OnClickArrow(m, 0, 0, COMPOSIT_1387)
if 3 == m.val then
	SetViewMode(m, true)
else
	SetViewMode(m,false)
end
end
FORM_CONSIGNMENT_SEARCH.C51395_OnClick = function( m )
OnClickArrow(m, 3, 1, COMPOSIT_1390)
end
FORM_CONSIGNMENT_SEARCH.C51394_OnClick = function( m )
OnClickArrow(m, 2, 1, COMPOSIT_1389)
end
FORM_CONSIGNMENT_SEARCH.C51393_OnClick = function( m )
OnClickArrow(m, 1, 1, COMPOSIT_1388)
end
FORM_CONSIGNMENT_SEARCH.C51392_OnClick = function( m )
m.val = OnClickArrow(m, 0, 1, COMPOSIT_1387)
if 3 == m.val then
	SetViewMode(m, true)
else
	SetViewMode(m,false)
end
end
FORM_CONSIGNMENT_SEARCH.C51403_OnClick = function( m )
m.name = GetInput(m, COMPOSIT_1403)
if Tools.JudgeSpecialWord(m.name) then
	WarnUser(m, "输入不合法，请重新输入!")
	m.name = ""
	UI_Engine.SetText(m.formIndex, COMPOSIT_1403, m.name)
end
end
FORM_CONSIGNMENT_SEARCH.C51402_OnClick = function( m )
OnClickArrow(m, 0, 0, COMPOSIT_1400)
end
FORM_CONSIGNMENT_SEARCH.C51401_OnClick = function( m )
OnClickArrow(m, 0, 1, COMPOSIT_1400)
end
FORM_CONSIGNMENT_SEARCH.C51413_OnClick = function( m )
OnClickArrow(m, 2, 0, COMPOSIT_1406)
end
FORM_CONSIGNMENT_SEARCH.C51412_OnClick = function( m )
OnClickArrow(m, 1, 0, COMPOSIT_1405)
end
FORM_CONSIGNMENT_SEARCH.C51411_OnClick = function( m )
OnClickArrow(m, 0, 0, COMPOSIT_1404)
end
FORM_CONSIGNMENT_SEARCH.C51410_OnClick = function( m )
OnClickArrow(m, 2, 1, COMPOSIT_1406)
end
FORM_CONSIGNMENT_SEARCH.C51409_OnClick = function( m )
OnClickArrow(m, 1, 1, COMPOSIT_1405)
end
FORM_CONSIGNMENT_SEARCH.C51408_OnClick = function( m )
OnClickArrow(m, 0, 1, COMPOSIT_1404)
end
FORM_CONSIGNMENT_SEARCH.C51417_OnClick = function( m )
OnClickArrow(m, 0, 0, COMPOSIT_1414)
end
FORM_CONSIGNMENT_SEARCH.C51416_OnClick = function( m )
OnClickArrow(m, 0, 1, COMPOSIT_1414)
end
FORM_CONSIGNMENT_SEARCH.C51415_OnClick = function( m )
m.name = GetInput(m, COMPOSIT_1415)
if Tools.JudgeSpecialWord(m.name) then
	WarnUser(m, "输入不合法，请重新输入!")
	m.name = ""
	UI_Engine.SetText(m.formIndex, COMPOSIT_1415, m.name)
end
end
FORM_CONSIGNMENT_SEARCH.C51355_OnLoad = function( m )
SetTypeText(m, 0, 0, COMPOSIT_1359)	-- tab0,  装备
SetTypeText(m, 1, 0, COMPOSIT_1360)
SetTypeText(m, 2, 0, COMPOSIT_1361)
SetTypeText(m, 3, 0, COMPOSIT_1362)
SetTypeText(m, 4, 0, COMPOSIT_1363)

SetTypeText(m, 0, 0, COMPOSIT_1375)	-- tab1，武器
SetTypeText(m, 1, 0, COMPOSIT_1376)
SetTypeText(m, 2, 0, COMPOSIT_1377)
SetTypeText(m, 3, 0, COMPOSIT_1378)

SetTypeText(m, 0, 0, COMPOSIT_1387)	-- tab2，宝石
SetTypeText(m, 1, 0, COMPOSIT_1388)
SetTypeText(m, 2, 0, COMPOSIT_1389)
SetTypeText(m, 3, 0, COMPOSIT_1390)

SetTypeText(m, 0, 0, COMPOSIT_1400)	-- tab3，宠物

SetTypeText(m, 0, 0, COMPOSIT_1404)	-- tab4，鉓品
SetTypeText(m, 1, 0, COMPOSIT_1405)
SetTypeText(m, 2, 0, COMPOSIT_1406) 	

SetTypeText(m, 0, 0, COMPOSIT_1414)	-- tab5，杂货
end
