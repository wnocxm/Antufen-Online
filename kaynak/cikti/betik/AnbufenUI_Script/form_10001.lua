FORM_DIALOG_OK= { }
FORM_DIALOG_OK.Main = function( m )
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
FORM_DIALOG_OK.C52785_OnLoad = function( m )
UI_Engine.SetState(m.formIndex,COMPOSIT_DIALOG_OK_BUTTON,1)
end
FORM_DIALOG_OK.C52785_OnClick = function( m )
m:SetMsgBoxResult(MsgBox.ECODE_OK)
m:InputFinished()
end
