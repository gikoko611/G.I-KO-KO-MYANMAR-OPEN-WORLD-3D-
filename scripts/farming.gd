extends Reference

var phase = "empty"
var growth_seconds = 0.0
var growth_required = 24.0

func plant(inventory):
    if phase != "empty":
        return "ဒီစပါးခင်းမှာ စပါးစိုက်ထားပြီးပါပြီ။"
    if int(inventory.get("Seed",0)) <= 0:
        return "မျိုးစေ့မရှိပါ။ ဈေးမှာ ဝယ်ယူပါ။"
    inventory["Seed"] = int(inventory["Seed"]) - 1
    phase = "planted"
    growth_seconds = 0.0
    return "စပါးမျိုးစေ့ စိုက်ပြီးပါပြီ။ ရေလောင်းပေးပါ။"

func water(inventory):
    if phase != "planted":
        return "ရေလောင်းရန် စိုက်ထားတဲ့ စပါးခင်းလိုအပ်ပါတယ်။"
    if int(inventory.get("Water",0)) <= 0:
        return "ရေမရှိပါ။ ရေတွင်းကနေ ရေဖြည့်ပါ။"
    inventory["Water"] = int(inventory["Water"]) - 1
    phase = "growing"
    return "စပါးခင်းကို ရေလောင်းပြီးပါပြီ။ ကြီးထွားလာဖို့ စောင့်ပါ။"

func tick(delta):
    if phase == "growing":
        growth_seconds += delta
        if growth_seconds >= growth_required:
            phase = "ready"

func harvest(inventory):
    if phase != "ready":
        return "စပါးမမှည့်သေးပါ။ စိုက်ပြီး ရေလောင်းကာ စောင့်ပေးပါ။"
    inventory["Rice"] = int(inventory.get("Rice",0)) + 4
    phase = "empty"
    growth_seconds = 0.0
    return "စပါး ၄ ထုပ် ရိတ်သိမ်းပြီးပါပြီ။"

func get_status():
    if phase == "empty":
        return "စပါးခင်း: မစိုက်ရသေး"
    if phase == "planted":
        return "စပါးခင်း: မျိုးစေ့စိုက်ပြီး (ရေလောင်းရန်)"
    if phase == "growing":
        return "စပါးခင်း: ကြီးထွားနေဆဲ " + str(int(growth_seconds)) + "/" + str(int(growth_required)) + "s"
    return "စပါးခင်း: ရိတ်သိမ်းရန် အသင့်ဖြစ်ပြီ"
