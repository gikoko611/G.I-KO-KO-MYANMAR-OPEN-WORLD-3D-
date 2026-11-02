extends Reference
# Godot 3.5.2 compatible gameplay systems. No external plugins required.
# This module is intentionally independent so it can be validated before UI integration.

const LANG_MM = "MM"
const LANG_EN = "EN"
const MODE_MISSION = "MISSION"
const MODE_FREE_ROAM = "FREE_ROAM"

var language = LANG_MM
var game_mode = MODE_MISSION
var missions = []
var active_mission = {}
var completed_missions = []
var inventory = {
    "Rice": 3, "Seed": 8, "Water": 2, "Wood": 0, "Stone": 0,
    "Fiber": 0, "Fish": 0, "Meat": 0, "Hide": 0, "Herb": 0,
    "IronOre": 0, "IronIngot": 0, "Bamboo": 0, "Arrow": 0,
    "FishingRod": 0, "StoneAxe": 0, "StonePickaxe": 0, "Spear": 0
}
var coins = 120
var player_health = 100
var player_stamina = 100
var workshop_level = 1
var fishing_level = 1
var hunting_level = 1
var last_message = ""

const MISSION_TYPES = [
    {"key":"talk_elder","mm":"ရွာလူကြီးနှင့် စကားပြောပါ","en":"Talk to the village elder","kind":"talk","target":"elder","base":10},
    {"key":"collect_wood","mm":"သစ်သား စုဆောင်းပါ","en":"Collect wood","kind":"collect","target":"Wood","base":12},
    {"key":"collect_stone","mm":"ကျောက်တုံး စုဆောင်းပါ","en":"Collect stone","kind":"collect","target":"Stone","base":10},
    {"key":"catch_fish","mm":"ငါး ဖမ်းပါ","en":"Catch fish","kind":"collect","target":"Fish","base":15},
    {"key":"hunt_game","mm":"တောကောင် အမဲလိုက်ပါ","en":"Hunt wild game","kind":"collect","target":"Meat","base":18},
    {"key":"craft_tool","mm":"Workshop တွင် ကိရိယာ ပြုလုပ်ပါ","en":"Craft a tool at the workshop","kind":"craft","target":"tool","base":20},
    {"key":"farm_rice","mm":"စပါး စိုက်ပျိုးရိတ်သိမ်းပါ","en":"Grow and harvest rice","kind":"collect","target":"Rice","base":14},
    {"key":"deliver_goods","mm":"ရွာဈေးသို့ ပစ္စည်း ပို့ပါ","en":"Deliver goods to the village market","kind":"deliver","target":"Rice","base":16},
    {"key":"explore_forest","mm":"တောအုပ်ကို စူးစမ်းပါ","en":"Explore the forest","kind":"explore","target":"forest","base":12},
    {"key":"help_villager","mm":"ရွာသားတစ်ဦးကို ကူညီပါ","en":"Help a villager","kind":"talk","target":"villager","base":14},
    {"key":"gather_herbs","mm":"ဆေးဖက်ဝင်အပင် စုဆောင်းပါ","en":"Gather medicinal herbs","kind":"collect","target":"Herb","base":13},
    {"key":"repair_bridge","mm":"တံတား ပြုပြင်ရန် ပစ္စည်း စုပါ","en":"Gather supplies to repair the bridge","kind":"collect","target":"Wood","base":17}
]

