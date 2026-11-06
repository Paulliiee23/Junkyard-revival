extends RefCounted
class_name JunkyardZones

const ZONES := [
    {"name": "Scrap Row", "level": 1, "models": [0, 1, 5]},
    {"name": "Industrial Wrecks", "level": 10, "models": [1, 2, 4]},
    {"name": "Import Graveyard", "level": 20, "models": [0, 2, 3, 6]},
    {"name": "Performance Yard", "level": 35, "models": [3, 4, 6]},
    {"name": "Collector's Corner", "level": 50, "models": [1, 3, 4, 6]}
]

static func unlocked(zone_index: int, level: int) -> bool:
    return zone_index >= 0 and zone_index < ZONES.size() and level >= int(ZONES[zone_index]["level"])

static func zone_name(zone_index: int) -> String:
    if zone_index < 0 or zone_index >= ZONES.size():
        return "Unknown"
    return str(ZONES[zone_index]["name"])

static func pick_model_index(zone_index: int, rng: RandomNumberGenerator) -> int:
    if zone_index < 0 or zone_index >= ZONES.size():
        return 0
    var models: Array = ZONES[zone_index]["models"]
    return int(models[rng.randi_range(0, models.size() - 1)])
