extends Node

@onready var start_menu: CanvasLayer = $StartMenu
@onready var pause_button: Button = $PauseButton
@onready var pause_menu: CanvasLayer = $PauseMenu

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    start_menu.visible = true
    pause_button.visible = false
    pause_button.pressed.connect(_on_pause_button_pressed)
    pause_menu.visible = false

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ESCAPE:
            # Don't toggle pause if start menu is showing
            if start_menu.visible:
                return
            toggle_pause()

func _on_pause_button_pressed() -> void:
    toggle_pause()

func toggle_pause() -> void:
    if pause_menu.visible:
        pause_menu.visible = false
        get_tree().paused = false
        pause_button.visible = true
    else:
        pause_menu.visible = true
        get_tree().paused = true
        pause_button.visible = false

func _on_start_game() -> void:
    pause_button.visible = true
