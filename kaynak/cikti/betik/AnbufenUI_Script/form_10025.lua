FORM_ROLEPROP= { }
FORM_ROLEPROP.Main = function( m )
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
FORM_ROLEPROP.C50417_OnLoad = function( m )
m.modify = false
m.age = ""
m.country = ""
m.tel = ""
m.mail = ""
m.sigh = ""
m.lookMode = 0
m.draw = false
m.input = false
end
function GetPlayerInfo(m)
local name = m:GetNickName()
local race = m:GetRace()
local level = m:GetLevel()
local job    = m:GetJob()
local perExp = m:GetExp()
local curTitle = m:GetCurTitle()
local union = m:GetUnion()
local hp = m:GetHP()
local mp = m:GetMP()
local physAttack = m:GetPhysAttack()
local magicAttack = m:GetMagicAttack()
local defence = m:GetDefence();
local target = m:GetTarget()
local jookPer = m:GetJookPer()
local fatal = m:GetFatal()
local luck = m:GetLuck()
local holy = m:GetHoly()
local dark = m:GetDark()
local fire = m:GetFire()
local water = m:GetWater()

local RenXing = m:GetRenXing()
UI_Engine.SetText(m.formIndex,COMPOSIT_2576,RenXing)


UI_Engine.SetText(m.formIndex,COMPOSIT_2396,name)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_RACERECT,race)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_WORKRECT,job)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_LEVELRECT,level)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_EXPERIENCERECT,perExp)
UI_Engine.SetRollText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_DESIGNATIONRECT,curTitle)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_PARTYRECT,union)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_FORCERECT,hp)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_SUPPOWERRECT,mp)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_PHYSICSRECT,physAttack)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_MAGICRECT,magicAttack)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_RECOVERYRECT,defence)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_TARGETRECT,target)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_HIDERECT,jookPer)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_ATTACKRECT,fatal)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_REDUCERECT,luck)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_SHENGRECT,holy)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_ANRECT,dark)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_ICERECT,water)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB0_FIRERECT,fire)
end

local DrawEquip = function(m)
	local img, nSN = m:DrawEquipImage(0)
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2281, img, 0, 0, false, nSN)

	img, nSN = m:DrawEquipImage(1)
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2282, img, 0, 0, false, nSN)

	img, nSN = m:DrawEquipImage(2)
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2283, img, 0, 0, false, nSN)

	img, nSN = m:DrawEquipImage(3)
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2284, img, 0, 0, false, nSN)

	img, nSN = m:DrawEquipImage(4)
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2285, img, 0, 0, false, nSN)

	img, nSN = m:DrawEquipImage(5)
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2286, img, 0, 0, false, nSN)

	img, nSN = m:DrawEquipImage(6)
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2287, img, 0, 0, false, nSN)

	img, nSN = m:DrawEquipImage(7)
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_2288, img, 0, 0, false, nSN)
end

local GetCurImgID = function(m) 
	if m.human == 1 and m.male == 1 then
		return 0
	elseif m.human == 1 and m.male == 0 then
		return 1
	elseif m.human == 0 and m.male == 1 then
		return 2
	elseif m.human == 0 and m.male == 0 then
		return 3
	end
end

local DrawHeadImg = function(m, index)
	local ptr = m:GetHeadImg(index)
	UI_Engine.SetSurfaceImg(m.formIndex, COMPOSIT_ROLEPROP_TAB3_HEADRECT, ptr)
end
	
local SetCtlMode = function(m, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2134, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2135, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2136, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2137, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2747, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2748, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2749, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2750, mode)
	if m.modify == true then
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2048, true)
	else
		UI_Engine.SetVisible(m.formIndex, COMPOSIT_2048, false)
	end
end

local GetInput = function(m, ctlID)		-- 创建输入框
	local text = UI_Engine.GetText(m.formIndex, ctlID, 0)
	m.InputBox = OpenInputBox(m,text,70)
	m.InputBox :WaitUserInput(m)
	local result = m.InputBox :GetResult()
	UI_Engine.SetText(m.formIndex,ctlID,result,0)
	return result
