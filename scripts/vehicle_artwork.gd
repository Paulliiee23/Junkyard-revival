extends RefCounted
class_name VehicleArtwork

const SPRITES := [
    "01_blue_tuner.png",
    "02_white_rotary.png",
    "03_purple_supercar.png",
    "04_red_muscle.png",
    "05_yellow_sedan.png",
    "06_orange_coupe.png",
    "07_green_muscle.png",
    "08_blue_hatchback.png",
    "09_red_rally_sedan.png",
    "10_white_sports_sedan.png"
]

static func sprite_path(car: Dictionary) -> String:
    var key: String = str(car.get("brand", "")) + ":" + str(car.get("model", ""))
    var index: int = 0
    match key:
        "Neesan:Sparrow": index = 0
        "Mozdo:Rotary": index = 1
        "Holten:Comet": index = 3
        "Toyoda:Sprinter": index = 5
        "Forge:Falconer": index = 6
        "Hondo:Civicus": index = 7
        "Subaro:Rallye": index = 8
        _: index = abs(key.hash()) % SPRITES.size()
    return "res://assets/vehicles/" + SPRITES[index]

static func sprite_for(car: Dictionary) -> Texture2D:
    var path: String = sprite_path(car)
    if ResourceLoader.exists(path):
        return load(path) as Texture2D
    return null
