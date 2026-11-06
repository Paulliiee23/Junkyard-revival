extends Control
signal tab_requested(index: int)
signal wreck_requested(index: int)
signal page_requested(direction: int)

var live_hud: Label

const ART = preload("res://assets/junkyard_reference.png.png")

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var art := TextureRect.new()
    art.texture = ART
    art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    art.stretch_mode = TextureRect.STRETCH_SCALE
    art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(art)
    live_hud = Label.new()
    live_hud.anchor_left = 0.20
    live_hud.anchor_top = 0.008
    live_hud.anchor_right = 0.73
    live_hud.anchor_bottom = 0.085
    live_hud.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    live_hud.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    live_hud.add_theme_font_size_override("font_size", 21)
    live_hud.add_theme_color_override("font_color", Color("#ffffff"))
    live_hud.add_theme_color_override("font_shadow_color", Color("#000000"))
    live_hud.add_theme_constant_override("shadow_offset_x", 3)
    live_hud.add_theme_constant_override("shadow_offset_y", 3)
    live_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(live_hud)
    var tabs := [0, 1, 2, 3, 4, 5, 9, 6]
    for i in range(tabs.size()):
        var tab_index: int = tabs[i]
        _hit(Rect2(12 + 205 * i, 784, 192, 132), "Open section", func(): tab_requested.emit(tab_index))
    for i in range(3):
        var slot: int = i
        _hit(Rect2(171 + 492 * i, 578, 442, 128), "Claim displayed salvage wreck", func(): wreck_requested.emit(slot))
    _hit(Rect2(0, 420, 92, 110), "Previous wrecks", func(): page_requested.emit(-1))
    _hit(Rect2(1550, 420, 98, 110), "Next wrecks", func(): page_requested.emit(1))
    _hit(Rect2(1530, 5, 105, 86), "Open storage", func(): tab_requested.emit(7))

func _hit(rect: Rect2, hint: String, action: Callable) -> void:
    var button := Button.new()
    button.flat = true
    button.tooltip_text = hint
    button.anchor_left = rect.position.x / 1648.0
    button.anchor_top = rect.position.y / 928.0
    button.anchor_right = rect.end.x / 1648.0
    button.anchor_bottom = rect.end.y / 928.0
    button.pressed.connect(action)
    add_child(button)

func update_hud(player_level: int, player_xp: int, required_xp: int, cash: int) -> void:
    if live_hud != null:
        live_hud.text = "LV %d  |  XP %d/%d  |  $%d" % [player_level, player_xp, required_xp, cash]
