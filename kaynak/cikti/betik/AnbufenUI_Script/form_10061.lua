FORM_RANK= { }
FORM_RANK.Main = function( m )
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
FORM_RANK.C51676_OnLoad = function( m )
m:GetCurTab(0)
end
local SetList = function(m, offset, nID)
	local rank, name, val = m:GetSubInfo(m.offset+offset)
	UI_Engine.SetText(m.formIndex, nID, rank, 0)
	UI_Engine.SetText(m.formIndex, nID, name, 1)
	UI_Engine.SetText(m.formIndex, nID, val, 2)
end
FORM_RANK.C52791_OnClick = function( m )
m:InputFinished()
DelRankForm(m)
end
FORM_RANK.C51689_OnClick = function( m )
m:InputFinished()
DelRankForm(m)
end
FORM_RANK.C51688_OnClick = function( m )
m:OnClick(1, m.userSelectItem)
end
FORM_RANK.C51701_OnClick = function( m )
m:GetCurTab(1)
local title = m:BeginQuery(m.userSelectItem)
UI_Engine.SetText(m.formIndex, COMPOSIT_1690, title)
end
FORM_RANK.C51693_OnUpdate = function( m )
local title, text = m:GetMainInfo(m.offset+1)
UI_Engine.SetText(m.formIndex, COMPOSIT_1693, text) 
UI_Engine.SetText(m.formIndex, COMPOSIT_1690, title)
end
FORM_RANK.C51694_OnUpdate = function( m )
local title, text = m:GetMainInfo(m.offset+2)
UI_Engine.SetText(m.formIndex, COMPOSIT_1694, text)
end
FORM_RANK.C51695_OnUpdate = function( m )
local title, text = m:GetMainInfo(m.offset+3)
UI_Engine.SetText(m.formIndex, COMPOSIT_1695, text)
end
FORM_RANK.C51696_OnUpdate = function( m )
local title, text = m:GetMainInfo(m.offset+4)
UI_Engine.SetText(m.formIndex, COMPOSIT_1696,text)
end
FORM_RANK.C51697_OnUpdate = function( m )
local title, text = m:GetMainInfo(m.offset+5)
UI_Engine.SetText(m.formIndex, COMPOSIT_1697, text)
end
FORM_RANK.C51698_OnUpdate = function( m )
local title, text = m:GetMainInfo(m.offset+6)
UI_Engine.SetText(m.formIndex, COMPOSIT_1698, text)
end
FORM_RANK.C51699_OnUpdate = function( m )
local title, text = m:GetMainInfo(m.offset+7)
UI_Engine.SetText(m.formIndex, COMPOSIT_1699, text)
end
FORM_RANK.C51687_OnClick = function( m )
m:OnClick(0, m.userSelectItem)
end
FORM_RANK.C51678_OnUpdate = function( m )
SetList(m, 0, COMPOSIT_1678)
end
FORM_RANK.C51679_OnUpdate = function( m )
SetList(m, 1, COMPOSIT_1679)
end
FORM_RANK.C51680_OnUpdate = function( m )
SetList(m, 2, COMPOSIT_1680)
end
FORM_RANK.C51681_OnUpdate = function( m )
SetList(m, 3, COMPOSIT_1681)
end
FORM_RANK.C51682_OnUpdate = function( m )
SetList(m, 4, COMPOSIT_1682)
end
FORM_RANK.C51683_OnUpdate = function( m )
SetList(m, 5, COMPOSIT_1683)
end
FORM_RANK.C51684_OnUpdate = function( m )
SetList(m, 6, COMPOSIT_1684)
end
FORM_RANK.C51685_OnUpdate = function( m )
SetList(m, 7, COMPOSIT_1684)
end
