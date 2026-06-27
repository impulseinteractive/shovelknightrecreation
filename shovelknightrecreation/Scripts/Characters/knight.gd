class_name Knight
extends CharacterBody2D

# All variables pertaining to character movement
@export_category("Movement")
@export var movement_speed: float = 200.0   # Max running speed of the knight
@export var movement_ramp_up: float = 10.0  # Ramp up speed of knight running

# Tracks previous movement state
var was_running_right: bool = false
var was_running_left: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move_and_slide()
	pass

#MOVEMENT FUNCTIONS --------------------------------------------------------------------------------
# Character movement function that takes Vector2.LEFT (-1, 0) or Vector2.RIGHT (1, 0) as directional 
# input
func run(direction: Vector2) -> void:
	velocity = velocity.move_toward(direction * movement_speed, movement_ramp_up)
	print_debug("Running at a speed of " + str(velocity))
		
	# Stops all left velocity when right input is detected
	if direction == Vector2.RIGHT:
		if velocity.x < 0:
			velocity = Vector2(0, velocity.y)
	
	# Stops all right velocity when left input is detected
	if direction == Vector2.LEFT:
		if velocity.x > 0:
			velocity = Vector2(0, velocity.y)	
	
# ATTACK FUNCTIONS ---------------------------------------------------------------------------------
# Physics process for shovel swing
# Starts the shovel swing when shovel swing is input
func shovel_swing() -> void:
		print_debug("Shovel Swung")
