extends Node

const scenes_folder = "res://code/tscn/"
const settings_file = "user://settings.conf"
const save_file_folder = "user://" #%appdata%/Godot/app_userdata/Mayan 300 <- Temporal title

var current_scene = null

var language = null
var music_v = null
var sound_v = null
var dialogue_v = null
var current_save_file = null

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
	file.open((save_file_folder + name + ".save"), File.WRITE)

	# SAVE SCENE
	file.store_var(current_scene.name, true)

	# SAVE PLAYER ATTRIBUTES
	file.store_var(player.HEALTH, true)
	file.store_var(player.position.x, true)
	file.store_var(player.position.y, true)
	file.close()

	#SAVE DECISIONS TREE (Not sure how should i develop this...)

	current_save_file = name
	save_settings()
	
	print("saving file")


func load_file(name):
	var file = File.new()

	if file.file_exists(save_file_folder + name + ".save"):
		file.open((save_file_folder + name + ".save"), File.READ)

		#GET SCENE
		var scene_reference = file.get_var(true)

		#GET PLAYER ATTRIBUTES
		var player_reference_HEALTH = file.get_var(true)
		var player_reference_x = file.get_var(true)
		var player_reference_y = file.get_var(true)

		#GET CURRENT DECISIONS TREE

		file.close()

		#SCENE TO LOAD
		goto_scene(scenes_folder + scene_reference + ".tscn")

		var player = current_scene.get_node("Player")
		print(player)
		player.HEALTH = player_reference_HEALTH
		player.position.x = player_reference_x
		player.position.y = player_reference_y
	else:
		print("WTF STOP HACKING PLOX GGEZBBQROFLCOPTERXD")
	print("loading file")
