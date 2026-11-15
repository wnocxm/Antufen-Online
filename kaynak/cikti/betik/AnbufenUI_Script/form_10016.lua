FORM_GAMECOMMU= { }
FORM_GAMECOMMU.Main = function( m )
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
FORM_GAMECOMMU.C50169_OnClick = function( m )
m:OnClickMenu(28)

end
FORM_GAMECOMMU.C50168_OnClick = function( m )
m:OnClickMenu(27)

end
FORM_GAMECOMMU.C50167_OnClick = function( m )
m:OnClickMenu(29)

end
FORM_GAMECOMMU.C50166_OnClick = function( m )
m:OnClickMenu(26)

end
