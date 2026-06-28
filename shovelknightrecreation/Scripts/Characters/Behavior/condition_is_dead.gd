@tool
class_name IsDead
extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("is_dead"):
		return SUCCESS
	return FAILURE
