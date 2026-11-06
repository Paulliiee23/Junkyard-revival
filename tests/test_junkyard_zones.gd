extends SceneTree

const Zones = preload("res://scripts/junkyard_zones.gd")
const Economy = preload("res://scripts/salvage_economy.gd")

func _initialize() -> void:
    assert(Zones.ZONES.size() == 5)
    for i in range(Zones.ZONES.size()):
        var zone: Dictionary = Zones.ZONES[i]
        assert(not Zones.unlocked(i, int(zone["level"]) - 1))
        assert(Zones.unlocked(i, int(zone["level"])))
        var rng := RandomNumberGenerator.new()
        rng.seed = 600 + i
        for j in range(12):
            var index: int = Zones.pick_model_index(i, rng)
            assert(zone["models"].has(index))
            var car: Dictionary = Economy.make_zone_wreck(index, 700 + j)
            assert(car["brand"] == Economy.CATALOG[index]["brand"])
            assert(car["model"] == Economy.CATALOG[index]["model"])
    assert(not Zones.unlocked(-1, 100))
    assert(not Zones.unlocked(5, 100))
    print("Five junkyard zones and model pools passed")
    quit(0)
