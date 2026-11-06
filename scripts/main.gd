extends Control

const Economy = preload("res://scripts/salvage_economy.gd")
const Restoration = preload("res://scripts/restoration.gd")
const Customisation = preload("res://scripts/customisation.gd")
const PartsInventory = preload("res://scripts/parts_inventory.gd")
const VehiclePreviewScript = preload("res://scripts/vehicle_preview.gd")
const TABS := ["Junkyard", "Garage", "Customise", "Upgrades", "Contracts", "Car Show", "Shop", "Storage", "Inspection", "Drag Strip"]
const MAX_STORAGE := 100
var current_tab := 0
var cash := 5000
var level := 1
var cars: Array[Dictionary] = []
var spare_parts: Array = []
var selected_car := 0
var garage_bay := 0
var storage_filter := "All"
var selected_category := "Spoiler"
var status := "Welcome to Junkyard Revival."
var root: VBoxContainer
var header: Label
var body: VBoxContainer

func _ready() -> void:
    _load_game()
    _build_ui()
    _render()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#211d1b")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    root = VBoxContainer.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_theme_constant_override("separation", 12)
    add_child(root)
    header = Label.new()
    header.add_theme_font_size_override("font_size", 30)
    root.add_child(header)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(scroll)
    body = VBoxContainer.new()
    body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 8)
    scroll.add_child(body)
    var nav := HFlowContainer.new()
    root.add_child(nav)
    for i in range(TABS.size()):
        var button := Button.new()
        button.text = TABS[i]
        button.pressed.connect(_change_tab.bind(i))
        nav.add_child(button)

func _label(value: String) -> void:
    var label := Label.new()
    label.text = value
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    body.add_child(label)

func _button(title: String, callback: Callable) -> void:
    var button := Button.new()
    button.text = title
    button.pressed.connect(callback)
    body.add_child(button)

func _render() -> void:
    header.text = "JUNKYARD REVIVAL   |   LV %d   |   $%d   |   %d/%d cars" % [level, cash, cars.size(), MAX_STORAGE]
    for child in body.get_children():
        body.remove_child(child)
        child.queue_free()
    _label(TABS[current_tab].to_upper())
    _label(status)
    match current_tab:
        0:
            _label("Free salvage: claim a wreck, strip it, restore it, or sell everything.")
            _button("Claim free junkyard wreck", _claim_wreck)
        1:
            _render_workshop()
            _render_cars()
        7:
            _label("VEHICLE STORAGE  |  Rust Bucket / Restored Beauty")
            _render_storage()
            _render_spare_parts()
        2, 8:
            _render_cars()
        _:
            _label("This feature is planned and not implemented yet.")

func _render_workshop() -> void:
    _label("WORKSHOP  |  Three restoration bays")
    var bay_row := HBoxContainer.new()
    body.add_child(bay_row)
    for i in range(3):
        var button := Button.new()
        button.text = "BAY %d%s" % [i + 1, "  [ACTIVE]" if garage_bay == i else ""]
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.pressed.connect(_select_bay.bind(i))
        bay_row.add_child(button)
    _label("Choose a vehicle below to inspect, restore, strip, or sell. No penalties.")

func _select_bay(index: int) -> void:
    garage_bay = clampi(index, 0, 2)
    status = "Workshop bay %d selected." % (garage_bay + 1)
    _save_and_render()

func _render_storage() -> void:
    var filter_row := HBoxContainer.new()
    body.add_child(filter_row)
    for filter_name in ["All", "Rust Bucket", "Restored Beauty"]:
        var button := Button.new()
        button.text = filter_name
        button.disabled = storage_filter == filter_name
        button.pressed.connect(_set_storage_filter.bind(filter_name))
        filter_row.add_child(button)
    var matches := 0
    for i in range(cars.size()):
        var car: Dictionary = cars[i]
        var category := "Restored Beauty" if car.get("restored", false) else "Rust Bucket"
        if storage_filter == "All" or storage_filter == category:
            matches += 1
            _button("%s | %s" % [Economy.display_name(car), category], _open_stored_car.bind(i))
    _label("Showing %d of %d vehicles" % [matches, cars.size()])

func _set_storage_filter(filter_name: String) -> void:
    storage_filter = filter_name
    _save_and_render()

func _open_stored_car(index: int) -> void:
    selected_car = index
    current_tab = 1
    status = "Vehicle moved into workshop view."
    _save_and_render()

