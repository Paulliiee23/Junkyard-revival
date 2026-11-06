extends Control
signal tab_requested(index: int)
signal wreck_requested(index: int)
signal page_requested(direction: int)

var live_hud: Label
var live_cards: Array[Label] = []

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
    var hud_back := ColorRect.new()
    hud_back.color = Color("#111315")
    hud_back.anchor_left = 0.20
    hud_back.anchor_top = 0.008
    hud_back.anchor_right = 0.73
    hud_back.anchor_bottom = 0.085
    hud_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(hud_back)
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
    _build_live_cards()
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

func _build_live_cards() -> void:
    for i in range(3):
        var panel := PanelContainer.new()
        var x: float = float(174 + i * 493)
        panel.anchor_left = x / 1648.0
        panel.anchor_right = (x + 442.0) / 1648.0
        panel.anchor_top = 577.0 / 928.0
        panel.anchor_bottom = 705.0 / 928.0
        panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
        var style := StyleBoxFlat.new()
        style.bg_color = Color("#101315")
        style.border_color = Color("#cda75d")
        style.set_border_width_all(2)
        style.set_corner_radius_all(13)
        panel.add_theme_stylebox_override("panel", style)
        add_child(panel)
        var label := Label.new()
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        label.add_theme_color_override("font_color", Color("#e9e2d4"))
        label.add_theme_font_size_override("font_size", 19)
        label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        panel.add_child(label)
        live_cards.append(label)

func update_stock(stock: Array, offset: int, zone_name: String) -> void:
    for i in range(live_cards.size()):
        if stock.is_empty():
            live_cards[i].text = "NO WRECKS AVAILABLE\n" + zone_name
        elif i >= stock.size():
            live_cards[i].text = "EMPTY SLOT\nNEXT RESTOCK"
        else:
            var wreck: Dictionary = stock[(offset + i) % stock.size()]
            var name: String = "%s %s (%d)" % [str(wreck.get("brand", "?")), str(wreck.get("model", "?")), int(wreck.get("year", 0))]
            var condition: int = int(wreck.get("condition", 30))
            live_cards[i].text = "%s\n%s  |  %d/100\nCLAIM FREE" % [name, str(wreck.get("rarity", "Common")), condition]
