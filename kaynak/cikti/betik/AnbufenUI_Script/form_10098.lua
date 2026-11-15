FORM_ROLE_LIST_IPHONE= { }
FORM_ROLE_LIST_IPHONE.Main = function( m )
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
FORM_ROLE_LIST_IPHONE.C52800_OnLoad = function( m )
m.Sel = 1
end
FORM_ROLE_LIST_IPHONE.C52800_OnClick = function( m )
m:OnBack()
end
function State(m)
	if m.Sel==1 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_1_IPHONE,1)
	elseif m.Sel== 2 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_2_IPHONE,1)
	elseif m.Sel==3 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_3_IPHONE,1)
	elseif m.Sel==4 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_4_IPHONE,1)
	elseif m.Sel==5 then
		UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_5_IPHONE,1)
	end
end

function SetImg(m, nType)

	if 6 < nType  then
		UI_Engine.SetImg (m.formIndex,COMPOSIT_2671,"UIData_iphone.godat", 2002,0,0)

	else

		UI_Engine.SetImg (m.formIndex,COMPOSIT_2671,"UIData_iphone.godat", 2003,0,0)
end

	if 1 == nType  then
		UI_Engine.SetImg (m.formIndex,COMPOSIT_ROLE_SHOW_IPHONE,"UIData_iphone.godat", 2004,0,0)

	elseif 2 == nType   then

		UI_Engine.SetImg (m.formIndex,COMPOSIT_ROLE_SHOW_IPHONE,"UIData_iphone.godat", 2005,0,0)

	elseif 3 == nType   then

		UI_Engine.SetImg (m.formIndex,COMPOSIT_ROLE_SHOW_IPHONE,"UIData_iphone.godat", 2042,0,0)

	elseif 4 == nType   then

		UI_Engine.SetImg (m.formIndex,COMPOSIT_ROLE_SHOW_IPHONE,"UIData_iphone.godat", 2006,0,0)
	elseif 5 == nType   then

		UI_Engine.SetImg (m.formIndex,COMPOSIT_ROLE_SHOW_IPHONE,"UIData_iphone.godat", 2007,0,0)

	elseif 6 == nType   then
		UI_Engine.SetImg (m.formIndex,COMPOSIT_ROLE_SHOW_IPHONE,"UIData_iphone.godat", 2043,0,0)
	elseif 7 == nType   then
		UI_Engine.SetImg (m.formIndex,COMPOSIT_ROLE_SHOW_IPHONE,"UIData_iphone.godat", 2008,0,0)

	elseif 8 == nType   then
		UI_Engine.SetImg (m.formIndex,COMPOSIT_ROLE_SHOW_IPHONE,"UIData_iphone.godat", 2009,0,0)
	elseif 9 == nType   then
		UI_Engine.SetImg (m.formIndex,COMPOSIT_ROLE_SHOW_IPHONE,"UIData_iphone.godat", 2040,0,0)
	elseif 10 == nType   then
		UI_Engine.SetImg (m.formIndex,COMPOSIT_ROLE_SHOW_IPHONE,"UIData_iphone.godat", 2010,0,0)
	elseif 11 == nType   then
		UI_Engine.SetImg (m.formIndex,COMPOSIT_ROLE_SHOW_IPHONE,"UIData_iphone.godat", 2011,0,0)
	elseif 12 == nType   then
		UI_Engine.SetImg (m.formIndex,COMPOSIT_ROLE_SHOW_IPHONE,"UIData_iphone.godat", 2041,0,0)
	end
end
FORM_ROLE_LIST_IPHONE.C52799_OnClick = function( m )
m:RoleLogin()
end
FORM_ROLE_LIST_IPHONE.C52798_OnClick = function( m )
m:OnResume()
end
FORM_ROLE_LIST_IPHONE.C52797_OnClick = function( m )
m.MsgBox=NewMsgBox(m, "确定要删除角色么？", MsgBox.MODE_YESNO)
m.MsgBox:WaitUserInput(m)
local result = m.MsgBox:GetResult()
DelMsgBox(m.MsgBox)
if result==MsgBox.ECODE_YES then
	 m:OnDel()
end
end
FORM_ROLE_LIST_IPHONE.C52666_OnClick = function( m )
DBGPRINTF("new form create begin")
m.newRole = NewRoleForm(m)
DBGPRINTF("new form create end")
m.newRole:WaitUserInput(m)
DelRoleForm(m.newRole)
State(m)
end
FORM_ROLE_LIST_IPHONE.C52660_OnLoad = function( m )
m.formIndex = m.formIndex
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(0)
if time==0 then
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2670,"")
else

UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2670,time.."小时后删除")
end

if name~=nil then
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_1_IPHONE,name,1)
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_1_IPHONE,level,2)
	UI_Engine.SetImg(formIndex,COMPOSIT_ROLELIST_SELECTROLE_1_IPHONE,res,imgId,imgIndex,0)
	local roleAttr = m:SelectRole(0)
	SetImg(m,roleAttr )
