NEW_FORM_ABOUT_IPHONE= { }
NEW_FORM_ABOUT_IPHONE.Main = function( m )
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
NEW_FORM_ABOUT_IPHONE.C50605_OnLoad = function( m )
local num = m:OpinionEdition()
if num == 0 then --app
	UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_601, false)
	UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_602, false)
	UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_603, false)
	UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_606, false)
else
	UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_873, false)
	UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_874, false)
	UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_875, false)
	UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_876, false)
end
end
NEW_FORM_ABOUT_IPHONE.C50598_OnClick = function( m )
DelAbout(m)

end