const FOREST_MISSION_TYPES = [
        {"key":"forest_meet_hermit","mm":"ရသေ့ထံ သွားရောက်စကားပြောပါ","en":"Visit the forest hermit","kind":"talk","target":"hermit","base":18},
        {"key":"forest_help_lumberjack","mm":"သစ်ခုတ်သူကို သစ်သား ၃ ခု ကူညီပေးပါ","en":"Help the lumberjack collect wood","kind":"collect","target":"Wood","base":22},
        {"key":"forest_collect_bamboo","mm":"ဝါး ၃ ချောင်း စုဆောင်းပါ","en":"Collect 3 bamboo","kind":"collect","target":"Bamboo","base":18},
        {"key":"forest_meet_hunter","mm":"မုဆိုးနှင့် တွေ့ဆုံပါ","en":"Meet the hunter","kind":"talk","target":"hunter","base":18},
        {"key":"forest_herb_for_hermit","mm":"ရသေ့အတွက် ဆေးပင် ၂ ပင် ရှာပါ","en":"Find 2 herbs for the hermit","kind":"collect","target":"Herb","base":24},
        {"key":"forest_repair_hunters_hut","mm":"မုဆိုးစခန်းအတွက် သစ်သား ၄ ခု စုပါ","en":"Gather 4 wood to repair the hunter camp","kind":"collect","target":"Wood","base":24},
        {"key":"forest_find_lost_traveler","mm":"တောတွင်းခရီးသည်ကို ရှာဖွေပါ","en":"Find the lost traveler","kind":"talk","target":"lost_traveler","base":30},
        {"key":"forest_track_deer","mm":"သမင်အကြောင်း သဲလွန်စရှာပါ","en":"Track signs of deer","kind":"explore","target":"forest","base":20},
        {"key":"forest_gather_stones","mm":"တောထဲမှ ကျောက် ၄ တုံး စုပါ","en":"Gather 4 stones in the forest","kind":"collect","target":"Stone","base":20},
        {"key":"forest_help_bamboo_cutter","mm":"ဝါးခုတ်သူကို ကူညီပါ","en":"Help the bamboo cutter","kind":"talk","target":"bamboo_cutter","base":22},
        {"key":"forest_deliver_herbs","mm":"ဆေးပင်များကို ဘုန်းကြီးကျောင်းသို့ ပို့ပါ","en":"Deliver herbs to the monastery","kind":"deliver","target":"Herb","base":26},
        {"key":"forest_monk_supplies","mm":"ဘုန်းကြီးအတွက် သစ်သား ၂ ခု ပို့ပါ","en":"Bring 2 wood to the monk","kind":"deliver","target":"Wood","base":24},
        {"key":"forest_nun_garden","mm":"သီလရှင်ကျောင်းဥယျာဉ်အတွက် ဆေးပင် ၂ ပင် ရှာပါ","en":"Find 2 herbs for the nunnery garden","kind":"collect","target":"Herb","base":24},
        {"key":"forest_forest_firewood","mm":"မီးဖိုအတွက် သစ်သား ၅ ခု စုပါ","en":"Collect 5 firewood for the camp","kind":"collect","target":"Wood","base":26},
        {"key":"forest_boar_hunt","mm":"တောဝက်အမဲလိုက်ပြီး အသားရယူပါ","en":"Hunt a wild boar for meat","kind":"collect","target":"Meat","base":32},
        {"key":"forest_deer_hide","mm":"သားရေ ၂ ခု ရယူပါ","en":"Collect 2 animal hides","kind":"collect","target":"Hide","base":32},
        {"key":"forest_craft_spear","mm":"Workshop တွင် လှံတစ်ချောင်း ပြုလုပ်ပါ","en":"Craft a spear at the workshop","kind":"craft","target":"tool","base":30},
        {"key":"forest_craft_fishing_rod","mm":"ငါးမျှားတံတစ်ချောင်း ပြုလုပ်ပါ","en":"Craft a fishing rod","kind":"craft","target":"tool","base":28},
        {"key":"forest_river_fishing","mm":"မြစ်ထဲမှ ငါး ၃ ကောင် ဖမ်းပါ","en":"Catch 3 fish from the river","kind":"collect","target":"Fish","base":28},
        {"key":"forest_forest_guard","mm":"တောစောင့်နှင့် တွေ့ဆုံပါ","en":"Meet the forest ranger","kind":"talk","target":"forest_guard","base":22},
        {"key":"forest_clear_forest_path","mm":"တောလမ်းအတွက် သစ်သား ၃ ခု စုပါ","en":"Collect 3 wood to clear the forest path","kind":"collect","target":"Wood","base":25},
        {"key":"forest_iron_ore","mm":"သံရိုင်း ၂ ခု ရှာဖွေပါ","en":"Find 2 iron ore","kind":"collect","target":"IronOre","base":34},
        {"key":"forest_campfire","mm":"တောစခန်းအတွက် မီးဖိုတစ်ခု ပြုလုပ်ပါ","en":"Craft a campfire for the forest camp","kind":"craft","target":"tool","base":32},
        {"key":"forest_help_injured_hunter","mm":"ဒဏ်ရာရမုဆိုးကို ကူညီပါ","en":"Help the injured hunter","kind":"talk","target":"hunter","base":30},
        {"key":"forest_wildlife_observation","mm":"တောရိုင်းတိရစ္ဆာန်များကို လေ့လာပါ","en":"Observe wildlife in the forest","kind":"explore","target":"forest","base":22},
        {"key":"forest_gather_fiber","mm":"အမျှင် ၄ ခု စုဆောင်းပါ","en":"Collect 4 fibers","kind":"collect","target":"Fiber","base":22},
        {"key":"forest_church_carpentry","mm":"ဘုရားရှိခိုးကျောင်းအတွက် သစ်သား ၃ ခု ပို့ပါ","en":"Deliver 3 wood to the church","kind":"deliver","target":"Wood","base":28},
        {"key":"forest_meet_pastor","mm":"ခရစ်ယာန်ဓမ္မဆရာနှင့် တွေ့ဆုံပါ","en":"Meet the Christian pastor","kind":"talk","target":"pastor","base":22},
        {"key":"forest_bridge_materials","mm":"တောတံတားပြုပြင်ရန် ဝါး ၃ ချောင်း ပို့ပါ","en":"Deliver 3 bamboo for the forest bridge","kind":"deliver","target":"Bamboo","base":30},
        {"key":"forest_hermit_medicine","mm":"ရသေ့အတွက် ဆေးပင် ၃ ပင် စုပါ","en":"Gather 3 medicinal herbs for the hermit","kind":"collect","target":"Herb","base":35}
]

