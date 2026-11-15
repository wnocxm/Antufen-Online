FORM_ROLE_LIST_BACKUP= { }
FORM_ROLE_LIST_BACKUP.Main = function( m )
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
FORM_ROLE_LIST_BACKUP.C50064_OnDraw = function( m )
m:DrawPortrait()
end
FORM_ROLE_LIST_BACKUP.C50060_OnClick = function( m )
--测试菜单
local item = m:OnClickTest()
m.Menu = CreateMenu(m, item)
print(m.Menu )
m.Menu :WaitUserInput(m)
local result = m.Menu :GetResult()
print("GetResult:"..result)
RemoveMenu(m.Menu)
end
FORM_ROLE_LIST_BACKUP.C50059_OnClick = function( m )
m:RoleLogin()
end
FORM_ROLE_LIST_BACKUP.C50068_OnClick = function( m )
local formIndex, sex,level,profession = m:OnClick(m.userSelectItem)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SEXINPUT,sex,0)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_LEVELINPUT,level,0)

UI_Engine.SetText(formIndex,
COMPOSIT_ROLELIST_PROFESSIONINPUT,profession,0)

m:DrawCommAttack()
end
FORM_ROLE_LIST_BACKUP.C50068_OnUpdate = function( m )
local formIndex,name,res,imgId,imgIndex= m:GetRoleList(m.offset)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_PERSON0,name,1)
UI_Engine.SetImg(formIndex,COMPOSIT_ROLELIST_PERSON0,res,imgId,imgIndex,0)

local formIndex, sex,level,profession = m:OnClick(m.userSelectItem)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SEXINPUT,sex,0)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_LEVELINPUT,level,0)
UI_Engine.SetText(formIndex,
COMPOSIT_ROLELIST_PROFESSIONINPUT,profession,0)
m:DrawCommAttack()
end
FORM_ROLE_LIST_BACKUP.C50065_OnClick = function( m )
local formIndex, sex,level,profession=m:OnClick(m.userSelectItem)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SEXINPUT,sex,0)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_LEVELINPUT,level,0)
UI_Engine.SetText(formIndex,
COMPOSIT_ROLELIST_PROFESSIONINPUT,profession,0)
m:DrawCommAttack()
end
FORM_ROLE_LIST_BACKUP.C50065_OnUpdate = function( m )
local formIndex,name,res,imgId,imgIndex= m:GetRoleList(m.offset+1)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_PERSON1,name,1)
UI_Engine.SetImg(formIndex,COMPOSIT_ROLELIST_PERSON1,res,imgId,imgIndex,0)

end
FORM_ROLE_LIST_BACKUP.C50066_OnClick = function( m )
local formIndex, sex,level,profession = m:OnClick(m.userSelectItem)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SEXINPUT,sex,0)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_LEVELINPUT,level,0)
UI_Engine.SetText(formIndex,
COMPOSIT_ROLELIST_PROFESSIONINPUT,profession,0)
m:DrawCommAttack()

end
FORM_ROLE_LIST_BACKUP.C50066_OnUpdate = function( m )
local formIndex,name,res,imgId ,imgIndex= m:GetRoleList(m.offset+2)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_PERSON2,name,1)
UI_Engine.SetImg(formIndex,COMPOSIT_ROLELIST_PERSON2,res,imgId,imgIndex,0)
end
FORM_ROLE_LIST_BACKUP.C50067_OnClick = function( m )
local formIndex, sex,level,profession = m:OnClick(m.userSelectItem)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SEXINPUT,sex,0)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_LEVELINPUT,level,0)
UI_Engine.SetText(formIndex, COMPOSIT_ROLELIST_PROFESSIONINPUT,profession,0)
m:DrawCommAttack()
end
FORM_ROLE_LIST_BACKUP.C50067_OnUpdate = function( m )
local formIndex,name,res,imgId ,imgIndex= m:GetRoleList(m.offset+3)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_PERSON3,name,1)
UI_Engine.SetImg(formIndex,COMPOSIT_ROLELIST_PERSON3,res,imgId,imgIndex,0)
end
FORM_ROLE_LIST_BACKUP.C50069_OnClick = function( m )
local formIndex, sex,level,profession = m:OnClick(m.userSelectItem)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SEXINPUT,sex,0)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_LEVELINPUT,level,0)
UI_Engine.SetText(formIndex,
COMPOSIT_ROLELIST_PROFESSIONINPUT,profession,0)
m:DrawCommAttack()
end
FORM_ROLE_LIST_BACKUP.C50069_OnUpdate = function( m )
local formIndex,name,res,imgId ,imgIndex= m:GetRoleList(m.offset+4)
UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_PERSON4,name,1)
UI_Engine.SetImg(formIndex,COMPOSIT_ROLELIST_PERSON4,res,imgId,imgIndex,0)
end
