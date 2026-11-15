FORM_ROLL= { }
FORM_ROLL.Main = function( m )
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
local WarnUser = function(m, str)             --单项对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_CANCEL)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local SetTabListText = function(m,nIndex,composit)
	local text , color= m:GetListText(m.offset + nIndex)
	if text== nil then
		DBGPRINTF("SetTabListText  text= null")
		UI_Engine.SetText(m.formIndex,composit,"")
	else
		UI_Engine.SetText(m.formIndex,composit,text , 0,color)
	end
end
FORM_ROLL.C51901_OnDraw = function( m )
local item = m:GetTime()
if item == nil then
return 
end
if item == -1  then
	WarnUser(m,"item exit")
	m:InputFinished()
	m:Close()
else
	UI_Engine.SetText(m.formIndex,COMPOSIT_1901,item )
end


end
FORM_ROLL.C51889_OnLoad = function( m )
local name = m:GetItemName()
if name == nil then
	UI_Engine.SetText(m.formIndex,COMPOSIT_1889,"" )
else
	UI_Engine.SetText(m.formIndex,COMPOSIT_1889,name )
end

end
FORM_ROLL.C51890_OnLoad = function( m )
local img , nSN = m:GetItemImg()

if img == nil then
	UI_Engine.SetSurfaceImg( m.formIndex, COMPOSIT_1890, nil )
else
	UI_Engine.SetSurfaceImg( m.formIndex, COMPOSIT_1890, img,0,0,false,nSN )
end
end
FORM_ROLL.C51890_OnClick = function( m )
local img = m:GetItemImg()

if img == nil then
	UI_Engine.SetSurfaceImg( m.formIndex, COMPOSIT_1890, nil )
else
	UI_Engine.SetSurfaceImg( m.formIndex, COMPOSIT_1890, img )
end
end
FORM_ROLL.C51890_OnUpdate = function( m )
local img = m:GetItemImg()

if img == nil then
	UI_Engine.SetSurfaceImg( m.formIndex, COMPOSIT_1890, nil )
else
	UI_Engine.SetSurfaceImg( m.formIndex, COMPOSIT_1890, img )
end
end
FORM_ROLL.C51887_OnClick = function( m )
if QueryUser(m,"fffffffffffff") then
m:Giveup()
m:InputFinished()
m:Close()
end


end
FORM_ROLL.C51886_OnClick = function( m )
m:Need()
m:InputFinished()
m:Close()
end
FORM_ROLL.C52759_OnClick = function( m )
m:InputFinished()
m:Close()
end
FORM_ROLL.C51888_OnClick = function( m )
m:InputFinished()
m:Close()
end
FORM_ROLL.C51899_OnUpdate = function( m )
SetTabListText(m,0,COMPOSIT_1899)
end
FORM_ROLL.C51898_OnUpdate = function( m )
SetTabListText(m,1,COMPOSIT_1898)
end
FORM_ROLL.C51897_OnUpdate = function( m )
SetTabListText(m,2,COMPOSIT_1897)
end
FORM_ROLL.C51896_OnUpdate = function( m )
SetTabListText(m,3,COMPOSIT_1896)
end
FORM_ROLL.C51895_OnUpdate = function( m )
SetTabListText(m,4,COMPOSIT_1895)
end
FORM_ROLL.C51894_OnUpdate = function( m )
SetTabListText(m,5,COMPOSIT_1894)
end
FORM_ROLL.C51893_OnUpdate = function( m )
SetTabListText(m,6,COMPOSIT_1893)
end
FORM_ROLL.C51892_OnUpdate = function( m )
SetTabListText(m,7,COMPOSIT_1892)
end
FORM_ROLL.C51891_OnUpdate = function( m )
SetTabListText(m,8,COMPOSIT_1891)

end
FORM_ROLL.C51885_OnLoad = function( m )
local decribe = m:GetDecribe()
if decribe == nil then
	UI_Engine.SetText(m.formIndex,COMPOSIT_1885,"" )
else
	UI_Engine.SetText(m.formIndex,COMPOSIT_1885,decribe )
end

end
