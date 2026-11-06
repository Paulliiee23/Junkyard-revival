extends Control

const Economy = preload("res://scripts/salvage_economy.gd")
const Restoration = preload("res://scripts/restoration.gd")
const Customisation = preload("res://scripts/customisation.gd")
const PartsInventory = preload("res://scripts/parts_inventory.gd")
const VehiclePreviewScript = preload("res://scripts/vehicle_preview.gd")
const WorkshopBays = preload("res://scripts/workshop_bays.gd")
const PlayerProgress = preload("res://scripts/player_progress.gd")
const JunkyardZones = preload("res://scripts/junkyard_zones.gd")
const YardStock = preload("res://scripts/yard_stock.gd")
const VehicleCondition = preload("res://scripts/vehicle_condition.gd")
const VehicleAppraisal = preload("res://scripts/vehicle_appraisal.gd")
const CarBuyers = preload("res://scripts/car_buyers.gd")
const TABS := ["Junkyard", "Garage", "Customise", "Upgrades", "Contracts", "Car Show", "Shop", "Storage", "Inspection", "Drag Strip"]
const MAX_STORAGE := 100
var current_tab := 0
var selected_zone := 0
var yard_stock: Dictionary = {}
var buyer_offers: Dictionary = {}
var sold_cars := 0
var cash := 5000
var level := 1
var xp := 0
var cars: Array[Dictionary] = []
var spare_parts: Array = []
var selected_car := 0
var garage_bay := 0
var bay_assignments: Array = ["", "", ""]
var storage_filter := "All"
var selected_category := "Spoiler"
var status := "Welcome to Junkyard Revival."
var root: VBoxContainer
var header: Label
var body: VBoxContainer

func _ready() -> void:
    _load_game()
    YardStock.refresh(yard_stock, int(Time.get_unix_time_from_system()))
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
    root.offset_left = 20.0
    root.offset_top = 12.0
    root.offset_right = -20.0
    root.offset_bottom = -12.0
    add_child(root)
    header = Label.new()
    header.add_theme_font_size_override("font_size", 28)
    header.add_theme_color_override("font_color", Color("#e9c98b"))
    root.add_child(header)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(scroll)
    body = VBoxContainer.new()
    body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 10)
    scroll.add_child(body)
    var nav := HFlowContainer.new()
    root.add_child(nav)
    for i in range(TABS.size()):
        var button := Button.new()
        button.text = TABS[i]
        button.custom_minimum_size = Vector2(110, 46)
        button.pressed.connect(_change_tab.bind(i))
        nav.add_child(button)

func _label(value: String) -> void:
    var label := Label.new()
    label.text = value
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_color_override("font_color", Color("#e8dfd3"))
    body.add_child(label)

func _button(title: String, callback: Callable) -> void:
    var button := Button.new()
    button.text = title
    button.custom_minimum_size.y = 42
    button.pressed.connect(callback)
    body.add_child(button)

func _render() -> void:
    header.text = "JUNKYARD REVIVAL | LV %d (%d/%d XP) | $%d | %d/%d cars" % [level, xp, PlayerProgress.required_xp(level), cash, cars.size(), MAX_STORAGE]
    for child in body.get_children():
        body.remove_child(child)
        child.queue_free()
    _label("────────────────  %s  ────────────────" % TABS[current_tab].to_upper())
    _label(status)
    if current_tab == 7 and cars.is_empty():
        _label("No vehicles in storage yet. Spare parts can still be managed below.")
    match current_tab:
        0:
            _render_junkyard()
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

func _render_junkyard() -> void:
    _label("FIVE SALVAGE ZONES | Free common wrecks | No stamina limits")
    for i in range(JunkyardZones.ZONES.size()):
        var zone: Dictionary = JunkyardZones.ZONES[i]
        var unlocked: bool = JunkyardZones.unlocked(i, level)
        var button := Button.new()
        button.text = "%s%s | LV %d%s" % [
            "▶ " if selected_zone == i else "",
            str(zone["name"]),
            int(zone["level"]),
            "" if unlocked else "  [LOCKED]"
        ]
        button.disabled = not unlocked
        button.pressed.connect(_select_zone.bind(i))
        body.add_child(button)
    var now: int = int(Time.get_unix_time_from_system())
    YardStock.refresh(yard_stock, now)
    _label("Selected yard: %s | Next stock refresh in %d min" % [JunkyardZones.zone_name(selected_zone), ceili(float(YardStock.seconds_until_refresh(now)) / 60.0)])
    var entry: Dictionary = yard_stock.get(str(selected_zone), {})
    var stock: Array = entry.get("cars", [])
    if stock.is_empty():
        _label("All wrecks claimed. Check back after the next stock refresh.")
    for i in range(stock.size()):
        var wreck: Dictionary = stock[i]
        _label("%s | %s | shell $%d" % [Economy.display_name(wreck), VehicleCondition.summary(wreck), Economy.sell_shell(wreck)])
        _button("CLAIM FREE: %s" % Economy.display_name(wreck), _claim_stock_wreck.bind(i))

