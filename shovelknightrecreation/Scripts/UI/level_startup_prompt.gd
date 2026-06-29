extends Control


@onready var level_manager = LevelStateManager
@onready var press_enter_to_start: RichTextLabel = %PressEnterToStart


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_manager.state_exited.connect(_on_exit_initial)
	level_manager.state_entered.connect(_on_enter_initial)
	
	get_tree().paused = true
	grab_focus()
	press_enter_to_start.show()

	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("enter"):
		level_manager.state_changed.emit(LevelStateManager.LevelState.PLAY)
		return
	return

func _on_enter_initial(new_state: LevelStateManager.LevelState):
	if new_state == LevelStateManager.LevelState.INITIAL:
		get_tree().paused = true
		grab_focus()
		press_enter_to_start.show()
	return

func _on_exit_initial(old_state: LevelStateManager.LevelState):
	if old_state == LevelStateManager.LevelState.INITIAL:
		get_tree().paused = false
		release_focus()
		press_enter_to_start.hide()
	return
