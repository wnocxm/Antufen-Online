NEW_FORM_EXCHANGE= { }
NEW_FORM_EXCHANGE.Main = function( m )
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
NEW_FORM_EXCHANGE.C50235_OnLoad = function( m )
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_208, false)
UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_209, false)
local num = m:Equip_or_Pro()
if num == 1 then
	UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_209, true)
elseif num == 2 then
	UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_209, true)
elseif num == 0 then
	UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_208, true)
	UI_Engine.SetVisible(m.formIndex, UI3_COMPOSIT_209, true)
end
m:OnClickTab(0)
local strShow = m:OnClickList(0)
ShowDes(m,strShow)
UI_Engine.SetLevel(m.formIndex, 3)
end
function ShowDes(m,result)
--UI_Engine.SetText(m.formIndex ,UI3_COMPOSIT_237,result,0)
UI_Engine.SetSlipperText(m.formIndex, UI3_COMPOSIT_785,result,0)
end

local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_CANCEL)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local Convert = function(m)
	if true == m:ConvertPet() then
		m.Pet = NewSelectBag(m,1)
		if m.Pet ~= nil then
			m.Pet:WaitUserInput(m)
			local SelectItem = m.Pet:GetSelectItem()
			local code = m.Pet:GetExitCode()
			if code == 0 then 
				DelSelectBag(m.Pet)
				return
			end
			if SelectItem == 0 then
				return
			end
			if MsgBox.ECODE_YES == QueryUser(m, UI_Engine.GetLuaStr(R_STRING_EXCHANGE)) then
				m:SendPetConvert(SelectItem)
				DelSelectBag(m.Pet)
			end
		else
			WarnUser(m,UI_Engine.GetLuaStr(STR_ONOPEN_PET_PACKAGE))
		end
	else
		local MaxNum = m:OnClick()
		if MaxNum == 0 then

		elseif MaxNum > 1 then
			m.SelectNumBox = NewNumSel(m, UI_Engine.GetLuaStr(STR_SELECTNUMBER_TYPE_BUY), 1, 1, MaxNum)
			m.SelectNumBox:WaitUserInput(m)
			local  Quantity = m.SelectNumBox:GetResult()
			DelNumSel(m.SelectNumBox)

			m:Send(Quantity)
		elseif MaxNum == 1 then
 			m:Send(1)
		end
	end
end
		
local OnClickList= function(m)
local strShow = m:OnClickList(m.userSelectItem)
ShowDes(m,strShow)
local m_String,m_info,img,nSN=m:Detail(m.userSelectItem)
	m.info = NewItemInfo(m, img, m_String,m_info,nSN)
            m.info:WaitUserInput(m)
	local ret = m.info:GetResult()
	DelItemInfo(m.info)
      	if ret == 2 then
		Convert (m)
	end
end
local DrawList = function(m, nId, index)
	local str, img,nSN = m:GetDrawInfo(m.offset + index)
	if str ~= nil then
		UI_Engine.SetSurfaceImg(m.formIndex, nId, img, 0, 0, false, nSN)
		UI_Engine.SetText(m.formIndex, nId, str, 1);
	else
		UI_Engine.SetSurfaceImg(m.formIndex, nId, nil, 0)
		UI_Engine.SetText(m.formIndex, nId, "", 1)
	end
end
NEW_FORM_EXCHANGE.C50236_OnClick = function( m )
DelCombine(m)
end
NEW_FORM_EXCHANGE.C50226_OnClick = function( m )
OnClickList(m)

end
NEW_FORM_EXCHANGE.C50226_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_226, 0)

end
NEW_FORM_EXCHANGE.C50227_OnClick = function( m )
OnClickList(m)

end
NEW_FORM_EXCHANGE.C50227_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_227, 1)
end
NEW_FORM_EXCHANGE.C50228_OnClick = function( m )
OnClickList(m)

end
NEW_FORM_EXCHANGE.C50228_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_228, 2)

end
NEW_FORM_EXCHANGE.C50229_OnClick = function( m )
OnClickList(m)

end
NEW_FORM_EXCHANGE.C50229_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_229, 3)
end
NEW_FORM_EXCHANGE.C50230_OnClick = function( m )
OnClickList(m)

end
NEW_FORM_EXCHANGE.C50230_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_230, 4)
end
NEW_FORM_EXCHANGE.C50231_OnClick = function( m )
OnClickList(m)

end
NEW_FORM_EXCHANGE.C50231_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_231, 5)
end
NEW_FORM_EXCHANGE.C50232_OnClick = function( m )
OnClickList(m)

end
NEW_FORM_EXCHANGE.C50232_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_232, 6)

end
NEW_FORM_EXCHANGE.C50209_OnClick = function( m )
local title = m:OnClickTab(0)
UI_Engine.SetFormTab(m.formIndex, 0)
UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_227)
--UI_Engine.SetText(m.formIndex,COMPOSIT_TITLE,title,0)

local strShow = m:OnClickList(0)
ShowDes(m,strShow)

end
NEW_FORM_EXCHANGE.C50208_OnClick = function( m )
local title = m:OnClickTab(1)
UI_Engine.SetFormTab(m.formIndex, 1)
UI_Engine.UpdateList(m.formIndex, UI3_COMPOSIT_213)
--UI_Engine.SetText(m.formIndex,COMPOSIT_TITLE,title,0)

local strShow = m:OnClickList(0)
ShowDes(m,strShow)

end
NEW_FORM_EXCHANGE.C50212_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE.C50212_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_212, 0)
end
NEW_FORM_EXCHANGE.C50213_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE.C50213_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_213, 1)
end
NEW_FORM_EXCHANGE.C50214_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE.C50214_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_214, 2)
end
NEW_FORM_EXCHANGE.C50215_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE.C50215_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_215, 3)
end
NEW_FORM_EXCHANGE.C50216_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE.C50216_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_216, 4)
end
NEW_FORM_EXCHANGE.C50217_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE.C50217_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_217, 5)
end
NEW_FORM_EXCHANGE.C50218_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_EXCHANGE.C50218_OnUpdate = function( m )
DrawList(m, UI3_COMPOSIT_218, 6)
end
NEW_FORM_EXCHANGE.C50196_OnLoad = function( m )
local strShow = m:OnClickList(0)
ShowDes(m,strShow)
end
