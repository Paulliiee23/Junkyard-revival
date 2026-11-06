extends SceneTree

const Economy = preload("res://scripts/salvage_economy.gd")
const Restoration = preload("res://scripts/restoration.gd")

func _initialize() -> void:
    var car: Dictionary = Economy.make_wreck(9876)
    assert(Restoration.next_task(car, "Bodywork") == "Inspect rust")
    assert(Restoration.perform_task(car, "Bodywork", 0) == 0)
    assert(Restoration.task_progress(car, "Bodywork") == 1)
    assert(Restoration.perform_task(car, "Bodywork", 0) == 0)
    assert(Restoration.perform_task(car, "Bodywork", 0) == -1)
    assert(Restoration.task_progress(car, "Bodywork") == 2)
    assert(Restoration.perform_task(car, "Bodywork", 180) == 180)
    assert(Restoration.task_progress(car, "Bodywork") == 3)
    assert(Restoration.stage_cost(car, "Bodywork") == 0)
    assert(Restoration.perform_task(car, "Bodywork", 500) == -1)
    assert(Restoration.next_task(car, "Bodywork") == "")
    for stage in Restoration.STAGES:
        if stage == "Bodywork":
            continue
        for task in range(3):
            assert(Restoration.perform_task(car, stage, 10000) >= 0)
    assert(Restoration.is_complete(car))
    assert(car.get("restored", false))
    print("Interactive restoration tests passed")
    quit(0)
