FORM_PETINFO= { }
FORM_PETINFO.Main = function( m )
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
FORM_PETINFO.C52712_OnLoad = function( m )
m.tab = 0
end
FORM_PETINFO.C52712_OnClick = function( m )
m:DelPetForm()
end
local QueryUser = function(m, str)            --是否对话框
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_YESNO)
	m.MsgBox:WaitUserInput(m)
	local result = m.MsgBox:GetResult()
	DelMsgBox(m.MsgBox)
	return result
end

local GetInput = function(m, ctlID)		-- 创建输入框
	local text = UI_Engine.GetText(m.formIndex, ctlID, 0)
	m.InputBox = OpenInputBox(m,text,16)
	m.InputBox :WaitUserInput(m)
	local result = m.InputBox :GetResult()
	return result
end

local GetCommonInfo = function(m)	-- 一般信息
	local Name = m:GetPetName()
	local Sex = m:GetPetSex()
	local Type = m:GetPetType()
	local Character = m:GetPetCharacter()
	local State = m:GetPetState()
	
	local hpGift, mpGift, phyAttack, magicAttack, defence, defence2, shoot, jook = m:GetGiftString()
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_FORCERECT,hpGift)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_POWERRECT,mpGift)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_PHYSICSRECT,phyAttack)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_RECOVERYRECT,defence)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TARGETRECT,shoot)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_MAGICRECT,magicAttack)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_FASTRECT,defence2)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_HIDERECT,jook)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_NAMERECT,Name)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_SEXRECT,Sex)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_DOMESTICRECT, State)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_CHARACTERRECT, Character)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_KINDRECT, Type)
end

local GetInfo = function(m)		-- 宠物信息
	local Name = m:GetPetName()
	local Type = m:GetPetType()
	local Level = m:GetPetLevel()
	local State = m:GetPetState()
	local Fantasize = m:GetPetFantasizeLv()
	local Exp = m:GetPetExp()
	local Full = m:GetPetFull()
	local Age = m:GetPetAge()
	local HP = m:GetPetHP()
	local MP = m:GetPetMP()
	local PhysAttack = m:GetPetPhysAttack()
	local MagicAttack = m:GetPetMagicAttack()
	local Defence = m:GetPetDefence()
	local ShootPer = m:GetPetShootPer()
	local JookPer = m:GetPetJookPer()
	local Fatal = m:GetPetFatal()
	local Luck = m:GetPetLuck()
	-- 战术
	local petAI = m:GetPetAI()
	local Holy = m:GetPetHoly()
	local Dark = m:GetPetDark()
	local Fire = m:GetPetFire()
	local Water = m:GetPetWater()

	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_NAMERECT,Name)
	--UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_NAMERECT,Name)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_LEVELRECT, Level)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_STATUSRECT, State)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_MIRAGERECT, Fantasize)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_EXPRECT, Exp)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_EATRECT, Full)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_LIFERECT, Age)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_FORCERECT, HP)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_SUPOWRECT, MP)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_PHYSICSRECT, PhysAttack)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_MAGICRECT, MagicAttack)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_RECOVERRECT, Defence)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_TARGETRECT, ShootPer)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_HIDERECT, JookPer)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_ATTACKRECT, Fatal)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_REDUCERECT, Luck)
	--UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_LEVELRECT, Level)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_SHENGRECT, Holy)
	UI_Engine.SetText(m.formIndex, COMPOSIT_PETINFO_TAB1_ANRECT, Dark)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_FIRERECT, Fire)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_ICERECT, Water)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_TACTICSRECT, petAI)
	UI_Engine.SetText(m.formIndex,COMPOSIT_PETINFO_TAB1_KINDRECT, Type)
end

local SetSkill = function(m, index, ctlID)
	local img, text = m:GetSkillImg(m.offset+index)
	if img ~= nil then
		UI_Engine.SetSurfaceImg(m.formIndex, ctlID, img, 0)
		UI_Engine.SetText(m.formIndex, ctlID, text, 1)
	end
end

local SetDescribe = function(m)
	local text = m:GetSkillDescribe(m.userSelectItem)
	if nil == text then
		UI_Engine.SetText(m.formIndex, COMPOSIT_827, "", 0)
	else
		UI_Engine.SetText(m.formIndex, COMPOSIT_827, text, 0)
	end
