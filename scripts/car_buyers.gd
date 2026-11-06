extends RefCounted
class_name CarBuyers

const BUYERS := ["Mara's Motors", "Outback Autos", "Ridgeway Classics", "The Weekend Collector"]

const OFFER_LIFETIME := 86400

static func vehicle_signature(car: Dictionary) -> String:
    # Stable across JSON save/load; changing fitted parts, finish or restoration invalidates an offer.
    var parts: Dictionary = car.get("parts", {})
    var part_names: Array = parts.keys()
    part_names.sort()
    var part_data: Array = []
    for part in part_names:
        part_data.append("%s:%s" % [part, str(parts[part])])
    var choices: Dictionary = car.get("customisation", {})
    var choice_names: Array = choices.keys()
    choice_names.sort()
    var choice_data: Array = []
    for name in choice_names:
        choice_data.append("%s:%s" % [name, str(choices[name])])
    return "|".join(part_data) + "#" + "|".join(choice_data) + "#" + str(car.get("paint", "Rust"))

static func day_bucket(now: int) -> int:
    return floori(float(maxi(0, now)) / 86400.0)

static func make_offer(car: Dictionary, now: int) -> Dictionary:
    var id: String = str(car.get("id", ""))
    if id.is_empty():
        return {}
    var appraisal: Dictionary = VehicleAppraisal.estimate(car)
    var seed_value: int = int(hash(id + ":" + str(day_bucket(now))))
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value
    var buyer: String = BUYERS[rng.randi_range(0, BUYERS.size() - 1)]
    var factor: float = rng.randf_range(0.86, 1.14)
    var estimate: int = int(appraisal["restored_resale_estimate"])
    var offer: int = maxi(1, roundi(float(estimate) * factor))
    return {"car_id": id, "buyer": buyer, "amount": offer, "created_at": now, "signature": vehicle_signature(car)}

static func valid_offer(car: Dictionary, offer: Dictionary, now: int = -1) -> bool:
    if offer.is_empty() or str(offer.get("car_id", "")) != str(car.get("id", "")):
        return false
    if int(offer.get("amount", 0)) <= 0 or str(offer.get("signature", "")) != vehicle_signature(car):
        return false
    if now >= 0:
        var age: int = now - int(offer.get("created_at", 0))
        if age < 0 or age >= OFFER_LIFETIME:
            return false
    return true

static func is_ready_for_buyer(car: Dictionary) -> bool:
    return Restoration.is_complete(car) and Customisation.is_driveable(car)
