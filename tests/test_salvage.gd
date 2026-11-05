extends SceneTree

const Economy = preload("res://scripts/salvage_economy.gd")

func _initialize() -> void:
    var car: Dictionary = Economy.make_wreck(12345)
    assert(car.has("parts"))
    assert(car.has("shell_value"))
    assert(Economy.PARTS.size() == 40)
    var initial_count: int = car["parts"].size()
    if initial_count > 0:
        var part: String = str(car["parts"].keys()[0])
        assert(Economy.sell_part(car, part) > 0)
        assert(car["parts"].size() == initial_count - 1)
    assert(Economy.strip_all(car) >= 0)
    assert(car["parts"].is_empty())
    assert(Economy.sell_shell(car) > 0)
    print("Salvage economy checks passed")
    quit(0)
