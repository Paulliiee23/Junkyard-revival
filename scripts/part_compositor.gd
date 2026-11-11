extends Control
## Prototype 2D part compositor. All coordinates are normalised to the car preview.
## These generic anchors are NOT approved vehicle-specific fitment.
const CATALOGUE := "res://assets/parts_catalogue.json"
const DRAW_ORDER := ["rear_bumper", "wheel", "front_bumper", "hood", "roof_scoop", "spoiler", "exhaust"]
const ANCHORS := {
    "front_bumper": Rect2(0.02, 0.55, 0.28, 0.27),
    "rear_bumper": Rect2(0.77, 0.55, 0.21, 0.25),
    "spoiler": Rect2(0.75, 0.20, 0.22, 0.20),
    "hood": Rect2(0.08, 0.33, 0.31, 0.16),
    "wheel": Rect2(0.16, 0.64, 0.18, 0.27),
    "exhaust": Rect2(0.81, 0.78, 0.16, 0.13),
    "roof_scoop": Rect2(0.48, 0.17, 0.16, 0.12)
}
var vehicle: Dictionary = {}
var temporary_category := ""
var temporary_id := ""
var textures: Dictionary = {}

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    var file := FileAccess.open(CATALOGUE, FileAccess.READ)
    if file == null:
        return
    var data: Variant = JSON.parse_string(file.get_as_text())
    if not data is Dictionary:
        return
    for part in data.get("parts", []):
        if not part is Dictionary:
            continue
        var id := str(part.get("id", ""))
        var path := str(part.get("preview", ""))
        if ResourceLoader.exists(path):
            textures[id] = load(path)
    queue_redraw()

func show_vehicle(car: Dictionary, category: String = "", id: String = "") -> void:
    vehicle = car
    temporary_category = category
    temporary_id = id
    queue_redraw()

func _draw() -> void:
    var fitted: Dictionary = vehicle.get("installed_catalogue_parts", {})
    var bounds := get_rect().size
    for category in DRAW_ORDER:
        var id := str(fitted.get(category, ""))
        if category == temporary_category and not temporary_id.is_empty():
            id = temporary_id
        if id.is_empty() or not textures.has(id):
            continue
        var texture: Texture2D = textures[id]
        var anchor: Rect2 = ANCHORS[category]
        var target := Rect2(anchor.position * bounds, anchor.size * bounds)
        if category == "wheel":
            draw_texture_rect(texture, target, false)
            draw_texture_rect(texture, Rect2(Vector2(bounds.x * 0.68, bounds.y * 0.64), target.size), false)
        else:
            draw_texture_rect(texture, target, false)
