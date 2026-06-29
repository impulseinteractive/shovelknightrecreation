@tool

class_name ShovelSwingAction
extends ActionLeaf

@export var attack_cooldown: float = 1.0
var time_since_last_attack: float = 0.0


func tick(actor: Node, blackboard: Blackboard) -> int:
	# Enforce knight class on actor variable
	var knight_actor: Knight = actor
	
	# Perform attack
	print("Enemy attacks player!")
	knight_actor.shovel_swing()
	return SUCCESS


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	return
