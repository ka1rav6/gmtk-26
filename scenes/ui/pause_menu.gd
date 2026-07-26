extends CanvasLayer

@onready var resume_button: Button = $ColorRect/ResumeButton
@onready var restart_button: Button = $ColorRect/RestartButton
@onready var how_to_play_button: Button = $ColorRect/HowToPlayButton
@onready var quit_button: Button = $ColorRect/QuitButton
@onready var how_to_play_overlay: CanvasLayer = $HowToPlayOverlay

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_on_resume_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	how_to_play_button.pressed.connect(_on_how_to_play_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	how_to_play_overlay.closed.connect(_on_how_to_play_closed)

func _input(event: InputEvent) -> void:
	if how_to_play_overlay.visible:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		toggle_pause()

func toggle_pause() -> void:
	visible = !visible
	get_tree().paused = visible

func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_restart_button_pressed() -> void:
	Global.restart_current_level()

func _on_how_to_play_button_pressed() -> void:
	_set_menu_buttons_disabled(true)
	how_to_play_overlay.open()

func _on_how_to_play_closed() -> void:
	_set_menu_buttons_disabled(false)

func _set_menu_buttons_disabled(is_disabled: bool) -> void:
	resume_button.disabled = is_disabled
	restart_button.disabled = is_disabled
	how_to_play_button.disabled = is_disabled
	quit_button.disabled = is_disabled

func _on_quit_button_pressed() -> void:
	get_tree().quit()
