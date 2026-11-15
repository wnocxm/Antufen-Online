NEW_FORM_NEWPETAI= { }
NEW_FORM_NEWPETAI.Main = function( m )
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
local UpdateText = function(m, id, offset)
	local name, str = m:GetAIInfo(m.offset + offset)
	if name ~= nil then
		UI_Engine.SetText(m.formIndex, id, name)
		UI_Engine.SetText(m.formIndex, id, str, 1)
	else
		UI_Engine.SetText(m.formIndex, id, "")
		UI_Engine.SetText(m.formIndex, id, "", 1)
	end
end
NEW_FORM_NEWPETAI.C50145_OnClick = function( m )
m:SetResult(m.userSelectItem)
m:InputFinished()
end
NEW_FORM_NEWPETAI.C50145_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_145, 0)
end
NEW_FORM_NEWPETAI.C50146_OnClick = function( m )
m:SetResult(m.userSelectItem)
m:InputFinished()
end
NEW_FORM_NEWPETAI.C50146_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_146, 1)
end
NEW_FORM_NEWPETAI.C50147_OnClick = function( m )
m:SetResult(m.userSelectItem)
m:InputFinished()
end
NEW_FORM_NEWPETAI.C50147_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_147, 2)
end
NEW_FORM_NEWPETAI.C50148_OnClick = function( m )
m:SetResult(m.userSelectItem)
m:InputFinished()
end
NEW_FORM_NEWPETAI.C50148_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_148, 3)
end
NEW_FORM_NEWPETAI.C50149_OnClick = function( m )
m:SetResult(m.userSelectItem)
m:InputFinished()
end
NEW_FORM_NEWPETAI.C50149_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_149, 4)
end
NEW_FORM_NEWPETAI.C50150_OnClick = function( m )
m:SetResult(m.userSelectItem)
m:InputFinished()
end
NEW_FORM_NEWPETAI.C50150_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_150, 5)
end
NEW_FORM_NEWPETAI.C50144_OnClick = function( m )
m:InputFinished()
end
