extends CanvasLayer

## Shared "How to Play" popup. Instanced by both StartMenu and PauseMenu so
## the content and behavior only live in one place. Call open() to show it;
## it emits `closed` when the player backs out, so whoever opened it can
## re-enable their own buttons if needed.

signal closed

@onready var back_button: Button = $ColorRect/PanelContainer/BackButton

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	back_button.pressed.connect(_on_back_pressed)

func open() -> void:
	visible = true

func _on_back_pressed() -> void:
	visible = false
	closed.emit()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_back_pressed()
		get_viewport().set_input_as_handled()
