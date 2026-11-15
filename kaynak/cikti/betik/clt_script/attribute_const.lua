--枚举变量

--属性
PROP_HPVALUE = 1			--体力值
PROP_MPVALUE = 2			--法力值
PROP_HAPPY_VALUE = 3			--快乐度
PROP_FULL_VALUE = 4			--饱食度

PROP_STRENGTH = 11			--力量
PROP_AGILITY = 12			--敏捷
PROP_CORPOREITY = 13			--体质
PROP_INTELLECT = 14			--智力

PHYSICAL_ATTACK = 20			--物理攻击
PHYSICAL_DEFENCE = 21			--物理防御
MAGIC_ATTACK = 22			--魔法攻击
MAGIC_DEFENCE = 23			--魔法防御

HP_MAX = 30				--体力上限
MP_MAX = 31				--法力上限
HP_RESUME = 32				--体力恢复
MP_RESUME = 33				--法力恢复

MOVE_SPEED = 40				--移动速度
MAGIC_FATAL = 42			--[废弃]魔法致命	
LUCK_RATE = 45				--幸运几率

SORBDAMAGE = 50			--吸收伤害

TERRA_RESIST = 60			--地抗性
FIRE_RESIST = 61			--火抗性
WIND_RESIST = 62			--风抗性
WATER_RESIST = 63			--水抗性
HOLY_RESIST = 64			--圣抗性
DARK_RESIST = 65			--暗抗性
PK_CONDITION = 66			--PK状态

TERRA_DAMAGE=100		--地伤害
FIRE_DAMAGE=101			--火伤害
WIND_DAMAGE=102			--风伤害
WATER_DAMAGE=103		--水伤害
DARK_DAMAGE = 120		--暗伤害
HOLY_DAMAGE = 121       --圣伤害

PHYSICAL_FATAL = 41           --原始暴击率（万分比）。之前的含义是物理致命。
FATAL_LEVEL = 122             --暴击等级
PANEL_FATAL_RATE = 123        --面板暴击率（万分比）

EMITDAMAGE = 51               --原始释放伤害比率（万分比）。之前的含义是释放伤害。
EMITDAMAGE_LEVEL = 124        --释放伤害等级
PANEL_EMITDAMAGE_RATE = 125   --面板释放伤害比率(万分比)

PROP_SHOOTRATE_ENHANCE=108    --原始命中率（万分比）。之前的含义是命中强化(%)。
SHOOT_RATE = 43               --命中等级。之前的含义是命中属性。
PANEL_SHOOT_RATE = 126        --面板命中率(万分比)

PROP_JOOK_ENHANCE=109         --原始回避率（万分比）。之前的含义是闪避强化(%)。
JOOK_RATE = 44                --闪避等级。之前的含义是闪避属性。
PANEL_JOOK_RATE = 127         --面板闪避率(万分比)

RAW_PVP_SORBDAMAGE_RATE = 128 --原始PVP减伤率(万分比)。PVP减伤就是韧性。
PVP_SORBDAMAGE_LEVEL = 129    --韧性等级
PANEL_PVP_SORBDAMAGE_RATE = 130 --面板PVP减伤率(万分比)

PROP_BUFF_CANNOT_USE_SKILL = 131  --不能使用主动技能(还包括召唤/召回魔法兽)
PROP_BUFF_CANNOT_USE_ITEM = 132   --不能使用道具(包括药水、奇物等消耗型道具)
PROP_BUFF_CANNOT_MOVE = 133       --不能移动（还包括从坐骑上赶下来、不能被邀请乘骑、不能召唤坐骑）

WEAPON_BIAS_RATE=104		--武器偏斜率

--程序中自定义的属性
PROP_LEVEL = 1000			--等级
PROP_SN = 1001			--序号
PROP_SEX = 1002			--性别
PROP_GEN = 1003			--辈分
PROP_CHARACTER = 1004		--性格

PROP_PHY_GIFT = 1005		--物攻
PROP_MAGIC_GIFT = 1006	--魔攻
PROP_CROP_GIFT = 1007		--体力
PROP_MANA_GIFT = 1008		--法力
PROP_DEFENCE_GIFT = 1009	--防御
PROP_RESIST_GIFT = 1010	--抗性
PROP_SHOOT_GIFT = 1011	--命中
PROP_JOOK_GIFT = 1012		--闪避

PROP_PHY_GIFT_MAX = 1020	--物攻
PROP_MAGIC_GIFT_MAX = 1021		--魔攻
PROP_CROP_GIFT_MAX = 1022			--体力
PROP_MANA_GIFT_MAX = 1023			--法力
PROP_DEFENCE_GIFT_MAX = 1024		--防御
PROP_RESIST_GIFT_MAX = 1025		--抗性
PROP_SHOOT_GIFT_MAX = 1026		--命中
PROP_JOOK_GIFT_MAX = 1027			--闪避

PROP_NUMERAL_SN = 1035		--数值模板SN
PROP_LEFT_TIME = 1036		--寿命

PROP_PHY_GIFT_INIT = 1040			--初始物攻
PROP_MAGIC_GIFT_INIT = 1041		--初始魔攻
PROP_CROP_GIFT_INIT = 1042		--初始体力
PROP_MANA_GIFT_INIT = 1043		--初始法力
PROP_DEFENCE_GIFT_INIT = 1044	--初始防御
PROP_RESIST_GIFT_INIT = 1045		--初始抗性
PROP_SHOOT_GIFT_INIT = 1046		--初始命中
PROP_JOOK_GIFT_INIT = 1047		--初始闪避

