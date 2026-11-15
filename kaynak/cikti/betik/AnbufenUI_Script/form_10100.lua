FORM_ABOUT_IPHONE= { }
FORM_ABOUT_IPHONE.Main = function( m )
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
FORM_ABOUT_IPHONE.C52815_OnClick = function( m )
DelAbout(m)
end
FORM_ABOUT_IPHONE.C52814_OnClick = function( m )
DelAbout(m)
end
FORM_ABOUT_IPHONE.C52813_OnDraw = function( m )
m:SetAlpha(COMPOSIT_2813)
end
