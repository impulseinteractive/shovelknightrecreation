class_name Knight
extends CharacterBody2D

@onready var level_manager = LevelStateManager

# PHYSICS VARS -------------------------------------------------------------------------------------
@export_category("Physics")
@export var ground_friction: float = 1200.0   ## The rate at which character speed moves toward 0 
@export var terminal_velocity: float = 1600.0 ## The max fall speed of the knight
var collision_shape_x: float                  ## default x pos of the collision shape

# MOVEMENT VARS ------------------------------------------------------------------------------------
@export_category("Movement")
@export var movement_speed: float = 200.0           ## Max is_running speed of the knight
@export var movement_acceleration: float = 500.0    ## Ramp up speed of knight is_running
@export var look_direction: Vector2 = Vector2.RIGHT ## The direction the knight is looking

var is_running: bool = false ## Whether the knight is runningx

# COMBAT VARS --------------------------------------------------------------------------------------
@export_category("Combat")
@export var max_health: int = 8.0    ## Max possible health for the knight
@export var knockback_y_ratio = 0.8  ## Portion of knockback applied vertically on horizontal attacks 
@export var attack_group: StringName ## Name of the group the knight's attacks belongs to
@export var damaged_duration: float = 0.5 ## Duration of damage effect on player
@export var damaged_sfx: AudioStream ## Sound effect for when this Knight takes damage

var current_health: int               ## Current health of the knight
var lock_input: bool = false          ## Stops new inputs from being processed
var is_damaged: bool = false          ## Whether the knight is currently in damaged state

# SHOVEL SWING VARS --------------------------------------------------------------------------------
@export_category("Shovel Swing")
@export var swing_shape: Shape2D                 ## Shape of the shovel swing hitbox
@export var swing_enemy_knockback: float = 200.0 ## Amount of knockback applied to enemy
@export var swing_self_knockback: float = 200.0  ## Amount of knockback applied to self
@export var swing_dmg_start: float = 0.1         ## How late into the animation the hitbox appears
@export var swing_dmg_duration: float = 0.1      ## Duration that the hitbox lingers for
@export var swing_x_offset: float = 80.0         ## X position of the hitbox relative to the knight
@export var swing_y_offset: float = -60.0        ## Y position of the hitbox relative to the knight
@export var swing_sfx: AudioStream               ## Sound effect for the shovel swing
var is_swinging: bool = false             ## Whether the knight is currently swinging shovel

# SPRITE VARS --------------------------------------------------------------------------------------
var sprite_ref: AnimatedSprite2D    ## Reference to the sprite component

signal on_health_changed(new_health: int)

# --------------------------------------------------------------------------------------------------
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if has_node("AnimatedSprite2D"):
		sprite_ref = $AnimatedSprite2D
	
	collision_shape_x = $CollisionShape2D.position.x
	current_health = max_health
	print_debug(name + " Health set to " + str(current_health))

## Called every idle frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_idle():
		sprite_ref.play("idle")
	
## Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Resolve inputs if input is not locked
	if not lock_input:
		handle_input(delta)
	
	# Come to a sharp stop when character stops is_running
	if not is_running:
		velocity.x = move_toward(velocity.x, 0, ground_friction * delta)
		
	# Handle gravity's effect on the knight
	velocity.y = move_toward(velocity.y, terminal_velocity, get_gravity().y * delta)
		
	move_and_slide()
	# Reset the is_running flag
	is_running = false
	
	# Flip necessary components when character turns around
	if look_direction == Vector2.LEFT:
		sprite_ref.flip_h = true
		$CollisionShape2D.position.x = -collision_shape_x
	elif look_direction == Vector2.RIGHT:
		sprite_ref.flip_h = false
		$CollisionShape2D.position.x = collision_shape_x
		
	# Return to idle pose when dno other actions are happening
	#if (not is_damaged and not is_swinging):
		#sprite_ref.play("idle")
		
## Resolve all inputs in this function
func handle_input(delta: float) -> void:
	pass

#MOVEMENT FUNCTIONS --------------------------------------------------------------------------------
func is_idle() -> bool:
	return true

## Character movement function that takes Vector2.LEFT (-1, 0) or Vector2.RIGHT (1, 0) as directional
func run(direction: Vector2, delta: float) -> void:
	if is_on_floor() and not is_running:
		sprite_ref.play("running")
		is_running = true
		
	velocity.x = move_toward(velocity.x, movement_speed * direction.x, 
			movement_acceleration * delta)
	
	look_direction = direction

# ATTACK FUNCTIONS ---------------------------------------------------------------------------------
## Physics process for shovel swing
## Starts the shovel swing when shovel swing is input
func shovel_swing() -> void:
	# Play the sound effect and lock input
	lock_input = true
	sprite_ref.play("shovel swing")
	is_swinging = true
	$SfxController.play(swing_sfx)
	
	#reenable input when attack fades
	sprite_ref.animation_finished.connect(handle_swing_finished)
	
	# Create the hitbox and assign necessary damage variables
	await get_tree().create_timer(swing_dmg_start).timeout
	
	#Checks to see if swing was interrupted
	if is_swinging:
		var hitbox = Hitbox.new(attack_group, swing_shape, swing_dmg_duration)
		hitbox.name = ("SwingHitbox")
		hitbox.position.x = swing_x_offset * look_direction.x
		hitbox.position.y = swing_y_offset
		hitbox.enemy_knockback = swing_enemy_knockback
		hitbox.self_knockback = swing_self_knockback
		hitbox.attack_direction = look_direction
		add_child(hitbox)
	
func handle_swing_finished() -> void:
	if is_swinging:
		lock_input = false
		is_swinging = false
		sprite_ref.animation_finished.disconnect(handle_swing_finished)
		if has_node("SwingHitbox"):
			get_node("SwingHitbox").queue_free()
		
# COMBAT FUNCTIONS ---------------------------------------------------------------------------------

## Removes health equal to incoming damage
func take_damage() -> void:
	# Lock inputs and interrupt mechanics
	lock_input = true
	is_damaged = true
	interrupt_mechanics()
	sprite_ref.play("damaged")
	
	# Play damage sound and decrement health
	print_debug(name + " Damage taken")
	$SfxController.play(damaged_sfx)
	if current_health > 0:
		current_health -= 1
	on_health_changed.emit(current_health)
	if current_health <= 0:
		death()
	
	# Reenable input and mechanics after a delay
	await get_tree().create_timer(damaged_duration).timeout
	lock_input = false
	is_damaged = false
	
## Handles the knight's death when current health hits 0
func death() -> void:
	pass
	
## Pushes the player back depending on given direction
func take_knockback(knockback: float, direction: Vector2) -> void:
	if direction == Vector2.UP or direction == Vector2.DOWN:
		velocity += knockback * direction
	else:
		velocity = Vector2(knockback * direction.x, - (knockback * knockback_y_ratio))
		print_debug(name + " Knocked back " + str(velocity))
	
## Stops current actions
func interrupt_mechanics() -> void:
	handle_swing_finished()
	
## Restores 1 point of health to the knight
func restore_health() -> void:
	print_debug(name + " Health restored")
	current_health += 1
	
## Restores health once per duration of the delay until the knight is full health
func restore_to_full_health(delay: float):
	while current_health < max_health:
		restore_health()
		await get_tree().create_timer(delay).timeout
	print_debug(name + " Health fully restored")
