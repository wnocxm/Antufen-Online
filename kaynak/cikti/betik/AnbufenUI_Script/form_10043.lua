FORM_ROLE_CREATE= { }
FORM_ROLE_CREATE.Main = function( m )
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
FORM_ROLE_CREATE.C52767_OnLoad = function( m )
m.name = ""
m.subImg = 0
end
local WarnUser = function(m, str)
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
		UI_Engine.SetImg(m.formIndex,51157,"Portrait.godat",1000,subPicIdx,0)
	elseif m.human == 1 and m.male == 0 then

		UI_Engine.SetImg(m.formIndex,51157,"Portrait.godat",2000,subPicIdx,0)
	elseif m.human == 0 and m.male == 1 then

		UI_Engine.SetImg(m.formIndex,51157,"Portrait.godat",3000,subPicIdx,0)
	elseif m.human == 0 and m.male == 0 then
		UI_Engine.SetImg(m.formIndex,51157,"Portrait.godat",4000,subPicIdx,0)
	end
end

function SetDefHead(m) --设置默认头像
--WarnUser (m,"头像")
	DBGPRINTF("SetDefHead(m) ")
DBGPRINTF("m.male = "..m.male)
DBGPRINTF("m.warrior = "..m.warrior)
DBGPRINTF("m.human = "..m.human)
	if m.human == 1 and m.male == 1 then
		DBGPRINTF("lua_info: Begin set default head image 1")
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",1000,0,0)
	elseif m.human == 1 and m.male == 0 then
		DBGPRINTF("lua_info: Begin set default head image 2")
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",2000,0,0)
	elseif m.human == 0 and m.male == 1 then
		DBGPRINTF("lua_info: Begin set default head image 3")
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",3000,0,0)
	elseif m.human == 0 and m.male == 0 then
		DBGPRINTF("lua_info: Begin set default head image 4")
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",4000,0,0)
	end
end

function GetCurImgID(m) 
	if m.human == 1 and m.male == 1 then
		m.Head = m.ImgHead1
		return 0
	elseif m.human == 1 and m.male == 0 then
		m.Head = m.ImgHead2
		return 1
	elseif m.human == 0 and m.male == 1 then
		m.Head = m.ImgHead3
		return 2
	elseif m.human == 0 and m.male == 0 then
		m.Head = m.ImgHead4
		return 3
	end
end

function SetBKImg(m)
	DBGPRINTF("SetBKImage(m)")
DBGPRINTF("m.male = "..m.male)
DBGPRINTF("m.warrior = "..m.warrior)
DBGPRINTF("m.human = "..m.human)
	if m.human == 1 then
	UI_Engine.SetImg(m.formIndex,COMPOSIT_1148,"UIData_iphone.godat", 2002,0,0)
	else
	UI_Engine.SetImg(m.formIndex,COMPOSIT_1148,"UIData_iphone.godat", 2003,0,0)
	end
end

function SetRoleImg(m)

	if 1 == m.human and 1 == m.warrior and 1 == m.male  then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW,"UIData_iphone.godat", 2009,0,0)

	elseif 1 == m.human and 1 == m.warrior and 0 == m.male  then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW,"UIData_iphone.godat", 2011,0,0)

	elseif 1 == m.human and 0 == m.warrior and 1 == m.male then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW,"UIData_iphone.godat", 2008,0,0)

	elseif 1 == m.human and 0 == m.warrior and 0 == m.male then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW,"UIData_iphone.godat", 2010,0,0)
	elseif 1 == m.human and 2 == m.warrior and 1 == m.male then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW,"UIData_iphone.godat", 2040,0,0)

	elseif 1 == m.human and 2 == m.warrior and 0 == m.male then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW,"UIData_iphone.godat", 2041,0,0)
	elseif  0 == m.human and 1 == m.warrior and 1 == m.male then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW,"UIData_iphone.godat", 2005,0,0)

	elseif 0 == m.human and 1 == m.warrior and 0 == m.male then 
		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW,"UIData_iphone.godat", 2007,0,0)
	elseif 0 == m.human and 0 == m.warrior and 1 == m.male then 
		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW,"UIData_iphone.godat", 2004,0,0)
	elseif 0 == m.human and 0 == m.warrior and 0 == m.male then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW,"UIData_iphone.godat", 2006,0,0)
	elseif 0 == m.human and 2 == m.warrior and 1 == m.male then 
		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW,"UIData_iphone.godat", 2042,0,0)
	elseif 0 == m.human and 2 == m.warrior and 0 == m.male then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_ROLE_SHOW,"UIData_iphone.godat", 2043,0,0)
	end
