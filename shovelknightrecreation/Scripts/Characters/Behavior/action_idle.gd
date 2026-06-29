@tool
class_name Idle
extends ActionLeaf

#@export var idle_time: float = 5.0
var current_time: float = 0.0


func tick(actor: Node, blackboard: Blackboard) -> int:
	blackboard.set_value("is_idle", true)
	if current_time >= blackboard.get_value("idle_time"):
		print("[BEHAVIOR] done idling...")
		#blackboard.set_value("is_idle", false)
		current_time = 0.0
		return SUCCESS
	else:
		current_time += get_physics_process_delta_time()
	
	# Still idling
	return RUNNING


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	return
