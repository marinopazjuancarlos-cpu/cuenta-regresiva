extends Node2D
class_name DulceHogar

const RUTA_OFICINA = "uid://cfd61lgqbjf37"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func _physics_process(delta: float) -> void:
	if $Player.velocity !=Vector2(0,0) and $Player/AudioStreamPlayer2D.is_playing() == false:
		$Player/AudioStreamPlayer2D.pitch_scale = randf_range(0.8,1.5)
		$Player/AudioStreamPlayer2D.play()
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_area_2d_body_entered(body: Node2D) -> void:
		ControladorAudio.detener_musica()
		ControladorTransiciones.ir_a_escena(RUTA_OFICINA)


func _on_radio_body_entered(body: Node2D) -> void:

	pass


func _on_radio_2_pressed() -> void:
	$boton.play()