end

function SetDiscRace(m)
	if m.human == 1 then
	UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_RACEBOX,m.DisHM,0)
	else
	UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_RACEBOX,m.DisNE,0)
	end
end

function SetDiscJob(m)
	if   0 == m.warrior then
		UI_Engine.SetMultiRollText(m.formIndex,COMPOSIT_ROLE_JOBBOX,m.DisKO,0)
	elseif 1 == m.warrior then
		UI_Engine.SetMultiRollText(m.formIndex,COMPOSIT_ROLE_JOBBOX,m.DisKN,0)
	else
		UI_Engine.SetMultiRollText(m.formIndex,COMPOSIT_ROLE_JOBBOX,m.DisPA,0)
	end
end

FORM_ROLE_CREATE.C51120_OnClick = function( m )
local text = UI_Engine.GetText(m.formIndex,COMPOSIT_ROLE_NICKBOX)
m.InputBox = OpenInputBox(m,text,16)
m.InputBox :WaitUserInput(m)
m.name = m.InputBox :GetResult()
if m:SetName(m.name)==1 then --昵称输入合法
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_NICKBOX,m.name,0)
else
m.name=""
UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_NICKBOX,m.name,0)
end
DBGPRINTF("lua_info:SetWindowText OK!")
end
FORM_ROLE_CREATE.C52773_OnClick = function( m )
m.male = 0
m.subImg = 0
SetRoleImg(m)
--SetDefHead(m) 
GetRoleInfo(m) 
--GetCurImgID(m) 


	if m.human == 1 then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",2000,m.subImg,0)

	else
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",4000,m.subImg,0)
	end
end
FORM_ROLE_CREATE.C52772_OnClick = function( m )
m.male = 1
m.subImg = 0
SetRoleImg(m)
--SetDefHead(m) 
GetRoleInfo(m) 
--GetCurImgID(m) 

if m.human == 1 then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",1000,m.subImg,0)

	else 
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",3000,m.subImg,0)
end

end
FORM_ROLE_CREATE.C52771_OnClick = function( m )
m.human = 1
m.subImg = 0
SetRoleImg(m)
SetBKImg(m)
--SetDefHead(m) 
--SetDiscRace(m)
GetRoleInfo(m) 
GetTownImg(m)
--GetCurImgID(m) 


	UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_RACEBOX,m.DisHM,0)

if m.male == 1 then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",1000,m.subImg,0)
	else

		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",2000,m.subImg,0)

end
end
FORM_ROLE_CREATE.C52770_OnClick = function( m )
m.human = 0
m.subImg = 0
SetRoleImg(m)
SetBKImg(m)
--SetDefHead(m) 
--SetDiscRace(m)
GetRoleInfo(m) 
GetTownImg(m)
GetCurImgID(m) 


	UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_RACEBOX,m.DisNE,0)


	if  m.male == 1 then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",3000,m.subImg,0)
	else
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",4000,m.subImg,0)
	end
end
FORM_ROLE_CREATE.C52644_OnClick = function( m )
m.warrior = 0
SetRoleImg(m)
--SetDiscJob(m)
GetRoleInfo(m) 

		UI_Engine.SetMultiRollText(m.formIndex,COMPOSIT_ROLE_JOBBOX,m.DisKO,0)

end
FORM_ROLE_CREATE.C52642_OnClick = function( m )
m.warrior = 2
SetRoleImg(m)
--SetDiscJob(m)
GetRoleInfo(m) 


		UI_Engine.SetMultiRollText(m.formIndex,COMPOSIT_ROLE_JOBBOX,m.DisPA,0)

end
FORM_ROLE_CREATE.C52641_OnClick = function( m )
m.warrior = 1
SetRoleImg(m)
--SetDiscJob(m)
GetRoleInfo(m) 


		UI_Engine.SetMultiRollText(m.formIndex,COMPOSIT_ROLE_JOBBOX,m.DisKN,0)


end
FORM_ROLE_CREATE.C52800_OnClick = function( m )
m:Back()
m:InputFinished()
DBGPRINTF("lua_info:Exit clicked")
end
FORM_ROLE_CREATE.C51157_OnLoad = function( m )
DBGPRINTF("lua_info:SetImgBox loaded")
DBGPRINTF("lua_info:m.human = "..m.human)
DBGPRINTF("lua_info:m.male = "..m.male)
--SetDefHead(m)
end
FORM_ROLE_CREATE.C51157_OnClick = function( m )
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
--DrawHeadImg(m, m.subImg)
if m.human == 1 and m.male == 1 then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",1000,m.subImg,0)
	elseif m.human == 1 and m.male == 0 then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",2000,m.subImg,0)
	elseif m.human == 0 and m.male == 1 then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",3000,m.subImg,0)
	elseif m.human == 0 and m.male == 0 then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",4000,m.subImg,0)
	end