--装备中新加入的属性
PROP_100SHOOTRATE=105			--必中
PROP_DEFENCE_IGNORE=106			--忽略对方防御(%)
PROP_DEFENCE_ENHANCE=107		--防御强化(%)
PROP_FIRE_RESISIT_DECREASE=110		--降低对方火抗110
PROP_WATER_RESISIT_DECREASE=111		--降低对方冰抗111

PROP_EXP_GETRATE=112			--经验值倍数
PROP_MONEY_GETRATE=113			--金钱倍数
PROP_DROP_GETRATE=114			--掉落倍数

PROP_MD_RESIST_PERSENT=118		--魔法盾抵抗伤害百分比
PROP_MD_RESIST_PER_100_MANA=119		--每100点魔法抵抗伤害值，一般要设置成100


--触发器类型
TRIGGER_TODAMAGE = 10000        --触发器_造成伤害时
TRIGGER_DAMAGED = 10001         --触发器_被伤害时
TRIGGER_TORESUME = 10002        --触发器_造成治疗时
TRIGGER_RESUMED = 10003         --触发器_被治疗时
TRIGGER_TOGIVE_BUFF = 10004     --触发器_给BUFF时
TRIGGER_GIVED_BUFF = 10005      --触发器_被给BUFF时
TRIGGER_TOCAST_SKILL = 10006    --触发器_释放技能时（已经扣蓝时）


--EquipType 装备类型枚举
EQUIPTYPE_ALL = -1       --所有
EQUIPTYPE_WEAPON = 0     --武器
EQUIPTYPE_HAT = 1        --头
EQUIPTYPE_SHOULDER = 2   --肩
EQUIPTYPE_CLOTHING = 3   --衣服
EQUIPTYPE_CESTUS = 4     --腰带
EQUIPTYPE_GLOVE = 5      --手套
EQUIPTYPE_SHOES = 6      --鞋
EQUIPTYPE_NECKLACE = 7   --项链
EQUIPTYPE_RING = 8       --戒指
EQUIPTYPE_HORSE = 9      --坐骑

--ProfessionStage 生活技能阶段枚举
PROFESSION_STAGE1 = 0  --初级
PROFESSION_STAGE2 = 1  --中级
PROFESSION_STAGE3 = 2  --高级
PROFESSION_STAGE4 = 3  --大师
PROFESSION_STAGE5 = 4  --宗师

--ProfessionType 生活技能类型枚举
PROF_TYPE_GATHERING = 0   --采集
PROF_TYPE_PRODUCTION = 1  --生产

--ProfessionSubType 生活技能子类型枚举
--生活技能为采集 PROF_TYPE_GATHERING，子类型为
PROF_SUB_TYPE_MINING = 0     --采矿
PROF_SUB_TYPE_HERBALISM = 1  --草药
--生活技能为生产 PROF_TYPE_PRODUCTION，子类型为

--ProfessionStatus 生活技能状态枚举
PROF_STATUS_INVALID = -1
PROF_STATUS_NORMAL = 0
PROF_STATUS_FORGETTING = 1
PROF_STATUS_FORGOT = 2

--EPetGiftLogType 宠物天赋日志类型
EPetGiftLogType_Invalid = 0
EPetGiftLogType_Feed = 1

--TRace 种族
ERace_Human = 250001
ERace_NightElf = 250002

--TCamp 阵营
ECamp_None = -1       --无阵营
ECamp_Neutral = 0     --中立阵营
ECamp_Human = 1       --人族阵营
ECamp_NightElf = 2    --夜精灵阵营
ECamp_Hostile = 3     --敌对阵营

--物体SN枚举
ESN_SvrStringSN = 0  --服务器字符串的SN

--精灵类型
ESpriteType_Player = 0 --玩家
ESpriteType_NPC = 1    --NPC，包括城镇NPC、守卫、怪物
ESpriteType_Pet = 2    --魔法兽

--VIP等级
EVIPLevel_NoVIP = 0       --普通玩家
EVIPLevel_SilverCard = 1  --银卡VIP
EVIPLevel_GoldCard = 2    --金卡VIP
EVIPLevel_DiamondCard = 3 --钻石卡VIP

--任务状态
ETaskStatus_Unaccept = 0      --未接
ETaskStatus_OnDoing = 1       --正在进行
ETaskStatus_Ready = 2         --就绪，可以去完成了
ETaskStatus_Finish = 3        --任务结束
ETaskStatus_Unfinishable = 4  --无法完成

--数据版本
EDataEdition_Test = 10          --内部测试
EDataEdition_V8 = 20            --V8版
EDataEdition_TengXun = 30       --腾讯版
EDataEdition_139 = 40           --139版
EDataEdition_Web = 50           --WEB版
EDataEdition_QuYouWeb = 1000    --趣游(WEB)

--平台版本
EPlatformEdition_SymbianV3 = 10
EPlatformEdition_SymbianV5 = 20
EPlatformEdition_IPhone = 30
EPlatformEdition_Web = 40

--静态属性加成方式
EStaticPropImpactType_Numerical = 1
EStaticPropImpactType_Percent = 2
