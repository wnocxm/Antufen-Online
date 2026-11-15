FORM_GAMEROLE= { }
FORM_GAMEROLE.Main = function( m )
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
FORM_GAMEROLE.C50174_OnClick = function( m )
m:OnClickMenu(13)
end
FORM_GAMEROLE.C50173_OnClick = function( m )
m:OnClickMenu(12)

end
FORM_GAMEROLE.C50172_OnClick = function( m )
m:OnClickMenu(10)

end
FORM_GAMEROLE.C50171_OnClick = function( m )
m:OnClickMenu(14)

end
FORM_GAMEROLE.C50170_OnClick = function( m )
m:OnClickMenu(11)

end
