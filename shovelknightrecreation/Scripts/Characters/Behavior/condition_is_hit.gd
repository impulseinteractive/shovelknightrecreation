@tool
class_name IsHit
extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("is_hit"):
		return SUCCESS
	return RUNNING
