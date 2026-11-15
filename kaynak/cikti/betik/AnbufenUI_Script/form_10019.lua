FORM_SYS_MENU= { }
FORM_SYS_MENU.Main = function( m )
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
FORM_SYS_MENU.C52800_OnClick = function( m )
m:OnSysMenuClick(COMPOSIT_SYS_MENU11)
m:InputFinished()
end
FORM_SYS_MENU.C52799_OnClick = function( m )
m:OnSysMenuClick(COMPOSIT_SYS_MENU10)
m:InputFinished()
end
FORM_SYS_MENU.C52798_OnClick = function( m )
m:OnSysMenuClick(COMPOSIT_SYS_MENU9)
m:InputFinished()
end
FORM_SYS_MENU.C52797_OnClick = function( m )
m:OnSysMenuClick(COMPOSIT_SYS_MENU8)
m:InputFinished()
end
FORM_SYS_MENU.C52796_OnClick = function( m )
m:OnSysMenuClick(COMPOSIT_SYS_MENU7)
m:InputFinished()
end
FORM_SYS_MENU.C52795_OnClick = function( m )
m:OnSysMenuClick(COMPOSIT_SYS_MENU6)
m:InputFinished()
end
FORM_SYS_MENU.C52794_OnClick = function( m )
m:OnSysMenuClick(COMPOSIT_SYS_MENU5)
m:InputFinished()
end
FORM_SYS_MENU.C52793_OnClick = function( m )
m:OnSysMenuClick(COMPOSIT_SYS_MENU4)
m:InputFinished()
end
FORM_SYS_MENU.C52792_OnClick = function( m )
m:OnSysMenuClick(COMPOSIT_SYS_MENU3)
m:InputFinished()
end
FORM_SYS_MENU.C52791_OnClick = function( m )
m:OnSysMenuClick(COMPOSIT_SYS_MENU2)
m:InputFinished()
end
FORM_SYS_MENU.C52790_OnClick = function( m )
m:OnSysMenuClick(COMPOSIT_SYS_MENU1)
m:InputFinished()
end
FORM_SYS_MENU.C52789_OnClick = function( m )
m:OnSysMenuClick(COMPOSIT_SYS_MENU0)
m:InputFinished()
end
FORM_SYS_MENU.C52809_OnClick = function( m )
RemoveMenu(m)
end
