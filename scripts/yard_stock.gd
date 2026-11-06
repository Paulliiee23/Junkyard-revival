extends RefCounted
class_name YardStock

const REFRESH_SECONDS := 1800
const STOCK_PER_ZONE := 5

static func generate(zone_index: int, timestamp: int) -> Array:
    var result: Array = []
    var bucket: int = floori(float(maxi(0, timestamp)) / float(REFRESH_SECONDS))
    var rng := RandomNumberGenerator.new()
    rng.seed = int((bucket + 1) * 104729 + (zone_index + 1) * 8191)
    for slot in range(STOCK_PER_ZONE):
        var model_index: int = JunkyardZones.pick_model_index(zone_index, rng)
        var car: Dictionary = SalvageEconomy.make_zone_wreck(model_index, int(rng.randi()))
        car["id"] = "yard-%d-%d-%d" % [zone_index, bucket, slot]
        car["source_zone"] = JunkyardZones.zone_name(zone_index)
        VehicleCondition.apply_find(car, rng)
        result.append(car)
    return result

static func refresh(stock: Dictionary, now: int) -> void:
    var bucket: int = floori(float(maxi(0, now)) / float(REFRESH_SECONDS))
    for zone_index in range(JunkyardZones.ZONES.size()):
        var key: String = str(zone_index)
        var entry: Dictionary = stock.get(key, {})
        if int(entry.get("bucket", -1)) != bucket:
            stock[key] = {"bucket": bucket, "cars": generate(zone_index, now)}

static func take(stock: Dictionary, zone_index: int, slot: int) -> Dictionary:
    var key: String = str(zone_index)
    var entry: Dictionary = stock.get(key, {})
    var available: Array = entry.get("cars", [])
    if slot < 0 or slot >= available.size():
        return {}
    var car: Dictionary = available[slot]
    available.remove_at(slot)
    return car

static func seconds_until_refresh(now: int) -> int:
    return REFRESH_SECONDS - posmod(now, REFRESH_SECONDS)
