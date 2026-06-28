class_name ShovelKnight
extends Knight

@export_category("Movement")
@export var pivot_delay: float = 0.1 ## How long it takes to start moving after pivoting

var pivot_timer: float = 0.0 ## Tracks times since pivot started

# Movement flags
var pivoting: bool = false ## Whether the knight is pivoting

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

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
	
## Handles movement input for the Shovel Knight
func run(direction: Vector2, delta: float):
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
