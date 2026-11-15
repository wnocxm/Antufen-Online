FORM_LOGIN_MENU= { }
FORM_LOGIN_MENU.Main = function( m )
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
FORM_LOGIN_MENU.C50091_OnClick = function( m )
m.RevisePwd()
end
FORM_LOGIN_MENU.C50090_OnClick = function( m )
m.GameRegist()
end
FORM_LOGIN_MENU.C50089_OnClick = function( m )
m.LoginGame()
end
