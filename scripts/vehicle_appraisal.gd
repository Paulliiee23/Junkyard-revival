extends RefCounted
class_name VehicleAppraisal

# Estimates only: resale marketplace and buyers are not implemented.
static func estimate(car: Dictionary) -> Dictionary:
    var parts: Dictionary = car.get("parts", {})
    var parts_total: int = 0
    for value in parts.values():
        parts_total += maxi(1, int(value))
    var shell: int = SalvageEconomy.sell_shell(car)
    var repairs: int = 0
    for stage in Restoration.STAGES:
        repairs += maxi(0, Restoration.stage_cost(car, stage))
    var condition: int = clampi(int(car.get("condition", 30)), 0, 100)
    var rarity: String = str(car.get("rarity", "Common"))
    var rarity_multiplier: float = 1.0
    match rarity:
        "Uncommon": rarity_multiplier = 1.12
        "Rare": rarity_multiplier = 1.35
        "Legendary": rarity_multiplier = 1.75
    # Restored resale assumes a complete car. Missing components reduce the estimate.
    var missing: int = VehicleCondition.missing_parts(car).size()
    var completeness: float = clampf(1.0 - float(missing) * 0.015, 0.55, 1.0)
    var restored_value: int = roundi(float(shell + parts_total + 700) * rarity_multiplier * completeness * (1.0 + float(condition) / 500.0))
    return {
        "shell": shell,
        "parts": parts_total,
        "strip_total": shell + parts_total,
        "remaining_repairs": repairs,
        "restored_resale_estimate": restored_value,
        "estimated_margin": restored_value - repairs,
        "missing_parts": missing
    }
