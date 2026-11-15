FORM_ARENA_REPORT= { }
FORM_ARENA_REPORT.Main = function( m )
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
FORM_ARENA_REPORT.C52566_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52566_OnUpdate = function( m )
local name=m:GetList(m.offset)
UI_Engine.SetText(m.formIndex,COMPOSIT_2566,name,0)

end
FORM_ARENA_REPORT.C52567_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52567_OnUpdate = function( m )
local name=m:GetList(m.offset+1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2567,name,0)
end
FORM_ARENA_REPORT.C52568_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52568_OnUpdate = function( m )
local name=m:GetList(m.offset+2)
UI_Engine.SetText(m.formIndex,COMPOSIT_2568,name,0)
end
FORM_ARENA_REPORT.C52569_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52569_OnUpdate = function( m )
local name=m:GetList(m.offset+3)
UI_Engine.SetText(m.formIndex,COMPOSIT_2569,name,0)
end
FORM_ARENA_REPORT.C52570_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52570_OnUpdate = function( m )
local name=m:GetList(m.offset+4)
UI_Engine.SetText(m.formIndex,COMPOSIT_2570,name,0)
end
FORM_ARENA_REPORT.C52571_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52571_OnUpdate = function( m )
local name=m:GetList(m.offset+5)
UI_Engine.SetText(m.formIndex,COMPOSIT_2571,name,0)
end
FORM_ARENA_REPORT.C52797_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52797_OnUpdate = function( m )
local name=m:GetList(m.offset+6)
UI_Engine.SetText(m.formIndex,COMPOSIT_2797,name,0)
end
FORM_ARENA_REPORT.C52796_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52796_OnUpdate = function( m )
local name=m:GetList(m.offset+7)
UI_Engine.SetText(m.formIndex,COMPOSIT_2796,name,0)
end
FORM_ARENA_REPORT.C52801_OnClick = function( m )
m:GetTab(0)
UI_Engine.SetFormTab(m.formIndex, 0)
end
FORM_ARENA_REPORT.C52802_OnClick = function( m )
m:GetTab(1)
UI_Engine.SetFormTab(m.formIndex, 1)
end
FORM_ARENA_REPORT.C52510_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52510_OnUpdate = function( m )
local name,score=m:GetList(m.offset)
UI_Engine.SetText(m.formIndex,COMPOSIT_2510,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2510,score,1)
end
FORM_ARENA_REPORT.C52511_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52511_OnUpdate = function( m )
local name,score=m:GetList(m.offset+1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2511,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2511,score,1)
end
FORM_ARENA_REPORT.C52512_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52512_OnUpdate = function( m )
local name,score=m:GetList(m.offset+2)
UI_Engine.SetText(m.formIndex,COMPOSIT_2512,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2512,score,1)
end
FORM_ARENA_REPORT.C52513_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52513_OnUpdate = function( m )
local name,score=m:GetList(m.offset+3)
UI_Engine.SetText(m.formIndex,COMPOSIT_2513,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2513,score,1)
end
FORM_ARENA_REPORT.C52514_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52514_OnUpdate = function( m )
local name,score=m:GetList(m.offset+4)
UI_Engine.SetText(m.formIndex,COMPOSIT_2514,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2514,score,1)
end
FORM_ARENA_REPORT.C52515_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52515_OnUpdate = function( m )
local name,score=m:GetList(m.offset+5)
UI_Engine.SetText(m.formIndex,COMPOSIT_2515,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2515,score,1)
end
FORM_ARENA_REPORT.C52516_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52516_OnUpdate = function( m )
local name,score=m:GetList(m.offset+6)
UI_Engine.SetText(m.formIndex,COMPOSIT_2516,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2516,score,1)
end
FORM_ARENA_REPORT.C52798_OnClick = function( m )
m:ClickList(m.userSelectItem)
end
FORM_ARENA_REPORT.C52798_OnUpdate = function( m )
local name,score=m:GetList(m.offset+7)
UI_Engine.SetText(m.formIndex,COMPOSIT_2798,name,0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2798,score,1)
end
FORM_ARENA_REPORT.C52508_OnClick = function( m )
local name, ptr =m:Detail()
if name ==nil then
else
m.info = NewInfoText(m, name, ptr)
end
end
FORM_ARENA_REPORT.C52517_OnDraw = function( m )
local strTime = m:GetTime()

if strTime then
	UI_Engine.SetText(m.formIndex, COMPOSIT_2517 ,strTime )
end

end