func _render_cars() -> void:
    if cars.is_empty():
        _label("No vehicles in storage. Claim a free wreck in Junkyard.")
        return
    selected_car = clampi(selected_car, 0, cars.size() - 1)
    for i in range(cars.size()):
        var car: Dictionary = cars[i]
        _button("%s  [%s]" % [Economy.display_name(car), "Restored Beauty" if car.get("restored", false) else "Rust Bucket"], _select_car.bind(i))
    var car: Dictionary = cars[selected_car]
    _label("Selected: %s" % Economy.display_name(car))
    var preview = VehiclePreviewScript.new()
    preview.custom_minimum_size = Vector2(560, 220)
    preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_child(preview)
    preview.set_vehicle(car)
    _label("%d removable parts remaining" % car.get("parts", {}).size())
    if current_tab == 2:
        _label("Remove a part to storage, or select a fitted part style.")
        _label("SELECT A PART STYLE  |  None is always available")
        for part in car.get("parts", {}).keys():
            _button("Detach %s (keep in storage)" % part, _detach_part.bind(part))
        for part in Economy.PARTS:
            var row := HBoxContainer.new()
            body.add_child(row)
            var name_label := Label.new()
            name_label.text = part
            name_label.custom_minimum_size.x = 190
            row.add_child(name_label)
            var selector := OptionButton.new()
            selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            var choices: Array = Customisation.choices_for(part)
            for choice in choices:
                selector.add_item(str(choice))
            var selected_index: int = choices.find(Customisation.selected_choice(car, part))
            selector.select(maxi(0, selected_index))
            selector.item_selected.connect(_choose_part.bind(part))
            row.add_child(selector)
        _label("Driveable: %s" % ("Yes" if Customisation.is_driveable(car) else "No - essential parts missing"))
        _render_spare_parts()
    if current_tab == 8:
        for part in car.get("parts", {}).keys():
            _button("Sell %s  ($%d)" % [part, int(car["parts"][part])], _sell_part.bind(part))
    _button("Strip and sell all remaining parts", _strip_car)
    if current_tab == 1 or current_tab == 2:
        _label("Restoration: %d/%d stages" % [Restoration.restoration_progress(car), Restoration.STAGES.size()])
        for stage in Restoration.STAGES:
            var cost: int = Restoration.stage_cost(car, stage)
            if cost == 0:
                _label("%s: complete" % stage)
            else:
                _button("Restore %s ($%d)" % [stage, cost], _restore_stage.bind(stage))
        _label("Paint finish: %s" % car.get("paint", "Rust"))
        for paint_name in ["Rust", "Crimson", "Midnight", "Ivory", "Violet", "Lime"]:
            _button("Paint: %s" % paint_name, _paint_car.bind(paint_name))
    _button("Sell bare shell and remove vehicle", _sell_shell)

func _render_spare_parts() -> void:
    _label("Spare parts in storage: %d" % spare_parts.size())
    for i in range(spare_parts.size()):
        var item: Dictionary = spare_parts[i]
        _label("%s - %s ($%d)" % [item.get("part", "?"), item.get("variant", "Factory"), int(item.get("value", 0))])
        _button("Sell spare #%d" % (i + 1), _sell_spare.bind(i))
        if not cars.is_empty():
            _button("Fit spare #%d to selected car" % (i + 1), _fit_spare.bind(i))

func _detach_part(part: String) -> void:
    if cars.is_empty():
        return
    if PartsInventory.detach(cars[selected_car], part, spare_parts):
        status = "Removed %s and placed it in storage." % part
    _save_and_render()

func _sell_spare(index: int) -> void:
    var payout: int = PartsInventory.sell(spare_parts, index)
    cash += payout
    status = "Sold stored part for $%d." % payout
    _save_and_render()

func _fit_spare(index: int) -> void:
    if cars.is_empty():
        return
    if PartsInventory.attach(cars[selected_car], spare_parts, index):
        status = "Installed stored part."
    else:
        status = "Cannot fit this part: category already occupied or item unavailable."
    _save_and_render()

func _choose_part(index: int, part: String) -> void:
    if cars.is_empty():
        return
    var car: Dictionary = cars[selected_car]
    var choices: Array = Customisation.choices_for(part)
    if index < 0 or index >= choices.size():
        return
    var next_choice: String = str(choices[index])
    if next_choice == "None":
        if car.get("parts", {}).has(part):
            PartsInventory.detach(car, part, spare_parts)
            status = "Removed %s to storage." % part
        else:
            Customisation.set_choice(car, part, "None")
            status = "%s: None." % part
    elif not car.get("parts", {}).has(part):
        status = "Fit a %s from spare-parts storage first." % part
    else:
        Customisation.set_choice(car, part, next_choice)
        status = "%s set to %s." % [part, next_choice]
    _save_and_render()

