FORM_SMCHANNEL= { }
FORM_SMCHANNEL.Main = function( m )
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
FORM_SMCHANNEL.C52804_OnClick = function( m )
m:GetSelID(1)
m:InputFinished()
end
FORM_SMCHANNEL.C52803_OnClick = function( m )
m:GetSelID(2)
m:InputFinished()
end
