extends Area2D

const RUTA_CASA = "uid://c5tycjcp8j56r"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("click") and ControladorJuego.fin_de_jornada == true:
		ControladorJuego.dia_actual += 1
		ControladorJuego.fin_de_jornada = false
		ControladorTransiciones.ir_a_escena(RUTA_CASA)
		