end

local SetListText = function(m,nIndex,composit)
	local name,strTime= m:GetListText(m.offset + nIndex)

	UI_Engine.SetText(m.formIndex,composit,name,0)
	UI_Engine.SetText(m.formIndex,composit,strTime,1)
end
FORM_ROLEPROP.C52278_OnLoad = function( m )
m.mode = true
end
local SetInput = function(m, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2747, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2748, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2749, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2750, mode)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2048, mode)
end

FORM_ROLEPROP.C52998_OnLoad = function( m )
local strName = m:GetPointNum()
UI_Engine.SetText(m.formIndex,COMPOSIT_POINT,strName )
end
FORM_ROLEPROP.C52988_OnClick = function( m )
m:Look(0,m.userSelectItem)
end
FORM_ROLEPROP.C52987_OnClick = function( m )
local name, pinfo = m:GetInfo()
if name ~= nil and pinfo ~= nil  then
	m.info = NewInfo(m,name,pinfo)
	m.info:WaitUserInput(m)
	DelInfo(m.info)
end
end
FORM_ROLEPROP.C52996_OnClick = function( m )
m:SetSuccessSel(m.userSelectItem)
end
FORM_ROLEPROP.C52996_OnUpdate = function( m )
SetListText(m,0,COMPOSIT_2996)
end
FORM_ROLEPROP.C52995_OnClick = function( m )
m:SetSuccessSel(m.userSelectItem)
end
FORM_ROLEPROP.C52995_OnUpdate = function( m )
SetListText(m,1,COMPOSIT_2995)
end
FORM_ROLEPROP.C52994_OnClick = function( m )
m:SetSuccessSel(m.userSelectItem)
end
FORM_ROLEPROP.C52994_OnUpdate = function( m )
SetListText(m,2,COMPOSIT_2994)
end
FORM_ROLEPROP.C52993_OnClick = function( m )
m:SetSuccessSel(m.userSelectItem)
end
FORM_ROLEPROP.C52993_OnUpdate = function( m )
SetListText(m,3,COMPOSIT_2993)
end
FORM_ROLEPROP.C52992_OnClick = function( m )
m:SetSuccessSel(m.userSelectItem)
end
FORM_ROLEPROP.C52992_OnUpdate = function( m )
SetListText(m,4,COMPOSIT_2992)
end
FORM_ROLEPROP.C52991_OnClick = function( m )
m:SetSuccessSel(m.userSelectItem)
end
FORM_ROLEPROP.C52991_OnUpdate = function( m )
SetListText(m,5,COMPOSIT_2991)
end
FORM_ROLEPROP.C52990_OnClick = function( m )
m:SetSuccessSel(m.userSelectItem)
end
FORM_ROLEPROP.C52990_OnUpdate = function( m )
SetListText(m,6,COMPOSIT_2990)
end
FORM_ROLEPROP.C52989_OnClick = function( m )
m:SetSuccessSel(m.userSelectItem)
end
FORM_ROLEPROP.C52989_OnUpdate = function( m )
SetListText(m,7,COMPOSIT_2989)
end
FORM_ROLEPROP.C52986_OnClick = function( m )
m:Look(1,m.userSelectItem)
end
FORM_ROLEPROP.C50404_OnClick = function( m )
if true == m.modify then
	local temp = UI_Engine.GetText(m.formIndex, COMPOSIT_ROLEPROP_TAB_AGE)
	m.age = GetInput(m, COMPOSIT_ROLEPROP_TAB_AGE)
	if false == Tools.IsNumberOnly(m.age) then
		WarnUser(m, "仅接受数字输入!")
		m.age = temp
		UI_Engine.SetText(m.formIndex, COMPOSIT_ROLEPROP_TAB_AGE, m.age)
	end
end
	
end
FORM_ROLEPROP.C52695_OnClick = function( m )
DelPlayerInfo(m)
end
FORM_ROLEPROP.C50381_OnClick = function( m )
DelPlayerInfo(m)
end
FORM_ROLEPROP.C50402_OnClick = function( m )
if true == m.modify then
	m.sigh = GetInput(m, COMPOSIT_ROLEPROP_TAB3_WRITERECT)
