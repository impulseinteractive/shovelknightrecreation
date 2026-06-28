extends Control

@export var life_bubble_empty: Texture2D
@export var life_bubble_half: Texture2D
@export var life_bubble_full: Texture2D

#var texture_rect_ref: TextureRect
@onready var life_bar_container: HBoxContainer = %LifeBarContainer

var ui_max_health: int = 0
@export var boss_ref: Knight

var ui_current_health: int = ui_max_health

@export var debug_input: bool = false

signal on_boss_health_changed(new_health: int)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	on_boss_health_changed.connect(update_boss_health)
	
	if boss_ref:
		ui_max_health = boss_ref.max_health
		ui_current_health = boss_ref.current_health

	for i in ceil(ui_max_health / 2):
		var texture_rect_ref: TextureRect = TextureRect.new()
		texture_rect_ref.texture = life_bubble_full
		life_bar_container.add_child(texture_rect_ref)

	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if debug_input and Input.is_action_just_pressed("ui_page_up"):
		ui_current_health -= 1
		on_boss_health_changed.emit(ui_current_health)
		pass
	pass


func update_boss_health(new_health: int):
	var life_bubbles = life_bar_container.get_children()
	for idx in ceil(ui_max_health / 2):
		if idx < ceil(ui_current_health / 2):
			var texture_bubble: TextureRect = life_bubbles.get(idx)
			texture_bubble.texture = life_bubble_full
		else:
			var texture_bubble: TextureRect = life_bubbles.get(idx)
			texture_bubble.texture = life_bubble_empty
	
	if new_health % 2 != 0:
		print("Odd")
		var last_bubble: TextureRect = life_bubbles.get(ceil(new_health / 2))
		last_bubble.texture = life_bubble_half
	return
