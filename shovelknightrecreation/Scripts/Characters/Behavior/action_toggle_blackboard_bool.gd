@tool
class_name ToggleBlackboardBool
extends ActionLeaf

@export var blackboard_key: String


func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value(blackboard_key) != null:
		if blackboard.get_value(blackboard_key) is bool:
			blackboard.set_value(blackboard_key, not blackboard.get_value(blackboard_key))
			return SUCCESS
	return FAILURE


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	return
