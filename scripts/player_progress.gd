extends RefCounted
class_name PlayerProgress

const XP_PER_LEVEL := 150

static func required_xp(level: int) -> int:
    return XP_PER_LEVEL + maxi(0, level - 1) * 75

static func add_xp(state: Dictionary, amount: int) -> void:
    if amount <= 0:
        return
    var level: int = maxi(1, int(state.get("level", 1)))
    var xp: int = maxi(0, int(state.get("xp", 0))) + amount
    while xp >= required_xp(level):
        xp -= required_xp(level)
        level += 1
    state["level"] = level
    state["xp"] = xp

static func salvage_xp(parts_sold: int) -> int:
    return maxi(0, parts_sold) * 8

static func restoration_xp(stage_completed: bool) -> int:
    return 50 if stage_completed else 12