end
end
FORM_ROLEPROP.C50401_OnClick = function( m )
if true == m.modify then
	m.mail = GetInput(m, COMPOSIT_ROLEPROP_TAB3_MAILRECT)
end
end
FORM_ROLEPROP.C50400_OnClick = function( m )
if true == m.modify then
	local temp = UI_Engine.GetText(m.formIndex, COMPOSIT_ROLEPROP_TAB3_TELRECT)
	m.tel = GetInput(m, COMPOSIT_ROLEPROP_TAB3_TELRECT)
	if false == Tools.IsNumberOnly(m.tel) then
		WarnUser(m, "仅接受数字输入!")
		m.tel = temp
		UI_Engine.SetText(m.formIndex, COMPOSIT_ROLEPROP_TAB3_TELRECT, m.tel)
	end
end
end
FORM_ROLEPROP.C52288_OnClick = function( m )
local position,equip,descript = m:OnClickEquip(7)
UI_Engine.SetText(m.formIndex,COMPOSIT_2288,position)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_STATUS_RECT,equip)
UI_Engine.SetText(m.formIndex,COMPOSIT_813,descript, 0)

end
FORM_ROLEPROP.C52287_OnClick = function( m )
local position,equip,descript = m:OnClickEquip(6)
UI_Engine.SetText(m.formIndex,COMPOSIT_2287,position)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_STATUS_RECT,equip)
UI_Engine.SetText(m.formIndex,COMPOSIT_813,descript, 0)

end
FORM_ROLEPROP.C52286_OnClick = function( m )
local position,equip,descript = m:OnClickEquip(5)
UI_Engine.SetText(m.formIndex,COMPOSIT_2286,position)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_STATUS_RECT,equip)
UI_Engine.SetText(m.formIndex,COMPOSIT_813,descript, 0)
end
FORM_ROLEPROP.C52285_OnClick = function( m )
local position,equip,descript = m:OnClickEquip(4)
UI_Engine.SetText(m.formIndex,COMPOSIT_2285,position)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_STATUS_RECT,equip)
UI_Engine.SetText(m.formIndex,COMPOSIT_813,descript, 0)
end
FORM_ROLEPROP.C52284_OnClick = function( m )
local position,equip,descript = m:OnClickEquip(3)
UI_Engine.SetText(m.formIndex,COMPOSIT_2284,position)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_STATUS_RECT,equip)
UI_Engine.SetText(m.formIndex,COMPOSIT_813,descript, 0)

end
FORM_ROLEPROP.C52283_OnClick = function( m )
local position,equip,descript = m:OnClickEquip(2)
UI_Engine.SetText(m.formIndex,COMPOSIT_2283,position)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_STATUS_RECT,equip)
UI_Engine.SetText(m.formIndex,COMPOSIT_813,descript, 0)

end
FORM_ROLEPROP.C52282_OnClick = function( m )
local position,equip,descript = m:OnClickEquip(1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2282,position)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_STATUS_RECT,equip)
UI_Engine.SetText(m.formIndex,COMPOSIT_813,descript, 0)

end
FORM_ROLEPROP.C52281_OnClick = function( m )
local position,equip,descript = m:OnClickEquip(0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2281,position)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_STATUS_RECT,equip)
UI_Engine.SetText(m.formIndex,COMPOSIT_813,descript, 0)
end
FORM_ROLEPROP.C50386_OnLoad = function( m )
if false == m:GetCurType() then
	GetPlayerInfo(m)
end


end
FORM_ROLEPROP.C50386_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 0)
SetCtlMode(m, m.modify)
m.draw = false
if false == m.mode then
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2041, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2043, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2044, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2046, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2047, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2048, false)
end



end
FORM_ROLEPROP.C50387_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 1)
SetCtlMode(m, m.modify)
m.draw = false
if false == m.mode then
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2041, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2043, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2044, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2046, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2047, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2048, false)
end

