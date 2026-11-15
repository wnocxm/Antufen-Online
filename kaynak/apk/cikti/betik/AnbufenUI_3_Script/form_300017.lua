NEW_FORM_TASK= { }
NEW_FORM_TASK.Main = function( m )
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
NEW_FORM_TASK.C50280_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 2)
end
NEW_FORM_TASK.C50280_OnClick = function( m )
m:OnClickLRFunction(1)
end
local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local OnClickList= function(m)
         local m_vString, m_vInfo =m:Detail()
                m.info = NewItemInfo(m, m_vString, m_vInfo)
                m.info:WaitUserInput(m)
	    local ret = m.info:GetResult()
	    DelItemInfo(m.info)
      	 if ret == 1 then
		m:FindNpc()
             elseif ret == 2 then
		if MsgBox.ECODE_YES == QueryUser(m, UI_Engine.GetLuaStr(R_STRING_TASK_NOTECANCELTASK)) then
                             	if m:DelCurTask() then
				UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_TASK_PREPARELIST0)
			end	
		end
	end
end
NEW_FORM_TASK.C50273_OnClick = function( m )
local strShow = m:OnClickList(m.offset)
OnClickList(m)
end
NEW_FORM_TASK.C50273_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST0,task,0)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST0,status,1)





end
NEW_FORM_TASK.C50274_OnClick = function( m )
local strShow = m:OnClickList(m.offset+1)
OnClickList(m)

end
NEW_FORM_TASK.C50274_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset+1)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST1,task,0)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST1,status,1)






end
NEW_FORM_TASK.C50275_OnClick = function( m )
local strShow = m:OnClickList(m.offset+2)
OnClickList(m)
end
NEW_FORM_TASK.C50275_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset+2)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST2,task,0)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST2,status,1)






end
NEW_FORM_TASK.C50276_OnClick = function( m )
local strShow = m:OnClickList(m.offset+3)
OnClickList(m)
end
NEW_FORM_TASK.C50276_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset+3)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST3,task,0)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST3,status,1)







end
NEW_FORM_TASK.C50277_OnClick = function( m )
local strShow = m:OnClickList(m.offset+4)
OnClickList(m)
end
NEW_FORM_TASK.C50277_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset+4)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST4,task,0)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST4,status,1)








end
NEW_FORM_TASK.C50278_OnClick = function( m )
local strShow = m:OnClickList(m.offset+5)
OnClickList(m)
end
NEW_FORM_TASK.C50278_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset+5)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST5,task,0)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST5,status,1)









end
NEW_FORM_TASK.C50279_OnClick = function( m )
local strShow = m:OnClickList(m.offset+6)
OnClickList(m)
end
NEW_FORM_TASK.C50279_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset+6)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST6,task,0)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST6,status,1)










end
NEW_FORM_TASK.C50788_OnClick = function( m )
local strShow = m:OnClickList(m.offset+7)
OnClickList(m)
end
NEW_FORM_TASK.C50788_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset+7)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST7,task,0)
UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_TASK_PREPARELIST7,status,1)











end
