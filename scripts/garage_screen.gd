extends Control
## Illustrated garage scene. Upload garage_reference.png to res://assets/garage_reference.png.
signal tab_requested(index: int)
signal bay_requested(index: int)
signal restore_requested
signal customise_requested
signal strip_requested

const IMAGE_PATH := "res://assets/garage_reference.png"
const FALLBACK_PATH := "res://assets/junkyard_reference.png.png"
const DESIGN := Vector2(1670, 941)
var art: TextureRect
var car_labels: Array[Label] = []
var previews: Array[Control] = []
var hud: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    art = TextureRect.new()
    art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    art.stretch_mode = TextureRect.STRETCH_SCALE
    art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var path := IMAGE_PATH if ResourceLoader.exists(IMAGE_PATH) else FALLBACK_PATH
    art.texture = load(path)
    add_child(art)
    for i in range(3):
        var x := 205.0 + float(i) * 470.0
        var preview := Control.new()
        _place(preview, Rect2(x, 377, 370, 200))
        preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(preview)
        previews.append(preview)
        var label := Label.new()
        _place(label, Rect2(x, 563, 370, 38))
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        label.add_theme_font_size_override("font_size", 20)
        label.add_theme_color_override("font_color", Color.WHITE)
        label.add_theme_color_override("font_shadow_color", Color.BLACK)
        label.add_theme_constant_override("shadow_offset_x", 2)
        label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(label)
        car_labels.append(label)
        _hit(Rect2(x, 345, 370, 260), "Select build bay", func(): bay_requested.emit(i))
    _hit(Rect2(207, 619, 350, 95), "Restore active vehicle", func(): restore_requested.emit())
    _hit(Rect2(639, 619, 390, 95), "Customise active vehicle", func(): customise_requested.emit())
    _hit(Rect2(1102, 619, 345, 95), "Strip or sell active vehicle", func(): strip_requested.emit())
    var tabs := [0, 1, 2, 3, 4, 5, 9, 6]
    for i in range(tabs.size()):
        var index: int = tabs[i]
        _hit(Rect2(12 + i * 207, 787, 192, 140), "Open section", func(): tab_requested.emit(index))
    hud = Label.new()
    _place(hud, Rect2(365, 5, 385, 82))
    hud.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hud.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    hud.add_theme_font_size_override("font_size", 18)
    hud.add_theme_color_override("font_color", Color.WHITE)
    hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(hud)

func _place(node: Control, rect: Rect2) -> void:
    node.anchor_left = rect.position.x / DESIGN.x
    node.anchor_top = rect.position.y / DESIGN.y
    node.anchor_right = rect.end.x / DESIGN.x
    node.anchor_bottom = rect.end.y / DESIGN.y

func _hit(rect: Rect2, hint: String, action: Callable) -> void:
    var button := Button.new()
    button.flat = true
    button.tooltip_text = hint
    _place(button, rect)
    button.pressed.connect(action)
    add_child(button)

func update_garage(cars: Array[Dictionary], assignments: Array, active_bay: int, level: int, xp: int, required_xp: int, cash: int) -> void:
    if hud != null:
        hud.text = "Lv. %d    %d / %d XP    $%d" % [level, xp, required_xp, cash]
    for i in range(3):
        for child in previews[i].get_children():
            previews[i].remove_child(child)
            child.queue_free()
        var car_index := -1
        if i < assignments.size():
            car_index = _find_car(cars, str(assignments[i]))
        if car_index == -1:
            car_labels[i].text = "EMPTY BAY %d%s" % [i + 1, "  • SELECTED" if i == active_bay else ""]
            continue
        var car: Dictionary = cars[car_index]
        car_labels[i].text = "%s%s" % [str(car.get("model", "Project car")), "  • SELECTED" if i == active_bay else ""]
        var vehicle = preload("res://scripts/vehicle_preview.gd").new()
        vehicle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        vehicle.mouse_filter = Control.MOUSE_FILTER_IGNORE
        previews[i].add_child(vehicle)
        vehicle.set_vehicle(car)

func _find_car(cars: Array[Dictionary], id: String) -> int:
    if id.is_empty():
        return -1
    for i in range(cars.size()):
        if str(cars[i].get("id", "")) == id:
            return i
    return -1
