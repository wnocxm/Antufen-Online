NEW_FORM_GAME_SET= { }
NEW_FORM_GAME_SET.Main = function( m )
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
	ReSetItemSate(m, UI1_COMPOSIT_GAMESET_BUTTON1, GameItem.GAMEET_ITEM_RED)
	ReSetItemSate(m, UI1_COMPOSIT_GAMESET_BUTTON2, GameItem.GAMEET_ITEM_WHITE)
	ReSetItemSate(m, UI1_COMPOSIT_GAMESET_BUTTON3, GameItem.GAMEET_ITEM_UNION)
	ReSetItemSate(m, UI1_COMPOSIT_GAMESET_BUTTON4, GameItem.GAMEET_ITEM_NORMAL)
	ReSetItemSate(m, UI1_COMPOSIT_GAMESET_BUTTON5, GameItem.GAMEET_ITEM_GOOD)
end

NEW_FORM_GAME_SET.C50122_OnClick = function( m )
SaveAll(m)
m:SaveSetting()
m:InputFinished()
m:Close()
DelGameSetting(m)
end
NEW_FORM_GAME_SET.C50125_OnLoad = function( m )
local strValue = m:GetPkValue()
DBGPRINTF(strValue )
local color = m:GetPkValueColor()
UI_Engine.SetText(m.formIndex, UI1_COMPOSIT_GAMESET_PK_VALUE ,strValue, 0 ,color) 
DBGPRINTF("SetText end")	
end
NEW_FORM_GAME_SET.C50133_OnLoad = function( m )
ReSetControlSate(m, UI1_COMPOSIT_GAMESET_BUTTON1, GameItem.GAMEET_ITEM_RED)
end
NEW_FORM_GAME_SET.C50134_OnLoad = function( m )
ReSetControlSate(m, UI1_COMPOSIT_GAMESET_BUTTON2, GameItem.GAMEET_ITEM_WHITE)
end
NEW_FORM_GAME_SET.C50135_OnLoad = function( m )
ReSetControlSate(m, UI1_COMPOSIT_GAMESET_BUTTON3, GameItem.GAMEET_ITEM_UNION)
end
NEW_FORM_GAME_SET.C50136_OnLoad = function( m )
ReSetControlSate(m, UI1_COMPOSIT_GAMESET_BUTTON4, GameItem.GAMEET_ITEM_NORMAL)
end
NEW_FORM_GAME_SET.C50137_OnLoad = function( m )
ReSetControlSate(m, UI1_COMPOSIT_GAMESET_BUTTON5, GameItem.GAMEET_ITEM_GOOD)
end
NEW_FORM_GAME_SET.C50105_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
