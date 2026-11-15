FORM_ROLE_LIST= { }
FORM_ROLE_LIST.Main = function( m )
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
FORM_ROLE_LIST.C52790_OnLoad = function( m )
m.Sel = 1
end
FORM_ROLE_LIST.C52790_OnClick = function( m )
m:OnBack()
end
function MyState(m)
	if m.Sel==1 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_1,1)
	elseif m.Sel== 2 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_2,1)
	elseif m.Sel==3 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_3,1)
	elseif m.Sel==4 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_4,1)
	elseif m.Sel==5 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_5,1)
	end
end

function SetImage(m, nType)

	if 6 < nType  then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_727,"UIData_iphone.godat", 2020,0,0)
	else
		UI_Engine.SetImg(m.formIndex,COMPOSIT_727,"UIData_iphone.godat", 2021,0,0)
end

	if 1 == nType  then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_728,"UIData_iphone.godat", 2029,0,0)

	elseif 2 == nType   then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_728,"UIData_iphone.godat", 2031,0,0)

	elseif 3 == nType   then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_728,"UIData_iphone.godat", 2033,0,0)

	elseif 4 == nType   then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_728,"UIData_iphone.godat", 2030,0,0)
	elseif 5 == nType   then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_728,"UIData_iphone.godat", 2032,0,0)

	elseif 6 == nType   then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_728,"UIData_iphone.godat", 2034,0,0)
	elseif 7 == nType   then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_728,"UIData_iphone.godat", 2023,0,0)

	elseif 8 == nType   then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_728,"UIData_iphone.godat", 2025,0,0)
	elseif 9 == nType   then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_728,"UIData_iphone.godat", 2027,0,0)
	elseif 10 == nType   then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_728,"UIData_iphone.godat", 2024,0,0)
	elseif 11 == nType   then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_728,"UIData_iphone.godat", 2026,0,0)
	elseif 12 == nType   then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_728,"UIData_iphone.godat", 2028,0,0)
	end
end
FORM_ROLE_LIST.C52789_OnClick = function( m )
m:RoleLogin()
end
FORM_ROLE_LIST.C52788_OnClick = function( m )
m:OnResume()
end
FORM_ROLE_LIST.C52787_OnClick = function( m )
m.MsgBox=NewMsgBox(m, "确定要删除角色么？", MsgBox.MODE_YESNO)
m.MsgBox:WaitUserInput(m)
local result = m.MsgBox:GetResult()
DelMsgBox(m.MsgBox)
if result==MsgBox.ECODE_YES then
	 m:OnDel()
end
end
FORM_ROLE_LIST.C50715_OnClick = function( m )
DBGPRINTF("new form create begin")
m.newRole = NewRoleForm(m)
DBGPRINTF("new form create end")
m.newRole:WaitUserInput(m)
DelRoleForm(m.newRole)
MyState(m)

end
FORM_ROLE_LIST.C50719_OnLoad = function( m )
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(0)


if time==0 then
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2479,"")
UI_Engine.SetVisible(m.formIndex,COMPOSIT_2678,false)
else

UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2479,time.."小时后删除")
UI_Engine.SetVisible(m.formIndex,COMPOSIT_2678,true)
end

if name~=nil then
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_1,name,1)
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_1,level,2)
	UI_Engine.SetImg(formIndex,COMPOSIT_ROLELIST_SELECTROLE_1,res,imgId,imgIndex,0)
	local roleAttr = m:SelectRole(0)
	SetImage(m, roleAttr)
else
	UI_Engine.SetVisible(formIndex,COMPOSIT_ROLELIST_SELECTROLE_1,false)
end

UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_1,1)

end
FORM_ROLE_LIST.C50719_OnLoseFocus = function( m )
 MyState(m)

end
FORM_ROLE_LIST.C50719_OnClick = function( m )
m.Sel = 1
local roleAttr = m:SelectRole(0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_1,1)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_2,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_3,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_4,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_5,0)
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(0)
if time==0 then
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2479,"")
UI_Engine.SetVisible(m.formIndex,COMPOSIT_2678,false)
else

UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2479,time.."小时后删除")
UI_Engine.SetVisible(m.formIndex,COMPOSIT_2678,true)
end

