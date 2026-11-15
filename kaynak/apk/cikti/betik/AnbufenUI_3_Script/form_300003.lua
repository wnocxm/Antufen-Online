NEW_FORM_DIALOG_DUMB= { }
NEW_FORM_DIALOG_DUMB.Main = function( m )
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