func _cycle_part(part: String) -> void:
    if cars.is_empty():
        return
    var car: Dictionary = cars[selected_car]
    var choices: Array = Customisation.choices_for(part)
    var current: String = Customisation.selected_choice(car, part)
    var next_index: int = (choices.find(current) + 1) % choices.size()
    var next_choice: String = str(choices[next_index])
    if next_choice == "None" and car.get("parts", {}).has(part):
        PartsInventory.detach(car, part, spare_parts)
        status = "Removed %s to storage." % part
    elif next_choice != "None" and not car.get("parts", {}).has(part):
        status = "Fit a %s from spare-parts storage first." % part
    else:
        Customisation.set_choice(car, part, next_choice)
        status = "%s set to %s." % [part, next_choice]
    _save_and_render()

func _restore_stage(stage: String) -> void:
    if cars.is_empty():
        return
    var price: int = Restoration.complete_stage(cars[selected_car], stage, cash)
    if price > 0:
        cash -= price
        status = "Completed %s for $%d." % [stage, price]
    else:
        status = "Stage already complete or not enough cash."
    _save_and_render()

func _paint_car(paint_name: String) -> void:
    if cars.is_empty():
        return
    if Restoration.apply_paint(cars[selected_car], paint_name):
        status = "Selected %s paint finish." % paint_name
    _save_and_render()

func _claim_wreck() -> void:
    if cars.size() >= MAX_STORAGE:
        status = "Storage full. Sell a car to make room."
    else:
        var wreck: Dictionary = Economy.make_wreck()
        cars.append(wreck)
        selected_car = cars.size() - 1
        status = "Claimed %s for free!" % Economy.display_name(wreck)
    _save_and_render()

func _select_car(index: int) -> void:
    selected_car = index
    _save_and_render()

func _next_bay() -> void:
    garage_bay = (garage_bay + 1) % 3
    _save_and_render()

func _sell_part(part: String) -> void:
    if cars.is_empty():
        return
    var payout: int = Economy.sell_part(cars[selected_car], part)
    cash += payout
    status = "Sold %s for $%d. No penalties." % [part, payout]
    _save_and_render()

func _strip_car() -> void:
    if cars.is_empty():
        return
    var payout: int = Economy.strip_all(cars[selected_car])
    cash += payout
    status = "Sold remaining parts for $%d." % payout
    _save_and_render()

func _sell_shell() -> void:
    if cars.is_empty():
        return
    var payout: int = Economy.sell_shell(cars[selected_car])
    cash += payout
    cars.remove_at(selected_car)
    selected_car = maxi(0, selected_car - 1)
    status = "Sold shell for $%d. All choices are yours." % payout
    _save_and_render()

func _change_tab(index: int) -> void:
    current_tab = index
    _save_and_render()

func _save_and_render() -> void:
    _save_game()
    _render()

func _save_game() -> void:
    var file := FileAccess.open("user://junkyard_revival.json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify({"tab": current_tab, "cash": cash, "level": level, "cars": cars, "selected": selected_car, "bay": garage_bay, "spare_parts": spare_parts, "storage_filter": storage_filter}))

func _load_game() -> void:
    if not FileAccess.file_exists("user://junkyard_revival.json"):
        return
    var file := FileAccess.open("user://junkyard_revival.json", FileAccess.READ)
    if file == null:
        return
    var data = JSON.parse_string(file.get_as_text())
    if data is Dictionary:
        current_tab = clampi(int(data.get("tab", 0)), 0, TABS.size() - 1)
        cash = int(data.get("cash", 5000))
        level = int(data.get("level", 1))
        selected_car = int(data.get("selected", 0))
        garage_bay = clampi(int(data.get("bay", 0)), 0, 2)
        storage_filter = str(data.get("storage_filter", "All"))
        var saved_spares = data.get("spare_parts", [])
        if saved_spares is Array:
            spare_parts = saved_spares
        var saved_cars = data.get("cars", [])
        if saved_cars is Array:
            for item in saved_cars:
                if item is Dictionary:
                    cars.append(item)
