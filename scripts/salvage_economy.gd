extends RefCounted
class_name SalvageEconomy

const CATALOG := [
    {"brand": "Neesan", "model": "Sparrow", "year": 1998, "value": 900},
    {"brand": "Holten", "model": "Comet", "year": 1977, "value": 1200},
    {"brand": "Toyoda", "model": "Sprinter", "year": 1986, "value": 1050},
    {"brand": "Mozdo", "model": "Rotary", "year": 1994, "value": 1350},
    {"brand": "Forge", "model": "Falconer", "year": 1972, "value": 1500},
    {"brand": "Hondo", "model": "Civicus", "year": 2001, "value": 850},
    {"brand": "Subaro", "model": "Rallye", "year": 2003, "value": 1400}
]
const PARTS := [
    "Engine", "Transmission", "Turbo", "NOS", "Suspension", "Brakes", "Exhaust",
    "Front Bumper", "Rear Bumper", "Left Door", "Right Door", "Hood", "Roof",
    "Boot", "Headlights", "Taillights", "Mirrors", "Wheels", "Tyres", "Rims",
    "Spoiler", "Side Skirts", "Widebody Kit", "Racing Kit", "Hood Scoop",
    "Roof Scoop", "Snorkel", "Windows", "Windshield", "Rear Window",
    "Seats", "Steering Wheel", "Gauges", "Audio", "Hydraulics",
    "Neon", "Decals", "Vinyls", "Smoke Effects", "Spinners"
]
const FREE_SHELL_INTERVAL_SECONDS := 1800

static func make_zone_wreck(model_index: int, seed_value: int = 0) -> Dictionary:
    var wreck: Dictionary = make_wreck(seed_value)
    var model: Dictionary = CATALOG[clampi(model_index, 0, CATALOG.size() - 1)]
    wreck["brand"] = model["brand"]
    wreck["model"] = model["model"]
    wreck["year"] = model["year"]
    wreck["shell_value"] = int(model["value"] * 0.2)
    return wreck

static func make_wreck(seed_value: int = 0) -> Dictionary:
    var rng := RandomNumberGenerator.new()
    if seed_value == 0:
        rng.randomize()
    else:
        rng.seed = seed_value
    var model: Dictionary = CATALOG[rng.randi_range(0, CATALOG.size() - 1)]
    var components := {}
    for part in PARTS:
        if rng.randf() > 0.24:
            components[part] = rng.randi_range(12, 120)
    return {
        "id": "%d-%d" % [int(Time.get_unix_time_from_system()), rng.randi()],
        "brand": model["brand"], "model": model["model"], "year": model["year"],
        "shell_value": int(model["value"] * 0.2), "parts": components,
        "restored": false
    }

static func sell_part(car: Dictionary, part: String) -> int:
    var components: Dictionary = car.get("parts", {})
    if not components.has(part):
        return 0
    var payout := maxi(1, int(components[part]))
    components.erase(part)
    return payout

static func strip_all(car: Dictionary) -> int:
    var payout := 0
    var components: Dictionary = car.get("parts", {})
    for part in components.keys():
        payout += sell_part(car, part)
    return payout

static func sell_shell(car: Dictionary) -> int:
    var base_value: int = maxi(1, int(car.get("shell_value", 1)))
    var condition: int = clampi(int(car.get("condition", 30)), 0, 100)
    var multiplier: float = clampf(1.0 + (float(condition) - 30.0) * 0.005, 0.85, 1.35)
    return maxi(1, roundi(float(base_value) * multiplier))

static func display_name(car: Dictionary) -> String:
    return "%s %s (%d)" % [car.get("brand", "?"), car.get("model", "?"), int(car.get("year", 0))]
