extends RefCounted
class_name PartsInventory

# Each detached item is a distinct inventory entry. No arbitrary capacity or fees.
static func detach(car: Dictionary, part: String, inventory: Array) -> bool:
    var installed: Dictionary = car.get("parts", {})
    if not installed.has(part):
        return false
    inventory.append({
        "part": part,
        "variant": str(car.get("customisation", {}).get(part, "Factory")),
        "value": maxi(1, int(installed[part]))
    })
    installed.erase(part)
    var choices: Dictionary = car.get("customisation", {})
    choices[part] = "None"
    car["customisation"] = choices
    return true

static func attach(car: Dictionary, inventory: Array, index: int) -> bool:
    if index < 0 or index >= inventory.size():
        return false
    var item: Dictionary = inventory[index]
    var part: String = str(item.get("part", ""))
    if part.is_empty():
        return false
    var installed: Dictionary = car.get("parts", {})
    if installed.has(part):
        return false
    installed[part] = maxi(1, int(item.get("value", 1)))
    var choices: Dictionary = car.get("customisation", {})
    var variant: String = str(item.get("variant", "Factory"))
    choices[part] = "Factory" if variant == "None" else variant
    car["customisation"] = choices
    inventory.remove_at(index)
    return true

static func sell(inventory: Array, index: int) -> int:
    if index < 0 or index >= inventory.size():
        return 0
    var item: Dictionary = inventory[index]
    var payout: int = maxi(1, int(item.get("value", 1)))
    inventory.remove_at(index)
    return payout
