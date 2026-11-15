NEW_FORM_ROLLPRIZE= { }
NEW_FORM_ROLLPRIZE.Main = function( m )
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
NEW_FORM_ROLLPRIZE.C50261_OnDraw = function( m )
m:MyDraw()
end
NEW_FORM_ROLLPRIZE.C50262_OnClick = function( m )
m:InputFinished()
m:Close()
end
NEW_FORM_ROLLPRIZE.C50257_OnClick = function( m )
m:ClickRadio(1,UI_Engine.GetState(m.formIndex,UI1_COMPOSIT_ROLLPRIZE_BUTTON_AUTORUN))
end
NEW_FORM_ROLLPRIZE.C50258_OnClick = function( m )
m:ClickRadio(2,UI_Engine.GetState(m.formIndex,UI1_COMPOSIT_ROLLPRIZE_BUTTON_AUTOGET))
end
NEW_FORM_ROLLPRIZE.C50256_OnClick = function( m )
m:ClickBtn()
end
