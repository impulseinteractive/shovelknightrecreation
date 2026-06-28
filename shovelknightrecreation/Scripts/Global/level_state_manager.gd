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

	LEVEL_STATE = LevelState.INITIAL
	state_entered.emit(LevelState.INITIAL)
	return


func on_state_changed(new_state: LevelState):
	state_exited.emit(LEVEL_STATE)
	LEVEL_STATE = new_state
	print_debug("State is now " + str(new_state))
	state_entered.emit(new_state)
	return
