NEW_FORM_SHOP= { }
NEW_FORM_SHOP.Main = function( m )
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
local SetMoney = function(m)
	local str = m:GetGolden()
	UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_348, str)
end
NEW_FORM_SHOP.C50905_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50905_OnUpdate = function( m )
m:UpdateList(m.offset,UI3_COMPOSIT_905, 4)
end
NEW_FORM_SHOP.C50906_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50906_OnUpdate = function( m )
m:UpdateList(m.offset + 1,UI3_COMPOSIT_906, 4)
end
NEW_FORM_SHOP.C50907_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50907_OnUpdate = function( m )
m:UpdateList(m.offset + 2,UI3_COMPOSIT_907, 4)
end
NEW_FORM_SHOP.C50908_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50908_OnUpdate = function( m )
m:UpdateList(m.offset + 3,UI3_COMPOSIT_908, 4)
end
NEW_FORM_SHOP.C50909_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50909_OnUpdate = function( m )
m:UpdateList(m.offset + 4,UI3_COMPOSIT_909, 4)
end
NEW_FORM_SHOP.C50910_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50910_OnUpdate = function( m )
m:UpdateList(m.offset + 5,UI3_COMPOSIT_910, 4)
end
NEW_FORM_SHOP.C50911_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50911_OnUpdate = function( m )
m:UpdateList(m.offset + 6,UI3_COMPOSIT_911, 4)
end
NEW_FORM_SHOP.C50357_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50357_OnUpdate = function( m )
m:UpdateList(m.offset,UI2_COMPOSIT_357, 3)
end
NEW_FORM_SHOP.C50358_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50358_OnUpdate = function( m )
m:UpdateList(m.offset + 1,UI2_COMPOSIT_358, 3)
SetMoney(m)
end
NEW_FORM_SHOP.C50359_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50359_OnUpdate = function( m )
m:UpdateList(m.offset + 2,UI2_COMPOSIT_359, 3)
end
NEW_FORM_SHOP.C50360_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50360_OnUpdate = function( m )
m:UpdateList(m.offset + 3,UI2_COMPOSIT_360, 3)
end
NEW_FORM_SHOP.C50361_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50361_OnUpdate = function( m )
m:UpdateList(m.offset +4 ,UI2_COMPOSIT_361, 3)
end
NEW_FORM_SHOP.C50362_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50362_OnUpdate = function( m )
m:UpdateList(m.offset +5 ,UI2_COMPOSIT_362, 3)
end
NEW_FORM_SHOP.C50363_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50363_OnUpdate = function( m )
m:UpdateList(m.offset + 6,UI2_COMPOSIT_363, 3)
end
NEW_FORM_SHOP.C50356_OnClick = function( m )
m:Cancel()
end
NEW_FORM_SHOP.C50349_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50349_OnUpdate = function( m )
m:UpdateList(m.offset ,UI2_COMPOSIT_349,2)
end
NEW_FORM_SHOP.C50350_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50350_OnUpdate = function( m )
m:UpdateList(m.offset + 1,UI2_COMPOSIT_350, 2)
SetMoney(m)
end
NEW_FORM_SHOP.C50351_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50351_OnUpdate = function( m )
m:UpdateList(m.offset +2 ,UI2_COMPOSIT_351, 2)
end
NEW_FORM_SHOP.C50352_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50352_OnUpdate = function( m )
m:UpdateList(m.offset + 3,UI2_COMPOSIT_352, 2)
end
NEW_FORM_SHOP.C50353_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50353_OnUpdate = function( m )
m:UpdateList(m.offset + 4,UI2_COMPOSIT_353, 2)
end
NEW_FORM_SHOP.C50354_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50354_OnUpdate = function( m )
m:UpdateList(m.offset + 5,UI2_COMPOSIT_354, 2)
end
NEW_FORM_SHOP.C50355_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50355_OnUpdate = function( m )
m:UpdateList(m.offset + 6,UI2_COMPOSIT_355, 2)
end
NEW_FORM_SHOP.C50393_OnClick = function( m )
m:RepairAll()
end
NEW_FORM_SHOP.C50341_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50341_OnUpdate = function( m )
m:UpdateList(m.offset,UI2_COMPOSIT_341,1)
end
NEW_FORM_SHOP.C50342_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50342_OnUpdate = function( m )
m:UpdateList(m.offset + 1,UI2_COMPOSIT_342,1)
SetMoney(m)
end
NEW_FORM_SHOP.C50343_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50343_OnUpdate = function( m )
m:UpdateList(m.offset + 2,UI2_COMPOSIT_343,1)
end
NEW_FORM_SHOP.C50344_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50344_OnUpdate = function( m )
m:UpdateList(m.offset + 3,UI2_COMPOSIT_344,1)
end
NEW_FORM_SHOP.C50345_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50345_OnUpdate = function( m )
m:UpdateList(m.offset +4 ,UI2_COMPOSIT_345,1)
end
NEW_FORM_SHOP.C50346_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50346_OnUpdate = function( m )
m:UpdateList(m.offset +5 ,UI2_COMPOSIT_346,1)
end
NEW_FORM_SHOP.C50347_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50347_OnUpdate = function( m )
m:UpdateList(m.offset + 6,UI2_COMPOSIT_347,1)
end
NEW_FORM_SHOP.C50334_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50334_OnUpdate = function( m )
m:UpdateList(m.offset,UI2_COMPOSIT_334,0)
end
NEW_FORM_SHOP.C50335_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50335_OnUpdate = function( m )
m:UpdateList(m.offset + 1,UI2_COMPOSIT_335,0)
SetMoney(m)
end
NEW_FORM_SHOP.C50336_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50336_OnUpdate = function( m )
m:UpdateList(m.offset + 2,UI2_COMPOSIT_336,0)
end
NEW_FORM_SHOP.C50337_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50337_OnUpdate = function( m )
m:UpdateList(m.offset +3 ,UI2_COMPOSIT_337,0)
end
NEW_FORM_SHOP.C50338_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50338_OnUpdate = function( m )
m:UpdateList(m.offset + 4,UI2_COMPOSIT_338,0)
end
NEW_FORM_SHOP.C50339_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50339_OnUpdate = function( m )
m:UpdateList(m.offset + 5,UI2_COMPOSIT_339,0)
end
NEW_FORM_SHOP.C50340_OnClick = function( m )
m:OnClickList( m.userSelectItem )
end
NEW_FORM_SHOP.C50340_OnUpdate = function( m )
m:UpdateList(m.offset + 6,UI2_COMPOSIT_340,0)
end
NEW_FORM_SHOP.C50899_OnClick = function( m )
m:OnClickTab(0)
UI_Engine.SetFormTab(m.formIndex,0)
UI_Engine.UpdateList(m.formIndex,  UI2_COMPOSIT_335)
end
NEW_FORM_SHOP.C50900_OnClick = function( m )
m:OnClickTab(1)
UI_Engine.SetFormTab(m.formIndex,1)
UI_Engine.UpdateList(m.formIndex,  UI2_COMPOSIT_342)
end
NEW_FORM_SHOP.C50901_OnClick = function( m )
m:OnClickTab(2)
UI_Engine.SetFormTab(m.formIndex,2)
UI_Engine.UpdateList(m.formIndex,  UI2_COMPOSIT_350)
end
NEW_FORM_SHOP.C50902_OnClick = function( m )
m:OnClickTab(3)
UI_Engine.SetFormTab(m.formIndex,3)
UI_Engine.UpdateList(m.formIndex,  UI2_COMPOSIT_358)
end
NEW_FORM_SHOP.C50903_OnClick = function( m )
m:OnClickTab(4)
UI_Engine.SetFormTab(m.formIndex,4)
UI_Engine.UpdateList(m.formIndex,  UI3_COMPOSIT_906)
end
NEW_FORM_SHOP.C50327_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
