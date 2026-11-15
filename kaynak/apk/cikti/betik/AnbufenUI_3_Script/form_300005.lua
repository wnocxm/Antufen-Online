NEW_FORM_DIALOG_YESNO= { }
NEW_FORM_DIALOG_YESNO.Main = function( m )
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
NEW_FORM_DIALOG_YESNO.C50041_OnLoad = function( m )
UI_Engine.SetState(m.formIndex,COMPOSIT_DIALOG_YESNO_LBUTTON,1)
end
NEW_FORM_DIALOG_YESNO.C50041_OnClick = function( m )
m:SetMsgBoxResult(MsgBox.ECODE_YES)
m:InputFinished()
end
NEW_FORM_DIALOG_YESNO.C50040_OnClick = function( m )
m:SetMsgBoxResult(MsgBox.ECODE_NO)
m:InputFinished()
end
