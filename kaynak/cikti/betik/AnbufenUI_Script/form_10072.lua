FORM_CHEST= { }
FORM_CHEST.Main = function( m )
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
local UpDataDecribe = function(m)
	local Decribe = m:GetDecribe(m.userSelectItem)
	UI_Engine.SetText(m.formIndex,COMPOSIT_1920,Decribe)
end


local SetTabListText = function(m,nIndex,composit)

	local img,nSN,name,num = m:GetListText(m.offset + nIndex)

	if img == nil then
		UI_Engine.SetSurfaceImg( m.formIndex, composit, nil , 0 )
	else
		UI_Engine.SetSurfaceImg( m.formIndex, composit, img , 0 , 0,false,nSN)
	end
	
	if name == nil then
		UI_Engine.SetText(m.formIndex,composit,"",1)
	else
		UI_Engine.SetText(m.formIndex,composit,name,1)
	end
	
	if num == nil then
		UI_Engine.SetText(m.formIndex,composit,"",2)
	else
		UI_Engine.SetText(m.formIndex,composit,num,2)
	end

end

local UpDate = function(m)
	local title = m:GetTitle()
	if title == nil then
		UI_Engine.SetText(m.formIndex,COMPOSIT_1925,"")
	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_1925,title)
	end
	
	UI_Engine.UpdateList(m.formIndex ,COMPOSIT_1932)
	
	UpDataDecribe(m)
end
FORM_CHEST.C51934_OnLoad = function( m )
m.bDraw = false
DBGPRINTF("m.bDraw = false")
end
FORM_CHEST.C51934_OnDraw = function( m )
if m.bDraw  == false then
	if m:IsChestOpenEnd() then
		m.bDraw = true
	end
	DBGPRINTF("UpDate")
	UpDate(m) 
end
end
FORM_CHEST.C51924_OnClick = function( m )
m:NeedAll()
m:InputFinished()
m:Close()
end
FORM_CHEST.C51923_OnClick = function( m )
m:Need(m.userSelectItem)
UpDate(m) 
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1922, false)
end
FORM_CHEST.C51922_OnClick = function( m )
local name , vInfo = m:MakeInfo(m.userSelectItem)
if name ~= nil then
	m.info = NewInfo(m,name,vInfo )
	m.info:WaitUserInput(m)
	DelInfo(m.info)
end

end
FORM_CHEST.C52761_OnClick = function( m )
m:InputFinished()
m:Close()
end
FORM_CHEST.C51921_OnClick = function( m )
m:InputFinished()
m:Close()
end
FORM_CHEST.C51933_OnFocus = function( m )
UpDataDecribe(m)
end
FORM_CHEST.C51933_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1922, true)
end
FORM_CHEST.C51933_OnUpdate = function( m )
SetTabListText(m,0,COMPOSIT_1933)
end
FORM_CHEST.C51932_OnFocus = function( m )
UpDataDecribe(m)
end
FORM_CHEST.C51932_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1922, true)
end
FORM_CHEST.C51932_OnUpdate = function( m )
SetTabListText(m,1,COMPOSIT_1932)
end
FORM_CHEST.C51931_OnFocus = function( m )
UpDataDecribe(m)
end
FORM_CHEST.C51931_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1922, true)
end
FORM_CHEST.C51931_OnUpdate = function( m )
SetTabListText(m,2,COMPOSIT_1931)
end
FORM_CHEST.C51930_OnFocus = function( m )
UpDataDecribe(m)
end
FORM_CHEST.C51930_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1922, true)
end
FORM_CHEST.C51930_OnUpdate = function( m )
SetTabListText(m,3,COMPOSIT_1930)
end
FORM_CHEST.C51929_OnFocus = function( m )
UpDataDecribe(m)
end
FORM_CHEST.C51929_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1922, true)
end
FORM_CHEST.C51929_OnUpdate = function( m )
SetTabListText(m,4,COMPOSIT_1929)
end
FORM_CHEST.C51928_OnFocus = function( m )
UpDataDecribe(m)
end
FORM_CHEST.C51928_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1922, true)
end
FORM_CHEST.C51928_OnUpdate = function( m )
SetTabListText(m,5,COMPOSIT_1928)
end
FORM_CHEST.C51927_OnFocus = function( m )
UpDataDecribe(m)
end
FORM_CHEST.C51927_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1922, true)
end
FORM_CHEST.C51927_OnUpdate = function( m )
SetTabListText(m,6,COMPOSIT_1927)
end
FORM_CHEST.C51926_OnFocus = function( m )
UpDataDecribe(m)
end
FORM_CHEST.C51926_OnClick = function( m )
UI_Engine.SetVisible(m.formIndex, COMPOSIT_1922, true)
end
FORM_CHEST.C51926_OnUpdate = function( m )
SetTabListText(m,7,COMPOSIT_1926)
end
