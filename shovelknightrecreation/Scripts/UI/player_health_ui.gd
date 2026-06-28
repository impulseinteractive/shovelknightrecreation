extends Control

@export var life_bubble_empty: Texture2D
@export var life_bubble_half: Texture2D
@export var life_bubble_full: Texture2D

#var texture_rect_ref: TextureRect
@onready var life_bar_container: HBoxContainer = %LifeBarContainer

var ui_max_health: int = 10
@export var player_ref: ShovelKnight

var ui_current_health: int = ui_max_health

@export var debug_input: bool = false

#signal on_player_health_changed(new_health: int)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#on_player_health_changed.connect(update_player_health)
	player_ref.on_health_changed.connect(update_player_health)
	
	if player_ref:
		ui_max_health = player_ref.max_health
		ui_current_health = player_ref.current_health

	for i in ceil(ui_max_health / 2):
		var texture_rect_ref: TextureRect = TextureRect.new()
		texture_rect_ref.texture = life_bubble_full
		life_bar_container.add_child(texture_rect_ref)

	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if debug_input and Input.is_action_just_pressed("ui_page_down"):
		ui_current_health -= 1
		player_ref.on_health_changed.emit(ui_current_health)
		pass
	pass


func update_player_health(new_health: int):
	ui_current_health = new_health
	var life_bubbles = life_bar_container.get_children()
	for idx in ceil(ui_max_health / 2):
		if idx < ceil(ui_current_health / 2):
			var texture_bubble: TextureRect = life_bubbles.get(idx)
			texture_bubble.texture = life_bubble_full
		else:
			var texture_bubble: TextureRect = life_bubbles.get(idx)
			texture_bubble.texture = life_bubble_empty
	
	if ui_current_health % 2 != 0:
		print("Odd")
		var last_bubble: TextureRect = life_bubbles.get(ceil(ui_current_health / 2))
		last_bubble.texture = life_bubble_half
	return