end

local InitForm = function(m)
	local train = m:IsTrain()
	local callup = m:IsCallUp()
	local callback = m:IsCallBack()
	local drop = m:IsDrop()
	if false == train then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2464, true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2460, false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2461, false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2462, false)
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2464, false)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2460, true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2461, true)
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2462, true)
		if false == callup then
			if false == callback then
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2460, false)
			else
				UI_Engine.SetVisible(m.formIndex, COMPOSIT_2460, true)
				UI_Engine.SetText(m.formIndex, COMPOSIT_2460, "唤回")
			end
		else
			UI_Engine.SetVisible(m.formIndex, COMPOSIT_2460, true)
			UI_Engine.SetText(m.formIndex, COMPOSIT_2460, "召出")
		end
	end
	if false == drop then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2463, false)
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2463, true)
	end
	m:IsVis() --liao
end
FORM_PETINFO.C50601_OnLoad = function( m )
GetCommonInfo(m)
end
FORM_PETINFO.C50601_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 0)
GetCommonInfo(m)
InitForm(m)
UI_Engine.SetText(m.formIndex, COMPOSIT_827, "")
m.tab = 0
end
FORM_PETINFO.C50602_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 1)
GetInfo(m)
InitForm(m)
UI_Engine.SetText(m.formIndex, COMPOSIT_827, "")
m.tab = 1
end
FORM_PETINFO.C50603_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 2)
m:IsSelect(1)
InitForm(m)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_PETINFO_TAB2_LIST2)
UI_Engine.SetText(m.formIndex, COMPOSIT_827, "")
m.tab = 2
end
FORM_PETINFO.C50604_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 3)
m:IsSelect(2)
InitForm(m)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST2)
UI_Engine.SetText(m.formIndex, COMPOSIT_827, "")
m.tab = 3
end
FORM_PETINFO.C50698_OnClick = function( m )
SetDescribe(m)
end
FORM_PETINFO.C50698_OnUpdate = function( m )
SetSkill(m, 0, COMPOSIT_PETINFO_TAB2_LIST0)
end
FORM_PETINFO.C50699_OnClick = function( m )
SetDescribe(m)
end
FORM_PETINFO.C50699_OnUpdate = function( m )
SetSkill(m, 1, COMPOSIT_PETINFO_TAB2_LIST1)
end
FORM_PETINFO.C50700_OnClick = function( m )
SetDescribe(m)
end
FORM_PETINFO.C50700_OnUpdate = function( m )
SetSkill(m, 2, COMPOSIT_PETINFO_TAB2_LIST2)
InitForm(m)
end
FORM_PETINFO.C50701_OnClick = function( m )
SetDescribe(m)
end
FORM_PETINFO.C50701_OnUpdate = function( m )
SetSkill(m, 3, COMPOSIT_PETINFO_TAB2_LIST3)
end
FORM_PETINFO.C50702_OnClick = function( m )
SetDescribe(m)
end
FORM_PETINFO.C50702_OnUpdate = function( m )
SetSkill(m, 4, COMPOSIT_PETINFO_TAB2_LIST4)
end
FORM_PETINFO.C50828_OnClick = function( m )
SetDescribe(m)
end
FORM_PETINFO.C50828_OnUpdate = function( m )
SetSkill(m, 5, COMPOSIT_PETINFO_TAB2_LIST5)
end
FORM_PETINFO.C50829_OnClick = function( m )
SetDescribe(m)
end
FORM_PETINFO.C50829_OnUpdate = function( m )
SetSkill(m, 6, COMPOSIT_PETINFO_TAB2_LIST6)
end
FORM_PETINFO.C50830_OnClick = function( m )
SetDescribe(m)
end
FORM_PETINFO.C50830_OnUpdate = function( m )
SetSkill(m, 7, COMPOSIT_PETINFO_TAB2_LIST7)
end
FORM_PETINFO.C52464_OnClick = function( m )
m:Train()
InitForm(m)
end
FORM_PETINFO.C52463_OnClick = function( m )
local ret = QueryUser(m, "你真的要丢弃此魔法兽？")
if ret == MsgBox.ECODE_YES then
	m:DropPet()
	m:DelPetForm()
