NEW_FORM_MIANZE= { }
NEW_FORM_MIANZE.Main = function( m )
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
NEW_FORM_MIANZE.C50784_OnUpdate = function( m )
--local text = m:GetListText()
--UI_Engine.SetSlipperText(m.formIndex, UI3_COMPOSIT_784,text,0)
end
NEW_FORM_MIANZE.C50608_OnClick = function( m )
m:ClickOK(UI_Engine.GetState(formIndex,UI3_COMPOSIT_617))

end
