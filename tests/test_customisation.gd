extends SceneTree

const Economy = preload("res://scripts/salvage_economy.gd")
const Customisation = preload("res://scripts/customisation.gd")
const Inventory = preload("res://scripts/parts_inventory.gd")

func _initialize() -> void:
    var car: Dictionary = Economy.make_wreck(1122)
    var inventory: Array = []
    for part in Economy.PARTS:
        assert(Customisation.choices_for(part).has("None"))
        assert(Customisation.set_choice(car, part, "None"))
        assert(Customisation.selected_choice(car, part) == "None")
    assert(not Customisation.is_driveable(car))
    var parts: Dictionary = car["parts"]
    parts["Spoiler"] = 75
    assert(Customisation.set_choice(car, "Spoiler", "Racing Wing"))
    assert(Inventory.detach(car, "Spoiler", inventory))
    assert(Customisation.selected_choice(car, "Spoiler") == "None")
    assert(inventory.size() == 1)
    assert(Inventory.attach(car, inventory, 0))
    assert(Customisation.selected_choice(car, "Spoiler") == "Racing Wing")
    print("None options and detached custom parts passed")
    quit(0)
