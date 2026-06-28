@tool
class_name IsRetreating
extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var retreat_probability = blackboard.get_value("retreat_probability")
	var chance = randf()
	if chance < retreat_probability:
		print("[BEEHAVE] START RETREAT")
		return SUCCESS
	
	return FAILURE
