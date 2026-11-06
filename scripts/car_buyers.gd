extends RefCounted
class_name CarBuyers

const BUYERS := ["Mara's Motors", "Outback Autos", "Ridgeway Classics", "The Weekend Collector"]

static func make_offer(car: Dictionary, now: int) -> Dictionary:
    var id: String = str(car.get("id", ""))
    if id.is_empty():
        return {}
    var appraisal: Dictionary = VehicleAppraisal.estimate(car)
    var seed_value: int = int(hash(id + ":" + str(floori(float(now) / 86400.0))))
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value
    var buyer: String = BUYERS[rng.randi_range(0, BUYERS.size() - 1)]
    var factor: float = rng.randf_range(0.86, 1.14)
    var estimate: int = int(appraisal["restored_resale_estimate"])
    var offer: int = maxi(1, roundi(float(estimate) * factor))
    return {"car_id": id, "buyer": buyer, "amount": offer, "created_at": now}

static func valid_offer(car: Dictionary, offer: Dictionary) -> bool:
    return not offer.is_empty() and str(offer.get("car_id", "")) == str(car.get("id", "")) and int(offer.get("amount", 0)) > 0

static func is_ready_for_buyer(car: Dictionary) -> bool:
    return Restoration.is_complete(car) and Customisation.is_driveable(car)
