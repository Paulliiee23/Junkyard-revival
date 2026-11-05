extends RefCounted
class_name Restoration

const STAGES := ["Bodywork", "Mechanical", "Paint", "Interior", "Detailing"]
const STAGE_COSTS := {"Bodywork": 180, "Mechanical": 260, "Paint": 220, "Interior": 160, "Detailing": 120}

static func ensure_state(car: Dictionary) -> void:
    if not car.has("restoration"):
        car["restoration"] = {}
    if not car.has("paint"):
        car["paint"] = "Rust"

static func stage_cost(car: Dictionary, stage: String) -> int:
    if not STAGE_COSTS.has(stage):
        return -1
    var completed: Dictionary = car.get("restoration", {})
    if completed.get(stage, false):
        return 0
    return int(STAGE_COSTS[stage])

static func complete_stage(car: Dictionary, stage: String, available_cash: int) -> int:
    ensure_state(car)
    var price := stage_cost(car, stage)
    if price <= 0 or available_cash < price:
        return 0
    var completed: Dictionary = car["restoration"]
    completed[stage] = true
    car["restored"] = is_complete(car)
    return price

static func is_complete(car: Dictionary) -> bool:
    var completed: Dictionary = car.get("restoration", {})
    for stage in STAGES:
        if not completed.get(stage, false):
            return false
    return true

static func apply_paint(car: Dictionary, paint_name: String) -> bool:
    if paint_name not in ["Rust", "Crimson", "Midnight", "Ivory", "Violet", "Lime"]:
        return false
    ensure_state(car)
    car["paint"] = paint_name
    return true

static func restoration_progress(car: Dictionary) -> int:
    var completed: Dictionary = car.get("restoration", {})
    var count := 0
    for stage in STAGES:
        if completed.get(stage, false):
            count += 1
    return count
