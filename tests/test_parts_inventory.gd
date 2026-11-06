extends SceneTree

const Economy = preload("res://scripts/salvage_economy.gd")
const Inventory = preload("res://scripts/parts_inventory.gd")
const Customisation = preload("res://scripts/customisation.gd")

func _initialize() -> void:
    var car: Dictionary = Economy.make_wreck(42)
    var parts: Dictionary = car["parts"]
    assert(not parts.is_empty())
    var category: String = str(parts.keys()[0])
    var initial_value: int = int(parts[category])
    var inventory: Array = []
    assert(Inventory.detach(car, category, inventory))
    assert(not parts.has(category))
    assert(inventory.size() == 1)
    assert(Customisation.selected_choice(car, category) == "None")
    assert(not Inventory.detach(car, category, inventory))
    assert(Inventory.attach(car, inventory, 0))
    assert(inventory.is_empty())
    assert(int(parts[category]) == initial_value)
    assert(not Inventory.attach(car, inventory, 0))
    assert(Inventory.detach(car, category, inventory))
    assert(Inventory.sell(inventory, 0) == initial_value)
    assert(inventory.is_empty())
    assert(Inventory.sell(inventory, 0) == 0)
    print("Detached part inventory checks passed")
    quit(0)
