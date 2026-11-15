FORM_LEARN_LIVESKILL= { }
FORM_LEARN_LIVESKILL.Main = function( m )
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


local SetListText = function(m,nIndex,composit)
	local img,name,strEnd,color= m:GetListText(m.offset + nIndex)
	if color ~= 0 then
		UI_Engine.SetSurfaceImg( m.formIndex, composit, img ,0 )
		UI_Engine.SetText(m.formIndex,composit,name,1,color)
		UI_Engine.SetText(m.formIndex,composit,strEnd,2,color)
	else
		UI_Engine.SetSurfaceImg( m.formIndex, composit, img ,0 )
		UI_Engine.SetText(m.formIndex,composit,name,1)
		UI_Engine.SetText(m.formIndex,composit,strEnd,2)
	end
end


local UpDateLearn = function(m)
	if m:LiveStatus() then
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_2857,true)
    else
		UI_Engine.SetVisible(m.formIndex,COMPOSIT_2857,false)
	end
end

local ClickList = function(m)
	m:SetSel(m.userSelectItem)
	local strName = m:GetDescribe()
	UI_Engine.SetText(m.formIndex,COMPOSIT_2855,strName)
	UpDateLearn(m)
end


FORM_LEARN_LIVESKILL.C52858_OnClick = function( m )
local name, pinfo = m:LookUp(m.userSelectItem)
if name ~= nil and pinfo ~= nil  then
	m.info = NewInfo(m,name,pinfo)
	m.info:WaitUserInput(m)
	DelInfo(m.info)
end
end
FORM_LEARN_LIVESKILL.C52857_OnLoad = function( m )
--UpDateLearn(m)
end
FORM_LEARN_LIVESKILL.C52857_OnClick = function( m )
local name,ptemp = m:LookUp()
if QueryUser(m,"确定学习["..name.."]技能") == MsgBox.ECODE_YES then
	m:Liveskill()
end
end
FORM_LEARN_LIVESKILL.C52856_OnClick = function( m )
m:Close()
end
FORM_LEARN_LIVESKILL.C52867_OnClick = function( m )
ClickList(m)
end
FORM_LEARN_LIVESKILL.C52867_OnUpdate = function( m )
SetListText(m,0,COMPOSIT_2867)
end
FORM_LEARN_LIVESKILL.C52866_OnClick = function( m )
ClickList(m)
end
FORM_LEARN_LIVESKILL.C52866_OnUpdate = function( m )
SetListText(m,1,COMPOSIT_2866)
end
FORM_LEARN_LIVESKILL.C52865_OnClick = function( m )
ClickList(m)
end
FORM_LEARN_LIVESKILL.C52865_OnUpdate = function( m )
SetListText(m,2,COMPOSIT_2865)
end
FORM_LEARN_LIVESKILL.C52864_OnClick = function( m )
ClickList(m)
end
FORM_LEARN_LIVESKILL.C52864_OnUpdate = function( m )
SetListText(m,3,COMPOSIT_2864)
end
FORM_LEARN_LIVESKILL.C52863_OnClick = function( m )
ClickList(m)
end
FORM_LEARN_LIVESKILL.C52863_OnUpdate = function( m )
SetListText(m,4,COMPOSIT_2863)
end
FORM_LEARN_LIVESKILL.C52862_OnClick = function( m )
ClickList(m)
end
FORM_LEARN_LIVESKILL.C52862_OnUpdate = function( m )
SetListText(m,5,COMPOSIT_2862)
end
FORM_LEARN_LIVESKILL.C52861_OnClick = function( m )
ClickList(m)
end
FORM_LEARN_LIVESKILL.C52861_OnUpdate = function( m )
SetListText(m,6,COMPOSIT_2861)
end
FORM_LEARN_LIVESKILL.C52860_OnClick = function( m )
ClickList(m)
end
FORM_LEARN_LIVESKILL.C52860_OnUpdate = function( m )
SetListText(m,7,COMPOSIT_2860)
end