end
FORM_ROLEPROP.C50388_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 2)
SetCtlMode(m, m.modify)
m.draw = true
end
FORM_ROLEPROP.C50389_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 3)

if m.mode == true then
local name,age,sex,location,phone,Email,label,mode,img = m:OnClickTab(3)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB3_NAMERECT,name)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB_AGE,age)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB_SEXRECT,sex)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB3_CITYRECT,location)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB3_TELRECT,phone)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB3_MAILRECT,Email)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB3_WRITERECT,label)
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLEPROP_TAB3_MODERECT,mode)
UI_Engine.SetSurfaceImg(m.formIndex,COMPOSIT_ROLEPROP_TAB3_HEADRECT,img)
end

SetCtlMode(m, m.modify)
m.draw = false
if false == m.mode then
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2041, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2043, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2044, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2046, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2047, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2048, false)
end

end
FORM_ROLEPROP.C52985_OnClick = function( m )
UI_Engine.SetFormTab(m.formIndex, 4)
m:SendAchievementList()
end
FORM_ROLEPROP.C52044_OnClick = function( m )
local curSel = m:ChangeEquip()
if nil ~= curSel then
	m.equipPack = NewPackage(m, 1, 1, curSel, -1)
	m.equipPack:SetEquipMode(true)
	m.equipPack:WaitUserInput(m)
	DelPackage(m.equipPack)
end

end
FORM_ROLEPROP.C52043_OnClick = function( m )
m:TakeOff_L()
end
FORM_ROLEPROP.C52048_OnClick = function( m )
m.modify = false
SetCtlMode(m, false)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2048, false)
m:OnModify(m.age, m.tel, m.mail, m.sign)
end
FORM_ROLEPROP.C52047_OnClick = function( m )
m.modify = true
SetCtlMode(m, true)
SetInput(m, true)
end
FORM_ROLEPROP.C52046_OnClick = function( m )
local imgID = GetCurImgID(m)
DBGPRINTF("lua_info:HeadImgBox Clicked")
m.headImg = NewHeadImg(m, imgID)
if m.human == 1 and m.male == 1 then
	m.headImg.ret = m.headImg:LoadHeadImg(m, 0)
elseif m.human == 1 and m.male == 0 then
	m.headImg.ret = m.headImg:LoadHeadImg(m, 1)
elseif m.human == 0 and m.male == 1 then
	m.headImg.ret = m.headImg:LoadHeadImg(m, 2)
else
	m.headImg.ret = m.headImg:LoadHeadImg(m, 3)
end
m.headImg:WaitUserInput(m)
m.subImg = m.headImg:GetResult()
DelHeadImg(m.headImg)
DrawHeadImg(m, m.subImg)
UI_Engine.SetVisible(m.formIndex, COMPOSIT_2048, true)
end
FORM_ROLEPROP.C52042_OnClick = function( m )
local name, ptr = m:GetInfoPtr()
m.info = NewInfo(m, name, ptr)
end
FORM_ROLEPROP.C52134_OnClick = function( m )
m:OnModeArrow(false)
end
FORM_ROLEPROP.C52137_OnClick = function( m )
m:OnLocationArrow(false)
end
FORM_ROLEPROP.C52136_OnClick = function( m )
m:OnLocationArrow(true)
end
FORM_ROLEPROP.C52135_OnClick = function( m )
m:OnModeArrow(true)
end
FORM_ROLEPROP.C52041_OnClick = function( m )
local ptr = m:GetPointer()
NewTitle(m, ptr)
end
FORM_ROLEPROP.C50812_OnLoad = function( m )
m.male, m.human = m:GetHeadInfo(m)
SetCtlMode(m, false)
SetInput(m, false)
m.mode = m:GetOpenMode()
--DrawEquip(m)
if false == m.mode then
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2041, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2043, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2044, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2046, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2047, false)
	UI_Engine.SetVisible(m.formIndex, COMPOSIT_2048, false)
end
end
FORM_ROLEPROP.C50812_OnDraw = function( m )
if m:GetCurType() == false then
	if true == m.mode then
		DrawEquip(m)
	end
end

if true == m.draw then
	m:DrawOther()
end
end
