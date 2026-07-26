extends AnimatedSprite2D
func _ready() -> void:
	ControladorAudio.reproducir_musica(preload("res://OST/RADIO_CASSETE_MÚSICA_PUNK.ogg"))
	$".".play("default")

# Called when the node enters the scene tree for the first time.
