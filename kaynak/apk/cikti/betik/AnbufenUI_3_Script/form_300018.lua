NEW_FORM_NPC_DIALOGUE= { }
NEW_FORM_NPC_DIALOGUE.Main = function( m )
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
NEW_FORM_NPC_DIALOGUE.C50294_OnClick = function( m )
m:Close()

end
local UpdateAnswer = function(m, composit, offset)
	local formIndex,str,state=m:SetAnswerItem(m.offset+offset)
	if formIndex~= nil then
		UI_Engine.SetText(m.formIndex,composit,str,0)
		UI_Engine.SetText(m.formIndex,composit,state,1)
	end
end

local OnClickAnswer = function(m, composit, offset)
	m:OnItemSelect(m.userSelectItem)
	formIndex, m.text = m:SetNPCProblem()
	UI_Engine.SetSlipperText(m.formIndex, UI3_COMPOSIT_NPC_CLIENT, m.text,0)
	UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_289)
	UpdateAnswer(m, composit, offset)
end

NEW_FORM_NPC_DIALOGUE.C50289_OnClick = function( m )
OnClickAnswer(m, UI3_COMPOSIT_289, 0)
end
NEW_FORM_NPC_DIALOGUE.C50289_OnUpdate = function( m )
UpdateAnswer(m, UI3_COMPOSIT_289, 0)
end
NEW_FORM_NPC_DIALOGUE.C50290_OnClick = function( m )
OnClickAnswer(m, UI3_COMPOSIT_290, 1)
end
NEW_FORM_NPC_DIALOGUE.C50290_OnUpdate = function( m )
UpdateAnswer(m, UI3_COMPOSIT_290, 1)
end
NEW_FORM_NPC_DIALOGUE.C50291_OnClick = function( m )
OnClickAnswer(m, UI3_COMPOSIT_291, 2)
end
NEW_FORM_NPC_DIALOGUE.C50291_OnUpdate = function( m )
UpdateAnswer(m, UI3_COMPOSIT_291, 2)
end
NEW_FORM_NPC_DIALOGUE.C50292_OnClick = function( m )
OnClickAnswer(m, UI3_COMPOSIT_292, 3)
end
NEW_FORM_NPC_DIALOGUE.C50292_OnUpdate = function( m )
UpdateAnswer(m, UI3_COMPOSIT_292, 3)
end
NEW_FORM_NPC_DIALOGUE.C50293_OnClick = function( m )
OnClickAnswer(m, UI3_COMPOSIT_293, 4)
end
NEW_FORM_NPC_DIALOGUE.C50293_OnUpdate = function( m )
UpdateAnswer(m, UI3_COMPOSIT_293, 4)
end
NEW_FORM_NPC_DIALOGUE.C50296_OnLoad = function( m )
formIndex, m.text = m:SetNPCProblem()
UI_Engine.SetSlipperText(m.formIndex, UI3_COMPOSIT_NPC_CLIENT, m.text,0)



end
