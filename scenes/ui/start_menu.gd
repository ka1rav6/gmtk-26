extends CanvasLayer

@export_file("*.tscn") var next_scene_path: String
@export_file("*.tscn") var options_scene_path: String

@onready var start_button: Button = $ColorRect/StartButton
@onready var how_to_play_button: Button = $ColorRect/HowToPlayButton
@onready var options_button: Button = $ColorRect/OptionsButton
@onready var quit_button: Button = $ColorRect/QuitButton
@onready var how_to_play_overlay: CanvasLayer = $HowToPlayOverlay

func _ready() -> void:
	visible = true
	start_button.pressed.connect(_on_start_button_pressed)
	how_to_play_button.pressed.connect(_on_how_to_play_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	how_to_play_overlay.closed.connect(_on_how_to_play_closed)

func _on_start_button_pressed() -> void:
	if next_scene_path:
		Global.start_level(load(next_scene_path))
	else:
		visible = false

func _on_how_to_play_button_pressed() -> void:
	_set_menu_buttons_disabled(true)
	how_to_play_overlay.open()

func _on_how_to_play_closed() -> void:
	_set_menu_buttons_disabled(false)

func _set_menu_buttons_disabled(is_disabled: bool) -> void:
	start_button.disabled = is_disabled
	how_to_play_button.disabled = is_disabled
	options_button.disabled = is_disabled
	quit_button.disabled = is_disabled

func _on_options_button_pressed() -> void:
	if options_scene_path:
		get_tree().paused = false
		get_tree().change_scene_to_file(options_scene_path)
	else:
		print("Options button clicked!")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
