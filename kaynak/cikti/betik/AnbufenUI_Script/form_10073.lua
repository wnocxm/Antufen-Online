FORM_WORLDMAP= { }
FORM_WORLDMAP.Main = function( m )
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
FORM_WORLDMAP.C52802_OnClick = function( m )
if m:NewInGame()==1 then
	DelWorldMap(m)
else
	m:InputFinished()
end
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

local Enter = function(m)
	local str, code = m:EnterScene()
	if code == 0 then
		--if QueryUser(m, str) == MsgBox.ECODE_YES then
			m:GotoScene()
		--end
	elseif code == 1 then
		--if QueryUser(m, str) == MsgBox.ECODE_YES then
			m:GotoScene()
		--end
	elseif code == 2 then
		WarnUser(m, str)
	elseif code == 3 then
		WarnUser(m, str)
	end
end
	
FORM_WORLDMAP.C52938_OnClick = function( m )
m:luaChange()
end
FORM_WORLDMAP.C52801_OnClick = function( m )
--m:luaEnter()
Enter(m)
if m:NewInGame()==1 then
	DelWorldMap(m)
else
	m:InputFinished()
end
end
FORM_WORLDMAP.C51935_OnDraw = function( m )
m:DrawMap()
end
