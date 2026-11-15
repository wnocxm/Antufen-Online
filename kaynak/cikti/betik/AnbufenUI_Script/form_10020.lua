FORM_MULTICHATMENU= { }
FORM_MULTICHATMENU.Main = function( m )
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
FORM_MULTICHATMENU.C50226_OnClick = function( m )
m:OnClickReturn()
end
FORM_MULTICHATMENU.C50236_OnClick = function( m )
m:OnClickPublic(4)

end
FORM_MULTICHATMENU.C50235_OnClick = function( m )
m:OnClickPublic(3)

end
FORM_MULTICHATMENU.C50234_OnClick = function( m )
m:OnClickPublic(2)

end
FORM_MULTICHATMENU.C50233_OnClick = function( m )
m:OnClickPublic(1)

end
FORM_MULTICHATMENU.C50232_OnClick = function( m )
m:OnClickPublic(0)
end
FORM_MULTICHATMENU.C50231_OnClick = function( m )
m:OnClickRoom(2)


end
FORM_MULTICHATMENU.C50230_OnClick = function( m )
m:OnClickRoom(1)


end
FORM_MULTICHATMENU.C50229_OnClick = function( m )
m:OnClickRoom(0)

end
