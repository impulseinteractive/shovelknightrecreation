class_name Knight
extends CharacterBody2D

# PHYSICS VARS -------------------------------------------------------------------------------------
@export_category("Physics")
@export var ground_friction: float = 900.0    # The rate at which character speed moves toward 0 
											  # on the ground
@export var terminal_velocity: float = 1600.0 # The max fall speed of the knight

# MOVEMENT VARS ------------------------------------------------------------------------------------
@export_category("Movement")
@export var movement_speed: float = 200.0        # Max running speed of the knight
@export var movement_acceleration: float = 500.0 # Ramp up speed of knight running

# Movement flags
var running: bool = false  # Whether the knight is running

# DAMAGE SYSTEM VARS -------------------------------------------------------------------------------
@export_category("Health")
@export var max_health: int = 8.0 # Max possible health for the knight

var current_health: int           # Current health of the knight

# --------------------------------------------------------------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	print_debug("Health set to " + str(current_health))

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Come to a sharp stop when character stops running
	if not running:
		velocity.x = move_toward(velocity.x, 0, ground_friction * delta)
		
	# Handle gravity's effect on the knight
	velocity.y = move_toward(velocity.y, terminal_velocity, get_gravity().y * delta)
		
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
		
# DAMAGE SYSTEM FUNCTIONS --------------------------------------------------------------------------
# Removes health equal to incoming damage
func take_damage() -> void:
	print_debug("Ouch! Damage taken")
	current_health -= 1
	
# Restores 1 point of health to the knight
func restore_health() -> void:
	print_debug("Health restored")
	current_health += 1
	
# Restores health once per duration of the delay until the knight is full health
func restore_to_full_health(delay: float):
	while current_health < max_health:
		restore_health()
		await get_tree().create_timer(delay).timeout
	print_debug("Health fully restored")
