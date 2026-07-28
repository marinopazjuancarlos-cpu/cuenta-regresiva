extends Control


@onready var continuar_button: Button = %ContinuarButton
@onready var nueva_partida_button: Button = %NuevaPartidaButton
@onready var creditos_button: Button = %CreditosButton


func _ready() -> void:
	continuar_button.visible = ControladorJuego.hay_partida_actual()


func _on_continuar_button_pressed() -> void:
	$pulsar.play()
	ControladorJuego.continuar_partida()
	ControladorTransiciones.ir_a_escena(ControladorJuego.RUTA_OFICINA, "Continuar donde lo dejaste...[br]No siempre es la mejor idea...")


func _on_nueva_partida_button_pressed() -> void:
	$pulsar.play()
	ControladorJuego.nueva_partida()
	ControladorTransiciones.ir_a_escena(ControladorJuego.RUTA_OFICINA,tr("dia_1_dialogo1_interacion1") + "[br]" + tr("dia_1_dialogo1_interacion2") + "[br]" + tr("dia_1_dialogo1_interacion3"), 1.5, false)
	

func _on_creditos_button_pressed() -> void:
	$pulsar.play()
	print("Se supone que va una escena de creditos aqui, pero no se...")
