extends AudioStreamPlayer3D
class_name AudioPlayer

signal stream_finished


func _on_finished() -> void:
	stream_finished.emit()
	pass # Replace with function body.
