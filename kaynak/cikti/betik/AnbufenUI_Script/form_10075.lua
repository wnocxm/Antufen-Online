FORM_CASHSHOP= { }
FORM_CASHSHOP.Main = function( m )
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
FORM_CASHSHOP.C52359_OnClick = function( m )
m:GetTab(0)
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_1987)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, false)
end
local SetDrawInfo = function(m, nID, offset)
	local imgIndex, img, name, price = m:GetDrawInfo(offset)
	if -1 ~= imgIndex then
		UI_Engine.SetImg(m.formIndex, nID, "UIData.godat", 2028, imgIndex, 0 )
	else
		UI_Engine.SetSurfaceImg(m.formIndex, nID, nil, 0)
	end
	UI_Engine.SetSurfaceImg(m.formIndex, nID, img, 1)
	UI_Engine.SetText(m.formIndex, nID, name, 2)
	UI_Engine.SetText(m.formIndex, nID, price, 3)
end

local SetDescribe = function(m)
	local text = m:GetDescribe(m.userSelectItem)
	UI_Engine.SetText(m.formIndex, COMPOSIT_1969, text, 0)
end

local SetAccount = function(m)
	local szCash = m:GetAccount()
	UI_Engine.SetRollText(m.formIndex, COMPOSIT_1982, szCash)
end
FORM_CASHSHOP.C52360_OnClick = function( m )
m:GetTab(1)
UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2365)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, false)
end
FORM_CASHSHOP.C52361_OnClick = function( m )
m:GetTab(2)
UI_Engine.SetFormTab(m.formIndex, 2)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2373)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, false)
end
FORM_CASHSHOP.C52362_OnClick = function( m )
m:GetTab(3)
UI_Engine.SetFormTab(m.formIndex, 3)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2382)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, false)
end
FORM_CASHSHOP.C52363_OnClick = function( m )
m:GetTab(4)
UI_Engine.SetFormTab(m.formIndex, 4)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_2390)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, false)
end
FORM_CASHSHOP.C52749_OnClick = function( m )
DelCashShop(m)
end
FORM_CASHSHOP.C51977_OnClick = function( m )
m.SelectNumBox = NewNumSel(m, "Select Number", 1, 1, 30)
m.SelectNumBox:WaitUserInput(m)
local  ret = m.SelectNumBox:GetResult()
DelNumSel(m.SelectNumBox)
if -1 ~= ret then
	m:OnBuy(ret)
end
SetAccount(m)

end
FORM_CASHSHOP.C51976_OnClick = function( m )
NewDepositV8(m)
end
FORM_CASHSHOP.C51975_OnClick = function( m )
local name, ptr = m:GetItemInfo()
m.info = NewInfo(m, name, ptr)
end
FORM_CASHSHOP.C52358_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52358_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2358, m.offset)
end
FORM_CASHSHOP.C51985_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C51985_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_1985, m.offset+1)
end
FORM_CASHSHOP.C51986_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C51986_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_1986, m.offset+2)
end
FORM_CASHSHOP.C51987_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C51987_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_1987, m.offset+3)
end
FORM_CASHSHOP.C51988_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C51988_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_1988, m.offset+4)
end
FORM_CASHSHOP.C51989_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C51989_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_1989, m.offset+5)
end
FORM_CASHSHOP.C51990_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C51990_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_1990, m.offset+6)
end
FORM_CASHSHOP.C51991_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C51991_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_1991, m.offset+7)
end
FORM_CASHSHOP.C52364_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52364_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2364, m.offset)
end
FORM_CASHSHOP.C52365_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52365_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2365, m.offset+1)
end
FORM_CASHSHOP.C52366_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52366_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2366, m.offset+2)
end
FORM_CASHSHOP.C52367_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52367_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2367, m.offset+3)
end
FORM_CASHSHOP.C52368_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52368_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2368, m.offset+4)
end
FORM_CASHSHOP.C52369_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52369_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2369, m.offset+5)
end
FORM_CASHSHOP.C52370_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52370_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2370, m.offset+6)
end
FORM_CASHSHOP.C52371_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52371_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2371, m.offset+7)
end
FORM_CASHSHOP.C52372_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52372_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2372, m.offset)
end
FORM_CASHSHOP.C52373_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52373_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2373, m.offset+1)
end
FORM_CASHSHOP.C52374_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52374_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2374, m.offset+2)
end
FORM_CASHSHOP.C52375_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52375_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2375, m.offset+3)
end
FORM_CASHSHOP.C52376_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52376_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2376, m.offset+4)
end
FORM_CASHSHOP.C52377_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52377_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2377, m.offset+5)
end
FORM_CASHSHOP.C52378_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52378_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2378, m.offset+6)
end
FORM_CASHSHOP.C52379_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52379_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2379, m.offset+7)
end
FORM_CASHSHOP.C52380_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52380_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2380, m.offset)
end
FORM_CASHSHOP.C52381_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52381_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2381, m.offset+1)
end
FORM_CASHSHOP.C52382_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52382_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2382, m.offset+2)
end
FORM_CASHSHOP.C52383_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52383_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2383, m.offset+3)
end
FORM_CASHSHOP.C52384_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52384_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2384, m.offset+4)
end
FORM_CASHSHOP.C52385_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52385_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2385, m.offset+5)
end
FORM_CASHSHOP.C52386_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52386_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2386, m.offset+6)
end
FORM_CASHSHOP.C52387_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52387_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2387, m.offset+7)
end
FORM_CASHSHOP.C52388_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52388_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2388, m.offset)
end
FORM_CASHSHOP.C52389_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52389_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2389, m.offset+1)
end
FORM_CASHSHOP.C52390_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52390_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2390, m.offset+2)
end
FORM_CASHSHOP.C52391_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52391_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2391, m.offset+3)
end
FORM_CASHSHOP.C52392_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52392_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2392, m.offset+4)
end
FORM_CASHSHOP.C52393_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52393_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2393, m.offset+5)
end
FORM_CASHSHOP.C52394_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52394_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2394, m.offset+6)
end
FORM_CASHSHOP.C52395_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1975, true)
end
FORM_CASHSHOP.C52395_OnUpdate = function( m )
SetDrawInfo(m, COMPOSIT_2395, m.offset+7)
end
FORM_CASHSHOP.C51969_OnDraw = function( m )
SetDescribe(m)
end
FORM_CASHSHOP.C51968_OnLoad = function( m )
UI_Engine.UpdateList(m.formIndex, COMPOSIT_1987)
end
FORM_CASHSHOP.C51968_OnDraw = function( m )
SetAccount(m)
end
