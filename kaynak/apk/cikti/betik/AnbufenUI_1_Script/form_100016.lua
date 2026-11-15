NEW_FORM_WORLDMAP= { }
NEW_FORM_WORLDMAP.Main = function( m )
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
local OnClick = function( m, nCompositID )
	m:OnClick(nCompositID)
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
			DBGPRINTF("0")
			m:GotoScene()
			return 0
		--end
	elseif code == 1 then
		--if QueryUser(m, str) == MsgBox.ECODE_YES then
			DBGPRINTF("1")
			m:GotoScene()
			return 0
		--end
	elseif code == 2 then
		DBGPRINTF("2")
		--WarnUser(m, str)
		return 2
	elseif code == 3 then
		DBGPRINTF("3")
		--WarnUser(m, str)
		return 2
	end
end
	

NEW_FORM_WORLDMAP.C50322_OnClick = function( m )
OnClick( m, UI1_COMPOSIT_WORLDMAP_POINT_1 )
end
NEW_FORM_WORLDMAP.C50323_OnClick = function( m )
OnClick( m, UI1_COMPOSIT_WORLDMAP_POINT_2 )
end
NEW_FORM_WORLDMAP.C50324_OnClick = function( m )
OnClick( m, UI1_COMPOSIT_WORLDMAP_POINT_3 )
end
NEW_FORM_WORLDMAP.C50325_OnClick = function( m )
OnClick( m, UI1_COMPOSIT_WORLDMAP_POINT_4 )
end
NEW_FORM_WORLDMAP.C50326_OnClick = function( m )
OnClick( m, UI1_COMPOSIT_WORLDMAP_POINT_5 )
end
NEW_FORM_WORLDMAP.C50327_OnClick = function( m )
OnClick( m, UI1_COMPOSIT_WORLDMAP_POINT_6 )
end
NEW_FORM_WORLDMAP.C50328_OnClick = function( m )
OnClick( m, UI1_COMPOSIT_WORLDMAP_POINT_7 )
end
NEW_FORM_WORLDMAP.C50315_OnClick = function( m )
--if m:NewInGame()==1 then
	--DelWorldMap(m)
--else
	--m:InputFinished()
--end
OnClick( m, UI1_COMPOSIT_WORLDMAP_BUTTON_CLOSE )
end
NEW_FORM_WORLDMAP.C50316_OnClick = function( m )
m:luaChange()
end
NEW_FORM_WORLDMAP.C50317_OnClick = function( m )
local ret = Enter(m)
if ret == 0 then
	if m:NewInGame()==1 then
		DelWorldMap(m)
	else
		m:InputFinished()
	end
else
end
end
NEW_FORM_WORLDMAP.C50318_OnClick = function( m )
OnClick( m, UI1_COMPOSIT_WORLDMAP_NPC )
end
NEW_FORM_WORLDMAP.C50330_OnDraw = function( m )
m:DrawMap()
end
