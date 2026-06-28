@tool

class_name AdjustRetreatProbability
extends ActionLeaf


@export var retreat_probability_delta: float = .25
#@export var vision_cone_angle: float = 45.0  # degrees

func tick(actor: Node, blackboard: Blackboard) -> int:
	var current_probability = blackboard.get_value("retreat_probability")
	blackboard.set_value("retreat_probability", current_probability + retreat_probability_delta)
	return SUCCESS