func _select_zone(index: int) -> void:
    if not JunkyardZones.unlocked(index, level):
        status = "This junkyard zone is still locked."
    else:
        selected_zone = index
        status = "Exploring %s." % JunkyardZones.zone_name(index)
    _save_and_render()

func _render_workshop() -> void:
    _label("WORKSHOP  |  Three restoration bays")
    var bay_row := HBoxContainer.new()
    body.add_child(bay_row)
    for i in range(3):
        var button := Button.new()
        var car_index: int = WorkshopBays.find_index(cars, str(bay_assignments[i]))
        var occupant := "EMPTY" if car_index == -1 else Economy.display_name(cars[car_index])
        button.text = "BAY %d%s\n%s" % [i + 1, " [ACTIVE]" if garage_bay == i else "", occupant]
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.pressed.connect(_select_bay.bind(i))
        bay_row.add_child(button)
    _label("Assign a car to the active bay, or clear the bay to free the workspace.")
    if not cars.is_empty():
        _button("Assign selected vehicle to Bay %d" % (garage_bay + 1), _assign_selected_to_bay)
    _button("Clear Bay %d" % (garage_bay + 1), _clear_active_bay)
    var active_index: int = WorkshopBays.find_index(cars, str(bay_assignments[garage_bay]))
    if active_index >= 0:
        _button("Select vehicle occupying this bay", _select_car.bind(active_index))

func _assign_selected_to_bay() -> void:
    if cars.is_empty():
        return
    selected_car = clampi(selected_car, 0, cars.size() - 1)
    bay_assignments = WorkshopBays.assign(bay_assignments, cars, garage_bay, str(cars[selected_car].get("id", "")))
    status = "Vehicle assigned to workshop bay %d." % (garage_bay + 1)
    _save_and_render()

func _clear_active_bay() -> void:
    bay_assignments = WorkshopBays.clear(bay_assignments, garage_bay)
    status = "Workshop bay %d cleared." % (garage_bay + 1)
    _save_and_render()

