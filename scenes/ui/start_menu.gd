extends CanvasLayer

@export var next_scene: PackedScene
@export var options_scene: PackedScene

@onready var start_button: Button = $ColorRect/StartButton
@onready var options_button: Button = $ColorRect/OptionsButton
@onready var quit_button: Button = $ColorRect/QuitButton

func _ready() -> void:
	visible = true
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed() -> void:
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
	else:
		visible = false

func _on_options_button_pressed() -> void:
	if options_scene:
		get_tree().change_scene_to_packed(options_scene)
	else:
		print("Options button clicked!")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
