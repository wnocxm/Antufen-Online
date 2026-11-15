NEW_FORM_ROLL= { }
NEW_FORM_ROLL.Main = function( m )
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
NEW_FORM_ROLL.C50692_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_ROLL.C50692_OnClick = function( m )
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
NEW_FORM_ROLL.C50690_OnClick = function( m )
m:Need()
m:InputFinished()
m:Close()

end
NEW_FORM_ROLL.C50691_OnClick = function( m )
if QueryUser(m,UI_Engine.GetLuaStr(STR_ROLL_GIVEUP_TXT)) == MsgBox.ECODE_YES  then
m:Giveup()
m:InputFinished()
m:Close()
end



end
NEW_FORM_ROLL.C50694_OnDraw = function( m )
local item = m:GetTime()
if item == nil then
	return 
end
if item == -1  then
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_694,"00:00"  )
	WarnUser(m, UI_Engine.GetLuaStr(R_STRING_ROLL_OVER))		m:InputFinished()		
	m:Close()
elseif item == 1 then
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_694,"00:01"  )
else
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_694,item  )
end




end
NEW_FORM_ROLL.C50687_OnLoad = function( m )
local name = m:GetItemName()
if name == nil then
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_687,"" )
else
	UI_Engine.SetText(m.formIndex,UI3_COMPOSIT_687,name )
end


end
NEW_FORM_ROLL.C50686_OnLoad = function( m )
local img , nSN = m:GetItemImg()

if img == nil then
	UI_Engine.SetSurfaceImg( m.formIndex, UI3_COMPOSIT_686, nil )
else
	UI_Engine.SetSurfaceImg( m.formIndex, UI3_COMPOSIT_686, img,0,0,false,nSN )
end

end
NEW_FORM_ROLL.C50686_OnUpdate = function( m )
local img = m:GetItemImg()

if img == nil then
	UI_Engine.SetSurfaceImg( m.formIndex, UI3_COMPOSIT_686, nil )
else
	UI_Engine.SetSurfaceImg( m.formIndex, UI3_COMPOSIT_686, img )
end

end
