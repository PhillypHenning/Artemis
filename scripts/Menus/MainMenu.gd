extends CanvasLayer

@onready var main = $Main
@onready var settings = $Settings
@onready var intro_timer = $"../Timers/IntroTimer"
@onready var background = $"../Backgrounds/Background"
@onready var studio_intro = $"../Backgrounds/StudioIntro"
@onready var audio_stream_player_2d = $"../Audios/AudioStreamPlayer2D"


func _ready() -> void:
	intro_timer.start()
	audio_stream_player_2d.play()
	
	studio_intro.visible = true
	background.visible = false
	main.visible = false
	settings.visible = false

func _process(_delta: float) -> void:
	if Input.is_anything_pressed():
		intro_timer.stop()
		_on_intro_timer_timeout()

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Combat/combat_arena.tscn")


func _on_settings_button_pressed():
	main.visible = false
	settings.visible = true


func _on_quit_button_pressed():
	get_tree().quit()


func _on_back_button_pressed():
	main.visible = true
	settings.visible = false


func _on_intro_timer_timeout():
	audio_stream_player_2d.stop()
	studio_intro.visible = false
	background.visible = true
	main.visible = true
	settings.visible = false
