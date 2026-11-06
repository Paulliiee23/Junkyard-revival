extends SceneTree

const Economy = preload("res://scripts/salvage_economy.gd")
const Restoration = preload("res://scripts/restoration.gd")

func _initialize() -> void:
    var damaged: Dictionary = Economy.make_wreck(88)
    var average: Dictionary = Economy.make_wreck(88)
    var pristine: Dictionary = Economy.make_wreck(88)
    damaged["condition"] = 10
    average["condition"] = 30
    pristine["condition"] = 90
    assert(Restoration.stage_cost(damaged, "Bodywork") > Restoration.stage_cost(average, "Bodywork"))
    assert(Restoration.stage_cost(pristine, "Bodywork") < Restoration.stage_cost(average, "Bodywork"))
    assert(Restoration.stage_cost(average, "Bodywork") == 180)
    assert(Economy.sell_shell(damaged) < Economy.sell_shell(average))
    assert(Economy.sell_shell(pristine) > Economy.sell_shell(average))
    assert(Economy.sell_shell(average) == int(average["shell_value"]))
    var payment: int = Restoration.stage_cost(pristine, "Bodywork")
    assert(Restoration.complete_stage(pristine, "Bodywork", payment) == payment)
    assert(Restoration.stage_cost(pristine, "Bodywork") == 0)
    print("Condition-based restoration and shell valuation passed")
    quit(0)