else
	UI_Engine.SetVisible(formIndex,COMPOSIT_ROLELIST_SELECTROLE_1_IPHONE,false)
end

UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_1_IPHONE,1)

end
FORM_ROLE_LIST_IPHONE.C52660_OnLoseFocus = function( m )
State(m)
end
FORM_ROLE_LIST_IPHONE.C52660_OnClick = function( m )
local roleAttr = m:SelectRole(0)
m.Sel = 1
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_1_IPHONE,1)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_2_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_3_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_4_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_5_IPHONE,0)
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(0)
if time==0 then
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2670,"")
else

UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2670,time.."小时后删除")
end

SetImg(m,roleAttr )
end
FORM_ROLE_LIST_IPHONE.C52659_OnLoad = function( m )
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(1)
if name~=nil then
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_2_IPHONE,name,1)
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_2_IPHONE,level,2)
	UI_Engine.SetImg(formIndex,COMPOSIT_ROLELIST_SELECTROLE_2_IPHONE,res,imgId,imgIndex,0)
else
	UI_Engine.SetVisible(formIndex,COMPOSIT_ROLELIST_SELECTROLE_2_IPHONE,false)
end
end
FORM_ROLE_LIST_IPHONE.C52659_OnLoseFocus = function( m )
State(m)
end
FORM_ROLE_LIST_IPHONE.C52659_OnClick = function( m )
local roleAttr = m:SelectRole(1)
m.Sel = 2
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_1_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_2_IPHONE,1)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_3_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_4_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_5_IPHONE,0)
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(1)
if time==0 then
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2670,"")
else

UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2670,time.."小时后删除")
end

SetImg(m,roleAttr )
end
FORM_ROLE_LIST_IPHONE.C52658_OnLoad = function( m )
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(2)
if name~=nil then
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_3_IPHONE,name,1)
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_3_IPHONE,level,2)
	UI_Engine.SetImg(formIndex,COMPOSIT_ROLELIST_SELECTROLE_3_IPHONE,res,imgId,imgIndex,0)
else
	UI_Engine.SetVisible(formIndex,COMPOSIT_ROLELIST_SELECTROLE_3_IPHONE,false)
end
end
FORM_ROLE_LIST_IPHONE.C52658_OnLoseFocus = function( m )
State(m)
end
FORM_ROLE_LIST_IPHONE.C52658_OnClick = function( m )
local roleAttr = m:SelectRole(2)
m.Sel = 3
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_1_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_2_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_3_IPHONE,1)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_4_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_5_IPHONE,0)
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(2)
if time==0 then
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2670,"")
else

UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2670,time.."小时后删除")
end

SetImg(m,roleAttr )
end
FORM_ROLE_LIST_IPHONE.C52657_OnLoad = function( m )
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(3)
if name~=nil then
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_4_IPHONE,name,1)
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_4_IPHONE,level,2)
	UI_Engine.SetImg(formIndex,COMPOSIT_ROLELIST_SELECTROLE_4_IPHONE,res,imgId,imgIndex,0)
else
	UI_Engine.SetVisible(formIndex,COMPOSIT_ROLELIST_SELECTROLE_4_IPHONE,false)
end
end
FORM_ROLE_LIST_IPHONE.C52657_OnLoseFocus = function( m )
State(m)
end
FORM_ROLE_LIST_IPHONE.C52657_OnClick = function( m )
local roleAttr = m:SelectRole(3)
m.Sel = 4
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_1_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_2_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_3_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_4_IPHONE,1)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_5_IPHONE,0)
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(3)
if time==0 then
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2670,"")
else

UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2670,time.."小时后删除")
end

SetImg(m,roleAttr )
end
FORM_ROLE_LIST_IPHONE.C52656_OnLoad = function( m )
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(4)
if name~=nil then
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_5_IPHONE,name,1)
	UI_Engine.SetText(formIndex,COMPOSIT_ROLELIST_SELECTROLE_5_IPHONE,level,2)
	UI_Engine.SetImg(formIndex,COMPOSIT_ROLELIST_SELECTROLE_5_IPHONE,res,imgId,imgIndex,0)
else
	UI_Engine.SetVisible(formIndex,COMPOSIT_ROLELIST_SELECTROLE_5_IPHONE,false)
end
end
FORM_ROLE_LIST_IPHONE.C52656_OnLoseFocus = function( m )
State(m)
end
FORM_ROLE_LIST_IPHONE.C52656_OnClick = function( m )
local roleAttr = m:SelectRole(4)
m.Sel = 5
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_1_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_2_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_3_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_4_IPHONE,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_ROLELIST_SELECTROLE_5_IPHONE,1)
local formIndex,name,level,res,imgId,imgIndex,time= m:GetRoleList(4)
if time==0 then
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2670,"")
else

UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2670,time.."小时后删除")
end

SetImg(m,roleAttr )
end
