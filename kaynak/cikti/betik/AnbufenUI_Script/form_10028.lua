FORM_TASK= { }
FORM_TASK.Main = function( m )
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
FORM_TASK.C52475_OnClick = function( m )

		if m:DelCurTask() then
			UI_Engine.UpdateList(m.formIndex, COMPOSIT_TASK_PREPARELIST3)
		end



end
local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end
FORM_TASK.C52734_OnClick = function( m )
m:OnClickLRFunction(1)
end
FORM_TASK.C50543_OnClick = function( m )
m:OnClickLRFunction(1)
end
FORM_TASK.C52573_OnClick = function( m )
local name, ptr =m:Detail()
if name ==nil then
else
m.info = NewInfoText(m, name, ptr)
end
end
FORM_TASK.C52476_OnClick = function( m )
m:FindNpc()
end
FORM_TASK.C50555_OnClick = function( m )
local strShow = m:OnClickList(m.offset)

end
FORM_TASK.C50555_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST0,task,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST0,status,1)

end
FORM_TASK.C50556_OnClick = function( m )
local strShow = m:OnClickList(m.offset+1)

end
FORM_TASK.C50556_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset+1)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST1,task,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST1,status,1)

end
FORM_TASK.C50557_OnClick = function( m )
local strShow = m:OnClickList(m.offset+2)

end
FORM_TASK.C50557_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset+2)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST2,task,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST2,status,1)
end
FORM_TASK.C50558_OnClick = function( m )
local strShow = m:OnClickList(m.offset+3)

end
FORM_TASK.C50558_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset+3)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST3,task,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST3,status,1)
end
FORM_TASK.C50559_OnClick = function( m )
local strShow = m:OnClickList(m.offset+4)

end
FORM_TASK.C50559_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset+4)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST4,task,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST4,status,1)
end
FORM_TASK.C50816_OnClick = function( m )
local strShow = m:OnClickList(m.offset+5)

end
FORM_TASK.C50816_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset+5)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST5,task,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST5,status,1)
end
FORM_TASK.C50817_OnClick = function( m )
local strShow = m:OnClickList(m.offset+6)

end
FORM_TASK.C50817_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset+6)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST6,task,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST6,status,1)
end
FORM_TASK.C50818_OnClick = function( m )
local strShow = m:OnClickList(m.offset+7)

end
FORM_TASK.C50818_OnUpdate = function( m )
local  task,status = m:OnUpdateList(m.offset+7)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST7,task,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_TASK_PREPARELIST7,status,1)
end
