@tool

class_name ShovelSwingAction
extends ActionLeaf

@export var attack_cooldown: float = 1.0
var time_since_last_attack: float = 0.0


func tick(actor: Node, blackboard: Blackboard) -> int:
	# Enforce knight class on actor variable
	var knight_actor: Knight = actor
	
	# Check if cooldown has elapsed
	if time_since_last_attack < attack_cooldown:
		time_since_last_attack += get_physics_process_delta_time()
		return RUNNING
	
	# Reset cooldown
	time_since_last_attack = 0.0
	
	# Perform attack
	print("Enemy attacks player!")
	knight_actor.shovel_swing()
	# In a real game, you might trigger an animation or spawn a projectile here
	
	
	
	return SUCCESS


func interrupt(actor: Node, blackboard: Blackboard) -> void:
	return
