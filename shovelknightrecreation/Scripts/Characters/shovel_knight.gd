class_name ShovelKnight
extends Knight

@export_category("Movement")
@export var direction_change_delay: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# MOVEMENT INPUT HANDLING--------------------------------------------------
	if Input.is_action_pressed("move_left"):
		run(Vector2.LEFT)
		
	if Input.is_action_pressed("move_right"):
		run(Vector2.RIGHT)
		
	if Input.is_action_just_pressed("shovel_swing"):
		shovel_swing()
		
	if Input.is_action_just_pressed("crouch"):
		print_debug("Crouch")
		
	was_running_left = Input.is_action_pressed("move_left")
	was_running_right = Input.is_action_pressed("move_right")

	super(delta)
	pass
