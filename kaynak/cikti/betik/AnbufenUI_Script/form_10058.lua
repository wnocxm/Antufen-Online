FORM_TASK_PK= { }
FORM_TASK_PK.Main = function( m )
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
FORM_TASK_PK.C51656_OnLoad = function( m )
local strText = m:GetTemplate()
UI_Engine.SetText(m.formIndex,COMPOSIT_1656,strText )
end
FORM_TASK_PK.C51591_OnClick = function( m )
m:ChangeTemplate(1)
local strText = m:GetTemplate()
UI_Engine.SetText(m.formIndex,COMPOSIT_1656,strText )

end
FORM_TASK_PK.C51590_OnClick = function( m )
m:ChangeTemplate(0)
local strText = m:GetTemplate()
UI_Engine.SetText(m.formIndex,COMPOSIT_1656,strText )
end
FORM_TASK_PK.C51657_OnClick = function( m )
m.InputBox = OpenInputBox(m,"",10 )
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if Tools.IsNumberOnly(result) then
	WarnUser(m, "只能输入数字!")
	return
end


UI_Engine.SetText(m.formIndex,COMPOSIT_1657,result  )
m:SetPlayerID(result )
end
FORM_TASK_PK.C51593_OnClick = function( m )
m:ChangeCount(1)
local strText = m:GetCount()
UI_Engine.SetText(m.formIndex,COMPOSIT_1658,strText )
end
FORM_TASK_PK.C51592_OnClick = function( m )
m:ChangeCount(0)
local strText = m:GetCount()
UI_Engine.SetText(m.formIndex,COMPOSIT_1658,strText )
end
FORM_TASK_PK.C51658_OnLoad = function( m )

local strText = m:GetCount()
UI_Engine.SetText(m.formIndex,COMPOSIT_1658,strText )
end
FORM_TASK_PK.C51659_OnLoad = function( m )

UI_Engine.SetText(m.formIndex,COMPOSIT_1659,"0" )
end
FORM_TASK_PK.C51659_OnClick = function( m )



m.InputBox = OpenInputBox(m,"",10 )
m.InputBox :WaitUserInput(m)
local result = m.InputBox :GetResult()
if Tools.IsNumberOnly(result) then
	WarnUser(m, "只能输入数字!")
	return
end

m:SetPrice(result)
UI_Engine.SetText(m.formIndex,COMPOSIT_1659,result )

end
FORM_TASK_PK.C51596_OnClick = function( m )
m:ChangeLevel(1)
local strText = m:GetLevel()
UI_Engine.SetText(m.formIndex,COMPOSIT_1660,strText )
end
FORM_TASK_PK.C51595_OnClick = function( m )
m:ChangeLevel(0)
local strText = m:GetLevel()
UI_Engine.SetText(m.formIndex,COMPOSIT_1660,strText )
end
FORM_TASK_PK.C51660_OnLoad = function( m )

local strText = m:GetLevel()
UI_Engine.SetText(m.formIndex,COMPOSIT_1660,strText )
end
FORM_TASK_PK.C51570_OnClick = function( m )
if m:MakeTaskData() == false then
WarnUser(m,"Data error")
return 
end
if m:IsTaskMy() then
WarnUser(m,"IsTaskMy")
return 
end

if m:IsTaskGM() then
WarnUser(m,"IsTaskGM")
return 
end

m:GreatTask()
m:InputFinished()

end
FORM_TASK_PK.C51571_OnClick = function( m )
DBGPRINTF("exit")
m:InputFinished()
m:Close()
end
