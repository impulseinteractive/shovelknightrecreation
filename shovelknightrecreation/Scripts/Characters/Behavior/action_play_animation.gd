@tool
class_name PlayAnimation
extends ActionLeaf

@export var sprite: AnimatedSprite2D
@export var animation_name: StringName = ""


func tick(actor: Node, blackboard: Blackboard) -> int:
	sprite.animation = animation_name
	sprite.play(animation_name)
	return SUCCESS
