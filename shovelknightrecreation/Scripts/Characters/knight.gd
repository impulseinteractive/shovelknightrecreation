class_name Knight
extends CharacterBody2D

# PHYSICS VARS -------------------------------------------------------------------------------------
@export_category("Physics")
@export var ground_friction: float = 900.0    ## The rate at which character speed moves toward 0 
@export var terminal_velocity: float = 1600.0 ## The max fall speed of the knight

# MOVEMENT VARS ------------------------------------------------------------------------------------
@export_category("Movement")
@export var movement_speed: float = 200.0        ## Max running speed of the knight
@export var movement_acceleration: float = 500.0 ## Ramp up speed of knight running

# Movement flags
var running: bool = false  ## Whether the knight is running

# DAMAGE SYSTEM VARS -------------------------------------------------------------------------------
@export_category("Health")
@export var max_health: int = 8.0    ## Max possible health for the knight
@export var attack_group: StringName ## Name of the group the knight's attacks belongs to

var current_health: int           ## Current health of the knight

# SHOVEL SWING VARS --------------------------------------------------------------------------------
@export_category("Shovel Swing")
@export var swing_shape: Shape2D            ## Shape of the shovel swing hitbox
@export var swing_dmg_start: float = 0.1    ## How late into the animation the hitbox appears
@export var swing_dmg_duration: float = 0.1 ## Duration that the hitbox lingers for
@export var swing_x_offset: float = 80.0    ## X position of the hitbox relative to the knight
@export var swing_y_offset: float = -60.0   ## Y position of the hitbox relative to the knight
@export var swing_sfx: AudioStream          ## Sound effect for the shovel swing

# --------------------------------------------------------------------------------------------------
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	print_debug("Health set to " + str(current_health))

## Called every physics frame. 'delta' is the elapsed time since the previous frame.
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
## Character movement function that takes Vector2.LEFT (-1, 0) or Vector2.RIGHT (1, 0) as directional
func run(direction: Vector2, delta: float) -> void:
	running = true
	
	velocity.x = move_toward(velocity.x, movement_speed * direction.x, 
			movement_acceleration * delta)
	print_debug("Running at a speed of " + str(velocity))
		
	
# ATTACK FUNCTIONS ---------------------------------------------------------------------------------
## Physics process for shovel swing
## Starts the shovel swing when shovel swing is input
func shovel_swing() -> void:
	# Play the sound effect
	var sfx = AudioStreamPlayer.new()
	if swing_sfx:
		add_child(sfx)
		
		sfx.stream = swing_sfx
		
		sfx.play()
	
	# Create the hitbox
	get_tree().create_timer(swing_dmg_start).timeout
	var hitbox = Hitbox.new(attack_group, swing_shape, swing_dmg_duration)
	hitbox.position.x = swing_x_offset
	hitbox.position.y = swing_y_offset
	add_child(hitbox)
	
	# Swing shovel
	print_debug("Shovel Swung")
	
	await sfx.finished
	sfx.queue_free()
		
# DAMAGE SYSTEM FUNCTIONS --------------------------------------------------------------------------
## Removes health equal to incoming damage
func take_damage() -> void:
	print_debug("Ouch! Damage taken")
	current_health -= 1
	
## Restores 1 point of health to the knight
func restore_health() -> void:
	print_debug("Health restored")
	current_health += 1
	
## Restores health once per duration of the delay until the knight is full health
func restore_to_full_health(delay: float):
	while current_health < max_health:
		restore_health()
		await get_tree().create_timer(delay).timeout
	print_debug("Health fully restored")