end
FORM_ROLE_CREATE.C52799_OnClick = function( m )
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
FORM_ROLE_CREATE.C51122_OnLoad = function( m )
m.ImgElfMaleMage = m:CreateSurface("UIData_iphone.godat", 2004) 
m.ImgElfMaleWarrior = m:CreateSurface("UIData_iphone.godat", 2005) 
m.ImgElfFemaleMage = m:CreateSurface("UIData_iphone.godat", 2006) 
m.ImgElfFemaleWarrior = m:CreateSurface("UIData_iphone.godat", 2007) 
m.ImgHumanMaleMage = m:CreateSurface("UIData_iphone.godat", 2008) 
m.ImgHumanMaleWarrior = m:CreateSurface("UIData_iphone.godat", 2009) 
m.ImgHumanFemaleMage = m:CreateSurface("UIData_iphone.godat", 2010) 
m.ImgHumanFemaleWarrior = m:CreateSurface("UIData_iphone.godat", 2011) 

m.ImgElfMalePastor = m:CreateSurface("UIData_iphone.godat", 2033) 
m.ImgElfFemalePastor = m:CreateSurface("UIData_iphone.godat", 2034) 
m.ImgHumanMalePastor = m:CreateSurface("UIData_iphone.godat", 2027) 
m.ImgHumanFemalePastor = m:CreateSurface("UIData_iphone.godat", 2028)

m.ImgAkadiya = m:CreateSurface("UIData_iphone.godat", 2002) 
m.ImgGuanlinzheng = m:CreateSurface("UIData_iphone.godat", 2003) 
-- m.RoleImage = m.ImgElfMaleMage

m.ImgHead1 = m:CreateSurface("Portrait.godat",1001)
m.ImgHead2 = m:CreateSurface("Portrait.godat",2001)
m.ImgHead3 = m:CreateSurface("Portrait.godat",3001)
m.ImgHead4 =m:CreateSurface("Portrait.godat",4001)


m.male, m.warrior, m.human = m:GetRandRole()
m.DisKN, m.DisKO, m.DisPA,m.DisNE,m.DisHM = m:GetDiscribe()
DBGPRINTF("m.male = "..m.male)
DBGPRINTF("m.warrior = "..m.warrior)
DBGPRINTF("m.human = "..m.human)
--SetRoleImage(m)
--SetDefHead(m) 
--SetDiscRace(m)
--SetDiscJob(m)

SetRoleImg(m)
SetBKImg(m)

GetRoleInfo(m)
GetTownImg(m)
GetCurImgID(m) 


	if m.human == 1 then
	UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_RACEBOX,m.DisHM,0)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2771,1)
	else
	UI_Engine.SetText(m.formIndex,COMPOSIT_ROLE_RACEBOX,m.DisNE,0)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2770,1)
	end

	if   0 == m.warrior then
		UI_Engine.SetMultiRollText(m.formIndex,COMPOSIT_ROLE_JOBBOX,m.DisKO,0)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2644,1)
	elseif 1 == m.warrior then
		UI_Engine.SetMultiRollText(m.formIndex,COMPOSIT_ROLE_JOBBOX,m.DisKN,0)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2641,1)
	else
		UI_Engine.SetMultiRollText(m.formIndex,COMPOSIT_ROLE_JOBBOX,m.DisPA,0)
	UI_Engine.SetState(m.formIndex,COMPOSIT_2642,1)
	end


if m.human == 1 and m.male == 1 then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",1000,m.subImg,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_2772,1)
	elseif m.human == 1 and m.male == 0 then
UI_Engine.SetState(m.formIndex,COMPOSIT_2773,1)
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",2000,m.subImg,0)
	elseif m.human == 0 and m.male == 1 then

		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",3000,m.subImg,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_2772,1)
	elseif m.human == 0 and m.male == 0 then
		UI_Engine.SetImg(m.formIndex,COMPOSIT_SELHEADIMG,"Portrait.godat",4000,m.subImg,0)
UI_Engine.SetState(m.formIndex,COMPOSIT_2773,1)
	end

end
FORM_ROLE_CREATE.C51148_OnLoad = function( m )
--SetBKImage(m)
end
