extends Node


enum LevelState{INITIAL, PLAY, CUTSCENE, LEVEL_SUCCESS, LEVEL_FAILURE}

## Emit this signal with new LevelState enum value to trigger transition to a new state
signal state_changed(new_state: LevelState)

## Connect to this signal to handle any initial state setup after transitioning into a new state
signal state_entered(new_state: LevelState)

## Connect to this signal to handle any state cleanup before transitioning into a new state completes
signal state_exited(old_state: LevelState)

## Current level state value
var LEVEL_STATE: LevelState


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_changed.connect(on_state_changed)
	state_entered.connect(on_state_entered)
	initialize_level()
	return

func initialize_level() -> void:
	LEVEL_STATE = LevelState.INITIAL
	state_entered.emit(LevelState.INITIAL)
	

func on_state_entered(entered_state: LevelState) -> void:
	if entered_state == LevelState.LEVEL_SUCCESS or entered_state == LevelState.LEVEL_FAILURE:
		handle_level_complete()

func handle_level_complete() -> void:
	get_tree().reload_current_scene.call_deferred()
	initialize_level()

func on_state_changed(new_state: LevelState) -> void:
	state_exited.emit(LEVEL_STATE)
	LEVEL_STATE = new_state
	print_debug("State is now " + str(new_state))
	state_entered.emit(new_state)
	return
