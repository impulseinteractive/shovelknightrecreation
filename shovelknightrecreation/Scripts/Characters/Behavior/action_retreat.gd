@tool
class_name Retreat
extends ActionLeaf

## Max retreat distance before SUCCESS
@export var retreat_distance: float = 400.0

## Max retreat time before SUCCESS, in case player chases the AI and can never get far enough away
@export var retreat_max_timer: float = 3.0
var current_retreat_time: float = 0.0


func tick(actor: Node, blackboard: Blackboard) -> int:
	# Get the player position from the blackboard
	var player: Knight = get_tree().get_first_node_in_group("player")

	if not player:
		return FAILURE
	
	# Calculate direction to player, only care about x direction
	var direction = -(player.global_position - actor.global_position).normalized()
	direction.y = 0.0
	
	# Move toward player
	var knight_actor: Knight = actor
	knight_actor.run(direction, get_physics_process_delta_time())
	
	current_retreat_time += get_physics_process_delta_time()
	
	# Check if within attack range, only check x values because only care about horizontal positioning
	var distance = knight_actor.global_position.x - player.global_position.x
	
	if distance >= retreat_distance or current_retreat_time >= retreat_max_timer:
		blackboard.set_value("retreat_probability", 0.0)
		current_retreat_time = 0.0
		return SUCCESS
	
	# Still chasing
	return RUNNING


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	current_retreat_time = 0.0
	return
