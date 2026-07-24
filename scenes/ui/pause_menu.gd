extends CanvasLayer

@export var options_scene: PackedScene

@onready var resume_button: Button = $ColorRect/ResumeButton
@onready var options_button: Button = $ColorRect/OptionsButton
@onready var quit_button: Button = $ColorRect/QuitButton

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_on_resume_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		toggle_pause()

func toggle_pause() -> void:
	visible = !visible
	get_tree().paused = visible

func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_options_button_pressed() -> void:
	if options_scene:
		get_tree().paused = false
		get_tree().change_scene_to_packed(options_scene)
	else:
		print("Options button clicked!")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
