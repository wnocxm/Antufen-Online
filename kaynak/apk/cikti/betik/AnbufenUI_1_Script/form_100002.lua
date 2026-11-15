NEW_FORM_CHEST= { }
NEW_FORM_CHEST.Main = function( m )
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
--[
	if name ~= nil then
		UI_Engine.SetVisible(m.formIndex,composit,true)
		UI_Engine.SetSurfaceImg( m.formIndex, composit, img , 0 , 0,false,nSN)
		UI_Engine.SetText(m.formIndex,composit,name,1)
		UI_Engine.SetText(m.formIndex,composit,num,2)
	else
		UI_Engine.SetVisible(m.formIndex,composit,false)
	end
--]
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
	UI_Engine.UpdateList(m.formIndex ,UI1_COMPOSIT_ITEM_0)
	--for i = 0, 6 do
		--local id = UI1_COMPOSIT_ITEM_0 + i
		--SetTabListText( m, i, id)
	--end
end

local ClearState = function(m)
	for i = 0, 6 do
		local id = UI1_COMPOSIT_ITEM_0 + i
		UI_Engine.SetState(m.formIndex,id,0)
	end
end

local OnSelectItem = function(m)
	local img,str,pinfo,sn = m:GetDescribe(m.userSelectItem)
	m.info = NewItemInfo(m,img,str,pinfo,sn)
	m.info:WaitUserInput(m)
	local exit = m.info:GetResult()
	DelItemInfo(m.info)
	if exit ~= 0 then
		m:Need(m.userSelectItem)
		UpDate(m)
		ClearState(m)
	end
end
NEW_FORM_CHEST.C50073_OnClick = function( m )
m:InputFinished()
m:Close()
end
NEW_FORM_CHEST.C50057_OnClick = function( m )
m:NeedAll()
m:InputFinished()
m:Close()
end
NEW_FORM_CHEST.C50065_OnClick = function( m )
OnSelectItem(m)
end
NEW_FORM_CHEST.C50065_OnUpdate = function( m )
SetTabListText(m,0,UI1_COMPOSIT_ITEM_0)
end
NEW_FORM_CHEST.C50066_OnClick = function( m )
OnSelectItem(m)
end
NEW_FORM_CHEST.C50066_OnUpdate = function( m )
SetTabListText(m,1,UI1_COMPOSIT_ITEM_1)
end
NEW_FORM_CHEST.C50067_OnClick = function( m )
OnSelectItem(m)
end
NEW_FORM_CHEST.C50067_OnUpdate = function( m )
SetTabListText(m,2,UI1_COMPOSIT_ITEM_2)
end
NEW_FORM_CHEST.C50068_OnClick = function( m )
OnSelectItem(m)
end
NEW_FORM_CHEST.C50068_OnUpdate = function( m )
SetTabListText(m,3,UI1_COMPOSIT_ITEM_3)
end
NEW_FORM_CHEST.C50069_OnClick = function( m )
OnSelectItem(m)
end
NEW_FORM_CHEST.C50069_OnUpdate = function( m )
SetTabListText(m,4,UI1_COMPOSIT_ITEM_4)
end
NEW_FORM_CHEST.C50070_OnClick = function( m )
OnSelectItem(m)
end
NEW_FORM_CHEST.C50070_OnUpdate = function( m )
SetTabListText(m,5,UI1_COMPOSIT_ITEM_5)
end
NEW_FORM_CHEST.C50071_OnClick = function( m )
OnSelectItem(m)
end
NEW_FORM_CHEST.C50071_OnUpdate = function( m )
SetTabListText(m,6,UI1_COMPOSIT_ITEM_6)
end
