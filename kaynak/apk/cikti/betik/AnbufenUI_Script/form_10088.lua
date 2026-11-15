FORM_ROLE_CREATE_V5= { }
FORM_ROLE_CREATE_V5.Main = function( m )
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
FORM_ROLE_CREATE_V5.C52457_OnLoad = function( m )
m.name = ""
m.subImg = 0

 m.human=1 
m.warrior=1 
m.male =1
end
WarnUser = function(m, str)
	m.MsgBox = NewMsgBox(m, str, MsgBox.MODE_CANCEL)
	m.MsgBox:WaitUserInput(m)
	DelMsgBox(m.MsgBox)
end

function GetRoleInfo(m) -- 用于确定加载哪个角色图片
	if 1 == m.human and 1 == m.warrior and 1 == m.male  then
		DBGPRINTF("人男战")
		m.RoleImage = m.ImgHumanMaleWarrior
	elseif 1 == m.human and 1 == m.warrior and 0 == m.male  then
		DBGPRINTF("人女战")
		m.RoleImage = m.ImgHumanFemaleWarrior
	elseif 1 == m.human and 0 == m.warrior and 1 == m.male then
		DBGPRINTF("人男法")
		m.RoleImage = m.ImgHumanMaleMage
	elseif 1 == m.human and 0 == m.warrior and 0 == m.male then
		DBGPRINTF("人女法")
		m.RoleImage = m.ImgHumanFemaleMage
	elseif 1 == m.human and 2 == m.warrior and 1 == m.male then
		DBGPRINTF("人男牧师")
		m.RoleImage = m.ImgHumanMalePastor
	elseif 1 == m.human and 2 == m.warrior and 0 == m.male then
		DBGPRINTF("人女牧师")
		m.RoleImage = m.ImgHumanFemalePastor
	elseif  0 == m.human and 1 == m.warrior and 1 == m.male then
		DBGPRINTF("妖男战")
		m.RoleImage = m.ImgElfMaleWarrior
	elseif 0 == m.human and 1 == m.warrior and 0 == m.male then 
		DBGPRINTF("妖女战")
		m.RoleImage = m.ImgElfFemaleWarrior
	elseif 0 == m.human and 0 == m.warrior and 1 == m.male then 
		DBGPRINTF("妖男法")
		m.RoleImage = m.ImgElfMaleMage
	elseif 0 == m.human and 0 == m.warrior and 0 == m.male then 
		DBGPRINTF("妖女法")
		m.RoleImage = m.ImgElfFemaleMage
	elseif 0 == m.human and 2 == m.warrior and 1 == m.male then 
		DBGPRINTF("妖男牧师")
		m.RoleImage = m.ImgElfMalePastor
	elseif 0 == m.human and 2 == m.warrior and 0 == m.male then 
		DBGPRINTF("妖女牧师")
		m.RoleImage = m.ImgElfFemalePastor
	end
	return m.RoleImage
end

function GetTownImg(m) -- 用于确定城镇背景图片
	if 1 == m.human then
		m.BackImage = m.ImgAkadiya
	else 
		m.BackImage = m.ImgGuanlinzheng
	end
end

function DrawHeadImg(m, subPicIdx) --点确定后，画头像图片
	if m.human == 1 and m.male == 1 then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG_V5,"Portrait.godat",1000,subPicIdx,0)
	elseif m.human == 1 and m.male == 0 then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG_V5,"Portrait.godat",2000,subPicIdx,0)
	elseif m.human == 0 and m.male == 1 then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG_V5,"Portrait.godat",3000,subPicIdx,0)
	elseif m.human == 0 and m.male == 0 then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG_V5,"Portrait.godat",4000,subPicIdx,0)
	end
end

function SetDefHead(m) --设置默认头像
	if m.human == 1 and m.male == 1 then
		DBGPRINTF("lua_info: Begin set default head image 1")
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG_V5,"Portrait.godat",1000,0,0)
	elseif m.human == 1 and m.male == 0 then
		DBGPRINTF("lua_info: Begin set default head image 2")
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG_V5,"Portrait.godat",2000,0,0)
	elseif m.human == 0 and m.male == 1 then
		DBGPRINTF("lua_info: Begin set default head image 3")
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG_V5,"Portrait.godat",3000,0,0)
	elseif m.human == 0 and m.male == 0 then
		DBGPRINTF("lua_info: Begin set default head image 4")
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG_V5,"Portrait.godat",4000,0,0)
	end
end

function GetCurImgID(m) 
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

function SetBKImage(m)
	if m.human == 1 then
	UI_Engine.SetImg(m.formIndex,COMPOSIT_2333,"UIData_iphone.godat", 2020,0,0)
	else
	UI_Engine.SetImg(m.formIndex,COMPOSIT_2333,"UIData_iphone.godat", 2021,0,0)
	end
