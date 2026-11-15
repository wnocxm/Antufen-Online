FORM_NPC_DIALOGUE= { }
FORM_NPC_DIALOGUE.Main = function( m )
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
FORM_NPC_DIALOGUE.C52484_OnClick = function( m )
m:Close()
end
local UpdateAnswer = function(m, composit, offset)
	if false == m:IsNeedSplit() then
		UI_Engine.SetText(m.formIndex, COMPOSIT_DIALOGUE1, "继续")
	else
		local formIndex,str=m:SetAnswerItem(m.offset+offset)
		UI_Engine.SetText(formIndex,composit,str)
	end
end

local OnClickAnswer = function(m, composit, offset)
	if false == m:IsNeedSplit() then
		if COMPOSIT_DIALOGUE1 == composit then
			m.ret = m:OnClickGoOn()				
		end
		if true == m.ret then
			if true == m:IsNeedSplit() then
				UpdateAnswer(m, composit, offset)
			end
		end
	else
		m:OnItemSelect(m.userSelectItem)
		formIndex, m.text = m:SetNPCProblem()
		UI_Engine.SetText(m.formIndex, COMPOSIT_NPC_CLIENT, m.text)
	end
	UI_Engine.UpdateList(m.formIndex, COMPOSIT_DIALOGUE1)
	UpdateAnswer(m, composit, offset)
end
FORM_NPC_DIALOGUE.C52688_OnClick = function( m )
m:Close()
end
FORM_NPC_DIALOGUE.C50734_OnClick = function( m )
--[[m:OnItemSelect(m.userSelectItem)
formIndex, m.text = m:SetNPCProblem()
UI_Engine.SetText(m.formIndex, COMPOSIT_NPC_CLIENT, m.text)--]]
OnClickAnswer(m, COMPOSIT_DIALOGUE0, 0)
end
FORM_NPC_DIALOGUE.C50734_OnUpdate = function( m )
--local formIndex,str=m:SetAnswerItem(m.offset)
--UI_Engine.SetText(formIndex,COMPOSIT_DIALOGUE0,str,0)
UpdateAnswer(m, COMPOSIT_DIALOGUE0, 0)
end
FORM_NPC_DIALOGUE.C50735_OnClick = function( m )
OnClickAnswer(m, COMPOSIT_DIALOGUE1, 1)
end
FORM_NPC_DIALOGUE.C50735_OnUpdate = function( m )
--local formIndex,str=m:SetAnswerItem(m.offset+1)
--UI_Engine.SetText(formIndex,COMPOSIT_DIALOGUE1,str,0)
UpdateAnswer(m, COMPOSIT_DIALOGUE1, 1)
end
FORM_NPC_DIALOGUE.C50736_OnClick = function( m )
OnClickAnswer(m, COMPOSIT_DIALOGUE2, 2)
end
FORM_NPC_DIALOGUE.C50736_OnUpdate = function( m )
--local formIndex,str=m:SetAnswerItem(m.offset+2)
--UI_Engine.SetText(formIndex,COMPOSIT_DIALOGUE2,str,0)
UpdateAnswer(m, COMPOSIT_DIALOGUE2, 2)
end
FORM_NPC_DIALOGUE.C50737_OnClick = function( m )
OnClickAnswer(m, COMPOSIT_DIALOGUE3, 3)
end
FORM_NPC_DIALOGUE.C50737_OnUpdate = function( m )
--local formIndex,str=m:SetAnswerItem(m.offset+3)
--UI_Engine.SetText(formIndex,COMPOSIT_DIALOGUE3,str,0)
UpdateAnswer(m, COMPOSIT_DIALOGUE3, 3)
end
FORM_NPC_DIALOGUE.C50738_OnClick = function( m )
OnClickAnswer(m, COMPOSIT_DIALOGUE4,4)
end
FORM_NPC_DIALOGUE.C50738_OnUpdate = function( m )
--local formIndex,str=m:SetAnswerItem(m.offset+4)
--UI_Engine.SetText(formIndex,COMPOSIT_DIALOGUE4,str,0)
UpdateAnswer(m, COMPOSIT_DIALOGUE4, 4)
end
FORM_NPC_DIALOGUE.C50739_OnClick = function( m )
OnClickAnswer(m, COMPOSIT_DIALOGUE5, 5)
end
FORM_NPC_DIALOGUE.C50739_OnUpdate = function( m )
--local formIndex,str=m:SetAnswerItem(m.offset+5)
--UI_Engine.SetText(formIndex,COMPOSIT_DIALOGUE5,str,0)
UpdateAnswer(m, COMPOSIT_DIALOGUE5, 5)
end
FORM_NPC_DIALOGUE.C50740_OnLoad = function( m )
formIndex, m.text = m:SetNPCProblem()
UI_Engine.SetText(m.formIndex, COMPOSIT_NPC_CLIENT, m.text)
end
