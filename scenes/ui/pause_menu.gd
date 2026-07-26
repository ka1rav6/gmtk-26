extends CanvasLayer

@onready var title_label: Label = $ColorRect/TitleLabel
@onready var resume_button: Button = $ColorRect/ResumeButton
@onready var restart_button: Button = $ColorRect/RestartButton
@onready var how_to_play_button: Button = $ColorRect/HowToPlayButton
@onready var quit_button: Button = $ColorRect/QuitButton
@onready var how_to_play_overlay: CanvasLayer = $HowToPlayOverlay

const DEATH_TITLE := "You Died"
const DEATH_TITLE_COLOR := Color(0.9, 0.16, 0.22)
# Vertical gap Resume leaves behind when it's hidden; the buttons below it
# slide up by this much so the death screen doesn't have a hole in it.
const RESUME_SLOT_HEIGHT := 67.0

# Once the player is dead this menu is the only thing left running, so it
# stops behaving like a pause screen: no resuming, and Escape can't dismiss it.
var is_dead := false

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_on_resume_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	how_to_play_button.pressed.connect(_on_how_to_play_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	how_to_play_overlay.closed.connect(_on_how_to_play_closed)

func _input(event: InputEvent) -> void:
	if how_to_play_overlay.visible or is_dead:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		toggle_pause()

func toggle_pause() -> void:
	if is_dead:
		return
	visible = !visible
	get_tree().paused = visible

# Called by the player when its health hits zero. Reuses this menu so the
# death screen and the pause screen never drift apart.
func show_death_screen() -> void:
	is_dead = true
	title_label.text = DEATH_TITLE
	title_label.add_theme_color_override("font_color", DEATH_TITLE_COLOR)
	resume_button.visible = false
	for button in [restart_button, how_to_play_button, quit_button]:
		button.offset_top -= RESUME_SLOT_HEIGHT
		button.offset_bottom -= RESUME_SLOT_HEIGHT
	visible = true
	get_tree().paused = true

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
