extends AnimatedSprite2D
var encendido = -1
@onready var radio = [preload("uid://bt6luyhhjiecw"),preload("uid://tvord3t7e8m8")]
func _ready() -> void:
	pass

func _on_radio_2_pressed() -> void:
	encendido += 1
	if encendido == 0:
		$".".play("default")
		ControladorAudio.reproducir_musica(radio[encendido])
	if encendido == 1:
		$".".play("default")
		ControladorAudio.reproducir_musica(radio[encendido])
	if encendido == 2:
		$".".stop()
		ControladorAudio.detener_musica()
	if encendido >= 3:
		encendido = 0