end
end
FORM_PETINFO.C52462_OnClick = function( m )
local temp = UI_Engine.GetText(m.formIndex, COMPOSIT_PETINFO_NAMERECT)
local newName = GetInput(m, COMPOSIT_PETINFO_TAB1_NAMERECT)
if Tools.JudgeSpecialWord(newName) then
	WarnUser(m, "输入不合法，请重新输入!")
	newName = temp
end
local ret = m:ChangePetName(newName)
if true == ret then
	UI_Engine.SetText(m.fomIndex, COMPOSIT_PETINFO_TAB1_NAMERECT, newName)
	UI_Engine.SetText(m.fomIndex, COMPOSIT_PETINFO_NAMERECT, newName)
end
end
FORM_PETINFO.C52461_OnClick = function( m )
m.ai = NewPetAI(m)
m.ai:WaitUserInput(m)
local sel, name = m.ai:GetResult()
DelPetAI(m.ai)

if -1 ~= sel then
	m:SetPetAI(sel)
	UI_Engine.SetText(m.formIndex, COMPOSIT_PETINFO_TAB1_TACTICSRECT, name)
end
end
FORM_PETINFO.C52460_OnClick = function( m )
m:luaCallPet()
InitForm(m)
end
FORM_PETINFO.C52459_OnClick = function( m )
m:FeedPet(m.userSelectItem)
UI_Engine.UpdateList(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST3)
end
FORM_PETINFO.C50706_OnClick = function( m )
m:ClickFood(m.offset)
end
FORM_PETINFO.C50706_OnUpdate = function( m )
local Img, Text = m:GetPetFood(m.offset)
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST0, Img, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST0, Text, 1)
end
FORM_PETINFO.C50707_OnClick = function( m )
m:ClickFood(m.offset+1)
end
FORM_PETINFO.C50707_OnUpdate = function( m )
local Img, Text = m:GetPetFood(m.offset + 1)
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST1, Img, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST1, Text, 1)
end
FORM_PETINFO.C50708_OnClick = function( m )
m:ClickFood(m.offset+2)
end
FORM_PETINFO.C50708_OnUpdate = function( m )
local Img, Text = m:GetPetFood(m.offset + 2)
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST2, Img, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST2, Text, 1)
end
FORM_PETINFO.C50709_OnClick = function( m )
m:ClickFood(m.offset+3)
end
FORM_PETINFO.C50709_OnUpdate = function( m )
local Img, Text = m:GetPetFood(m.offset + 3)
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST3, Img, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST3, Text, 1)
end
FORM_PETINFO.C50710_OnClick = function( m )
m:ClickFood(m.offset+4)
end
FORM_PETINFO.C50710_OnUpdate = function( m )
local Img, Text = m:GetPetFood(m.offset + 4)
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST4, Img, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST4, Text, 1)
end
FORM_PETINFO.C50711_OnClick = function( m )
m:ClickFood(m.offset+5)
end
FORM_PETINFO.C50711_OnUpdate = function( m )
local Img, Text = m:GetPetFood(m.offset + 5)
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST5, Img, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST5, Text, 1)
end
FORM_PETINFO.C50712_OnClick = function( m )
m:ClickFood(m.offset+6)
end
FORM_PETINFO.C50712_OnUpdate = function( m )
local Img, Text = m:GetPetFood(m.offset + 6)
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST6, Img, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST6, Text, 1)
end
FORM_PETINFO.C50713_OnClick = function( m )
m:ClickFood(m.offset)
end
FORM_PETINFO.C50713_OnUpdate = function( m )
local Img, Text = m:GetPetFood(m.offset + 7)
UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST7, Img, 0)
UI_Engine.SetText(m.formIndex, COMPOSIT_PETINFO_TAB3_LIST7, Text, 1)
end
FORM_PETINFO.C50825_OnLoad = function( m )
InitForm(m)

end
FORM_PETINFO.C50825_OnDraw = function( m )
if m.tab == 0 then
	m:DrawAni()
	InitForm(m)
end
end
