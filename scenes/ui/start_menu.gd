extends CanvasLayer

@onready var start_button: Button = $ColorRect/StartButton
@onready var options_button: Button = $ColorRect/OptionsButton
@onready var quit_button: Button = $ColorRect/QuitButton

func _ready() -> void:
    visible = true
    process_mode = Node.PROCESS_MODE_ALWAYS
    start_button.pressed.connect(_on_start_button_pressed)
    options_button.pressed.connect(_on_options_button_pressed)
    quit_button.pressed.connect(_on_quit_button_pressed)
    get_tree().paused = true

func _on_start_button_pressed() -> void:
    visible = false
    get_tree().paused = false
    # Notify parent UIController to show pause button
    var parent = get_parent()
    if parent and parent.has_method("_on_start_game"):
        parent._on_start_game()

func _on_options_button_pressed() -> void:
    print("Options button clicked!")

func _on_quit_button_pressed() -> void:
    get_tree().quit()