const RECIPES = {
    "StoneAxe":{"Wood":2,"Stone":3},
    "StonePickaxe":{"Wood":2,"Stone":4},
    "Spear":{"Wood":2,"Stone":2,"Fiber":1},
    "FishingRod":{"Wood":2,"Fiber":3,"Bamboo":1},
    "Arrow":{"Wood":1,"Stone":1,"Fiber":1},
    "Campfire":{"Wood":4,"Stone":3},
    "HerbalMedicine":{"Herb":3,"Fiber":1},
    "IronIngot":{"IronOre":3,"Wood":2}
}

func _init():
    _generate_missions()

func set_language(value):
    language = LANG_EN if str(value).to_upper() == LANG_EN else LANG_MM
    return language

func set_mode(value):
    game_mode = MODE_FREE_ROAM if str(value).to_upper() == MODE_FREE_ROAM else MODE_MISSION
    if game_mode == MODE_FREE_ROAM:
        active_mission = {}
    return game_mode

func _generate_missions():
    missions.clear()
    var id = 1
    for tier in range(10):
        for template in MISSION_TYPES:
            var amount = int(1 + tier * 0.65)
            var mission = {
                "id": id,
                "key": str(template.key) + "_" + str(tier + 1),
                "title_mm": str(template.mm) + " (" + str(tier + 1) + ")",
                "title_en": str(template.en) + " (" + str(tier + 1) + ")",
                "kind": template.kind,
                "target": template.target,
                "required": amount,
                "progress": 0,
                "reward": int(template.base) + tier * 8,
                "tier": tier + 1,
                "completed": false
            }
            missions.append(mission)
            id += 1
    for template in FOREST_MISSION_TYPES:
        var forest_mission = {
            "id": id,
            "key": str(template.key),
            "title_mm": str(template.mm),
            "title_en": str(template.en),
            "kind": template.kind,
            "target": template.target,
            "required": 1 if str(template.kind) == "talk" or str(template.kind) == "explore" or str(template.kind) == "craft" else (3 if str(template.target) in ["Wood","Bamboo","Herb","Fish","Stone","Fiber"] else 1),
            "progress": 0,
            "reward": int(template.base),
            "tier": 11,
            "completed": false
        }
        missions.append(forest_mission)
        id += 1

