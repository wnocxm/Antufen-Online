FORM_PETAI= { }
FORM_PETAI.Main = function( m )
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
FORM_PETAI.C52795_OnLoad = function( m )
m.sel = 0
end
FORM_PETAI.C52795_OnClick = function( m )

m:InputFinished()
end
local SetForm = function(m, nIndex)
	local name, des = m:GetAIInfo()
	UI_Engine.SetText(m.formIndex,COMPOSIT_2474 , name)
	UI_Engine.SetText(m.formIndex,COMPOSIT_2473 , des)
end

local ClickArrow = function(m, mode)
	m:OnClickArrow(mode)
	local ret = m:GetResult()
	SetForm(m, ret)
end
FORM_PETAI.C52794_OnClick = function( m )
m:SetResult()
m:InputFinished()
end
FORM_PETAI.C52472_OnClick = function( m )
ClickArrow(m, true)
end
FORM_PETAI.C52471_OnClick = function( m )
ClickArrow(m, false)

end
FORM_PETAI.C52790_OnLoad = function( m )
SetForm(m, 0)
end
