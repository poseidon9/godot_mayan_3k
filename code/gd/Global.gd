extends Node

var current_scene = null
var current_save_file = null
var settings_file = "user://settings.conf"
var save_file_folder = "user://"
var language = null
var music_v = null
var sound_v = null
var dialogue_v = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

	#LOAD SETTINGS
	load_settings()

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)


func save_settings():
	var file = File.new()
	file.open(settings_file, File.WRITE)
	file.store_var(language)
	file.store_var(music_v)
	file.store_var(sound_v)
	file.store_var(dialogue_v)
	file.store_var(current_save_file)
	file.close()
	print("saving settings")


func load_settings():
	var file = File.new()
	if file.file_exists(settings_file):
		file.open(settings_file, File.READ)
		language = file.get_var()
		music_v = file.get_var()
		sound_v = file.get_var()
		dialogue_v = file.get_var()
		current_save_file = file.get_var()
		file.close()
	else:
		language = "en" #not used/implemented yet
		music_v = 100 #not used/implemented yet
		sound_v = 100 #not used/implemented yet
		dialogue_v = 100 #not used/implemented yet
		current_save_file = null

	print("loading settings")


func save_file(player, name):
	var file = File.new()
	print("POO POO")
	file.open((save_file_folder + name + ".save"), File.WRITE)
	file.store_var(player.HEALTH, true)
	file.store_var(player, true)
	file.close()

	print("save current life: " + str(player.HEALTH))
	print("save current x: " + str(player.position.x))
	print("save current y: " + str(player.position.y))

	#current_save_file = name
	#save_settings()
	print("saving file")


func load_file(player, name):
	var file = File.new()
	if file.file_exists(save_file_folder + name + ".save"):
		file.open((save_file_folder + name + ".save"), File.READ)
		var player_reference_HEALTH = file.get_var(true)
		var player_reference = file.get_var(true)
		file.close()

		print("load life: " + str(player_reference_HEALTH))
		print("load x: " + str(player_reference.position.x))
		print("load y: " + str(player_reference.position.y))
		player.position.x = player_reference.position.x
		player.position.y = player_reference.position.y
		player.HEALTH = player_reference_HEALTH
	else:
		print("WTF STOP HACKING PLOX GGEZBBQROFLCOPTERXD")
	print("loading file")
