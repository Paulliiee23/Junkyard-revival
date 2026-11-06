extends RefCounted
class_name Customisation

const ESSENTIAL_PARTS := ["Engine", "Transmission", "Brakes", "Wheels", "Tyres"]
const CHOICES := {
    "Spoiler": ["None", "Factory", "Street", "Racing Wing", "Custom"],
    "Hood Scoop": ["None", "Factory", "Street", "Performance"],
    "Roof Scoop": ["None", "Factory", "Rally"],
    "Widebody Kit": ["None", "Street", "Racing"],
    "Racing Kit": ["None", "Circuit", "Drag"],
    "Neon": ["None", "Purple", "Lime", "Blue", "Red"],
    "Decals": ["None", "Stripes", "Number", "Graphics"],
    "Vinyls": ["None", "Classic", "Custom"],
    "Spinners": ["None", "Chrome", "Gold"],
    "Snorkel": ["None", "Off-road"],
    "Smoke Effects": ["None", "White", "Purple"],
    "Engine": ["None", "Stock", "Sports", "Racing"],
    "Wheels": ["None", "Stock", "Sports", "Racing"],
    "Tyres": ["None", "Road", "Drag", "Rally"],
    "Brakes": ["None", "Stock", "Sports", "Racing"]
}

static func choices_for(part: String) -> Array:
    if CHOICES.has(part):
        return CHOICES[part].duplicate()
    return ["None", "Factory", "Custom"]

static func set_choice(car: Dictionary, part: String, choice: String) -> bool:
    if not choices_for(part).has(choice):
        return false
    if not car.has("customisation"):
        car["customisation"] = {}
    var selected: Dictionary = car["customisation"]
    selected[part] = choice
    return true

static func selected_choice(car: Dictionary, part: String) -> String:
    var selected: Dictionary = car.get("customisation", {})
    return str(selected.get(part, "Factory" if car.get("parts", {}).has(part) else "None"))

static func is_driveable(car: Dictionary) -> bool:
    var parts: Dictionary = car.get("parts", {})
    for part in ESSENTIAL_PARTS:
        if not parts.has(part) or selected_choice(car, part) == "None":
            return false
    return true
