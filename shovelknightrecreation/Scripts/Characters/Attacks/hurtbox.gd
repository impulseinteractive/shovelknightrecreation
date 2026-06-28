class_name Hurtbox
extends Area2D

@export_category("Collision")
@export var monitored_group: StringName ##Group that can be detected by the hurtbox


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monitorable = false
	area_entered.connect(_on_area_entered)

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Plays when another area enters this one
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group(monitored_group) and area.has_method("deal_damage"):
		print("Hit connected with " + get_parent().name)
		area.deal_damage(self)
		
