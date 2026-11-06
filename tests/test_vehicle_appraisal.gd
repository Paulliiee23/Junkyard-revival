extends SceneTree

const Appraisal = preload("res://scripts/vehicle_appraisal.gd")
const Economy = preload("res://scripts/salvage_economy.gd")
const Restoration = preload("res://scripts/restoration.gd")

func _initialize() -> void:
    var car: Dictionary = Economy.make_wreck(2026)
    car["condition"] = 60
    car["rarity"] = "Common"
    var before: Dictionary = Appraisal.estimate(car)
    assert(before["strip_total"] == before["shell"] + before["parts"])
    assert(before["remaining_repairs"] > 0)
    assert(before["missing_parts"] >= 0)
    var rare: Dictionary = car.duplicate(true)
    rare["rarity"] = "Legendary"
    assert(Appraisal.estimate(rare)["restored_resale_estimate"] > before["restored_resale_estimate"])
    for stage in Restoration.STAGES:
        var cost: int = Restoration.stage_cost(car, stage)
        assert(Restoration.complete_stage(car, stage, cost) == cost)
    var after: Dictionary = Appraisal.estimate(car)
    assert(after["remaining_repairs"] == 0)
    assert(after["strip_total"] == before["strip_total"])
    print("Vehicle appraisal estimate tests passed")
    quit(0)
