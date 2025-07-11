extends Resource
class_name PlayerSettings

@export var invert_y: bool = false

const SAVE_PATH := "PlayerData/settings.sav"
# This password is used directly by FileAccess.open_encrypted_with_pass().
# Still, hardcoding it is a security risk. For production, consider obfuscation
# or deriving it from something unique to the user/system, though that adds complexity.
const FILE_ENCRYPTION_PASSWORD := "your-strong-password-goes-here" 

func get_full_path() -> String:
	var base_dir = OS.get_user_data_dir()
	return base_dir.path_join(SAVE_PATH)

func save_settings():
	var data = {
		"invert_y": invert_y
	}

	var json_string := JSON.stringify(data)
	
	# Ensure directory exists
	var dir := DirAccess.open(OS.get_user_data_dir())
	if not dir.dir_exists("PlayerData"):
		dir.make_dir("PlayerData")

	# Use FileAccess.open_encrypted_with_pass() for saving
	var file := FileAccess.open_encrypted_with_pass(get_full_path(), FileAccess.WRITE, FILE_ENCRYPTION_PASSWORD)
	if file:
		file.store_string(json_string) # Store the JSON string directly
		file.close()
		print("Settings saved successfully (encrypted).")
	else:
		push_error("Failed to open file for writing (encrypted).")

func load_settings():
	var path := get_full_path()
	if not FileAccess.file_exists(path):
		print("No settings file found. Using defaults.")
		save_settings() # Save defaults if no file exists
		return

	# Use FileAccess.open_encrypted_with_pass() for loading
	var file := FileAccess.open_encrypted_with_pass(path, FileAccess.READ, FILE_ENCRYPTION_PASSWORD)
	if not file:
		push_error("Failed to open settings file (encrypted). Decryption likely failed or file is corrupt.")
		# If decryption fails, FileAccess.open_encrypted_with_pass will return null.
		# In this case, we treat it as a corrupt file.
		_delete_corrupt_file_and_save_defaults(path)
		return

	var json_string := file.get_as_text() # Get the decrypted JSON string
	file.close()

	var json := JSON.new()
	var err := json.parse(json_string)
	if err != OK:
		print("JSON parse error after decryption. File will be deleted.")
		_delete_corrupt_file_and_save_defaults(path)
		return

	var result: Dictionary = json.data
	if typeof(result) != TYPE_DICTIONARY \
		or not result.has("invert_y") \
		or typeof(result["invert_y"]) != TYPE_BOOL:
		print("Corrupt or unknown data after decryption. Resetting.")
		_delete_corrupt_file_and_save_defaults(path)
		return

	invert_y = result["invert_y"]
	print("Settings loaded successfully (encrypted).")

func _delete_corrupt_file_and_save_defaults(path: String):
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Corrupt file deleted.")
	print("Reset to defaults.")
	save_settings()
