# PackageLoader.gd
extends Node2D

# This needs to be the resource path *within* your .pck files.
# Make sure this path exactly matches where your actual game's starting scene
# (e.g., your game's main menu, or first level) is located in your exported PCK.
const MAIN_GAME_SCENE_PATH = "res://Packages/Package_Base/game_base.tscn" # <--- IMPORTANT: Update this path!

func _ready():
	print("PackageLoader: Initializing...")
	load_packages()
	# DEFER THE CALL TO load_and_start_game()
	# This ensures it runs after the current frame's processing,
	# when the SceneTree is not busy.
	call_deferred("load_and_start_game") # <--- CHANGE IS HERE!

func load_packages():
	var pck_files = []
	var exe_path = OS.get_executable_path().get_base_dir()
	var package_path = exe_path.path_join("Packages")
	
	print("Scanning for packages in: %s" % package_path)
	
	var dir = DirAccess.open(package_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() == "pck":
				pck_files.append(package_path.path_join(file_name))
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		printerr("ERROR: Could not open packages directory at: %s" % package_path)
		return

	if pck_files.is_empty():
		print("No .pck files found in the 'Packages' directory.")
	else:
		pck_files.sort()
		print("Loading packages...")
		for file_path in pck_files:
			var success = ProjectSettings.load_resource_pack(file_path)
			if success:
				print("Successfully loaded: %s" % file_path.get_file())
			else:
				printerr("ERROR: Failed to load package: %s" % file_path)

func load_and_start_game():
	print("Attempting to load main game scene: %s" % MAIN_GAME_SCENE_PATH)
	
	var main_scene_packed = ResourceLoader.load(MAIN_GAME_SCENE_PATH)
	
	if main_scene_packed:
		if main_scene_packed is PackedScene:
			var error = get_tree().change_scene_to_packed(main_scene_packed)
			
			if error != OK:
				printerr("ERROR: Failed to change scene to %s. Error code: %s" % [MAIN_GAME_SCENE_PATH, error])
			else:
				print("Successfully loaded and started main game scene.")
		else:
			printerr("ERROR: Resource at %s is not a PackedScene. It's a: %s" % [MAIN_GAME_SCENE_PATH, typeof(main_scene_packed)])
	else:
		printerr("ERROR: Could not load main game scene at: %s" % MAIN_GAME_SCENE_PATH)
		printerr("This likely means the scene is not in any loaded .pck, or the path is wrong.")
