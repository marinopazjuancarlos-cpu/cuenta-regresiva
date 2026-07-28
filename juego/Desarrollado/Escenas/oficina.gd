extends Node2D

const RUTA_CASA = "uid://c5tycjcp8j56r"
const RUTA_VENTILACION = "uid://biilnxqs0ofwg"
const RUTA_CABLES = "uid://wghivwd36qef"

@export var lineas: Array[String] = ["fin_jornada"]
@export var una_sola_vez: bool = false

var ya_interactuado: bool = false
var secuencia_en_curso: bool = false

func _physics_process(delta: float) -> void:
	if $Player.velocity !=Vector2(0,0) and $Player/AudioStreamPlayer2D.is_playing() == false:
		$Player/AudioStreamPlayer2D.pitch_scale = randf_range(0.8,1.5)
		$Player/AudioStreamPlayer2D.play()
	if ControladorJuego.fin_de_jornada == true and una_sola_vez ==false:
		ControladorDialogo.mostrar_dialogo(lineas)
		una_sola_vez= true
		
		
		print("hola soy homero chino")

		

func _on_area_2d_body_entered(body: Node2D) -> void:
	ControladorTransiciones.ir_a_escena(RUTA_VENTILACION)

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	ControladorTransiciones.ir_a_escena(RUTA_CABLES)

func _on_area_2d_3_body_entered(body: Node2D) -> void:
	if ControladorJuego.fin_de_jornada == true:
		ControladorTransiciones.ir_a_escena(RUTA_CASA)
