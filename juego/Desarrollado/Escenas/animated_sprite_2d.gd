extends AnimatedSprite2D
var encendido : int
@onready var radio = [preload("uid://tvord3t7e8m8"),preload("uid://bt6luyhhjiecw")]
func _ready() -> void:
	pass
	

# Called when the node enters the scene tree for the first time.




func _on_radio_2_pressed() -> void:
	$".".play("default")
	
	if encendido == 1:
		
		ControladorAudio.reproducir_musica(preload("uid://pby5qpqwos21"))
		encendido = 0
		ControladorAudio.reproducir_musica(radio[encendido])
	else:
		ControladorAudio.reproducir_musica(preload("uid://pby5qpqwos21"))
		encendido = 1
		ControladorAudio.reproducir_musica(radio[encendido])
	#ControladorAudio.reproducir_musica(preload("res://OST/RADIO_CASSETE_MÚSICA_PUNK.ogg"))
