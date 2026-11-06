extends SceneTree

const Progress = preload("res://scripts/player_progress.gd")

func _initialize() -> void:
    var state := {"level": 1, "xp": 0}
    assert(Progress.required_xp(1) == 150)
    Progress.add_xp(state, 149)
    assert(state["level"] == 1)
    assert(state["xp"] == 149)
    Progress.add_xp(state, 1)
    assert(state["level"] == 2)
    assert(state["xp"] == 0)
    Progress.add_xp(state, 500)
    assert(state["level"] == 3)
    assert(state["xp"] == 275)
    Progress.add_xp(state, -100)
    assert(state["xp"] == 275)
    assert(Progress.salvage_xp(3) == 24)
    assert(Progress.restoration_xp(true) > Progress.restoration_xp(false))
    print("Player XP progression tests passed")
    quit(0)
