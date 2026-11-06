extends Control
class_name JunkyardBackdrop

# Procedural placeholder for the final painted junkyard artwork.
func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    resized.connect(queue_redraw)

func _draw() -> void:
    var w: float = size.x
    var h: float = size.y
    if w < 1 or h < 1:
        return
    draw_rect(Rect2(Vector2.ZERO, size), Color("#241b25"))
    # Layered dusk sky
    for i in range(40):
        var t: float = float(i) / 40.0
        draw_rect(Rect2(0, h * 0.05 + t * h * 0.65, w, h * 0.018),
            Color("#3a2438").lerp(Color("#bd663c"), t))
    draw_circle(Vector2(w * 0.78, h * 0.44), minf(w, h) * 0.11, Color("#edac65", 0.6))
    draw_rect(Rect2(0, h * 0.71, w, h * 0.29), Color("#292825"))
    # Distant factory silhouettes
    for i in range(11):
        var x: float = w * float(i) / 10.0
        var roof: float = h * (0.49 + float(i % 4) * 0.04)
        draw_rect(Rect2(x, roof, w * 0.12, h * 0.27), Color("#302d31"))
        draw_rect(Rect2(x + 8, roof - 25, 11, 25), Color("#29282c"))
    # Fencing
    for i in range(21):
        var x: float = w * float(i) / 20.0
        draw_line(Vector2(x, h * 0.65), Vector2(x, h * 0.84), Color("#756456", 0.55), 2.0)
    draw_line(Vector2(0, h * 0.7), Vector2(w, h * 0.7), Color("#8c7863", 0.6), 2.0)
    # Salvage building
    draw_rect(Rect2(w * 0.08, h * 0.45, w * 0.3, h * 0.31), Color("#393733"))
    draw_rect(Rect2(w * 0.07, h * 0.43, w * 0.32, 15), Color("#66564c"))
    draw_rect(Rect2(w * 0.13, h * 0.54, w * 0.2, h * 0.16), Color("#252a2b"))
    draw_string(ThemeDB.fallback_font, Vector2(w * 0.1, h * 0.51), "RIVERDALE AUTO SALVAGE",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#e9c58c"))
    # Wreck silhouettes on the ground
    for i in range(7):
        var x: float = w * (0.42 + float(i % 4) * 0.15)
        var y: float = h * (0.73 + float(i / 4) * 0.13)
        var car_w: float = w * 0.11
        draw_rect(Rect2(x, y - 20, car_w, 24), Color("#54423b"))
        draw_colored_polygon(PackedVector2Array([
            Vector2(x + 14, y - 20), Vector2(x + 29, y - 39),
            Vector2(x + car_w - 25, y - 39), Vector2(x + car_w - 8, y - 20)
        ]), Color("#655247"))
        draw_circle(Vector2(x + 20, y + 5), 11, Color("#191b1c"))
        draw_circle(Vector2(x + car_w - 20, y + 5), 11, Color("#191b1c"))
    # Foreground vignette
    draw_rect(Rect2(0, h * 0.88, w, h * 0.12), Color("#18191a", 0.45))
