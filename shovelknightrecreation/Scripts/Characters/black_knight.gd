class_name BlackKnight
extends Knight


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Debugging actions for health functions
	if Input.is_action_just_pressed("move_left"):
		take_damage()
	
	
	if Input.is_action_just_pressed("move_right"):
		restore_to_full_health(0.2)
	
	pass
	
## Handles movement input for the Black Knight
func run(direction: Vector2, delta: float) -> void:
	super(direction, delta)
	
	# Stops momentum immediately when changing direction
	if (direction == Vector2.RIGHT and velocity.x < 0) \
				or (direction == Vector2.LEFT and velocity.x > 0):
				velocity = Vector2(0, velocity.y)
