class_name BlackKnight
extends Knight

# CONTACT DAMAGE VARS ------------------------------------------------------------------------------
@export_category("Contact Damage")
@export var contact_knockback: float = 200.0 ## Amount of knockback dealt on contact

var contact_hitboxes: Dictionary[String, Hitbox] = {}

var contact_hitbox_x: Dictionary[String, float] = {}

## Called when the node enters the scene tree for the first time.s
func _ready() -> void:
	if find_child("ContactHitboxUp") is Hitbox:
		contact_hitboxes["up"] = find_child("ContactHitboxUp")
		if contact_hitboxes["up"] is Hitbox:
			contact_hitboxes["up"].attack_direction = Vector2.UP
	if find_child("ContactHitboxLeft") is Hitbox:
		contact_hitboxes["left"] = find_child("ContactHitboxLeft")
		contact_hitboxes["left"].attack_direction = Vector2.LEFT
	if find_child("ContactHitboxRight") is Hitbox:
		contact_hitboxes["right"] = find_child("ContactHitboxRight")
		contact_hitboxes["right"].attack_direction = Vector2.RIGHT
	if find_child("ContactHitboxDown") is Hitbox:
		contact_hitboxes["down"] = find_child("ContactHitboxDown")
		contact_hitboxes["down"].attack_direction = Vector2.DOWN
		
	for hb in contact_hitboxes:
		contact_hitboxes[hb].enemy_knockback = contact_knockback
		contact_hitbox_x[hb] = contact_hitboxes[hb].position.x
		
	super()

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:	
	super(delta)

# Resolves inputs for the Black Knight
func handle_input(delta: float) -> void:
	# Debug action for restoring health
	if Input.is_action_just_pressed("crouch"):
		restore_to_full_health(0.2)
		
# MOVEMENT FUNCTIONS -------------------------------------------------------------------------------
func is_idle() -> bool:
	return is_on_floor() and (not is_swinging) and (not is_damaged)
	
## Handles movement input for the Black Knight
func run(direction: Vector2, delta: float) -> void:
	super(direction, delta)
	
	# Stops momentum immediately when changing direction
	if (direction == Vector2.RIGHT and velocity.x < 0) \
				or (direction == Vector2.LEFT and velocity.x > 0):
				velocity = Vector2(0, velocity.y)	
			
# COMBAT FUNCTIONS ---------------------------------------------------------------------------------
## Broadcasts success state on Black Knight death
func death() -> void:
	level_manager.state_changed.emit(LevelStateManager.LevelState.LEVEL_SUCCESS)