end

function SetRoleImage(m)

	if 1 == m.human and 1 == m.warrior and 1 == m.male  then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW_V5,"UIData_iphone.godat", 2025,0,0)

	elseif 1 == m.human and 1 == m.warrior and 0 == m.male  then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW_V5,"UIData_iphone.godat", 2026,0,0)

	elseif 1 == m.human and 0 == m.warrior and 1 == m.male then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW_V5,"UIData_iphone.godat", 2023,0,0)

	elseif 1 == m.human and 0 == m.warrior and 0 == m.male then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW_V5,"UIData_iphone.godat", 2024,0,0)

	elseif 1 == m.human and 2 == m.warrior and 1 == m.male then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW_V5,"UIData_iphone.godat", 2027,0,0)

	elseif 1 == m.human and 2 == m.warrior and 0 == m.male then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW_V5,"UIData_iphone.godat", 2028,0,0)

	elseif  0 == m.human and 1 == m.warrior and 1 == m.male then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW_V5,"UIData_iphone.godat", 2031,0,0)

	elseif 0 == m.human and 1 == m.warrior and 0 == m.male then 
		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW_V5,"UIData_iphone.godat", 2032,0,0)
	elseif 0 == m.human and 0 == m.warrior and 1 == m.male then 
		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW_V5,"UIData_iphone.godat", 2029,0,0)
	elseif 0 == m.human and 0 == m.warrior and 0 == m.male then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW_V5,"UIData_iphone.godat", 2030,0,0)
	elseif 0 == m.human and 2 == m.warrior and 1 == m.male then 
		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW_V5,"UIData_iphone.godat", 2033,0,0)
	elseif 0 == m.human and 2 == m.warrior and 0 == m.male then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW_V5,"UIData_iphone.godat", 2034,0,0)
	end
end

function SetDiscRace(m)
	if m.human == 1 then
	UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_RACEBOX_V5,m.DisHM,0)

	else
	UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_RACEBOX_V5,m.DisNE,0)

	end
end

function SetDiscJob(m)
	if   0 == m.warrior then
		UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_JOBBOX_V5,m.DisKO,0)

	elseif 1 == m.warrior then
		UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_JOBBOX_V5,m.DisKN,0)

	else
		UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_JOBBOX_V5,m.DisPA,0)

	end
end

function SetRace(m)
	if m.human == 1 then

	UI_Engine.SetState(m.formIndex,COMPOSIT_2348,1)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2347,0)
	else

	UI_Engine.SetState(m.formIndex,COMPOSIT_2348,0)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2347,1)
	end
end

function SetJob(m)
	if   0 == m.warrior then

	UI_Engine.SetState(m.formIndex,COMPOSIT_2352,1)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2351,0)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2353,0)
	elseif 1 == m.warrior then

	UI_Engine.SetState(m.formIndex,COMPOSIT_2352,0)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2351,1)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2353,0)
	else

	UI_Engine.SetState(m.formIndex,COMPOSIT_2352,0)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2351,0)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2353,1)
	end
end

function SetSex(m)
	if   0 == m.male then
		UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_JOBBOX_V5,m.DisKO,0)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2350,1)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2349,0)

	elseif 1 == m.male then
		UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_JOBBOX_V5,m.DisKN,0)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2350,0)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2349,1)


	end
end

FORM_ROLE_CREATE_V5.C52353_OnClick = function( m )
m.warrior = 2
SetRoleImage(m)
SetDiscJob(m)


end
FORM_ROLE_CREATE_V5.C52352_OnClick = function( m )
m.warrior = 0
SetRoleImage(m)

SetDiscJob(m)


end
FORM_ROLE_CREATE_V5.C52351_OnClick = function( m )
m.warrior = 1
SetRoleImage(m)
SetDiscJob(m)


end
FORM_ROLE_CREATE_V5.C52350_OnClick = function( m )
m.male = 0
m.subImg = 0
SetRoleImage(m)
SetDefHead(m) 

end
FORM_ROLE_CREATE_V5.C52349_OnClick = function( m )
m.male = 1
m.subImg = 0
SetRoleImage(m)
SetDefHead(m) 

end
FORM_ROLE_CREATE_V5.C52329_OnClick = function( m )
local text = UI_Engine.GetText(m.formIndex,COMPOSIT_ROLE_NICKBOX_V5)
m.InputBox = OpenInputBox(m,text,16)
m.InputBox :WaitUserInput(m)
m.name = m.InputBox :GetResult()
if m:SetName(m.name)==1 then --昵称输入合法
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_NICKBOX_V5,m.name,0)
else
m.name=""
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_NICKBOX_V5,m.name,0)
end
DBGPRINTF("lua_info:SetWindowText OK!")
end
FORM_ROLE_CREATE_V5.C52348_OnClick = function( m )
m.human = 1
m.subImg = 0
SetRoleImage(m)
SetBKImage(m)
SetDefHead(m) 
SetDiscRace(m)


