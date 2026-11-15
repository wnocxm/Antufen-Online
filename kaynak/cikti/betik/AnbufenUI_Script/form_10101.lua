FORM_ABOUT_V5= { }
FORM_ABOUT_V5.Main = function( m )
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
FORM_ABOUT_V5.C52818_OnClick = function( m )
DelAbout(m)
end
FORM_ABOUT_V5.C52817_OnClick = function( m )
DelAbout(m)
end
FORM_ABOUT_V5.C52816_OnDraw = function( m )
m:SetAlpha(COMPOSIT_2816)
end
