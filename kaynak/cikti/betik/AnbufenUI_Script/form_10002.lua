FORM_DIALOG_YESNO= { }
FORM_DIALOG_YESNO.Main = function( m )
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
FORM_DIALOG_YESNO.C52786_OnLoad = function( m )
UI_Engine.SetState(m.formIndex,COMPOSIT_DIALOG_YESNO_LBUTTON,1)
end
FORM_DIALOG_YESNO.C52786_OnClick = function( m )
m:SetMsgBoxResult(MsgBox.ECODE_YES)
m:InputFinished()
end
FORM_DIALOG_YESNO.C52788_OnClick = function( m )
m:SetMsgBoxResult(MsgBox.ECODE_NO)
m:InputFinished()
end
