class_name BlackKnight
extends Knight

# CONTACT DAMAGE VARS ------------------------------------------------------------------------------
@export_category("Contact Damage")
@export var contact_knockback: float = 200.0 ## Amount of knockback dealt on contact

var contact_hitboxes: Dictionary[String, Hitbox] = {}

var contact_hitbox_x: Dictionary[String, float] = {}

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if has_node("ContactHitboxUp") and get_node("ContactHitboxUp") is Hitbox:
		contact_hitboxes["up"] = $ContactHitboxUp
		if contact_hitboxes["up"] is Hitbox:
			contact_hitboxes["up"].attack_direction = Vector2.UP
	if has_node("ContactHitboxLeft") and get_node("ContactHitboxLeft") is Hitbox:
		contact_hitboxes["left"] = $ContactHitboxLeft
		contact_hitboxes["left"].attack_direction = Vector2.LEFT
	if has_node("ContactHitboxRight") and get_node("ContactHitboxRight") is Hitbox:
		contact_hitboxes["right"] = $ContactHitboxRight
		contact_hitboxes["right"].attack_direction = Vector2.RIGHT
	if has_node("ContactHitboxDown") and get_node("ContactHitboxDown") is Hitbox:
		contact_hitboxes["down"] = $ContactHitboxDown
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
# MOVEMENT FUNCTION --------------------------------------------------------------------------------
## Handles movement input for the Black Knight
func run(direction: Vector2, delta: float) -> void:
	super(direction, delta)
	
	# Stops momentum immediately when changing direction
	if (direction == Vector2.RIGHT and velocity.x < 0) \
				or (direction == Vector2.LEFT and velocity.x > 0):
				velocity = Vector2(0, velocity.y)	
