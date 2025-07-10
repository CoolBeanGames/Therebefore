# PackageLoader.gd
extends Node

# This function is automatically called when the node enters the scene tree.
# As an autoload, this will happen at the very start of the game.
func _ready():
	load_packages()

# Scans the 'Packages' directory next to the executable, and loads all .pck files.
func load_packages():
	var pck_files = []
	
	# Get the directory where the executable is located.
	var exe_path = OS.get_executable_path().get_base_dir()
	var package_path = exe_path.path_join("Packages")
	
	print("Scanning for packages in: %s" % package_path)
	
	# Open the 'Packages' directory
	var dir = DirAccess.open(package_path)
	if dir:
		# Iterate over all files in the directory
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# We only care about files ending in .pck
			if not dir.current_is_dir() and file_name.get_extension() == "pck":
				pck_files.append(package_path.path_join(file_name))
			
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		printerr("ERROR: Could not open packages directory at: %s" % package_path)
		return

	# If we found no .pck files, there's nothing else to do.
	if pck_files.is_empty():
		print("No .pck files found in the 'Packages' directory.")
		return

	# Sort the list of files alphanumerically.
	pck_files.sort()
	
	# Load each .pck file in the sorted order.
	print("Loading packages...")
	for file_path in pck_files:
		var success = ProjectSettings.load_resource_pack(file_path)
		if success:
			print("Successfully loaded: %s" % file_path.get_file())
		else:
			printerr("ERROR: Failed to load package: %s" % file_path)
