@tool
class_name IsPlayerClose
extends ConditionLeaf


@export var player_detection_range: float = 20.0
#@export var vision_cone_angle: float = 45.0  # degrees

func tick(actor: Node, blackboard: Blackboard) -> int:
	# Get player reference (could be cached in blackboard)
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return FAILURE
	
	# Calculate distance and direction to player
	var to_player = player.global_position - actor.global_position
	var distance = to_player.length()
	print("[BEEHAVE BK] DISTANCE TO PLAYER: ", distance)
	
	# Check if player is within detection range
	if distance > player_detection_range:
		return FAILURE

	return SUCCESS
