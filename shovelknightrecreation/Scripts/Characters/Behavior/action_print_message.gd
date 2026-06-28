@tool

class_name PrintMessage
extends ActionLeaf

@export var message: String


func tick(actor: Node, blackboard: Blackboard) -> int:
	if message:
		print(message)
		return SUCCESS
	else:
		return FAILURE
