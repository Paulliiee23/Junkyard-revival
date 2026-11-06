extends RefCounted
class_name WorkshopBays

const BAY_COUNT := 3

static func normalise(assignments: Array, cars: Array) -> Array:
    var valid_ids := {}
    for car in cars:
        valid_ids[str(car.get("id", ""))] = true
    var result := ["", "", ""]
    var used := {}
    for i in range(mini(BAY_COUNT, assignments.size())):
        var id := str(assignments[i])
        if not id.is_empty() and valid_ids.has(id) and not used.has(id):
            result[i] = id
            used[id] = true
    return result

static func assign(assignments: Array, cars: Array, bay: int, car_id: String) -> Array:
    var result := normalise(assignments, cars)
    if bay < 0 or bay >= BAY_COUNT:
        return result
    var found := false
    for car in cars:
        if str(car.get("id", "")) == car_id and not car_id.is_empty():
            found = true
            break
    if not found:
        return result
    for i in range(BAY_COUNT):
        if result[i] == car_id:
            result[i] = ""
    result[bay] = car_id
    return result

static func clear(assignments: Array, bay: int) -> Array:
    var result := assignments.duplicate()
    if bay >= 0 and bay < mini(BAY_COUNT, result.size()):
        result[bay] = ""
    return result

static func find_index(cars: Array, car_id: String) -> int:
    for i in range(cars.size()):
        if str(cars[i].get("id", "")) == car_id and not car_id.is_empty():
            return i
    return -1
