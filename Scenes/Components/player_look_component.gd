extends RayCast3D
class_name player_look

@export var collider_look_at : CollisionObject3D
@export var interact_look_at : interactable


func _process(delta: float) -> void:
	if is_colliding():
		var col = get_collider()
		if col is interactable:
			var interact : interactable = col
			var old_interact : interactable = interact_look_at
			var is_empty : bool = interact_look_at == null
			var is_same : bool = interact_look_at == col
			interact_look_at = interact
			collider_look_at = col
			var ui : game_hud = References.get_reference("ui")
			if is_same:
				interact_check()
				return
			if is_empty:
				interact.start_looking_at()
				interact_check()
				return
			old_interact.stop_looking_at()
			interact_look_at.start_looking_at()
			interact_check()
			return
	else:
		if interact_look_at != null:
			interact_look_at.stop_looking_at()
			var ui : game_hud = References.get_reference("ui")
			ui.clear_interaction()
			collider_look_at=null
			interact_look_at = null

func interact_check():
	if interact_look_at != null and Input.is_action_just_released("confirm"):
		interact_look_at.interact()
