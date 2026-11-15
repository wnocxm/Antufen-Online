FORM_GAMEOTHER= { }
FORM_GAMEOTHER.Main = function( m )
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
FORM_GAMEOTHER.C50597_OnClick = function( m )
m:OnClickMenu(20)
end
FORM_GAMEOTHER.C50596_OnClick = function( m )
m:OnClickMenu(21)
end
