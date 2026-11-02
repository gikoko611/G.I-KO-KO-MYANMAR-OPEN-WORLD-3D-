extends Reference
# Lightweight RPG economy and life-progression system for Godot 3.5.2.
var inventory = {}
var coins = 0
var level = 1
var experience = 0
var experience_next = 100
var skill_points = 0
var skills = {"Farming":1,"Hunting":1,"Woodcutting":1,"Fishing":1,"Mining":1,"Crafting":1,"Combat":1}
var properties = {"house":false,"farm":false,"family":false}
var story_stage = 0
var story_choice = "UNDECIDED"
var total_sales = 0
var companion_bond_ready = false

const SELL_PRICES = {
    "Rice":18,"Fruit":12,"Fish":22,"Meat":30,"Hide":20,"Herb":9,"Wood":8,
    "Stone":5,"Fiber":6,"Bamboo":7,"IronOre":14,"IronIngot":42,"Gem":75,
    "Treasure":120,"Arrow":3
}
const BUY_PRICES = {
    "Seed":5,"Water":4,"FishingRod":90,"StoneAxe":65,"StonePickaxe":70,
    "Spear":85,"Arrow":5,"Sword":220,"Armor":260,"Shield":180,
    "HerbalMedicine":35,"Campfire":45
}
const SKILL_NAMES = ["Farming","Hunting","Woodcutting","Fishing","Mining","Crafting","Combat"]

func get_sell_value(item):
    return int(SELL_PRICES.get(str(item), 0))

func sell_item(item, amount=1):
    var key = str(item)
    var price = get_sell_value(key)
    var count = int(inventory.get(key, 0))
    var quantity = min(max(0,int(amount)), count)
    if price <= 0 or quantity <= 0:
        return "ရောင်းရန် " + key + " မရှိပါ။"
    inventory[key] = count - quantity
    var earned = price * quantity
    coins += earned
    total_sales += earned
    grant_xp("Trading", quantity * 4)
    return key + " x" + str(quantity) + " ရောင်းပြီး Gold +" + str(earned)

func sell_bag():
    var earned = 0
    var sold = []
    for key in SELL_PRICES.keys():
        var count = int(inventory.get(key,0))
        if count > 0:
            var value = count * int(SELL_PRICES[key])
            inventory[key] = 0
            earned += value
            sold.append(str(key) + " x" + str(count))
    if earned <= 0:
        return "ရောင်းနိုင်သော ပစ္စည်းမရှိပါ။"
    coins += earned
    total_sales += earned
    grant_xp("Trading", int(earned / 10))
    return "ရောင်းပြီး: " + ", ".join(sold) + " | Gold +" + str(earned)

func buy_item(item, amount=1):
    var key = str(item)
    var price = int(BUY_PRICES.get(key,0))
    var quantity = max(1,int(amount))
    if price <= 0:
        return "ဒီပစ္စည်းကို ဆိုင်မှာ မရောင်းသေးပါ။"
    var total = price * quantity
    if coins < total:
        return "Gold မလုံလောက်ပါ။ လိုအပ်ချက်: " + str(total) + " Gold"
    coins -= total
    inventory[key] = int(inventory.get(key,0)) + quantity
    return key + " x" + str(quantity) + " ဝယ်ယူပြီးပါပြီ။ Gold -" + str(total)

func grant_xp(skill, amount):
    var gained = max(0,int(amount))
    experience += gained
    var key = str(skill)
    if skills.has(key):
        var skill_xp_key = key + "_XP"
        inventory[skill_xp_key] = int(inventory.get(skill_xp_key,0)) + gained
        while int(inventory[skill_xp_key]) >= int(skills[key]) * 60:
            inventory[skill_xp_key] = int(inventory[skill_xp_key]) - int(skills[key]) * 60
            skills[key] = int(skills[key]) + 1
    while experience >= experience_next:
        experience -= experience_next
        level += 1
        skill_points += 1
        experience_next = 100 + (level - 1) * 50
    return gained

func upgrade_skill(skill):
    var key = str(skill)
    if not skills.has(key):
        return "မသိသော Skill ဖြစ်သည်။"
    if skill_points <= 0:
        return "Skill Point မရှိသေးပါ။ XP စု၍ Level တက်ပါ။"
    skills[key] = int(skills[key]) + 1
    skill_points -= 1
    return key + " Skill Level " + str(skills[key]) + " ဖြစ်သွားပါပြီ။"

