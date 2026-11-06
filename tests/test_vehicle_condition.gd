extends SceneTree

const Condition = preload("res://scripts/vehicle_condition.gd")
const Economy = preload("res://scripts/salvage_economy.gd")
const Stock = preload("res://scripts/yard_stock.gd")

func _initialize() -> void:
    assert(Condition.rarity_for_roll(0) == "Common")
    assert(Condition.rarity_for_roll(820) == "Uncommon")
    assert(Condition.rarity_for_roll(960) == "Rare")
    assert(Condition.rarity_for_roll(995) == "Legendary")
    var car: Dictionary = Economy.make_wreck(121)
    var rng := RandomNumberGenerator.new()
    rng.seed = 44
    Condition.apply_find(car, rng)
    assert(Condition.RARITIES.has(car["rarity"]))
    assert(int(car["condition"]) >= 0)
    assert(int(car["condition"]) <= 100)
    var missing: Array = Condition.missing_parts(car)
    assert(missing.size() + car["parts"].size() == Economy.PARTS.size())
    var stock: Array = Stock.generate(0, 1800)
    assert(stock.size() == Stock.STOCK_PER_ZONE)
    for wreck in stock:
        assert(wreck.has("rarity"))
        assert(wreck.has("condition"))
        assert(wreck.has("source_zone"))
    print("Vehicle rarity and condition tests passed")
    quit(0)
