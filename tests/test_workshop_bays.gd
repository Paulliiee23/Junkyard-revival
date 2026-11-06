extends SceneTree

const Bays = preload("res://scripts/workshop_bays.gd")

func _initialize() -> void:
    var cars: Array = [{"id": "alpha"}, {"id": "beta"}, {"id": "gamma"}]
    var bays: Array = ["", "", ""]
    bays = Bays.assign(bays, cars, 0, "alpha")
    bays = Bays.assign(bays, cars, 1, "beta")
    assert(bays == ["alpha", "beta", ""])
    bays = Bays.assign(bays, cars, 2, "alpha")
    assert(bays == ["", "beta", "alpha"])
    bays = Bays.assign(bays, cars, 1, "unknown")
    assert(bays == ["", "beta", "alpha"])
    bays = Bays.clear(bays, 1)
    assert(bays == ["", "", "alpha"])
    cars.remove_at(0)
    bays = Bays.normalise(bays, cars)
    assert(bays == ["", "", ""])
    assert(Bays.find_index(cars, "beta") == 0)
    assert(Bays.find_index(cars, "missing") == -1)
    print("Workshop bay assignment tests passed")
    quit(0)
