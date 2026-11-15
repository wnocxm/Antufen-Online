FORM_PETLIST= { }
FORM_PETLIST.Main = function( m )
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
G_IsSelectPet = function(m, nIndex)
	if m:IsExistPet(nIndex) then
		if m:IsCanDealPet(nIndex) then
			if m:IsCallPet(nIndex) then
				if m:IsDemisePet(nIndex) then
					m.MsgBox = NewMsgBox(m, "魔法兽死亡，无					法交易!", MsgBox.MODE_OK)
					m.MsgBox:WaitUserInput(m)
					local result = m.MsgBox:GetResult()
					m:GetClickSkill(result)
					DelMsgBox(m.MsgBox)
				else
					m:IncMinePetDeal(nIndex)
				end
			else
				m.MsgBox = NewMsgBox(m, "魔法兽不能召唤，无法				交易!", MsgBox.MODE_OK)
				m.MsgBox:WaitUserInput(m)
				local result = m.MsgBox:GetResult()
				m:GetClickSkill(result)
				DelMsgBox(m.MsgBox)

			end
		else
			m.MsgBox = NewMsgBox(m, "魔法兽不能交易!", 				MsgBox.MODE_OK)	
			m.MsgBox:WaitUserInput(m)
			local result = m.MsgBox:GetResult()
			m:GetClickSkill(result)
			DelMsgBox(m.MsgBox)
		end	
	else
	m.MsgBox = NewMsgBox(m, "魔法兽不存在，不能交易!", 	MsgBox.MODE_OK)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	m:GetClickSkill(result)
	DelMsgBox(m.MsgBox)
	end
end

local DrawList = function(m, offset, ctlID)
	local name,status,img = m:OnUpdateList(offset)
	UI_Engine.SetText(m.formIndex,ctlID,name,1)
	UI_Engine.SetText(m.formIndex,ctlID,status,2)
	UI_Engine.SetSurfaceImg(m.formIndex, ctlID, img, 0)
end
FORM_PETLIST.C50589_OnUpdate = function( m )
DrawList(m, m.offset+1, COMPOSIT_PET_LIST1 )
end
FORM_PETLIST.C50590_OnUpdate = function( m )
DrawList(m, m.offset+2, COMPOSIT_PET_LIST2 )
end
FORM_PETLIST.C50591_OnUpdate = function( m )
DrawList(m, m.offset+3, COMPOSIT_PET_LIST3 )
end
FORM_PETLIST.C50592_OnUpdate = function( m )
DrawList(m, m.offset+4, COMPOSIT_PET_LIST4 )
end
FORM_PETLIST.C50593_OnUpdate = function( m )
DrawList(m, m.offset+5, COMPOSIT_PET_LIST5 )
end
FORM_PETLIST.C50594_OnUpdate = function( m )
DrawList(m, m.offset+6, COMPOSIT_PET_LIST6 )
end
FORM_PETLIST.C50595_OnUpdate = function( m )
local name,status = m:OnUpdateList(m.offset+7)
UI_Engine.SetText(m.formIndex,COMPOSIT_PET_LIST7,name,1)
UI_Engine.SetText(m.formIndex,COMPOSIT_PET_LIST7,status,2)
end
FORM_PETLIST.C52121_OnClick = function( m )
m:OnExpand()
end
FORM_PETLIST.C50571_OnClick = function( m )
m:OnClickLRFunction(1)
m:InputFinished()
end
FORM_PETLIST.C50572_OnClick = function( m )
m:OnClick(m.userSelectItem)
m:ClickConfirm()
m:InputFinished()
	
end
