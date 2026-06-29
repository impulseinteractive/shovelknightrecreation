@tool
class_name ApproachPlayer
extends ActionLeaf

#@export var move_speed: float = 10.0
#@export var attack_range: float = 150.0


func tick(actor: Node, blackboard: Blackboard) -> int:
	# Get the player position from the blackboard
	#var player_pos = blackboard.get_value("player_position")
	var player: Knight = get_tree().get_first_node_in_group("player")

	if not player:
		return FAILURE
	
	# Calculate direction to player, only care about x direction
	var direction = (player.global_position - actor.global_position).normalized()
	direction.y = 0.0
	
	# Move toward player
	var knight_actor: Knight = actor
	knight_actor.run(direction, get_physics_process_delta_time())

	# Check if within attack range, only check x values because only care about horizontal positioning
	var distance = knight_actor.global_position.x - player.global_position.x
	
	if distance <= blackboard.get_value("attack_range"):
		return SUCCESS
	
	# Still chasing
	return RUNNING


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	return
