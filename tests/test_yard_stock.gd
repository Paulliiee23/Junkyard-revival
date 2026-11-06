extends SceneTree

const Stock = preload("res://scripts/yard_stock.gd")

func _initialize() -> void:
    var stock := {}
    Stock.refresh(stock, 1800)
    assert(stock.size() == 5)
    var entry: Dictionary = stock["0"]
    var initial: Array = entry["cars"]
    assert(initial.size() == 5)
    var first_id: String = str(initial[0]["id"])
    var claimed: Dictionary = Stock.take(stock, 0, 0)
    assert(claimed["id"] == first_id)
    assert(stock["0"]["cars"].size() == 4)
    assert(Stock.take(stock, 0, -1).is_empty())
    Stock.refresh(stock, 1850)
    assert(stock["0"]["cars"].size() == 4)
    Stock.refresh(stock, 3600)
    assert(stock["0"]["cars"].size() == 5)
    assert(stock["0"]["cars"][0]["id"] != first_id)
    assert(Stock.seconds_until_refresh(1800) == 1800)
    assert(Stock.seconds_until_refresh(3599) == 1)
    print("Yard stock refresh and one-time claiming checks passed")
    quit(0)
