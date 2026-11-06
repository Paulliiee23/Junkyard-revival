extends Control
class_name VehiclePreview

var vehicle: Dictionary = {}

func set_vehicle(data: Dictionary) -> void:
    vehicle = data
    queue_redraw()

func _draw() -> void:
    var bounds := get_rect()
    draw_rect(Rect2(Vector2.ZERO, bounds.size), Color("#302b28"))
    var w: float = bounds.size.x
    var h: float = bounds.size.y
    if w < 100.0 or h < 80.0:
        return
    var base := Color("#8e4c32")
    match str(vehicle.get("paint", "Rust")):
        "Crimson": base = Color("#b32936")
        "Midnight": base = Color("#1e293d")
        "Ivory": base = Color("#e6dfc7")
        "Violet": base = Color("#7034a0")
        "Lime": base = Color("#a3d42a")
    var left := w * 0.14
    var top := h * 0.30
    var width := w * 0.72
    var height := h * 0.43
    var installed: Dictionary = vehicle.get("parts", {})
    var choices: Dictionary = vehicle.get("customisation", {})
    # Temporary procedural side profile, not final layered vehicle artwork.
    draw_rect(Rect2(left, top + height * 0.33, width, height * 0.48), base)
    if not installed.has("Left Door") or str(choices.get("Left Door", "Factory")) == "None":
        draw_rect(Rect2(left + width * 0.36, top + height * 0.34, width * 0.30, height * 0.40), Color("#171615"))
    else:
        draw_line(Vector2(left + width * 0.36, top + height * 0.34), Vector2(left + width * 0.36, top + height * 0.76), base.darkened(0.4), 3.0)
    if not installed.has("Hood") or str(choices.get("Hood", "Factory")) == "None":
        draw_rect(Rect2(left + width * 0.03, top + height * 0.31, width * 0.25, height * 0.09), Color("#161515"))
    if not installed.has("Front Bumper") or str(choices.get("Front Bumper", "Factory")) == "None":
        draw_rect(Rect2(left, top + height * 0.70, width * 0.08, height * 0.14), Color("#171615"))
    if not installed.has("Rear Bumper") or str(choices.get("Rear Bumper", "Factory")) == "None":
        draw_rect(Rect2(left + width * 0.92, top + height * 0.70, width * 0.08, height * 0.14), Color("#171615"))
    draw_colored_polygon(PackedVector2Array([
        Vector2(left + width * 0.20, top + height * 0.34),
        Vector2(left + width * 0.36, top),
        Vector2(left + width * 0.68, top),
        Vector2(left + width * 0.82, top + height * 0.34)
    ]), base.darkened(0.12))
    if installed.has("Windows") and str(choices.get("Windows", "Factory")) != "None":
        draw_rect(Rect2(left + width * 0.37, top + 4, width * 0.27, height * 0.23), Color("#7c9da7"))
    if installed.has("Wheels") and str(choices.get("Wheels", "Factory")) != "None":
        for x in [left + width * 0.22, left + width * 0.79]:
            draw_circle(Vector2(x, top + height * 0.80), height * 0.18, Color("#111113"))
            draw_circle(Vector2(x, top + height * 0.80), height * 0.09, Color("#aeb0b3"))
    if installed.has("Spoiler") and str(choices.get("Spoiler", "Factory")) != "None":
        draw_rect(Rect2(left + width * 0.82, top + height * 0.08, width * 0.17, 7), Color("#1d1b1c"))
        draw_line(Vector2(left + width * 0.88, top + height * 0.08), Vector2(left + width * 0.88, top + height * 0.36), Color("#1d1b1c"), 5.0)
    if installed.has("Hood Scoop") and str(choices.get("Hood Scoop", "Factory")) != "None":
        draw_rect(Rect2(left + width * 0.08, top + height * 0.22, width * 0.12, 9), Color("#252529"))
    if installed.has("Roof Scoop") and str(choices.get("Roof Scoop", "Factory")) != "None":
        draw_rect(Rect2(left + width * 0.45, top - 10, width * 0.13, 10), Color("#252529"))
    if installed.has("Neon") and str(choices.get("Neon", "None")) != "None":
        draw_line(Vector2(left + width * 0.28, top + height * 0.94), Vector2(left + width * 0.74, top + height * 0.94), Color("#a65dff"), 6.0)
