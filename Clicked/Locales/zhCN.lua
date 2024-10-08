-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2024  Kevin Krol
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local L = LibStub("AceLocale-3.0"):NewLocale("Clicked", "zhCN")

if not L then
	return
end

L["Clicked"] = "Clicked"
L["Unable to register unit frame: %s"] = "无法注册单位框架: %s"
L["Clicked is not compatible with %s and requires one of the two to be disabled."] = "Clicked 和 %s 不兼容，请禁用其中一个插件."
L["Keep %s"] = "保留 %s"
L["Upgraded profile from version %s to version %s"] = "已将配置文件从版本 %s 升级到版本 %s"
L["You are in combat, the binding configuration is in read-only mode."] = "你正在战斗中, 快捷键设置处于只读模式."
L["Clicked Binding Configuration"] = "Clicked 快捷键配置"
L["Cast %s"] = "施放 %s"
L["Use %s"] = "使用 %s"
L["Cancel %s"] = "取消 %s"
L["Run custom macro"] = "运行自定义宏"
L["Target the unit"] = "目标单位"
L["Open the unit menu"] = "打开单位框架菜单"
L["UNBOUND"] = "未绑定"
L["Loaded"] = "载入"
L["Unloaded"] = "未载入"
L["Key"] = "关键词"
L["ABC"] = "关键字"
L["Targets"] = "目标"
L["Create"] = "创建"
L["Duplicate"] = "复制"
L["Copy Data"] = "拷贝数据"
L["Paste Data"] = "粘贴数据"
L["Select"] = "选择"
L["Pick from spellbook"] = "从法术书中选取"
L["Remove rank"] = "移除技能等级"
L["Are you sure you want to delete this binding?"] = "你真的想删除这个快捷键吗?"
L["Are you sure you want to delete this group and ALL bindings it contains? This will delete %s bindings."] = "你真的想删除这个组和它所有相关的快捷键吗? 这将删除 %s 快捷键."
L["Click and press a key to bind, or ESC to clear the binding."] = "点击任意键以绑定快捷键, 或按ESC键清除绑定快捷键."
L["Search..."] = "搜索..."
L["New Group"] = "新建组"
L["Action"] = "动作"
L["Action Groups"] = "动作组"
L["Type"] = "类型"
L["Targets"] = "目标"
L["Macro conditions"] = "宏条件"
L["Load conditions"] = "读取条件"
L["Status"] = "状态"
L["Create a new binding"] = "创建一个新的快捷键"
L["Simple Binding"] = "普通快捷键"
L["Clickcast Binding"] = "点击施法快捷键"
L["Healer Binding"] = "治疗者快捷键"
L["Custom Macro (advanced)"] = "自定义宏(高级)"
L["Convert to"] = "转换为"
L["Group"] = "组"
L["Group %d"] = "组 %d"
L["Group Name and Icon"] = "组名称和图标"
L["The left and right mouse button can only activate when hovering over unit frames."] = "鼠标左键和右键只能在悬停于单位框架上时激活 ."
L["Click on a spell book entry to select it."] = "点击法术书条目进行选择."
L["Right click to use the max rank."] = "右键点击将使用最高等级技能."
L["Enter an item name, item ID, or equipment slot number."] = "输入一个物品的名称、物品ID或装备槽数字."
L["If the input field is empty you can also shift-click an item from your bags to auto-fill."] = "如果输入字段为空, 您也可以按住 shift 键并单击背包中的物品以自动填写."
L["This macro will only execute when hovering over unit frames, in order to interact with the selected target use the [@mouseover] conditional."] = "此宏仅在悬停于单位框架上时执行, 为了与选定目标交互, 请使用 [@mouseover] 为条件."
L["This mode will directly append the macro text onto an automatically generated command generated by other bindings using the specified keybind. Generally, this means that it will be the last section of an '/cast' command."] = "此模式将直接把宏文本附加到自动生成的命令后, 这意味着你填写的内容是 '/cast' 命令的后面部分."
L["With this mode you're not writing a macro command. You're adding parts to an already existing command, so writing '/cast Holy Light' will not work, in order to cast Holy Light simply type 'Holy Light'."] = "所以此模式下你不用写入宏命令. 你是在为已存在的命令增加组件,  '/cast 圣光术'将不能运行, 要施放圣光术只需要简单的输入'圣光术'."
L["Bindings using a mouse button and the Mouseover target will not activate when hovering over a unit frame, enable the Unit Frame Target to enable unit frame clicks."] = "当鼠标悬停在单位框架上时, 无法绑定鼠标按钮和 Mouseover 目标, 请先启用目标单位框架才能启用单位框架点击."
L["Macro Name and Icon (optional)"] = "宏名称和图标 (可选)"
L["Options"] = "选项"
L["Shared Options"] = "共享选项"
L["External Integrations"] = "外部集成"
L["Create WeakAura"] = "创建 WeakAura"
L["Beta"] = "Beta"
L["On this target"] = "在这个目标"
L["Or"] = "或"
L["Or (inactive)"] = "或 (不可用)"
L["Quick start"] = "快速开始"
L["Automatically import from spellbook"] = "从法术书中自动导入"
L["Automatically import from action bars"] = "从动作条导入"
L["Cast a spell"] = "施放一个法术"
L["Cast a spell on a unit frame"] = "对一个单位框架施法"
L["Use an item"] = "使用一个物品"
L["Cancel an aura"] = "取消一个光环"
L["Run a macro"] = "运行一个宏"
L["Append a binding segment"] = "追加一个快捷键组件"
L["Advanced binding types"] = "高级快捷键类型"
L["Target the unit"] = "目标单位"
L["Open the unit menu"] = "打开单位菜单"
L["Target Spell"] = "目标法术"
L["Enter the spell name or spell ID."] = "输入法术名称或法术ID"
L["Enter the aura name or spell ID."] = "输入光环名称或法术ID"
L["Target Item"] = "目标物品"
L["Macro Text"] = "宏文本"
L["Target Aura"] = "目标光环"
L["Interrupt current cast"] = "打断当前施法"
L["Allow this binding to cancel any spells that are currently being cast."] = "这个快捷键将在施放技能前打断正在施放的法术"
L["Start auto attacks"] = "开始自动攻击"
L["Allow this binding to start auto attacks, useful for any damaging abilities."] = "这个快捷键在施放任何伤害技能的同时开始自动攻击"
L["Start pet attacks"] = "开始宠物攻击"
L["Allow this binding to start pet attacks."] = "这个快捷键将在施放技能同时开始宠物攻击"
L["Override queued spell"] = "覆盖低级法术"
L["Allow this binding to override a spell that is queued by the lag-tolerance system, should be reserved for high-priority spells."] = "这个快捷键将用最高级别法术覆盖低级别相同法术."
L["Target on cast"] = "选定施法目标"
L["Targets the unit you are casting on."] = "自动将施法目标选定为当前目标"
L["Unit Frame Target"] = "单位框架目标"
L["Macro Targets"] = "宏目标"
L["Player (you)"] = "玩家 (你)"
L["Target of target"] = "目标的目标"
L["Mouseover"] = "鼠标指向"
L["Target of mouseover"] = "鼠标指向的目标"
L["Unit frame"] = "单位框架"
L["Cursor"] = "鼠标位置"
L["Pet target"] = "宠物目标"
L["Party %s"] = "小队 %s"
L["Arena %s"] = "区域 %s"
L["<No one>"] = "< 无 >"
L["<Remove this target>"] = "< 移除这个目标 >"
L["Friendly, Hostile"] = "友方, 敌方"
L["Alive, Dead"] = "存活, 死亡"
L["Alive"] = "存活"
L["Never load"] = "永不载入"
L["Talent specialization"] = "限定天赋"
L["Talent selected"] = "天赋选择"
L["PvP talent selected"] = "PvP 天赋选择"
L["War Mode"] = "战争模式"
L["Form"] = "形态"
L["Stance"] = "姿态"
L["Player Name-Realm"] = "玩家名称-服务器"
L["Spell known"] = "已知法术"
L["In group"] = "队伍中"
L["Player in group"] = "玩家在队伍中"
L["War Mode enabled"] = "启用战争模式"
L["War Mode disabled"] = "禁用战争模式"
L["Specialization %s"] = "限定 %s"
L["Talent %s/%s"] = "天赋 %s/%s"
L["Talent %s"] = "天赋 %s"
L["PvP Talent %s"] = "PvP 天赋 %s"
L["Stance %s"] = "姿态 %s"
L["Humanoid Form"] = "人形"
L["In combat"] = "进入战斗"
L["Not in combat"] = "不在战斗"
L["Not in a group"] = "不在队伍"
L["In a party"] = "在小队中"
L["In a raid group"] = "在团队中"
L["In a party or raid group"] = "在小队或团队中"
L["Pet exists"] = "有宠物"
L["No pet"] = "无宠物"
L["Stealth"] = "潜行"
L["In Stealth"] = "潜行状态"
L["Not in Stealth"] = "未潜行"
L["Mounted"] = "骑乘状态"
L["Not mounted"] = "未骑乘"
L["Flying"] = "飞行状态"
L["Not flying"] = "未飞行"
L["Flyable"] = "可飞行"
L["Not flyable"] = "不可飞行"
L["Swimming"] = "游泳状态"
L["Not swimming"] = "未游泳"
L["Outdoors"] = "野外"
L["Indoors"] = "室内"
L["Not channeling"] = "非通道"
L["Primary Specialization"] = "第一专业"
L["Secondary Specialization"] = "第二专业"
L["Instance type"] = "副本类型"
L["No Instance"] = "不在副本"
L["Zone name(s)"] = "区域名称"
L["Semicolon separated, use an exclamation mark (%s) to negate a zone condition, for example:"] = "用分号分隔, 使用感叹号 (%s) 反转区域条件, 例如:"
L["%s will be active if you're not in Oribos"] = "%s 你不在奥利波斯区域时将被激活"
L["%s will be active if you're in Durotar or Orgrimmar"] = "%s 你身处杜隆塔尔或奥格瑞玛区域时将被激活"
L["Durotar"] = "杜隆塔尔"
L["Orgrimmar"] = "奥格瑞玛"
L["Oribos"] = "奥利波斯"
L["Item equipped"] = "已装备物品"
L["This will not update when in combat, so swapping weapons or shields during combat does not work."] = "无法在战斗中更新, 所以无法在战斗中更换武器或盾."
L["Scenario"] = "场景"
L["Dungeon"] = "副本"
L["Raid"] = "团队"
L["On"] = "开"
L["Single"] = "单选"
L["Multiple"] = "多选"
L["Not loaded"] = "未读取"
L["Generated hovercast macro"] = "生成鼠标指向宏"
L["Generated macro"] = "生成宏"
L["Unit frame macro"] = "单位框架宏"
L["%d related binding(s)"] = "%d 相关绑定"
L["Profiles"] = "配置文件"
L["Frame Blacklist"] = "框架黑名单"
L["If you are using custom unit frames you may have to adjust a setting within the unit frame configuration panel to enable support for this, and potentially even a UI reload."] = "如果你正在使用自定义单位框架, 可能需要调整单位框架的相应设置来支持黑名单功能, 甚至可能需要重新加载 UI 界面(即 /rl)."
L["Enable minimap icon"] = "启用迷你地图图标"
L["Enable or disable the minimap icon."] = "启用或禁用迷你地图图标"
L["Show abilities in unit tooltips"] = "在信息提示框中显示技能"
L["If enabled unit tooltips will be augmented to show abilities and keybinds that can be used on the target."] = "启用此功能将加强信息提示框的内容, 以显示所有可以给目标施放的技能和快捷键."
L["Cast on key down rather than key up"] = "点击时施法"
L["This option will make bindings trigger on the 'down' portion of a button press rather than the 'up' portion."] = "在点击时就开始施法, 而不是默认的点击后开始施法."
L["If you want to exclude certain unit frames from click-cast functionality, you can tick the boxes next to each item in order to blacklist them. This will take effect immediately."] = "如果你想在点击施法功能中排除某些单位框架, 可以勾选项目旁的选择框, 这将会使它被列入黑名单, 并立即生效."
L["Selected"] = "选择"
L["Add a unit frame"] = "添加一个单位框架"
L["Blizzard"] = "暴雪"
L["ElvUI"] = "ElvUI"
L["Grid2"] = "Grid2"
L["VuhDo"] = "VuhDo"
L["Gladius"] = "Gladius"
L["Export Bindings"] = "导出快捷键"
L["Import Bindings"] = "导入快捷键"
L["Export Full Profile"] = "导出完整配置文件"
L["Import Full Profile"] = "导入完整配置文件"
L["Exporting bindings from: %s"] = "导出快捷键到: %s"
L["Exporting full profile: %s"] = "导出完整配置文件: %s"
L["Importing bindings into: %s"] = "导入快捷键到: %s"
L["Importing full profile into: %s"] = "导入完整配置文件到: %s"
L["Import external profile data into your current profile, or export the current profile into a sharable format."] = "导入其它配置文件数据到你当前配置文件, 或导出当前配置文件为可共享格式."
L["Immediately share the current profile with another player. The target player must be on the same realm as you (or a connected realm), and allow for profile sharing."] = "立即将当前配置文件共享给其它玩家. 目标玩家必须与你同一服务器 (或已连接的服务器), 并且对方允许共享配置文件."
L["Import"] = "导入"
L["Export"] = "导出"
L["Target player"] = "目标玩家"
L["Share"] = "共享"
L["Allow profile sharing"] = "允许共享配置文件"
L["Sending profile to %s, progress %d/%d (%d%%)"] = "发送配置文件给 %s, 进度 %d/%d (%d%%)"
L["%s has sent you a Clicked profile, do you want to apply it? This will overwrite the current profile."] = "%s 向您发送了一个 Clicked 配置文件, 您要应用它吗? 这将覆盖当前的配置文件."
L["Unable to send a message to %s. Make sure that they are online, have allowed profile sharing, and are on the same realm or a connected realm."] = "无法向 %s 发送消息. 请确认他们在线, 允许配置文件共享, 并且位于同一服务器或已连接的服务器。"
L["Waiting for acknowledgement from %s"] = "正在等待 %s 的确认"
L["Profile import successful, do you want to apply this profile? This will overwrite the current profile."] = "配置文件导入成功, 你要应用此配置文件吗? 这将覆盖当前的配置文件."
L["Bound to %s"] = "绑定到 %s"
L["Abilities"] = "技能"
L["Arena"] = "竞技场"
L["Battleground"] = "战场"
L["Cancel"] = "取消"
L["Channeling"] = "通道魔法"
L["Class"] = "职业"
L["Combat"] = "战斗"
L["Continue"] = "继续"
L["Dead"] = "死亡"
L["Default"] = "默认"
L["Delete"] = "删除"
L["Focus"] = "焦点"
L["Friendly"] = "友方"
L["Hostile"] = "敌方"
L["Macro"] = "宏"
L["New"] = "新建"
L["No"] = "不"
L["None"] = "无"
L["Off"] = "关闭"
L["Other"] = "其它"
L["Target"] = "目标"
L["Pet"] = "宠物"
L["Race"] = "种族"
L["Yes"] = "是"
L["Bind unassigned modifier keys automatically"] = "自动绑定未分配的辅助键"
L["If enabled, modifier key combinations that aren't bound will be bound to the main key, for example, binding 'Q' will also bind 'SHIFT-Q', 'AlT-Q', and 'CTRL-Q'."] = "如果启用，未绑定的辅助键组合将被绑定到主键, 例如: 绑定 Q 也将同时绑定 SHIFT-Q, AlT-Q 和 CTRL-Q"
L["Also bound to:"] = "也必须: "
L["Search Filters"] = "搜索过滤器"
L["Prefix your search with k: to search for a specific key only, for example:"] = "在搜索前加上 k: 即代表只搜索特定的热键, 例如:"
L["k:Q will only show bindings bound to Q"] = "k:Q 即为只显示绑定在 Q 键上的相关设置"
L["k:ALT-A will only show bindings bound to ALT-A"] = "k:ALT-A 则只显示绑定到 ALT-A 的"
L["Nothing"] = "无"
L["Everything"] = "所有"
L["Mixed..."] = "混合..."
L["Invert"] = "反转"



-- 国服一区寒脊山小径联盟TOPCN公会:晨光语风/慢小慢/Jokey 汉化
