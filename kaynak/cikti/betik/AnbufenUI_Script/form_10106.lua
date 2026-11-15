FORM_MIANZE= { }
FORM_MIANZE.Main = function( m )
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
FORM_MIANZE.C52981_OnUpdate = function( m )
	local text = m:GetListText(m.offset )
	if text== nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_2981,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_2981,text )
	end
end
FORM_MIANZE.C52980_OnUpdate = function( m )
	local text = m:GetListText(m.offset +1)
	if text== nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_2980,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_2980,text )
	end
end
FORM_MIANZE.C52979_OnUpdate = function( m )
	local text = m:GetListText(m.offset +2)
	if text== nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_2979,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_2979,text )
	end
end
FORM_MIANZE.C52978_OnUpdate = function( m )
	local text = m:GetListText(m.offset +3)
	if text== nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_2978,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_2978,text )
	end
end
FORM_MIANZE.C52977_OnUpdate = function( m )
	local text = m:GetListText(m.offset +4)
	if text== nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_2977,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_2977,text )
	end
end
FORM_MIANZE.C52976_OnUpdate = function( m )
	local text = m:GetListText(m.offset +5)
	if text== nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_2976,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_2976,text )
	end
end
FORM_MIANZE.C52975_OnUpdate = function( m )
	local text = m:GetListText(m.offset +6)
	if text== nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_2975,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_2975,text )
	end
end
FORM_MIANZE.C52974_OnUpdate = function( m )
	local text = m:GetListText(m.offset +7)
	if text== nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_2974,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_2974,text )
	end
end
FORM_MIANZE.C52973_OnUpdate = function( m )
	local text = m:GetListText(m.offset +8)
	if text== nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_2973,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_2973,text )
	end
end
FORM_MIANZE.C52985_OnUpdate = function( m )
	local text = m:GetListText(m.offset + 9)
	if text== nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_2981,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_2985s,text )
	end
end
FORM_MIANZE.C52972_OnClick = function( m )
m:ClickOK(UI_Engine.GetState(formIndex,COMPOSIT_RADIO))
end
