NEW_FORM_DIALOG_OK= { }
NEW_FORM_DIALOG_OK.Main = function( m )
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
NEW_FORM_DIALOG_OK.C50039_OnLoad = function( m )
UI_Engine.SetState(m.formIndex,COMPOSIT_DIALOG_OK_BUTTON,1)
end
NEW_FORM_DIALOG_OK.C50039_OnClick = function( m )
m:SetMsgBoxResult(MsgBox.ECODE_OK)
m:InputFinished()
end
