extends SceneTree

const Economy = preload("res://scripts/salvage_economy.gd")
const Restoration = preload("res://scripts/restoration.gd")

func _initialize() -> void:
    var car: Dictionary = Economy.make_wreck(12345)
    assert(Restoration.restoration_progress(car) == 0)
    assert(Restoration.complete_stage(car, "Bodywork", 0) == 0)
    assert(Restoration.complete_stage(car, "Bodywork", 500) == 180)
    assert(Restoration.complete_stage(car, "Bodywork", 500) == 0)
    assert(Restoration.restoration_progress(car) == 1)
    assert(not Restoration.is_complete(car))
    assert(Restoration.apply_paint(car, "Violet"))
    assert(car["paint"] == "Violet")
    assert(not Restoration.apply_paint(car, "Invalid"))
    for stage in Restoration.STAGES:
        Restoration.complete_stage(car, stage, 10000)
    assert(Restoration.is_complete(car))
    assert(car["restored"])
    assert(Economy.strip_all(car) >= 0)
    assert(Economy.sell_shell(car) > 0)
    print("Restoration and salvage checks passed")
    quit(0)
