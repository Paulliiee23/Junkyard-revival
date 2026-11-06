extends RefCounted
class_name VehicleCondition

const RARITIES := ["Common", "Uncommon", "Rare", "Legendary"]

static func rarity_for_roll(roll: int) -> String:
    var value: int = clampi(roll, 0, 999)
    if value >= 995:
        return "Legendary"
    if value >= 960:
        return "Rare"
    if value >= 820:
        return "Uncommon"
    return "Common"

static func apply_find(car: Dictionary, rng: RandomNumberGenerator) -> void:
    var rarity: String = rarity_for_roll(rng.randi_range(0, 999))
    var condition: int = rng.randi_range(10, 65)
    match rarity:
        "Uncommon":
            condition = rng.randi_range(35, 78)
        "Rare":
            condition = rng.randi_range(55, 90)
        "Legendary":
            condition = rng.randi_range(75, 98)
    car["rarity"] = rarity
    car["condition"] = condition

static func missing_parts(car: Dictionary) -> Array:
    var result: Array = []
    var fitted: Dictionary = car.get("parts", {})
    for part in SalvageEconomy.PARTS:
        if not fitted.has(part):
            result.append(part)
    return result

static func condition_label(car: Dictionary) -> String:
    var rating: int = clampi(int(car.get("condition", 30)), 0, 100)
    if rating >= 85:
        return "Excellent"
    if rating >= 65:
        return "Good"
    if rating >= 40:
        return "Fair"
    if rating >= 20:
        return "Poor"
    return "Wrecked"

static func summary(car: Dictionary) -> String:
    return "%s | %d/100 %s | %d missing parts" % [
        str(car.get("rarity", "Common")),
        int(car.get("condition", 30)),
        condition_label(car),
        missing_parts(car).size()
    ]
