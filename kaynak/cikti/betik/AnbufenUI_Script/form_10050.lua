FORM_UNION_CREATE= { }
FORM_UNION_CREATE.Main = function( m )
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
FORM_UNION_CREATE.C51312_OnLoad = function( m )
DBGPRINTF("lua_info:new form created")
m.unionName = ""
m.name = ""
m.begin = false
local describe = m:Init()
UI_Engine.SetText(m.formIndex, COMPOSIT_1314, "创建公会")
UI_Engine.SetText(m.formIndex, COMPOSIT_1312, describe, 0)
end
local GetInput = function(m, ctlID)		-- 创建输入框
	local text = UI_Engine.GetText(m.formIndex, ctlID)
	m.InputBox = OpenInputBox(m,text,16)
	m.InputBox :WaitUserInput(m)
	local result = m.InputBox :GetResult()
	UI_Engine.SetText(m.formIndex, ctlID, result, 0)
	return result
end

--[[ 	
	设置第二个标签页控件的显示模式， 初始显示输入框， 隐藏列表控件和公	会名、成员数、声望等，点击开始搜索后隐藏输入框， 显示列表控件及公	会名等。
--]]
local SetControlMode = function(m, mode)
	if true == mode then
		-- 设置输入框
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1337, true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1338, true)
		-- 设置公会名、成员数、声望、会长
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1320, false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1321, false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1322, false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1323, false)
		-- 设置列表控件
		for i = COMPOSIT_1325, COMPOSIT_1331 do
			UI_Engine.SetVisible(m.formIndex, i, false)
		end
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1337, false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1338, false)
		-- 设置公会名、成员数、声望、会长
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1320, true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1321, true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1322, true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_1323, true)
		-- 设置列表控件
		for i = COMPOSIT_1325, COMPOSIT_1331 do
			UI_Engine.SetVisible(m.formIndex, i, true)
		end
	end
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
FORM_UNION_CREATE.C52748_OnClick = function( m )
DelUnionCreate(m)
end
FORM_UNION_CREATE.C51338_OnClick = function( m )
m.name = GetInput(m, COMPOSIT_1338)
if Tools.JudgeSpecialWord(m.name) then
	WarnUser(m, "输入不合法，请重新输入!")
	m.name = ""
	UI_Engine.SetText(m.formIndex, COMPOSIT_1338, m.name)
end
end
FORM_UNION_CREATE.C51332_OnClick = function( m )
m.unionName = GetInput(m, COMPOSIT_1332)
if Tools.JudgeSpecialWord(m.unionName) then
	WarnUser(m, "输入不合法，请重新输入!")
	m.unionName = ""
	UI_Engine.SetText(m.formIndex, COMPOSIT_1332, m.unionName)
end
end
FORM_UNION_CREATE.C51325_OnClick = function( m )
m:SetButton(m.userSelectItem)
end
FORM_UNION_CREATE.C51325_OnUpdate = function( m )
UpdateText(m, m.offset, COMPOSIT_1325)
end
FORM_UNION_CREATE.C51326_OnClick = function( m )
m:SetButton(m.userSelectItem)
end
FORM_UNION_CREATE.C51326_OnUpdate = function( m )
UpdateText(m, m.offset+1, COMPOSIT_1326)
end
FORM_UNION_CREATE.C51327_OnClick = function( m )
m:SetButton(m.userSelectItem)
end
FORM_UNION_CREATE.C51327_OnUpdate = function( m )
UpdateText(m, m.offset+2, COMPOSIT_1327)
end
FORM_UNION_CREATE.C51328_OnClick = function( m )
m:SetButton(m.userSelectItem)
end
FORM_UNION_CREATE.C51328_OnUpdate = function( m )
UpdateText(m, m.offset+3, COMPOSIT_1328)
end
FORM_UNION_CREATE.C51329_OnClick = function( m )
m:SetButton(m.userSelectItem)
end
FORM_UNION_CREATE.C51329_OnUpdate = function( m )
UpdateText(m, m.offset+4, COMPOSIT_1329)
end
FORM_UNION_CREATE.C51330_OnClick = function( m )
m:SetButton(m.userSelectItem)
end
FORM_UNION_CREATE.C51330_OnUpdate = function( m )
UpdateText(m, m.offset+5, COMPOSIT_1330)
end
FORM_UNION_CREATE.C51331_OnClick = function( m )
m:SetButton(m.userSelectItem)
end
FORM_UNION_CREATE.C51331_OnUpdate = function( m )
UpdateText(m, m.offset+6, COMPOSIT_1331)
end
FORM_UNION_CREATE.C52745_OnClick = function( m )
m:SetButton(m.userSelectItem)
end
FORM_UNION_CREATE.C51324_OnClick = function( m )
m:QueryAllUnions(m.name)
UI_Engine.SetText(m.formIndex, COMPOSIT_1356, "")
m.begin  = true
m.name = ""
UI_Engine.SetFormTab(m.formIndex, 3)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2987, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2988, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2989, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2990, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2991, false)
end
FORM_UNION_CREATE.C51309_OnClick = function( m )
m:CreateUnion(m.unionName)
local text = m:GetDescribeInfo()
UI_Engine.SetText(m.formIndex, COMPOSIT_1312, text, 0)

end
FORM_UNION_CREATE.C51306_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 0)
local describe = m:Init()
UI_Engine.SetText(m.formIndex, COMPOSIT_1314, "创建公会")
UI_Engine.SetText(m.formIndex, COMPOSIT_1312, describe, 0)
end
FORM_UNION_CREATE.C51307_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetText(m.formIndex, COMPOSIT_1314, "公会列表")
UI_Engine.SetText(m.formIndex, COMPOSIT_1312, "")
UI_Engine.SetText(m.formIndex, COMPOSIT_1355, "")
UI_Engine.SetText(m.formIndex, COMPOSIT_1338, "")
end
FORM_UNION_CREATE.C52991_OnClick = function( m )
m:OnClickMenu(5, m.userSelectItem)
end
FORM_UNION_CREATE.C52990_OnClick = function( m )
m:OnClickMenu(4, m.userSelectItem)
end
FORM_UNION_CREATE.C52989_OnClick = function( m )
m:OnClickMenu(3, m.userSelectItem)
end
FORM_UNION_CREATE.C52988_OnClick = function( m )
m:OnClickMenu(2, m.userSelectItem)
end
FORM_UNION_CREATE.C52987_OnClick = function( m )
m:OnClickMenu(1, m.userSelectItem)
end
FORM_UNION_CREATE.C52986_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 1)
end
