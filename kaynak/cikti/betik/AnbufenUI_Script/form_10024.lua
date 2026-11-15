FORM_BAG_BACK= { }
FORM_BAG_BACK.Main = function( m )
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
FORM_BAG_BACK.C50326_OnClick = function( m )
m:OnClickLRFunction(0)
end
FORM_BAG_BACK.C50332_OnDraw = function( m )
m:OnDrawList(m.offset,COMPOSIT_BAG_EQUIP_LIST0,0)
end
FORM_BAG_BACK.C50331_OnDraw = function( m )
m:OnDrawList(m.offset+1,COMPOSIT_BAG_EQUIP_LIST1,0)
end
FORM_BAG_BACK.C50330_OnDraw = function( m )
m:OnDrawList(m.offset+2,COMPOSIT_BAG_EQUIP_LIST2,0)
end
FORM_BAG_BACK.C50329_OnDraw = function( m )
m:OnDrawList(m.offset+3,COMPOSIT_BAG_EQUIP_LIST3,0)
end
FORM_BAG_BACK.C50328_OnDraw = function( m )
m:OnDrawList(m.offset+4,COMPOSIT_BAG_EQUIP_LIST4,0)

end
FORM_BAG_BACK.C50327_OnDraw = function( m )
m:OnDrawList(m.offset+5,COMPOSIT_BAG_EQUIP_LIST5,0)

end
FORM_BAG_BACK.C50336_OnClick = function( m )
m:OnClickTab(0)
end
FORM_BAG_BACK.C50337_OnClick = function( m )
m:OnClickTab(1)
end
FORM_BAG_BACK.C50338_OnClick = function( m )
m:OnClickTab(2)
end
FORM_BAG_BACK.C50339_OnClick = function( m )
m:OnClickTab(3)
end
FORM_BAG_BACK.C50345_OnDraw = function( m )
m:OnDrawList(m.offset,COMPOSIT_BAG_CONSUME_LIST0,1)
end
FORM_BAG_BACK.C50344_OnDraw = function( m )
m:OnDrawList(m.offset+1,COMPOSIT_BAG_CONSUME_LIST1,1)

end
FORM_BAG_BACK.C50343_OnDraw = function( m )
m:OnDrawList(m.offset+2,COMPOSIT_BAG_CONSUME_LIST2,1)


end
FORM_BAG_BACK.C50342_OnDraw = function( m )
m:OnDrawList(m.offset+3,COMPOSIT_BAG_CONSUME_LIST3,1)


end
FORM_BAG_BACK.C50341_OnDraw = function( m )
m:OnDrawList(m.offset+4,COMPOSIT_BAG_CONSUME_LIST4,1)


end
FORM_BAG_BACK.C50340_OnDraw = function( m )
m:OnDrawList(m.offset+5,COMPOSIT_BAG_CONSUME_LIST5,1)


end
FORM_BAG_BACK.C50351_OnDraw = function( m )
m:OnDrawList(m.offset,COMPOSIT_BAG_COMMON_LIST0,2)


end
FORM_BAG_BACK.C50350_OnDraw = function( m )
m:OnDrawList(m.offset+1,COMPOSIT_BAG_COMMON_LIST1,2)


end
FORM_BAG_BACK.C50349_OnDraw = function( m )
m:OnDrawList(m.offset+2,COMPOSIT_BAG_COMMON_LIST2,2)
end
FORM_BAG_BACK.C50348_OnDraw = function( m )
m:OnDrawList(m.offset+3,COMPOSIT_BAG_COMMON_LIST3,2)



end
FORM_BAG_BACK.C50347_OnDraw = function( m )
m:OnDrawList(m.offset+4,COMPOSIT_BAG_COMMON_LIST4,2)



end
FORM_BAG_BACK.C50346_OnDraw = function( m )
m:OnDrawList(m.offset+5,COMPOSIT_BAG_COMMON_LIST5,2)



end
FORM_BAG_BACK.C50357_OnDraw = function( m )
m:OnDrawList(m.offset,COMPOSIT_BAG_TASK_LIST0,3)



end
FORM_BAG_BACK.C50356_OnDraw = function( m )
m:OnDrawList(m.offset+1,COMPOSIT_BAG_TASK_LIST1,3)




end
FORM_BAG_BACK.C50355_OnDraw = function( m )
m:OnDrawList(m.offset+2,COMPOSIT_BAG_TASK_LIST2,3)
end
FORM_BAG_BACK.C50354_OnDraw = function( m )
m:OnDrawList(m.offset+3,COMPOSIT_BAG_TASK_LIST3,3)




end
FORM_BAG_BACK.C50353_OnDraw = function( m )
m:OnDrawList(m.offset+4,COMPOSIT_BAG_TASK_LIST4,3)




end
FORM_BAG_BACK.C50352_OnDraw = function( m )
m:OnDrawList(m.offset+5,COMPOSIT_BAG_TASK_LIST5,3)




end
