NEW_FORM_SYS_NEW= { }
NEW_FORM_SYS_NEW.Main = function( m )
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
NEW_FORM_SYS_NEW.C50709_OnClick = function( m )
RemoveMenu(m)
end
NEW_FORM_SYS_NEW.C50718_OnClick = function( m )
m:OnSysMenuClick(6)
end
NEW_FORM_SYS_NEW.C50717_OnClick = function( m )
m:OnSysMenuClick(5)
end
NEW_FORM_SYS_NEW.C50716_OnClick = function( m )
m:OnSysMenuClick(4)
end
NEW_FORM_SYS_NEW.C50715_OnClick = function( m )
m:OnSysMenuClick(3)
end
NEW_FORM_SYS_NEW.C50714_OnClick = function( m )
m:OnSysMenuClick(2)
end
NEW_FORM_SYS_NEW.C50713_OnClick = function( m )
m:OnSysMenuClick(1)
end
NEW_FORM_SYS_NEW.C50712_OnClick = function( m )
m:OnSysMenuClick(0)
end
NEW_FORM_SYS_NEW.C50711_OnClick = function( m )
m:ClickArrow(true)
end
NEW_FORM_SYS_NEW.C50710_OnClick = function( m )
m:ClickArrow(false)
end
