FORM_ITEMBAR= { }
FORM_ITEMBAR.Main = function( m )
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
FORM_ITEMBAR.C50117_OnClick = function( m )
m:OnClickGameMenu()
end
FORM_ITEMBAR.C50101_OnClick = function( m )
m:OnItemPenEvent(0)
end
FORM_ITEMBAR.C50101_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,0,COMPOSIT_PROPERTY1)

end
FORM_ITEMBAR.C50102_OnClick = function( m )
m:OnItemPenEvent(1)
end
FORM_ITEMBAR.C50102_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,1,COMPOSIT_PROPERTY2)
end
FORM_ITEMBAR.C50103_OnClick = function( m )
m:OnItemPenEvent(2)
end
FORM_ITEMBAR.C50103_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,2,COMPOSIT_PROPERTY3)
end
FORM_ITEMBAR.C50104_OnClick = function( m )
m:OnItemPenEvent(3)
end
FORM_ITEMBAR.C50104_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,3,COMPOSIT_PROPERTY4)
end
FORM_ITEMBAR.C50105_OnClick = function( m )
m:OnItemPenEvent(4)
end
FORM_ITEMBAR.C50105_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,4,COMPOSIT_PROPERTY5)
end
FORM_ITEMBAR.C50106_OnClick = function( m )
m:OnItemPenEvent(5)

end
FORM_ITEMBAR.C50106_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,5,COMPOSIT_PROPERTY6)
end
FORM_ITEMBAR.C50107_OnClick = function( m )
m:OnItemPenEvent(6)
end
FORM_ITEMBAR.C50107_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,6,COMPOSIT_PROPERTY7)
end
FORM_ITEMBAR.C50108_OnClick = function( m )
m:OnItemPenEvent(7)
end
FORM_ITEMBAR.C50108_OnDraw = function( m )
local x,y=m:GetSurface()
m:DrawShortCut(x,y,7,COMPOSIT_PROPERTY8)
end
FORM_ITEMBAR.C50097_OnDraw = function( m )
m:DrawItemBar()
end
