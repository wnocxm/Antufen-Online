NEW_FORM_MAIL_LIST= { }
NEW_FORM_MAIL_LIST.Main = function( m )
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
NEW_FORM_MAIL_LIST.C50341_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_MAIL_LIST.C50341_OnClick = function( m )
m:InputFinished()
m:Close()

end
local WarnUser = function(m, str)             --单项对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_OK)
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

local DrawDescribe = function(m,index)
	local strText = m:GetDescribe(index)
end

local UpDateList = function(m)
	UI_Engine.UpdateList(m.formIndex ,UI3_COMPOSIT_334)
	UI_Engine.UpdateList(m.formIndex ,UI3_COMPOSIT_325)
	UI_Engine.UpdateList(m.formIndex ,UI3_COMPOSIT_313)
end


local SetListItem = function(m,nIndex,composit)
	local imgMail, imgAnnex ,name , time = m:GetMailList(m.offset + nIndex)

	if imgMail == 0 then
	UI_Engine.SetSurfaceImg( m.formIndex, composit, nil ,0 )
	else
	UI_Engine.SetSurfaceImg( m.formIndex, composit, imgMail  ,0 )
	end

	if imgAnnex == 0 then
	UI_Engine.SetSurfaceImg( m.formIndex, composit, nil ,1 )
	else
	UI_Engine.SetSurfaceImg( m.formIndex, composit, imgAnnex  ,1)
	end

	if name == 0 then
	UI_Engine.SetRollText(m.formIndex,composit,"",2)
	else
	UI_Engine.SetRollText(m.formIndex,composit,name,2)
	end

	if time == 0 then
	UI_Engine.SetText(m.formIndex,composit,"",3)
	else
	UI_Engine.SetText(m.formIndex,composit,time ,3)
	end
end

local OnClickList= function(m)
	m:SetSel(m.userSelectItem)
	local n  = m.userSelectItem
	if m.userSelectItem ~= nil  then
		if n < 0 then
			n = 0
		end
	else
		n= 0
	end
	m:SendLookMsg(n)
	UpDateList(m)
end
NEW_FORM_MAIL_LIST.C50342_OnLoad = function( m )
local nDrawType = m:GetDrawType()
m:SetSel(0)
m:SetTab(MailLabelType.MAIL_LABEL_SYSTEM)
UI_Engine.SetFormTab( m.formIndex, 0)
if nDrawType == MailDrawType.DRAW_MAIL_GM_SYSTEM then
	UI_Engine.SetVisible( m.formIndex, UI3_COMPOSIT_310, false )
else
	UI_Engine.SetVisible( m.formIndex,UI3_COMPOSIT_310, true )
end
DrawDescribe(m, 0)
UpDateList(m)
end
NEW_FORM_MAIL_LIST.C50334_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50334_OnClick = function( m )
OnClickList(m)


end
NEW_FORM_MAIL_LIST.C50334_OnUpdate = function( m )
SetListItem(m, 0 ,UI3_COMPOSIT_334)


end
NEW_FORM_MAIL_LIST.C50335_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50335_OnClick = function( m )
OnClickList(m)
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50335_OnUpdate = function( m )
SetListItem(m, 1 ,UI3_COMPOSIT_335)
end
NEW_FORM_MAIL_LIST.C50336_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50336_OnClick = function( m )
OnClickList(m)
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50336_OnUpdate = function( m )
SetListItem(m, 2 ,UI3_COMPOSIT_336)
end
NEW_FORM_MAIL_LIST.C50337_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50337_OnClick = function( m )
OnClickList(m)
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50337_OnUpdate = function( m )
SetListItem(m, 3 ,UI3_COMPOSIT_337)
end
NEW_FORM_MAIL_LIST.C50338_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50338_OnClick = function( m )
OnClickList(m)
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50338_OnUpdate = function( m )
SetListItem(m, 4 ,UI3_COMPOSIT_338)

