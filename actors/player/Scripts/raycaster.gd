extends RayCast3D

@export var hit_collider : Node3D

func camera_moved(input) -> void:
	var col = get_collider()
	if col != null:
		hit_collider = col
		print(col)
	else:
		hit_collider=null
		print("nothing was hit")
