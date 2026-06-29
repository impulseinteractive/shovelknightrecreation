@tool
class_name IsIdling
extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var idle_probability = blackboard.get_value("idle_probability")
	var chance = randf()
	if chance < idle_probability:
		print("[BEEHAVE] START IDLING")
		blackboard.set_value("is_idle", true)
		return SUCCESS
	
	return FAILURE
