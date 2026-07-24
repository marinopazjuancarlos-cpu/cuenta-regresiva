extends Node


enum Final { A, B, C }

const RUTA_GUARDADO = "user://partida.save"
const MINIJUEGOS_POR_DIA = [2, 3, 4]

var dia_actual: int = 1
var indice_minijuego_actual: int = 0
var partida_en_curso: bool = false
var puntos_por_final: Dictionary = {Final.A: 0, Final.B: 0, Final.C: 0}


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