func get_skill_status():
    var parts = []
    for key in SKILL_NAMES:
        parts.append(key + " Lv." + str(skills[key]))
    return "Level " + str(level) + " | XP " + str(experience) + "/" + str(experience_next) + " | Skill Points " + str(skill_points) + "\n" + " | ".join(parts)

func get_story_text():
    var stories = [
        "CHAPTER 1 — သူစိမ်းခရီးသွား: ဘယ်ကလာမှန်းမသိသော သင်သည် ဘုန်းကြီးကျောင်းတွင် နေရာရခဲ့သည်။ ဘုန်းကြီးကျောင်းကို ကူညီရန် Wood 5 စုပါ။",
        "CHAPTER 2 — ကိုယ့်အားကိုယ်ကိုး: တောထဲမှ Meat 3 ရယူပြီး ရွာသားများကို ကူညီပါ။",
        "CHAPTER 3 — ပထမဆုံးစုငွေ: Gold 300 စုဆောင်းပါ။",
        "CHAPTER 4 — ကိုယ်ပိုင်အိမ်: Gold 400 ဖြင့် အိမ်ဝယ်ပါ။",
        "CHAPTER 5 — ကိုယ်ပိုင်မြေ: Gold 250 ဖြင့် လယ်/ခြံမြေ ဝယ်ပါ။",
        "CHAPTER 6 — ဘဝလမ်းရွေးချယ်ခြင်း: မိသားစုဘဝ သို့မဟုတ် တောရသေ့ဘဝကို ရွေးချယ်ပါ။",
        "CHAPTER 7 — မိသားစုဘဝ: အိမ်နှင့်ခြံပိုင်ဆိုင်ပြီး မိသားစုတည်ဆောက်ရေး Mission စတင်ပါ။",
        "CHAPTER 8 — ရွာ့ဂုဏ်ဆောင်: ကိုယ့်လုပ်ငန်းနှင့် မိသားစုကို တိုးတက်အောင် တည်ဆောက်ပါ။",
        "CHAPTER 9 — တောလမ်းသို့: ရသေ့ထံ သွားပြီး Herb 8 စုပါ။",
        "CHAPTER 10 — တောအုပ်ထဲက အိမ်သစ်: Wood 12၊ Herb 8 နှင့် Gold 300 ဖြင့် တောတွင်းတဲတစ်လုံး တည်ဆောက်ပါ။",
        "CHAPTER 11 — ငြိမ်းချမ်းရာ: တောရေတံခွန်၊ ဂူနှင့် တောလမ်းကို စူးစမ်းပြီး Gem 1 ရှာပါ။",
        "FINAL CHAPTER — ရသေ့ဘဝ: မိတ်ဆွေနှင့်အတူ တောထဲတွင် ရိုးရှင်းငြိမ်းချမ်းစွာ နေထိုင်ပါ။"
    ]
    return stories[clamp(story_stage,0,stories.size()-1)]

