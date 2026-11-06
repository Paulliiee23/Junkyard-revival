extends SceneTree

const Buyers = preload("res://scripts/car_buyers.gd")
const Economy = preload("res://scripts/salvage_economy.gd")
const Restoration = preload("res://scripts/restoration.gd")

func _initialize() -> void:
    var car: Dictionary = Economy.make_wreck(73)
    var now := 1800000000
    var offer: Dictionary = Buyers.make_offer(car, now)
    assert(Buyers.valid_offer(car, offer, now))
    assert(not Buyers.valid_offer(car, offer, now + Buyers.OFFER_LIFETIME))
    assert(Buyers.day_bucket(now) == Buyers.day_bucket(now + 10))
    assert(not Buyers.is_ready_for_buyer(car))
    car["paint"] = "Violet"
    assert(not Buyers.valid_offer(car, offer, now))
    for stage in Restoration.STAGES:
        var price: int = Restoration.stage_cost(car, stage)
        assert(Restoration.complete_stage(car, stage, price) == price)
    assert(Restoration.is_complete(car))
    assert(not Buyers.valid_offer(car, offer, now))
    print("Buyer offer validity and expiry checks passed")
    quit(0)
