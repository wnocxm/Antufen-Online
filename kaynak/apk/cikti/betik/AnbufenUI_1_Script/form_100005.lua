NEW_FORM_LEARN_LIVESKILL= { }
NEW_FORM_LEARN_LIVESKILL.Main = function( m )
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
local WarnUser = function(m, str)             --单项对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_CANCEL)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local SetListText = function(m,nIndex,composit)
	local img,name,strEnd,color= m:GetListText(m.offset + nIndex)
	if color ~= 0 then
		UI_Engine.SetSurfaceImg( m.formIndex, composit, img ,0 )
		UI_Engine.SetText(m.formIndex,composit,name,1,color)
		UI_Engine.SetText(m.formIndex,composit,strEnd,2,color)
	else
		UI_Engine.SetSurfaceImg( m.formIndex, composit, img ,0 )
		UI_Engine.SetText(m.formIndex,composit,name,1)
		UI_Engine.SetText(m.formIndex,composit,strEnd,2)
	end
	local title = m:GetTitle()
	UI_Engine.SetText(m.formIndex,UI1_COMPOSIT_LEARN_LIVESKILL_TITLE,title,0)
end

local ShowInfo = function(m)
	m:SetSel(m.userSelectItem)
	local img,str,pinfo,sn = m:GetInfo()
	m.info = NewItemInfo(m,img,str,pinfo,sn)
	m.info:WaitUserInput(m)
	local exit = m.info:GetResult()
	DelItemInfo(m.info)
	if exit ~= 0 then
		local ask = m:GetLearnSkillAskStr()
			if QueryUser(m, ask  ) == MsgBox.ECODE_YES then
				m:Liveskill()
			end
	end
end
NEW_FORM_LEARN_LIVESKILL.C50086_OnClick = function( m )
m:Close()
end
NEW_FORM_LEARN_LIVESKILL.C50087_OnClick = function( m )
ShowInfo(m)
end
NEW_FORM_LEARN_LIVESKILL.C50087_OnUpdate = function( m )
SetListText(m,0,UI1_COMPOSIT_LEARN_LIVESKILL_0)
end
NEW_FORM_LEARN_LIVESKILL.C50088_OnClick = function( m )
ShowInfo(m)
end
NEW_FORM_LEARN_LIVESKILL.C50088_OnUpdate = function( m )
SetListText(m,1,UI1_COMPOSIT_LEARN_LIVESKILL_1)
end
NEW_FORM_LEARN_LIVESKILL.C50089_OnClick = function( m )
ShowInfo(m)
end
NEW_FORM_LEARN_LIVESKILL.C50089_OnUpdate = function( m )
SetListText(m,2,UI1_COMPOSIT_LEARN_LIVESKILL_2)
end
NEW_FORM_LEARN_LIVESKILL.C50090_OnClick = function( m )
ShowInfo(m)
end
NEW_FORM_LEARN_LIVESKILL.C50090_OnUpdate = function( m )
SetListText(m,3,UI1_COMPOSIT_LEARN_LIVESKILL_3)
end
NEW_FORM_LEARN_LIVESKILL.C50091_OnClick = function( m )
ShowInfo(m)
end
NEW_FORM_LEARN_LIVESKILL.C50091_OnUpdate = function( m )
SetListText(m,4,UI1_COMPOSIT_LEARN_LIVESKILL_4)
end
NEW_FORM_LEARN_LIVESKILL.C50092_OnClick = function( m )
ShowInfo(m)
end
NEW_FORM_LEARN_LIVESKILL.C50092_OnUpdate = function( m )
SetListText(m,5,UI1_COMPOSIT_LEARN_LIVESKILL_5)
end
NEW_FORM_LEARN_LIVESKILL.C50093_OnClick = function( m )
ShowInfo(m)
end
NEW_FORM_LEARN_LIVESKILL.C50093_OnUpdate = function( m )
SetListText(m,6,UI1_COMPOSIT_LEARN_LIVESKILL_6)
end
