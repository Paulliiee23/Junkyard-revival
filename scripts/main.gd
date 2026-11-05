extends Control

const TABS := ["Junkyard", "Garage", "Customise", "Upgrades", "Contracts", "Car Show", "Shop", "Storage", "Inspection", "Drag Strip"]
var current_tab := 0
var cash := 5000
var level := 1
var cars: Array[Dictionary] = []
var message := "Welcome to Junkyard Revival"
var content: Label

func _ready() -> void:
    _load_game()
    _build_ui()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#211d1b")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var root := VBoxContainer.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_theme_constant_override("separation", 16)
    add_child(root)

    var header := Label.new()
    header.text = "JUNKYARD REVIVAL  |  LV %d  |  $%d" % [level, cash]
    header.add_theme_font_size_override("font_size", 32)
    root.add_child(header)

    content = Label.new()
    content.text = message
    content.add_theme_font_size_override("font_size", 26)
    content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(content)

    var nav := HFlowContainer.new()
    root.add_child(nav)
    for i in range(TABS.size()):
        var button := Button.new()
        button.text = TABS[i]
        button.pressed.connect(_change_tab.bind(i))
        nav.add_child(button)
    _show_tab()

func _change_tab(index: int) -> void:
    current_tab = index
    _save_game()
    _show_tab()

func _show_tab() -> void:
    if content:
        content.text = "%s\n\n%s\n\nEarly functional scaffold; full game systems and artwork are still in development." % [TABS[current_tab], message]

func _save_game() -> void:
    var file := FileAccess.open("user://junkyard_revival.json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify({"tab": current_tab, "cash": cash, "level": level, "cars": cars}))

func _load_game() -> void:
    if not FileAccess.file_exists("user://junkyard_revival.json"):
        return
    var file := FileAccess.open("user://junkyard_revival.json", FileAccess.READ)
    if file:
        var data = JSON.parse_string(file.get_as_text())
        if data is Dictionary:
            current_tab = clampi(int(data.get("tab", 0)), 0, TABS.size() - 1)
            cash = int(data.get("cash", 5000))
            level = int(data.get("level", 1))
            cars.assign(data.get("cars", []))
