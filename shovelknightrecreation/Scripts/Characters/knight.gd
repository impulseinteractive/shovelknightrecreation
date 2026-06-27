class_name Knight
extends CharacterBody2D

@export_category("Physics")
@export var ground_friction: float = 900.0 # The rate at which character speed moves toward 0 
										   # on the ground

# All variables pertaining to character movement
@export_category("Movement")
@export var movement_speed: float = 200.0        # Max running speed of the knight
@export var movement_acceleration: float = 500.0 # Ramp up speed of knight running

# Movement flags
var running: bool = false  # Whether the knight is running

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Come to a sharp stop when character stops running
	if not running:
		velocity.x = move_toward(velocity.x, 0, ground_friction * delta)
		
	move_and_slide()
	# Reset the running flag
	running = false
	pass

#MOVEMENT FUNCTIONS --------------------------------------------------------------------------------
# Character movement function that takes Vector2.LEFT (-1, 0) or Vector2.RIGHT (1, 0) as directional 
# input
func run(direction: Vector2, delta: float) -> void:
	running = true
	
	velocity.x = move_toward(velocity.x, movement_speed * direction.x, 
			movement_acceleration * delta)
	print_debug("Running at a speed of " + str(velocity))
		
	
# ATTACK FUNCTIONS ---------------------------------------------------------------------------------
# Physics process for shovel swing
# Starts the shovel swing when shovel swing is input
func shovel_swing() -> void:
		print_debug("Shovel Swung")
