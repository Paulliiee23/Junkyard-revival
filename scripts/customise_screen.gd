extends Control
## Catalogue UI for the 70-part PNG starter pack.
signal tab_requested(index: int)
signal buy_requested(part_id: String)
const CATALOGUE := "res://assets/parts_catalogue.json"
const CATEGORY := {"front_bumper":"Front Bumper","rear_bumper":"Rear Bumper","spoiler":"Spoiler","hood":"Hood","wheel":"Wheels","exhaust":"Exhaust","roof_scoop":"Roof Scoop"}
var entries: Array = []
var active_category := "front_bumper"
var selected: Dictionary = {}
var owned: Dictionary = {}
var cash := 0
var car: Dictionary = {}
var title_label: Label
var status_label: Label
var part_grid: GridContainer
var detail: Label
var preview: TextureRect
var buy: Button
var car_preview: Control

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var f := FileAccess.open(CATALOGUE, FileAccess.READ)
    if f != null:
        var parsed: Variant = JSON.parse_string(f.get_as_text())
        if parsed is Dictionary:
            entries = parsed.get("parts", [])
    var bg := ColorRect.new()
    bg.color = Color("#17121f")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var outer := VBoxContainer.new()
    outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(outer)
    title_label = Label.new()
    title_label.add_theme_font_size_override("font_size", 25)
    outer.add_child(title_label)
    var middle := HBoxContainer.new()
    middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
    outer.add_child(middle)
    var categories := VBoxContainer.new()
    middle.add_child(categories)
    for key in CATEGORY.keys():
        var b := Button.new()
        b.text = CATEGORY[key]
        b.custom_minimum_size.x = 150
        b.pressed.connect(_choose_category.bind(key))
        categories.add_child(b)
    var scroll := ScrollContainer.new()
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    middle.add_child(scroll)
    part_grid = GridContainer.new()
    part_grid.columns = 3
    scroll.add_child(part_grid)
    var side := VBoxContainer.new()
    side.custom_minimum_size.x = 280
    middle.add_child(side)
    var car_label := Label.new()
    car_label.text = "CURRENT VEHICLE"
    side.add_child(car_label)
    car_preview = preload("res://scripts/vehicle_preview.gd").new()
    car_preview.custom_minimum_size = Vector2(270, 140)
    side.add_child(car_preview)
    preview = TextureRect.new()
    preview.custom_minimum_size = Vector2(260, 145)
    preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    side.add_child(preview)
    detail = Label.new()
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    side.add_child(detail)
    buy = Button.new()
    buy.text = "BUY & INSTALL"
    buy.pressed.connect(_purchase)
    side.add_child(buy)
    status_label = Label.new()
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    side.add_child(status_label)
    var nav := HBoxContainer.new()
    outer.add_child(nav)
    var labels := ["Junkyard","Garage","Customise","Upgrades","Contracts","Car Show","Drag Strip","Shop"]
    var indices := [0,1,2,3,4,5,9,6]
    for i in range(labels.size()):
        var b := Button.new()
        b.text = labels[i]
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        b.pressed.connect(_navigate.bind(indices[i]))
        nav.add_child(b)
    _refresh()

func _navigate(index: int) -> void:
    tab_requested.emit(index)

func _choose_category(value: String) -> void:
    active_category = value
    selected = {}
    _refresh()

func set_shop_state(balance: int, vehicle: Dictionary) -> void:
    cash = balance
    car = vehicle
    owned = vehicle.get("purchased_part_ids", {})
    if car_preview != null:
        car_preview.set_vehicle(car)
    _refresh()

func _refresh() -> void:
    if part_grid == null:
        return
    title_label.text = "JUNKYARD REVIVAL  |  CUSTOMISE  |  $%d" % cash
    for child in part_grid.get_children():
        part_grid.remove_child(child)
        child.queue_free()
    for item in entries:
        if not item is Dictionary or str(item.get("category", "")) != active_category:
            continue
        var tile := Button.new()
        tile.custom_minimum_size = Vector2(150, 112)
        var id := str(item.get("id", ""))
        var label := str(item.get("name", id))
        var price := int(item.get("price", 0))
        tile.text = "%s\n%s" % [label, "OWNED" if owned.has(id) else "$%d" % price]
        tile.icon = _texture_for(item)
        tile.expand_icon = true
        tile.pressed.connect(_select.bind(item))
        part_grid.add_child(tile)
    _show_selection()

func _texture_for(item: Dictionary) -> Texture2D:
    var path := "res://assets/parts_2d/%s.png" % str(item.get("id", ""))
    if ResourceLoader.exists(path):
        return load(path)
    return null

func _select(item: Dictionary) -> void:
    selected = item
    _show_selection()

func _show_selection() -> void:
    if selected.is_empty():
        preview.texture = null
        detail.text = "Select a part to inspect its independent 2D render."
        buy.disabled = true
        return
    var id := str(selected.get("id", ""))
    var price := int(selected.get("price", 0))
    preview.texture = _texture_for(selected)
    detail.text = "%s\n%s\nPrice $%d\n%s" % [str(selected.get("name", "")), CATEGORY.get(active_category, active_category), price, "Owned" if owned.has(id) else "Preview only — no charge"]
    buy.text = "INSTALL OWNED" if owned.has(id) else "BUY & INSTALL"
    buy.disabled = car.is_empty() or (not owned.has(id) and cash < price)
    status_label.text = "3D-derived part render. Precise vehicle fitment and in-car compositing are still in development."

func _purchase() -> void:
    if not selected.is_empty():
        buy_requested.emit(str(selected.get("id", "")))
