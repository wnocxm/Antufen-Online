FORM_EXCHANGE= { }
FORM_EXCHANGE.Main = function( m )
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
local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local DrawList = function(m, nId, index)
	local str, img, color, nSN = m:DrawList(m.offset + index)
	if str ~= nil then
		UI_Engine.SetSurfaceImg(m.formIndex, nId, img, 0, 0, false, nSN)
		UI_Engine.SetText(m.formIndex, nId, str, 1, color);
	else
		UI_Engine.SetSurfaceImg(m.formIndex, nId, nil, 0)
		UI_Engine.SetText(m.formIndex, nId, "", 1)
	end
end
FORM_EXCHANGE.C52526_OnClick = function( m )
local name, ptr = m:GetInfoPtr()
if name ~= nil then
	m.info = NewInfo(m, name, ptr)
end
	
end
FORM_EXCHANGE.C52525_OnClick = function( m )
local str = m:DlgText()
if MsgBox.ECODE_YES == QueryUser(m, str) then
	m:OnExchange()
end
end
FORM_EXCHANGE.C52703_OnClick = function( m )
DelExchange(m)
end
FORM_EXCHANGE.C52556_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52556_OnUpdate = function( m )
DrawList(m, COMPOSIT_2556, 0)
end
FORM_EXCHANGE.C52557_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52557_OnUpdate = function( m )
DrawList(m, COMPOSIT_2557, 1)
end
FORM_EXCHANGE.C52558_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52558_OnUpdate = function( m )
DrawList(m, COMPOSIT_2558, 2)
end
FORM_EXCHANGE.C52559_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52559_OnUpdate = function( m )
DrawList(m, COMPOSIT_2559, 3)
end
FORM_EXCHANGE.C52560_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52560_OnUpdate = function( m )
DrawList(m, COMPOSIT_2560, 4)
end
FORM_EXCHANGE.C52561_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52561_OnUpdate = function( m )
DrawList(m, COMPOSIT_2561, 5)
end
FORM_EXCHANGE.C52562_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52562_OnUpdate = function( m )
DrawList(m, COMPOSIT_2562, 6)
end
FORM_EXCHANGE.C52563_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52563_OnUpdate = function( m )
DrawList(m, COMPOSIT_2563, 7)
end
FORM_EXCHANGE.C52547_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52547_OnUpdate = function( m )
DrawList(m, COMPOSIT_2547, 0)
end
FORM_EXCHANGE.C52548_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52548_OnUpdate = function( m )
DrawList(m, COMPOSIT_2548, 1)
end
FORM_EXCHANGE.C52549_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52549_OnUpdate = function( m )
DrawList(m, COMPOSIT_2549, 2)
end
FORM_EXCHANGE.C52550_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52550_OnUpdate = function( m )
DrawList(m, COMPOSIT_2550, 3)
end
FORM_EXCHANGE.C52551_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52551_OnUpdate = function( m )
DrawList(m, COMPOSIT_2551, 4)
end
FORM_EXCHANGE.C52552_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52552_OnUpdate = function( m )
DrawList(m, COMPOSIT_2552, 5)
end
FORM_EXCHANGE.C52553_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52553_OnUpdate = function( m )
DrawList(m, COMPOSIT_2553, 6)
end
FORM_EXCHANGE.C52554_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52554_OnUpdate = function( m )
DrawList(m, COMPOSIT_2554, 7)
end
FORM_EXCHANGE.C52537_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52537_OnUpdate = function( m )
DrawList(m, COMPOSIT_2537, 0)
end
FORM_EXCHANGE.C52538_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52538_OnUpdate = function( m )
DrawList(m, COMPOSIT_2538, 1)
end
FORM_EXCHANGE.C52539_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52539_OnUpdate = function( m )
DrawList(m, COMPOSIT_2539, 2)
end
FORM_EXCHANGE.C52540_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52540_OnUpdate = function( m )
DrawList(m, COMPOSIT_2540, 3)
end
FORM_EXCHANGE.C52541_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52541_OnUpdate = function( m )
DrawList(m, COMPOSIT_2541, 4)
end
FORM_EXCHANGE.C52542_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52542_OnUpdate = function( m )
DrawList(m, COMPOSIT_2542, 5)
end
FORM_EXCHANGE.C52543_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52543_OnUpdate = function( m )
DrawList(m, COMPOSIT_2543, 6)
end
FORM_EXCHANGE.C52544_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52544_OnUpdate = function( m )
DrawList(m, COMPOSIT_2544, 7)
end
FORM_EXCHANGE.C52527_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52527_OnUpdate = function( m )
DrawList(m, COMPOSIT_2527, 0)
end
FORM_EXCHANGE.C52528_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52528_OnUpdate = function( m )
DrawList(m, COMPOSIT_2528, 1)
end
FORM_EXCHANGE.C52529_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52529_OnUpdate = function( m )
DrawList(m, COMPOSIT_2529, 2)
end
FORM_EXCHANGE.C52530_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52530_OnUpdate = function( m )
DrawList(m, COMPOSIT_2530, 3)
end
FORM_EXCHANGE.C52531_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52531_OnUpdate = function( m )
DrawList(m, COMPOSIT_2531, 4)
end
FORM_EXCHANGE.C52532_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52532_OnUpdate = function( m )
DrawList(m, COMPOSIT_2532, 5)
end
FORM_EXCHANGE.C52533_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52533_OnUpdate = function( m )
DrawList(m, COMPOSIT_2533, 6)
end
FORM_EXCHANGE.C52534_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
FORM_EXCHANGE.C52534_OnUpdate = function( m )
DrawList(m, COMPOSIT_2534, 7)
end
FORM_EXCHANGE.C52523_OnClick = function( m )
m:OnClickTab(0)
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2528)
end
FORM_EXCHANGE.C52522_OnClick = function( m )
m:OnClickTab(1)
UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2538)
end
FORM_EXCHANGE.C52521_OnClick = function( m )
m:OnClickTab(2)
UI_Engine.SetFormTab(m.formIndex, 2)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2548)
end
FORM_EXCHANGE.C52520_OnClick = function( m )
m:OnClickTab(3)
UI_Engine.SetFormTab(m.formIndex, 3)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2557)
end
FORM_EXCHANGE.C52518_OnDraw = function( m )
m:DrawInfo()
end