func _select_bay(index: int) -> void:
    garage_bay = clampi(index, 0, 2)
    var occupant: int = WorkshopBays.find_index(cars, str(bay_assignments[garage_bay]))
    if occupant >= 0:
        selected_car = occupant
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
        if current_tab == 2:
            _render_spare_parts()
        return
    selected_car = clampi(selected_car, 0, cars.size() - 1)
    for i in range(cars.size()):
        var car: Dictionary = cars[i]
        _button("%s  [%s]" % [Economy.display_name(car), "Restored Beauty" if car.get("restored", false) else "Rust Bucket"], _select_car.bind(i))
    var car: Dictionary = cars[selected_car]
    _label("Selected: %s" % Economy.display_name(car))
    _label("CONDITION: %s" % VehicleCondition.summary(car))
    _label("Origin: %s" % str(car.get("source_zone", "Unknown yard")))
    if current_tab == 8:
        var appraisal: Dictionary = VehicleAppraisal.estimate(car)
        _label("VEHICLE APPRAISAL | Estimates, not guaranteed sale prices")
        _label("Shell: $%d | Fitted parts: $%d | Strip + shell: $%d" % [appraisal["shell"], appraisal["parts"], appraisal["strip_total"]])
        _label("Remaining restoration work: $%d | Estimated restored resale: $%d" % [appraisal["remaining_repairs"], appraisal["restored_resale_estimate"]])
        _label("Estimated restored sale less remaining repairs: $%d (before other costs)" % appraisal["estimated_margin"])
        _render_buyer_offer(car)
    var preview = VehiclePreviewScript.new()
    preview.custom_minimum_size = Vector2(560, 220)
    preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_child(preview)
    preview.set_vehicle(car)
    _label("%d removable parts remaining" % car.get("parts", {}).size())
    _label("Shell resale: $%d  |  Installed parts: %d" % [Economy.sell_shell(car), car.get("parts", {}).size()])
    if current_tab == 2:
        _label("CUSTOMISATION WORKBENCH  |  Pick a category, then choose its style.")
        var category_picker := OptionButton.new()
        category_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        for part in Economy.PARTS:
            category_picker.add_item(part)
        var category_index: int = Economy.PARTS.find(selected_category)
        category_picker.select(maxi(0, category_index))
        category_picker.item_selected.connect(_select_category)
        body.add_child(category_picker)
        var installed: bool = car.get("parts", {}).has(selected_category)
        _label("Selected: %s  |  %s" % [selected_category, "Installed" if installed else "Not installed"])
        var style_picker := OptionButton.new()
        style_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var styles: Array = Customisation.choices_for(selected_category)
        for style in styles:
            style_picker.add_item(str(style))
        style_picker.select(maxi(0, styles.find(Customisation.selected_choice(car, selected_category))))
        style_picker.item_selected.connect(_choose_selected_style)
        body.add_child(style_picker)
        if installed:
            _button("Remove %s to spare-parts storage" % selected_category, _detach_part.bind(selected_category))
        else:
            _label("To install this part, select a matching spare below.")
        _label("Driveable: %s" % ("Yes" if Customisation.is_driveable(car) else "No - essential parts missing"))
        _render_spare_parts()
    if current_tab == 8:
        var missing: Array = VehicleCondition.missing_parts(car)
        _label("MISSING COMPONENTS (%d): %s" % [missing.size(), ", ".join(missing)])
        for part in car.get("parts", {}).keys():
            _button("Sell %s  ($%d)" % [part, int(car["parts"][part])], _sell_part.bind(part))
    _button("Strip and sell all remaining parts", _strip_car)
    if current_tab == 1 or current_tab == 2:
        _label("RESTORATION WORKBENCH  |  %d/%d stages" % [Restoration.restoration_progress(car), Restoration.STAGES.size()])
        var overall := ProgressBar.new()
        overall.max_value = Restoration.STAGES.size() * 3
        var completed_tasks := 0
        for stage in Restoration.STAGES:
            completed_tasks += Restoration.task_progress(car, stage)
            if Restoration.stage_cost(car, stage) == 0:
                completed_tasks += maxi(0, 3 - Restoration.task_progress(car, stage))
        overall.value = completed_tasks
        overall.custom_minimum_size.y = 22
        body.add_child(overall)
        for stage in Restoration.STAGES:
            var cost: int = Restoration.stage_cost(car, stage)
            if cost == 0:
                _label("✓ %s: complete" % stage)
            else:
                var progress: int = Restoration.task_progress(car, stage)
                _label("%s: %d/3 tasks | Stage cost $%d" % [stage, progress, cost])
                var task: String = Restoration.next_task(car, stage)
                if not task.is_empty():
                    _button("WORK: %s" % task, _perform_restoration_task.bind(stage))
        _label("Paint finish: %s" % car.get("paint", "Rust"))
        for paint_name in ["Rust", "Crimson", "Midnight", "Ivory", "Violet", "Lime"]:
            _button("Paint: %s" % paint_name, _paint_car.bind(paint_name))
    _button("Sell shell only (fitted parts not paid separately)", _sell_shell)
    if not car.get("parts", {}).is_empty():
        _button("Sell ALL fitted parts + shell together", _sell_complete_vehicle)

func _render_buyer_offer(car: Dictionary) -> void:
    _label("CAR FLIPPING | Local buyers")
    if not CarBuyers.is_ready_for_buyer(car):
        _label("Complete restoration and fit essential parts to request an offer.")
        return
    var id: String = str(car.get("id", ""))
    var offer: Dictionary = buyer_offers.get(id, {})
    if offer.is_empty():
        _button("Request buyer offer", _request_buyer_offer)
    else:
        _label("%s offers $%d" % [offer.get("buyer", "Buyer"), int(offer.get("amount", 0))])
        _button("Accept buyer offer", _accept_buyer_offer)
        _button("Decline buyer offer", _decline_buyer_offer)

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
    if payout > 0:
        _award_xp(PlayerProgress.salvage_xp(1))
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

func _select_category(index: int) -> void:
    if index < 0 or index >= Economy.PARTS.size():
        return
    selected_category = str(Economy.PARTS[index])
    _save_and_render()

func _choose_selected_style(index: int) -> void:
    _choose_part(index, selected_category)

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

func _award_xp(amount: int) -> void:
    var state := {"level": level, "xp": xp}
    PlayerProgress.add_xp(state, amount)
    level = int(state["level"])
    xp = int(state["xp"])

func _perform_restoration_task(stage: String) -> void:
    if cars.is_empty():
        return
    var task: String = Restoration.next_task(cars[selected_car], stage)
    var spent: int = Restoration.perform_task(cars[selected_car], stage, cash)
    if spent >= 0:
        cash -= spent
        _award_xp(PlayerProgress.restoration_xp(spent > 0))
        status = "Completed: %s%s" % [task, " ($%d)" % spent if spent > 0 else ""]
    else:
        status = "Cannot complete this task yet. Check available cash."
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

