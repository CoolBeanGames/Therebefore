extends RayCast3D
class_name player_raycast

@export var hit_collider : interactive

func _ready() -> void:
	GameData.references["player_raycaster"] = self

func camera_moved() -> void:
	var col = get_collider()
	if col == null:
		if hit_collider != null:
			clear_looking()
		hit_collider = null
		print("hit 'nothing'")
		return
	if col is interactive:
		process_looking(col)
		hit_collider=col
		print("hit ", col.parent.name)

func _process(_delta: float) -> void:
	if Input.is_action_just_released("interact") and hit_collider != null:
		hit_collider.interact()

func process_looking(new_object : interactive):
	if hit_collider != new_object:
		if hit_collider != null:
			hit_collider.start_looking()
		new_object.start_looking()

func clear_looking():
	GameData.references["interaction_text"].text = ""
	pass
