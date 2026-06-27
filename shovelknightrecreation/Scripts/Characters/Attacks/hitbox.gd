class_name Hitbox
extends Area2D

const HITBOX_LAYER: int = 32 ## The collision layer hitboxes exist on

var group: StringName   			  ## Name of the group the hitbox belongs to
var lifetime: float 				  ## Total time the hitbox exists in the scene
var shape: Shape2D  				  ## Shape of the hitbox
var collision_shape: CollisionShape2D ## The hitbox itself

## Initialize the hitbox
func _init(_group: StringName, _shape: Shape2D, _lifetime: float = 0.0) -> void:
	group = _group
	shape = _shape
	lifetime = _lifetime
	
	# Set the lifetime timer
	if lifetime > 0.0:
		var lifetime_timer = Timer.new()
		add_child(lifetime_timer)
		lifetime_timer.timeout.connect(queue_free)
		lifetime_timer.call_deferred("start", lifetime)
		
	# Create the hitbox
	collision_shape = CollisionShape2D.new()
	collision_shape.shape = shape
	add_child(collision_shape)
	
	# Remove default layers
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	#Set hitbox layer and assign to group
	set_collision_layer_value(HITBOX_LAYER, true)
	add_to_group(group)

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monitoring = false