func get_mission_count():
    return missions.size()

func get_mission_board():
    var board = []
    for mission in missions:
        if not mission.completed:
            board.append(_mission_text(mission))
    return board

func _mission_text(mission):
    var title = mission.title_en if language == LANG_EN else mission.title_mm
    return "#" + str(mission.id) + " " + title + " [" + str(mission.progress) + "/" + str(mission.required) + "]"

func accept_mission(mission_id):
    if game_mode == MODE_FREE_ROAM:
        return _say("Free Roam Mode တွင် Mission မလိုအပ်ပါ။", "Mission is optional in Free Roam Mode.")
    for mission in missions:
        if int(mission.id) == int(mission_id) and not mission.completed:
            active_mission = mission
            return _say("တာဝန် လက်ခံပြီးပါပြီ: " + mission.title_mm, "Mission accepted: " + mission.title_en)
    return _say("Mission မတွေ့ပါ။", "Mission not found.")

func record_event(event_kind, target, amount = 1):
    if game_mode == MODE_FREE_ROAM or active_mission.empty():
        return false
    if str(active_mission.kind) != str(event_kind) or str(active_mission.target) != str(target):
        return false
    active_mission.progress = min(int(active_mission.required), int(active_mission.progress) + int(amount))
    if active_mission.progress >= active_mission.required:
        active_mission.completed = true
        coins += int(active_mission.reward)
        completed_missions.append(int(active_mission.id))
        last_message = _say("တာဝန်ပြီးမြောက်ပါပြီ။ ဆုကြေး Coins +" + str(active_mission.reward), "Mission complete. Reward: +" + str(active_mission.reward) + " coins")
        active_mission = {}
    return true

func _say(mm, en):
    last_message = en if language == LANG_EN else mm
    return last_message

func fish_at_river(has_rod):
    if not has_rod and int(inventory.get("FishingRod", 0)) <= 0:
        return _say("ငါးမျှားတံ လိုအပ်ပါတယ်။ Workshop မှာ ပြုလုပ်ပါ။", "You need a fishing rod. Craft one at the workshop.")
    if player_stamina < 5:
        return _say("အားအင် မလုံလောက်ပါ။", "Not enough stamina.")
    player_stamina -= 5
    var chance = min(0.88, 0.42 + fishing_level * 0.06)
    if randf() <= chance:
        var amount = 1 if randf() < 0.8 else 2
        inventory["Fish"] = int(inventory.get("Fish", 0)) + amount
        fishing_level += 1
        record_event("collect", "Fish", amount)
        return _say("ငါး " + str(amount) + " ကောင် ရရှိပါပြီ။", "Caught " + str(amount) + " fish.")
    return _say("ငါး မမိသေးပါ။ ထပ်ကြိုးစားပါ။", "No bite yet. Try again.")

func hunt_animal(animal_name, has_weapon):
    if not has_weapon and int(inventory.get("Spear", 0)) <= 0 and int(inventory.get("Arrow", 0)) <= 0:
        return _say("အမဲလိုက်ရန် လှံ သို့မဟုတ် မြား လိုအပ်ပါတယ်။", "You need a spear or arrows to hunt.")
    if player_stamina < 12:
        return _say("အားအင် မလုံလောက်ပါ။ အနားယူပါ။", "You are exhausted. Rest first.")
    player_stamina -= 12
    var danger = 8
    if str(animal_name) == "Boar":
        danger = 22
    elif str(animal_name) == "Tiger":
        danger = 38
    elif str(animal_name) == "Deer":
        danger = 12
    var weapon_bonus = 0.18 if int(inventory.get("Spear", 0)) > 0 else 0.08
    var success = randf() < min(0.82, 0.55 + hunting_level * 0.025 + weapon_bonus)
    if success:
        var meat = 2 if str(animal_name) == "Boar" else 1
        inventory["Meat"] = int(inventory.get("Meat", 0)) + meat
        inventory["Hide"] = int(inventory.get("Hide", 0)) + 1
        record_event("collect", "Hide", 1)
        hunting_level += 1
        record_event("collect", "Meat", meat)
        return _say("အမဲလိုက်မှု အောင်မြင်ပါပြီ။ အသား " + str(meat) + "၊ သားရေ ၁ ရရှိပါပြီ။", "Hunt successful. Gained " + str(meat) + " meat and 1 hide.")
    player_health = max(1, player_health - danger)
    return _say("တောကောင်က ပြန်တိုက်ခိုက်ခဲ့ပါတယ်။ Health -" + str(danger), "The wild animal fought back. Health -" + str(danger))