func advance_story():
    if story_stage == 0:
        if int(inventory.get("Wood",0)) < 5: return "ဘုန်းကြီးကျောင်းအတွက် Wood 5 လိုအပ်သည်။"
        inventory["Wood"] -= 5
        story_stage = 1
    elif story_stage == 1:
        if int(inventory.get("Meat",0)) < 3: return "ရွာသားများအတွက် Meat 3 လိုအပ်သည်။"
        inventory["Meat"] -= 3
        story_stage = 2
    elif story_stage == 2:
        if coins < 300: return "ပထမဆုံးအိမ်ဝယ်ရန် Gold 300 စုပါ။"
        story_stage = 3
    elif story_stage == 3:
        if coins < 400: return "အိမ်ဝယ်ရန် Gold 400 လိုအပ်သည်။"
        coins -= 400
        properties["house"] = true
        story_stage = 4
    elif story_stage == 4:
        if coins < 250: return "လယ်/ခြံမြေဝယ်ရန် Gold 250 လိုအပ်သည်။"
        coins -= 250
        properties["farm"] = true
        story_stage = 5
    elif story_stage == 5:
        if story_choice == "UNDECIDED":
            return "ဘဝလမ်းရွေးချယ်ပါ။ Family သို့မဟုတ် Hermit ခလုတ်ကို နှိပ်ပါ။"
        if story_choice == "HERMIT":
            return "တောရသေ့လမ်းအတွက် Hermit Story ကို ဆက်လုပ်ပါ။"
        if coins < 500: return "အိမ်ထောင်ရေး Chapter အတွက် Gold 500 စုဆောင်းပါ။"
        story_stage = 6
    elif story_stage == 6:
        if not properties.house or not properties.farm: return "အိမ်နှင့်ခြံပိုင်ဆိုင်မှု ပြည့်စုံရန်လိုသည်။"
        properties["family"] = true
        story_stage = 7
    elif story_stage == 7:
        return "မိသားစုဘဝ Ending ရရှိပြီးပါပြီ။ Hermit ခလုတ်ဖြင့် တောရသေ့လမ်းကိုလည်း ရွေးချယ်နိုင်ပါသည်။"
    elif story_stage == 8:
        if int(inventory.get("Herb",0)) < 8: return "ရသေ့ထံ ပို့ရန် Herb 8 လိုအပ်သည်။"
        inventory["Herb"] -= 8
        story_stage = 9
    elif story_stage == 9:
        if int(inventory.get("Wood",0)) < 12 or int(inventory.get("Herb",0)) < 8 or coins < 300:
            return "တောတွင်းတဲအတွက် Wood 12၊ Herb 8 နှင့် Gold 300 လိုအပ်သည်။"
        inventory["Wood"] -= 12
        inventory["Herb"] -= 8
        coins -= 300
        story_stage = 10
    elif story_stage == 10:
        if int(inventory.get("Gem",0)) < 1: return "ငြိမ်းချမ်းရာကို သင်္ကေတပြုရန် Gem 1 ရှာပါ။"
        if not companion_bond_ready: return "မိတ်ဆွေနှင့် Bond 10 ရောက်အောင် အတူအလုပ်လုပ်ပါ။"
        inventory["Gem"] -= 1
        story_stage = 11
    else:
        return "ရသေ့ဘဝ Final Ending ပြီးဆုံးပါပြီ။ Free Roam ဖြင့် ဆက်လက်ကစားနိုင်ပါသည်။"
    grant_xp("Crafting", 50)
    return "Chapter ပြီးဆုံးပါပြီ။ " + get_story_text()

func choose_hermit_path(bond):
    if story_stage < 5:
        return "အိမ်နှင့်ခြံဝယ်ယူပြီးမှ ဘဝလမ်းရွေးချယ်နိုင်ပါမည်။"
    if story_choice == "HERMIT":
        return "တောရသေ့လမ်းကို ရွေးချယ်ပြီးပါပြီ။ " + get_story_text()
    if coins < 500:
        return "တောတွင်းခရီးအတွက် Gold 500 စုဆောင်းပါ။"
    coins -= 500
    story_choice = "HERMIT"
    story_stage = 8
    companion_bond_ready = int(bond) >= 10
    return "တောရသေ့လမ်းကို ရွေးချယ်လိုက်ပါပြီ။ " + get_story_text()

func choose_family_path():
    if story_stage != 5:
        return "ဒီအချိန်မှာ ဘဝလမ်းရွေးချယ်၍ မရသေးပါ။"
    story_choice = "FAMILY"
    return "မိသားစုဘဝလမ်းကို ရွေးချယ်လိုက်ပါပြီ။ Story ကို ဆက်လုပ်ပါ။"

func save_state():
    return {"level":level,"experience":experience,"experience_next":experience_next,"skill_points":skill_points,"skills":skills,"properties":properties,"story_stage":story_stage,"story_choice":story_choice,"total_sales":total_sales,"companion_bond_ready":companion_bond_ready}

func load_state(data):
    if typeof(data) != TYPE_DICTIONARY: return
    level = max(1,int(data.get("level",1)))
    experience = max(0,int(data.get("experience",0)))
    experience_next = max(100,int(data.get("experience_next",100)))
    skill_points = max(0,int(data.get("skill_points",0)))
    var saved_skills = data.get("skills",{})
    if typeof(saved_skills) == TYPE_DICTIONARY:
        for key in SKILL_NAMES:
            skills[key] = max(1,int(saved_skills.get(key,1)))
    var saved_properties = data.get("properties",{})
    if typeof(saved_properties) == TYPE_DICTIONARY:
        for key in ["house","farm","family"]:
            properties[key] = bool(saved_properties.get(key,false))
    story_stage = clamp(int(data.get("story_stage",0)),0,11)
    story_choice = str(data.get("story_choice","UNDECIDED"))
    if story_choice not in ["UNDECIDED","FAMILY","HERMIT"]:
        story_choice = "UNDECIDED"
    companion_bond_ready = bool(data.get("companion_bond_ready",false))
    total_sales = max(0,int(data.get("total_sales",0)))
