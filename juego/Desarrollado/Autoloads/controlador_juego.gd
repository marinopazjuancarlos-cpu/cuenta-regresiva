extends Node


enum Final { A, B, C }

const RUTA_GUARDADO = "user://partida.save"
const MINIJUEGOS_POR_DIA = [2, 3, 4]

#PENDIENTES DE CREAR: las tres escenas de final
const RUTA_OFICINA = "uid://cfd61lgqbjf37"
const RUTAS_FINAL = {
	Final.A: "res://Desarrollado/Escenas/final_a.tscn",
	Final.B: "res://Desarrollado/Escenas/final_b.tscn",
	Final.C: "res://Desarrollado/Escenas/final_c.tscn",
}

signal progreso_actualizado

var dia_actual: int = 1
var indice_minijuego_actual: int = 0
var partida_en_curso: bool = false
var puntos_por_final: Dictionary = {Final.A: 0, Final.B: 0, Final.C: 0}

var _instancia_minijuego_actual: Node = null


func _ready() -> void: get_viewport().physics_object_picking = true


#LLAMAR AL TERMINAR CADA MINIJUEGO: SUMA UN PUNTO AL FINAL QUE CORRESPONDA
#CADA MINIJUEGO PASA SUS PROPIOS UMBRALES, YA QUE CADA UNO TIENE SU PROPIA ESCALA DE PUNTOS
func registrar_puntaje_minijuego(puntos: int, umbral_final_a: int, umbral_final_b: int) -> void:
	puntos_por_final[_final_por_puntaje(puntos, umbral_final_a, umbral_final_b)] += 1


func hay_partida_actual() -> bool: return FileAccess.file_exists(RUTA_GUARDADO)


func nueva_partida() -> void: 
	dia_actual = 1
	indice_minijuego_actual = 0
	puntos_por_final = {Final.A: 0, Final.B: 0, Final.C: 0}
	partida_en_curso = true
	if hay_partida_actual():
		DirAccess.remove_absolute(RUTA_GUARDADO)


func continuar_partida() -> void:
	var archivo = FileAccess.open(RUTA_GUARDADO, FileAccess.READ)
	var datos: Dictionary = JSON.parse_string(archivo.get_as_text())
	archivo.close()
	
	dia_actual = datos.dia_actual
	indice_minijuego_actual = datos.indice_minijuego_actual
	
	puntos_por_final = {
		Final.A: datos.puntos_por_final["A"],
		Final.B: datos.puntos_por_final["B"],
		Final.C: datos.puntos_por_final["C"]
	}
	partida_en_curso = true


func avanzar_minijuego() -> void:
	indice_minijuego_actual += 1
	if indice_minijuego_actual >= MINIJUEGOS_POR_DIA[dia_actual-1]:
		indice_minijuego_actual = 0
		dia_actual += 1
	guardar_partida()


#LLAMAR DESDE PuntoMinijuego CUANDO EL JUGADOR LLEGA AL PUNTO Y VA A EMPEZAR A JUGAR
#INSTANCIA EL MINIJUEGO DENTRO DE UN SubViewport (SU CÁMARA QUEDA AISLADA AHÍ, NO PISA LA DEL JUGADOR)
#Y MUESTRA EL MARCO COMO UNA VENTANA FLOTANTE SOBRE LA OFICINA, QUE SIGUE VISIBLE DETRÁS
func abrir_minijuego(escena_minijuego: PackedScene, capa: Node) -> void:
	capa.get_parent().visible = true

	_instancia_minijuego_actual = escena_minijuego.instantiate()
	_instancia_minijuego_actual.process_mode = Node.PROCESS_MODE_ALWAYS
	capa.add_child(_instancia_minijuego_actual)

	get_tree().paused = true


#LLAMAR AL TERMINAR UN MINIJUEGO EN LUGAR DE registrar_puntaje_minijuego() + avanzar_minijuego() POR SEPARADO
#REGISTRA EL VOTO Y AVANZA EL PROGRESO. SI SIGUE EL MISMO DÍA, SOLO CIERRA EL OVERLAY Y VUELVE A LA
#MISMA OFICINA (SIN RECARGARLA). SI CAMBIA DE DÍA O SE COMPLETÓ EL DÍA TRES, AHÍ SÍ HACE UN CAMBIO DE ESCENA
func terminar_minijuego(puntos: int, umbral_final_a: int, umbral_final_b: int, evento_post: String = "") -> void:
	registrar_puntaje_minijuego(puntos, umbral_final_a, umbral_final_b)
	var dia_anterior := dia_actual
	avanzar_minijuego()

	get_tree().paused = false
	if _instancia_minijuego_actual:
		var marco := _instancia_minijuego_actual.get_parent().get_parent()
		_instancia_minijuego_actual.queue_free()
		_instancia_minijuego_actual = null
		marco.visible = false

	if dia_actual > MINIJUEGOS_POR_DIA.size():
		var final := decidir_final()
		finalizar_partida()
		ControladorTransiciones.ir_a_escena(RUTAS_FINAL[final], evento_post)
	elif dia_actual != dia_anterior:
		ControladorTransiciones.ir_a_escena(RUTA_OFICINA, evento_post)
	else:
		progreso_actualizado.emit()


func finalizar_partida() -> void:
	partida_en_curso = false
	if hay_partida_actual():
		DirAccess.remove_absolute(RUTA_GUARDADO)


func guardar_partida() -> void:
	var datos = {
		"dia_actual": dia_actual,
		"indice_minijuego_actual": indice_minijuego_actual,
		"puntos_por_final": {
			"A": puntos_por_final[Final.A],
			"B": puntos_por_final[Final.B],
			"C": puntos_por_final[Final.C]
		},
	}
	var archivo = FileAccess.open(RUTA_GUARDADO, FileAccess.WRITE)
	archivo.store_string(JSON.stringify(datos))
	archivo.close()


func _final_por_puntaje(puntos: int, umbral_final_a: int, umbral_final_b: int) -> int:
	if puntos >= umbral_final_a:
		return Final.A
	elif puntos >= umbral_final_b:
		return Final.B
	else:
		return Final.C


#LLAMAR AL CERRAR EL DIA TRES: DECIDE EL FINAL POR MAYORIA DE VOTOS
#EN CASO DE EMPATE, PRIORIDAD B > C > A
func decidir_final() -> int:
	var max_votos: int = puntos_por_final.values().max()
	var ganadores: Array = puntos_por_final.keys().filter(func(final): return puntos_por_final[final] == max_votos)

	if ganadores.size() == 1:
		return ganadores[0]

	for final in [Final.B, Final.C, Final.A]:
		if ganadores.has(final):
			return final

	return Final.B
