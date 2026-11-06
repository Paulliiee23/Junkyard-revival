extends RefCounted
class_name Restoration

const STAGES := ["Bodywork", "Mechanical", "Paint", "Interior", "Detailing"]
const STAGE_TASKS := {
    "Bodywork": ["Inspect rust", "Remove damaged panels", "Weld and straighten"],
    "Mechanical": ["Diagnose engine", "Service drivetrain", "Test components"],
    "Paint": ["Sand and prepare", "Apply primer", "Spray finish"],
    "Interior": ["Remove worn trim", "Repair upholstery", "Refit cabin"],
    "Detailing": ["Clean exterior", "Polish surfaces", "Final inspection"]
}
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
    # Better-preserved wrecks require less labour; legacy saves retain base cost.
    var condition: int = clampi(int(car.get("condition", 30)), 0, 100)
    var multiplier: float = clampf(1.0 + (30.0 - float(condition)) * 0.006, 0.58, 1.18)
    return maxi(1, roundi(float(STAGE_COSTS[stage]) * multiplier))

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

# Workshop actions are sequential and free to attempt. The stage charge is
# applied only when the final task is completed; no time or energy restrictions.
static func task_progress(car: Dictionary, stage: String) -> int:
    var tasks: Dictionary = car.get("restoration_tasks", {})
    return clampi(int(tasks.get(stage, 0)), 0, STAGE_TASKS.get(stage, []).size())

static func next_task(car: Dictionary, stage: String) -> String:
    if not STAGE_TASKS.has(stage) or stage_cost(car, stage) == 0:
        return ""
    var progress: int = task_progress(car, stage)
    var tasks: Array = STAGE_TASKS[stage]
    return str(tasks[progress]) if progress < tasks.size() else ""

static func perform_task(car: Dictionary, stage: String, available_cash: int) -> int:
    if not STAGE_TASKS.has(stage) or stage_cost(car, stage) <= 0:
        return -1
    var progress: int = task_progress(car, stage)
    var tasks: Array = STAGE_TASKS[stage]
    if progress >= tasks.size():
        return -1
    var final_task: bool = progress == tasks.size() - 1
    var cost: int = stage_cost(car, stage) if final_task else 0
    if available_cash < cost:
        return -1
    if not car.has("restoration_tasks"):
        car["restoration_tasks"] = {}
    var progress_data: Dictionary = car["restoration_tasks"]
    progress_data[stage] = progress + 1
    if final_task:
        var paid: int = complete_stage(car, stage, available_cash)
        if paid != cost:
            progress_data[stage] = progress
            return -1
    return cost
