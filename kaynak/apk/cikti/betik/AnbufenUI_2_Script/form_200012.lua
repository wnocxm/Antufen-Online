NEW_FORM_CASHSHOP= { }
NEW_FORM_CASHSHOP.Main = function( m )
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

local WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_OK)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local SetDrawInfo = function(m, nID, offset)
	local imgIndex, img, name, price = m:GetDrawInfo(m.offset + offset)
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
	UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_256, text, 0)
end

local SetAccount = function(m)
	local szCash = m:GetAccount()
	UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_324, szCash)
end

local ClickList = function(m, offset)
	m:OnClickList(offset)
end
NEW_FORM_CASHSHOP.C50296_OnClick = function( m )
DelCashShop(m)
end
NEW_FORM_CASHSHOP.C50290_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50290_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_290, 0)
end
NEW_FORM_CASHSHOP.C50291_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50291_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_291, 1)
end
NEW_FORM_CASHSHOP.C50292_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50292_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_292, 2)
end
NEW_FORM_CASHSHOP.C50293_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50293_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_293, 3)
end
NEW_FORM_CASHSHOP.C50294_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50294_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_294, 4)
end
NEW_FORM_CASHSHOP.C50295_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50295_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_295, 5)
end
NEW_FORM_CASHSHOP.C50310_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50310_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_310, 6)
end
NEW_FORM_CASHSHOP.C50283_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50283_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_283, 0)
end
NEW_FORM_CASHSHOP.C50284_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50284_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_284, 1)
end
NEW_FORM_CASHSHOP.C50285_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50285_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_285, 2)
end
NEW_FORM_CASHSHOP.C50286_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50286_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_286, 3)
end
NEW_FORM_CASHSHOP.C50287_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50287_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_287, 4)
end
NEW_FORM_CASHSHOP.C50288_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50288_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_288, 5)
end
NEW_FORM_CASHSHOP.C50309_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50309_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_309, 6)
end
NEW_FORM_CASHSHOP.C50275_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50275_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_275, 0)
end
NEW_FORM_CASHSHOP.C50276_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50276_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_276, 1)
end
NEW_FORM_CASHSHOP.C50277_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50277_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_277, 2)
end
NEW_FORM_CASHSHOP.C50278_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50278_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_278, 3)
end
NEW_FORM_CASHSHOP.C50279_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50279_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_279, 4)
end
NEW_FORM_CASHSHOP.C50280_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50280_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_280, 5)
end
NEW_FORM_CASHSHOP.C50308_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50308_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_308, 6)
end
NEW_FORM_CASHSHOP.C50269_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50269_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_269, 0)
end
NEW_FORM_CASHSHOP.C50270_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50270_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_270, 1)
end
NEW_FORM_CASHSHOP.C50271_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50271_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_271, 2)
end
NEW_FORM_CASHSHOP.C50272_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50272_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_272, 3)
end
NEW_FORM_CASHSHOP.C50273_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50273_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_273, 4)
end
NEW_FORM_CASHSHOP.C50274_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50274_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_274, 5)
end
NEW_FORM_CASHSHOP.C50307_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50307_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_307, 6)
end
NEW_FORM_CASHSHOP.C50263_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50263_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_263, 0)
end
NEW_FORM_CASHSHOP.C50264_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50264_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_264, 1)
end
NEW_FORM_CASHSHOP.C50265_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50265_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_265, 2)
end
NEW_FORM_CASHSHOP.C50266_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50266_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_266, 3)
end
NEW_FORM_CASHSHOP.C50267_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50267_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_267, 4)
end
NEW_FORM_CASHSHOP.C50268_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50268_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_268, 5)
end
NEW_FORM_CASHSHOP.C50305_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_CASHSHOP.C50305_OnUpdate = function( m )
SetDrawInfo(m, UI2_COMPOSIT_305, 6)
end
NEW_FORM_CASHSHOP.C50312_OnClick = function( m )
m:GetTab(0)
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_264)
end
NEW_FORM_CASHSHOP.C50313_OnClick = function( m )
m:GetTab(1)
UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_270)
end
NEW_FORM_CASHSHOP.C50314_OnClick = function( m )
m:GetTab(2)
UI_Engine.SetFormTab(m.formIndex, 2)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_276)
end
NEW_FORM_CASHSHOP.C50315_OnClick = function( m )
m:GetTab(3)
UI_Engine.SetFormTab(m.formIndex, 3)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_284)
end
NEW_FORM_CASHSHOP.C50316_OnClick = function( m )
m:GetTab(4)
UI_Engine.SetFormTab(m.formIndex, 4)
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_291)
end
NEW_FORM_CASHSHOP.C50254_OnLoad = function( m )
UI_Engine.UpdateList(m.formIndex, UI2_COMPOSIT_264)
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_CASHSHOP.C50254_OnDraw = function( m )
SetAccount(m)
end