func craft(item_name):
    if not RECIPES.has(item_name):
        return _say("ဒီပစ္စည်းအတွက် Recipe မရှိပါ။", "No recipe found for this item.")
    var recipe = RECIPES[item_name]
    for material in recipe.keys():
        if int(inventory.get(material, 0)) < int(recipe[material]):
            return _say("ပစ္စည်း မလုံလောက်ပါ: " + str(material), "Missing material: " + str(material))
    for material in recipe.keys():
        inventory[material] = int(inventory.get(material, 0)) - int(recipe[material])
    inventory[item_name] = int(inventory.get(item_name, 0)) + 1
    workshop_level += 1
    record_event("craft", "tool", 1)
    return _say(item_name + " ပြုလုပ်ပြီးပါပြီ။", "Crafted " + item_name + ".")

func sell(item_name, unit_price):
    var count = int(inventory.get(item_name, 0))
    if count <= 0:
        return _say("ရောင်းရန် ပစ္စည်းမရှိပါ။", "Nothing to sell.")
    inventory[item_name] = count - 1
    coins += int(unit_price)
    record_event("deliver", item_name, 1)
    return _say(item_name + " ရောင်းပြီး Coins +" + str(unit_price), "Sold " + item_name + " for +" + str(unit_price) + " coins.")

func rest():
    player_health = min(100, player_health + 25)
    player_stamina = min(100, player_stamina + 45)
    return _say("အနားယူပြီး Health နဲ့ Stamina ပြန်ပြည့်လာပါပြီ။", "Rested. Health and stamina restored.")

func get_status():
    return {
        "mode": game_mode,
        "language": language,
        "mission_count": missions.size(),
        "completed_count": completed_missions.size(),
        "coins": coins,
        "health": player_health,
        "stamina": player_stamina,
        "workshop_level": workshop_level,
        "inventory": inventory
    }

func save_state():
    return {
        "language": language, "game_mode": game_mode, "inventory": inventory,
        "coins": coins, "player_health": player_health, "player_stamina": player_stamina,
        "workshop_level": workshop_level, "fishing_level": fishing_level,
        "hunting_level": hunting_level, "completed_missions": completed_missions,
        "active_mission_id": int(active_mission.get("id", 0))
    }

func load_state(data):
    if typeof(data) != TYPE_DICTIONARY:
        return
    set_language(data.get("language", LANG_MM))
    set_mode(data.get("game_mode", MODE_MISSION))
    var saved_inventory = data.get("inventory", {})
    if typeof(saved_inventory) == TYPE_DICTIONARY:
        for key in saved_inventory.keys():
            inventory[key] = max(0, int(saved_inventory[key]))
    coins = max(0, int(data.get("coins", coins)))
    player_health = clamp(int(data.get("player_health", 100)), 1, 100)
    player_stamina = clamp(int(data.get("player_stamina", 100)), 0, 100)
    workshop_level = max(1, int(data.get("workshop_level", 1)))
    fishing_level = max(1, int(data.get("fishing_level", 1)))
    hunting_level = max(1, int(data.get("hunting_level", 1)))
    completed_missions = data.get("completed_missions", [])
    active_mission = {}
    var active_id = int(data.get("active_mission_id", 0))
    if active_id > 0:
        accept_mission(active_id)
