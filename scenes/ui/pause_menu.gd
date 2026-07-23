extends CanvasLayer

@onready var resume_button: Button = $ColorRect/ResumeButton
@onready var options_button: Button = $ColorRect/OptionsButton
@onready var quit_button: Button = $ColorRect/QuitButton

func _ready() -> void:
    visible = false
    process_mode = Node.PROCESS_MODE_ALWAYS
    resume_button.pressed.connect(_on_resume_button_pressed)
    options_button.pressed.connect(_on_options_button_pressed)
    quit_button.pressed.connect(_on_quit_button_pressed)

func _on_resume_button_pressed() -> void:
    visible = false
    get_tree().paused = false

func _on_options_button_pressed() -> void:
    print("Options button clicked!")

func _on_quit_button_pressed() -> void:
    get_tree().quit()