end
FORM_ROLE_CREATE_V5.C52347_OnClick = function( m )
m.human = 0
m.subImg = 0
SetRoleImage(m)
SetBKImage(m)
SetDefHead(m) 
SetDiscRace(m)


end
FORM_ROLE_CREATE_V5.C52346_OnClick = function( m )
local imgID = GetCurImgID(m)
DBGPRINTF("lua_info:HeadImgBox Clicked")
m.headImg = NewHeadImg(m, imgID)
if m.human == 1 and m.male == 1 then
	m.headImg.ret = m.headImg:LoadHeadImg(m, 0)
elseif m.human == 1 and m.male == 0 then
	m.headImg.ret = m.headImg:LoadHeadImg(m, 1)
elseif m.human == 0 and m.male == 1 then
	m.headImg.ret = m.headImg:LoadHeadImg(m, 2)
elseif m.human == 0 and m.male == 0 then
	m.headImg.ret = m.headImg:LoadHeadImg(m, 3)
end
m.headImg:WaitUserInput(m)
m.subImg = m.headImg:GetResult()
DelHeadImg(m.headImg)
DrawHeadImg(m, m.subImg)
end
FORM_ROLE_CREATE_V5.C52291_OnClick = function( m )
if m.name == "" then
	WarnUser(m, "请输入您的昵称")
	return
else
	m:GetCreateInfo(m.human,m.warrior,m.male,m.subImg)
	m:SetJobSN()
	m:SetRaceSN()
	DBGPRINTF("lua_info:global jobSN = "..G_JOBSN)
	m:InputFinished()
	m:CreateRole(m.name)
end
end
FORM_ROLE_CREATE_V5.C52290_OnClick = function( m )
m:Back()
m:InputFinished()
DBGPRINTF("lua_info:Exit clicked")
end
FORM_ROLE_CREATE_V5.C52330_OnLoad = function( m )
m.ImgElfMaleMage = m:CreateSurface("UIData_iphone.godat", 2029) 
m.ImgElfMaleWarrior = m:CreateSurface("UIData_iphone.godat", 2031) 
m.ImgElfFemaleMage = m:CreateSurface("UIData_iphone.godat", 2030) 
m.ImgElfFemaleWarrior = m:CreateSurface("UIData_iphone.godat", 2032) 
m.ImgElfMalePastor = m:CreateSurface("UIData_iphone.godat", 2033) 
m.ImgElfFemalePastor = m:CreateSurface("UIData_iphone.godat", 2034) 
m.ImgHumanMaleMage = m:CreateSurface("UIData_iphone.godat", 2023) 
m.ImgHumanMaleWarrior = m:CreateSurface("UIData_iphone.godat", 2025) 
m.ImgHumanFemaleMage = m:CreateSurface("UIData_iphone.godat", 2024) 
m.ImgHumanFemaleWarrior = m:CreateSurface("UIData_iphone.godat", 2026) 
m.ImgHumanMalePastor = m:CreateSurface("UIData_iphone.godat", 2027) 
m.ImgHumanFemalePastor = m:CreateSurface("UIData_iphone.godat", 2028)
m.ImgAkadiya = m:CreateSurface("UIData_iphone.godat", 2020) 
m.ImgGuanlinzheng = m:CreateSurface("UIData_iphone.godat", 2021) 
-- m.RoleImage = m.ImgElfMaleMage

m.male, m.warrior, m.human = m:GetRandRole()
m.DisKN, m.DisKO, m.DisPA,m.DisNE,m.DisHM = m:GetDiscribe()
DBGPRINTF("m.male = "..m.male)
DBGPRINTF("m.warrior = "..m.warrior)
DBGPRINTF("m.human = "..m.human)
SetRoleImage(m)
SetDefHead(m) 
SetDiscRace(m)
SetDiscJob(m)
SetRace(m)
SetJob(m)
SetSex(m)


--m.RoleImage = GetRoleInfo(m)
--m.BackImage = m.ImgAkadiya
end
FORM_ROLE_CREATE_V5.C52330_OnDraw = function( m )
--m.RoleImage = GetRoleInfo(m)
--m:DrawSurface(m.RoleImage, 0, 0, 480, 320)
end
FORM_ROLE_CREATE_V5.C52289_OnLoad = function( m )

 
end
FORM_ROLE_CREATE_V5.C52333_OnLoad = function( m )
SetBKImage(m)
end
