@tool
class_name IsCollidingWall
extends ConditionLeaf

## Restrict detection to specific physics layers
@export_flags_2d_physics var world_layers: int = 0

func tick(actor: Node, blackboard: Blackboard) -> int:
	if not actor is CharacterBody2D:
		blackboard.set_value("IsCollidingWithWall", false)
		return FAILURE
 
	var body: CharacterBody2D = actor
 
	if not body.is_on_wall():
		blackboard.set_value("IsCollidingWithWall", false)
		return FAILURE
 
	if world_layers == 0:
		blackboard.set_value("IsCollidingWithWall", true)
		return SUCCESS
 
	for i in body.get_slide_collision_count():
		var collision := body.get_slide_collision(i)
		var collider := collision.get_collider()
		if collider == null:
			continue
 
		var layer_ok := world_layers == 0
		if not layer_ok and collider is CollisionObject2D:
			layer_ok = (collider.collision_layer & world_layers) != 0
 
		if layer_ok:
			blackboard.set_value("IsCollidingWithWall", true)
			return SUCCESS
 
	blackboard.set_value("IsCollidingWithWall", false)
	return FAILURE