SetImage(m, roleAttr)
end
FORM_ROLE_LIST.C50720_OnLoad = function( m )
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(1)
if name~=nil then
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_2,name,1)
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_2,level,2)
	UI_Engine.SetImg(formIndex,COMPOSIT_ROLELIST_SELECTROLE_2,res,imgId,imgIndex,0)
else
	UI_Engine.SetVisible(formIndex,COMPOSIT_ROLELIST_SELECTROLE_2,false)
end

end
FORM_ROLE_LIST.C50720_OnLoseFocus = function( m )
 MyState(m)
end
FORM_ROLE_LIST.C50720_OnClick = function( m )
m.Sel = 2
local roleAttr = m:SelectRole(1)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_1,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_2,1)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_3,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_4,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_5,0)
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(1)
if time==0 then
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2479,"")
UI_Engine.SetVisible(m.formIndex,COMPOSIT_2678,false)
else

UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2479,time.."小时后删除")
UI_Engine.SetVisible(m.formIndex,COMPOSIT_2678,true)
end

SetImage(m, roleAttr)
end
FORM_ROLE_LIST.C50721_OnLoad = function( m )
local formIndex,name,level,res,imgId,imgIndex= m:GetRoleList(2)
if name~=nil then
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_3,name,1)
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_3,level,2)
	UI_Engine.SetImg(formIndex,COMPOSIT_ROLELIST_SELECTROLE_3,res,imgId,imgIndex,0)
else
	UI_Engine.SetVisible(formIndex,COMPOSIT_ROLELIST_SELECTROLE_3,false)
end
end
FORM_ROLE_LIST.C50721_OnLoseFocus = function( m )
 MyState(m)
end
FORM_ROLE_LIST.C50721_OnClick = function( m )
m.Sel = 3
local roleAttr = m:SelectRole(2)

UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_1,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_2,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_3,1)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_4,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_5,0)
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(2)
if time==0 then
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2479,"")
UI_Engine.SetVisible(m.formIndex,COMPOSIT_2678,false)
else

UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2479,time.."小时后删除")
UI_Engine.SetVisible(m.formIndex,COMPOSIT_2678,true)
end

SetImage(m, roleAttr)
end
FORM_ROLE_LIST.C50722_OnLoad = function( m )
local formIndex,name,level,res,imgId,imgIndex= m:GetRoleList(3)
if name~=nil then
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_4,name,1)
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_4,level,2)
	UI_Engine.SetImg(formIndex,COMPOSIT_ROLELIST_SELECTROLE_4,res,imgId,imgIndex,0)
else
	UI_Engine.SetVisible(formIndex,COMPOSIT_ROLELIST_SELECTROLE_4,false)
end
end
FORM_ROLE_LIST.C50722_OnLoseFocus = function( m )
 MyState(m)
end
FORM_ROLE_LIST.C50722_OnClick = function( m )
m.Sel = 4
local roleAttr = m:SelectRole(3)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_1,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_2,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_3,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_4,1)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_5,0)
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(3)
if time==0 then
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2479,"")
UI_Engine.SetVisible(m.formIndex,COMPOSIT_2678,false)
else

UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2479,time.."小时后删除")
UI_Engine.SetVisible(m.formIndex,COMPOSIT_2678,true)
end

SetImage(m, roleAttr)
end
FORM_ROLE_LIST.C52477_OnLoad = function( m )
local formIndex,name,level,res,imgId,imgIndex= m:GetRoleList(4)
if name~=nil then
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_5,name,1)
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_5,level,2)
	UI_Engine.SetImg(formIndex,COMPOSIT_ROLELIST_SELECTROLE_5,res,imgId,imgIndex,0)
else
	UI_Engine.SetVisible(formIndex,COMPOSIT_ROLELIST_SELECTROLE_5,false)
end
end
FORM_ROLE_LIST.C52477_OnLoseFocus = function( m )
 MyState(m)
end
FORM_ROLE_LIST.C52477_OnClick = function( m )
m.Sel = 5
local roleAttr = m:SelectRole(4)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_1,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_2,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_3,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_4,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_5,1)
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(4)
if time==0 then
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2479,"")
UI_Engine.SetVisible(m.formIndex,COMPOSIT_2678,false)
else

UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2479,time.."小时后删除")
UI_Engine.SetVisible(m.formIndex,COMPOSIT_2678,true)
end

SetImage(m, roleAttr)
end