end
NEW_FORM_MAIL_LIST.C50339_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50339_OnClick = function( m )
OnClickList(m)
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50339_OnUpdate = function( m )
SetListItem(m, 5 ,UI3_COMPOSIT_339)
end
NEW_FORM_MAIL_LIST.C50340_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50340_OnClick = function( m )
OnClickList(m)
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50340_OnUpdate = function( m )
SetListItem(m, 6 ,UI3_COMPOSIT_340)
end
NEW_FORM_MAIL_LIST.C50325_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50325_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_MAIL_LIST.C50325_OnUpdate = function( m )
SetListItem(m, 0 ,UI3_COMPOSIT_325)
end
NEW_FORM_MAIL_LIST.C50326_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50326_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_MAIL_LIST.C50326_OnUpdate = function( m )
SetListItem(m, 1 ,UI3_COMPOSIT_326)
end
NEW_FORM_MAIL_LIST.C50327_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50327_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_MAIL_LIST.C50327_OnUpdate = function( m )
SetListItem(m, 2 ,UI3_COMPOSIT_327)
end
NEW_FORM_MAIL_LIST.C50328_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50328_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_MAIL_LIST.C50328_OnUpdate = function( m )
SetListItem(m, 3 ,UI3_COMPOSIT_328)
end
NEW_FORM_MAIL_LIST.C50329_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50329_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_MAIL_LIST.C50329_OnUpdate = function( m )
SetListItem(m, 4 ,UI3_COMPOSIT_329)
end
NEW_FORM_MAIL_LIST.C50330_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50330_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_MAIL_LIST.C50330_OnUpdate = function( m )
SetListItem(m, 5 ,UI3_COMPOSIT_330)
end
NEW_FORM_MAIL_LIST.C50331_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50331_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_MAIL_LIST.C50331_OnUpdate = function( m )
SetListItem(m, 6 ,UI3_COMPOSIT_331)
end
NEW_FORM_MAIL_LIST.C50313_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50313_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_MAIL_LIST.C50313_OnUpdate = function( m )
SetListItem(m, 0 ,UI3_COMPOSIT_313)
end
NEW_FORM_MAIL_LIST.C50314_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50314_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_MAIL_LIST.C50314_OnUpdate = function( m )
SetListItem(m, 1 ,UI3_COMPOSIT_314)
end
NEW_FORM_MAIL_LIST.C50315_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50315_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_MAIL_LIST.C50315_OnUpdate = function( m )
SetListItem(m, 2 ,UI3_COMPOSIT_315)
end
NEW_FORM_MAIL_LIST.C50316_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50316_OnClick = function( m )
OnClickList(m)

end
NEW_FORM_MAIL_LIST.C50316_OnUpdate = function( m )
SetListItem(m, 3 ,UI3_COMPOSIT_316)
end
NEW_FORM_MAIL_LIST.C50317_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50317_OnClick = function( m )
OnClickList(m)

end
NEW_FORM_MAIL_LIST.C50317_OnUpdate = function( m )
SetListItem(m, 4 ,UI3_COMPOSIT_317)
end
NEW_FORM_MAIL_LIST.C50318_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50318_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_MAIL_LIST.C50318_OnUpdate = function( m )
SetListItem(m, 5 ,UI3_COMPOSIT_318)
end
NEW_FORM_MAIL_LIST.C50319_OnFocus = function( m )
DrawDescribe(m, m.userSelectItem)

end
NEW_FORM_MAIL_LIST.C50319_OnClick = function( m )
OnClickList(m)
end
NEW_FORM_MAIL_LIST.C50319_OnUpdate = function( m )
SetListItem(m, 6 ,UI3_COMPOSIT_319)
end
NEW_FORM_MAIL_LIST.C50308_OnClick = function( m )
m:SetSel(0)
m:SetTab(MailLabelType.MAIL_LABEL_SYSTEM)
UI_Engine.SetFormTab( m.formIndex, 0 )
UpDateList(m)
DrawDescribe(m,0)

end
NEW_FORM_MAIL_LIST.C50309_OnClick = function( m )

m:SetSel(0)
m:SetTab(MailLabelType.MAIL_LABEL_GM)
UI_Engine.SetFormTab( m.formIndex, 1)

UpDateList(m)
DrawDescribe(m,0)


end
NEW_FORM_MAIL_LIST.C50310_OnClick = function( m )
local nDrawType = m:GetDrawType()
if nDrawType == MailDrawType.DRAW_MAIL_GM_SYSTEM then
else
	m:SetSel(0)
	m:SetTab(MailLabelType.MAIL_LABEL_PLAYER)
	UI_Engine.SetFormTab( m.formIndex, 2 )
end

UpDateList(m)
DrawDescribe(m,0)

end
NEW_FORM_MAIL_LIST.C50846_OnClick = function( m )
m:DoBatchDelete()
end
