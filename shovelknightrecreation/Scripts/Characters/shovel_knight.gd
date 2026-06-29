class_name ShovelKnight
extends Knight

# MOVEMENT VARS ------------------------------------------------------------------------------------
@export_category("Movement")
@export var pivot_delay: float = 0.1 ## How long it takes to start moving after pivoting

var pivot_timer: float = 0.0 ## Tracks times since pivot started
var pivoting: bool = false ## Whether the knight is pivoting

# COMBAT VARS --------------------------------------------------------------------------------------
@export_category("Combat")
@export var iframe_duration: float = 1.5 ## Amount of i-frames received when taking damage

var hurtbox_ref: Hurtbox    ## Reference to Shovel Knight's hurtbox
var is_immune: bool = false ## Whether Shovel Knight is immune to damage

# SPRITE VARS --------------------------------------------------------------------------------------
@export_category("Visuals")
@export var iframe_flash_interval: float = 0.1 ## How frequently the sprite flashes in i-frames

var flash_timer: Timer ## Timer for flashing the sprite

#---------------------------------------------------------------------------------------------------

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	# Define the flash timer for i-frames
	flash_timer = Timer.new()
	flash_timer.wait_time = iframe_flash_interval
	flash_timer.one_shot = false
	flash_timer.timeout.connect(func(): 
			sprite_ref.visible = not sprite_ref.visible)
	add_child(flash_timer)
	
	if has_node("Hurtbox") and get_node("Hurtbox") is Hurtbox:
		hurtbox_ref = $Hurtbox

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	super(delta)
	if Input.is_action_just_pressed("crouch"):
		take_damage()
	pass
	
## Resolves all shovel knight inputs
func handle_input(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		run(Vector2.LEFT, delta)
		
	if Input.is_action_pressed("move_right"):
		run(Vector2.RIGHT, delta)
		
	if Input.is_action_just_pressed("shovel_swing"):
		shovel_swing()
		
	if Input.is_action_just_pressed("crouch"):
		print_debug("Crouch")
	
# MOVEMENT FUNCTIONS -------------------------------------------------------------------------------
## Handles movement input for the Shovel Knight

func is_idle() -> bool:
	return is_on_floor() and (not is_swinging) and (not is_damaged) and (not Input.is_anything_pressed())

func run(direction: Vector2, delta: float) -> void:
	if not pivoting:
		super(direction, delta)
	
		if (direction == Vector2.RIGHT and velocity.x < 0) \
				or (direction == Vector2.LEFT and velocity.x > 0):
				velocity = Vector2(0, velocity.y)
				pivoting = true
				pivot_timer = 0
				
	elif pivoting:
		pivot_timer += delta
		$AnimatedSprite2D.play("pivot")
		if pivot_timer >= pivot_delay:
			pivoting = false
			
# DAMAGE SYSTEM FUNCTION ---------------------------------------------------------------------------
## Gives invulnerability frames when Shovel Knight takes damage
func take_damage() -> void:
	start_iframes()
	super()
	
## Broadcasts fail state on Shovel Knight death
func death() -> void:
	level_manager.state_changed.emit(LevelStateManager.LevelState.LEVEL_FAILURE)

## Begins invincibility frames of Shovel Knight
func start_iframes() -> void:
	hurtbox_ref.set_deferred("monitoring", false)
	get_tree().create_timer(iframe_duration).timeout.connect(end_iframes)
	
	# Repeating timer to flash iframes
	flash_timer.start()

## Ends invincibility frames of Shovel Knight	
func end_iframes() -> void:
	sprite_ref.visible = true
	flash_timer.stop()
	hurtbox_ref.set_deferred("monitoring", true)
	
