class_name ShovelKnight
extends Knight

# MOVEMENT VARS ------------------------------------------------------------------------------------
@export_category("Movement")
@export var pivot_delay: float = 0.1 ## How long it takes to start moving after pivoting

var pivot_timer: float = 0.0 ## Tracks times since pivot started
var pivoting: bool = false ## Whether the knight is pivoting

# DAMAGE SYSTEM VARS -------------------------------------------------------------------------------
var hurtbox_ref: Hurtbox ## Reference to Shovel Knight's hurtbox
#---------------------------------------------------------------------------------------------------

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if has_node("Hurtbox") and get_node("Hurtbox") is Hurtbox:
		hurtbox_ref = $Hurtbox

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	super(delta)
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
		
		if pivot_timer >= pivot_delay:
			pivoting = false
			
# DAMAGE SYSTEM FUNCTION ---------------------------------------------------------------------------
## Gives invulnerability frames when Shovel Knight takes damage
func take_damage() -> void:
	hurtbox_ref.set_deferred("monitoring", false)
	super()
	await get_tree().create_timer(damaged_duration).timeout
	hurtbox_ref.set_deferred("monitoring", true)
	
## Broadcasts fail state on Shovel Knight death
func death() -> void:
	level_manager.state_changed.emit(LevelStateManager.LevelState.LEVEL_FAILURE)
