FORM_GAME_SET= { }
FORM_GAME_SET.Main = function( m )
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
local ReSetItemSate = function(m, composit , itemtype)     --根据控件状态设置系统选项        
		local nValue = UI_Engine.GetState(m.formIndex,composit )
		m:SetItemState(itemtype , nValue)
end

local ReSetControlSate = function(m,composit , itemtype)  --根据系统选项设置控件状态
		local nValue = m:GetItemState(itemtype)
		UI_Engine.SetState(m.formIndex, composit, nValue)
end

local SaveAll = function(m)            --保存全部根据控件状态设置全部系统选项
	ReSetItemSate(m, COMPOSIT_1360, GameItem.GAMEET_ITEM_RED)
	ReSetItemSate(m, COMPOSIT_1361, GameItem.GAMEET_ITEM_WHITE)
	ReSetItemSate(m, COMPOSIT_1362, GameItem.GAMEET_ITEM_UNION)
	ReSetItemSate(m, COMPOSIT_1363, GameItem.GAMEET_ITEM_NORMAL)
	ReSetItemSate(m, COMPOSIT_1364, GameItem.GAMEET_ITEM_GOOD)
end

local WarnUser = function(m, str)             --单项对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_OK)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end
FORM_GAME_SET.C52747_OnClick = function( m )
DBGPRINTF("exit")
m:InputFinished()
m:Close()
DelGameSetting(m)
end
FORM_GAME_SET.C51368_OnLoad = function( m )
local strValue = m:GetPkValue()
DBGPRINTF(strValue )
UI_Engine.SetText(m.formIndex, COMPOSIT_1368 ,strValue ) 
DBGPRINTF("SetText end")	
end
FORM_GAME_SET.C51364_OnLoad = function( m )
ReSetControlSate(m, COMPOSIT_1364, GameItem.GAMEET_ITEM_GOOD)
end
FORM_GAME_SET.C51363_OnLoad = function( m )
ReSetControlSate(m, COMPOSIT_1363, GameItem.GAMEET_ITEM_NORMAL)
end
FORM_GAME_SET.C51362_OnLoad = function( m )
ReSetControlSate(m, COMPOSIT_1362, GameItem.GAMEET_ITEM_UNION)
end
FORM_GAME_SET.C51361_OnLoad = function( m )
ReSetControlSate(m, COMPOSIT_1361, GameItem.GAMEET_ITEM_WHITE)
end
FORM_GAME_SET.C51360_OnLoad = function( m )
ReSetControlSate(m, COMPOSIT_1360, GameItem.GAMEET_ITEM_RED)
end
FORM_GAME_SET.C51358_OnClick = function( m )
DBGPRINTF("exit")
m:InputFinished()
m:Close()
DelGameSetting(m)
end
FORM_GAME_SET.C51357_OnClick = function( m )
SaveAll(m)
m:SaveSetting()
WarnUser(m,"保存成功")
m:InputFinished()
m:Close()
DelGameSetting(m)

end