func _claim_stock_wreck(slot: int) -> void:
    if cars.size() >= MAX_STORAGE:
        status = "Storage full. Sell a car to make room."
    elif not JunkyardZones.unlocked(selected_zone, level):
        status = "This junkyard zone is locked."
    else:
        YardStock.refresh(yard_stock, int(Time.get_unix_time_from_system()))
        var wreck: Dictionary = YardStock.take(yard_stock, selected_zone, slot)
        if wreck.is_empty():
            status = "That wreck is no longer available."
        else:
            cars.append(wreck)
            selected_car = cars.size() - 1
            status = "Claimed %s for free from %s!" % [Economy.display_name(wreck), JunkyardZones.zone_name(selected_zone)]
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
    Customisation.set_choice(cars[selected_car], part, "None")
    cash += payout
    if payout > 0:
        _award_xp(PlayerProgress.salvage_xp(1))
    status = "Sold %s for $%d. No penalties." % [part, payout]
    _save_and_render()

func _strip_car() -> void:
    if cars.is_empty():
        return
    var count: int = cars[selected_car].get("parts", {}).size()
    var payout: int = Economy.strip_all(cars[selected_car])
    for part in Economy.PARTS:
        Customisation.set_choice(cars[selected_car], part, "None")
    cash += payout
    _award_xp(PlayerProgress.salvage_xp(count))
    status = "Sold remaining parts for $%d." % payout
    _save_and_render()

func _sell_complete_vehicle() -> void:
    if cars.is_empty():
        return
    var count: int = cars[selected_car].get("parts", {}).size()
    var part_payout: int = Economy.strip_all(cars[selected_car])
    var shell_payout: int = Economy.sell_shell(cars[selected_car])
    cash += part_payout + shell_payout
    _award_xp(PlayerProgress.salvage_xp(count))
    cars.remove_at(selected_car)
    bay_assignments = WorkshopBays.normalise(bay_assignments, cars)
    selected_car = maxi(0, selected_car - 1)
    status = "Sold %d fitted parts and shell for $%d. No penalties." % [count, part_payout + shell_payout]
    _save_and_render()

func _sell_shell() -> void:
    if cars.is_empty():
        return
    var payout: int = Economy.sell_shell(cars[selected_car])
    cash += payout
    cars.remove_at(selected_car)
    bay_assignments = WorkshopBays.normalise(bay_assignments, cars)
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
        file.store_string(JSON.stringify({"tab": current_tab, "selected_zone": selected_zone, "yard_stock": yard_stock, "cash": cash, "level": level, "xp": xp, "cars": cars, "selected": selected_car, "bay": garage_bay, "spare_parts": spare_parts, "storage_filter": storage_filter, "bay_assignments": bay_assignments, "selected_category": selected_category}))

func _load_game() -> void:
    if not FileAccess.file_exists("user://junkyard_revival.json"):
        return
    var file := FileAccess.open("user://junkyard_revival.json", FileAccess.READ)
    if file == null:
        return
    var data = JSON.parse_string(file.get_as_text())
    if data is Dictionary:
        current_tab = clampi(int(data.get("tab", 0)), 0, TABS.size() - 1)
        selected_zone = clampi(int(data.get("selected_zone", 0)), 0, JunkyardZones.ZONES.size() - 1)
        var saved_stock = data.get("yard_stock", {})
        if saved_stock is Dictionary:
            yard_stock = saved_stock
        cash = int(data.get("cash", 5000))
        level = maxi(1, int(data.get("level", 1)))
        xp = maxi(0, int(data.get("xp", 0)))
        if not JunkyardZones.unlocked(selected_zone, level):
            selected_zone = 0
        selected_car = int(data.get("selected", 0))
        garage_bay = clampi(int(data.get("bay", 0)), 0, 2)
        storage_filter = str(data.get("storage_filter", "All"))
        selected_category = str(data.get("selected_category", "Spoiler"))
        if not Economy.PARTS.has(selected_category):
            selected_category = "Spoiler"
        var loaded_bays = data.get("bay_assignments", ["", "", ""])
        if loaded_bays is Array:
            bay_assignments = loaded_bays
        var saved_spares = data.get("spare_parts", [])
        if saved_spares is Array:
            spare_parts = saved_spares
        var saved_cars = data.get("cars", [])
        if saved_cars is Array:
            for item in saved_cars:
                if item is Dictionary:
                    cars.append(item)
        bay_assignments = WorkshopBays.normalise(bay_assignments, cars)
