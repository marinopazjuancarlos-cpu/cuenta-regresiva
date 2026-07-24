extends Node2D

## Minijuego "Cables": proteger al corazón conectando cables entre los círculos
## de cada lado antes de que la advertencia de ese lado lance una descarga.
## La configuración (tiempos, virus, eventos especiales) cambia según el día.

const LADOS = ["arriba", "derecha", "abajo", "izquierda"]

const POS_LADO = {
	"arriba": Vector2(0, -55),
	"derecha": Vector2(110, 0),
	"abajo": Vector2(0, 55),
	"izquierda": Vector2(-110, 0),
}

const ESQUINAS = [Vector2(-100, -60), Vector2(100, -60), Vector2(-100, 60), Vector2(100, 60)]

const RADIO_ARRASTRE = 20.0
const RADIO_CHOQUE_VIRUS = 18.0

const DURACION = {1: 20.0, 2: 40.0, 3: 45.0}
const INTERVALO_ADVERTENCIA = 5.0

const VIDA_INICIAL = 300
const DAÑO_GOLPE = 100
const PUNTOS_MINIMOS_FINAL_A = 300
const PUNTOS_MINIMOS_FINAL_B = 200

const VIRUS_INICIO = {2: 20.0, 3: 30.0}
const VIRUS_INTERVALO = {2: 6.0, 3: 5.0}
const VIRUS_VIAJE = {2: 6.0, 3: 4.0}

const LADOS_DOBLES_DIA3 = ["izquierda", "derecha"]
const EVENTO_RUPTURA_DIA3 = 10.0

var dia: int = 1

var vida: int = VIDA_INICIAL
var tiempo_restante: float = 0.0
var jugando: bool = true
var primera_advertencia: bool = true
var evento_ruptura_disparado: bool = false

var advertencia_acumulada: float = 0.0
var virus_acumulado: float = 0.0
var virus_activo: Control = null

## lado -> {tiempo_restante, conexiones_hechas, conexiones_requeridas, falsa}
var advertencias: Dictionary = {}
var conectados: Dictionary = {}
var armados: Dictionary = {}
var arrastre_origen = null

@onready var circulos := {
	"arriba": [$Circulo_arriba_0, $Circulo_arriba_1],
	"derecha": [$Circulo_derecha_0, $Circulo_derecha_1],
	"abajo": [$Circulo_abajo_0, $Circulo_abajo_1],
	"izquierda": [$Circulo_izquierda_0, $Circulo_izquierda_1],
}
@onready var cables := {
	"arriba": $Cable_arriba,
	"derecha": $Cable_derecha,
	"abajo": $Cable_abajo,
	"izquierda": $Cable_izquierda,
}
@onready var indicadores := {
	"arriba": $Advertencia_arriba,
	"derecha": $Advertencia_derecha,
	"abajo": $Advertencia_abajo,
	"izquierda": $Advertencia_izquierda,
}
@onready var cable_arrastre: Line2D = $CableArrastre
@onready var label_puntos: Label = $UI/Puntos
@onready var label_tiempo: Label = $UI/Tiempo
@onready var corazon: Label = $Corazon


func _ready() -> void:
	dia = ControladorJuego.dia_actual
	tiempo_restante = DURACION.get(dia, DURACION[1])

	for lado in LADOS:
		indicadores[lado].visible = false
		cables[lado].visible = false
		conectados[lado] = false
		armados[lado] = false

	cable_arrastre.visible = false
	_actualizar_ui()


func _process(delta: float) -> void:
	if not jugando:
		return

	tiempo_restante -= delta
	if tiempo_restante <= 0.0:
		_terminar()
		return

	_procesar_advertencias(delta)
	_procesar_generador_advertencias(delta)
	_procesar_virus(delta)
	_procesar_evento_dia3()
	_actualizar_ui()


func _unhandled_input(event: InputEvent) -> void:
	if not jugando:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_iniciar_arrastre()
		else:
			_soltar_arrastre()
	elif event is InputEventMouseMotion and arrastre_origen != null:
		cable_arrastre.points = [circulos[arrastre_origen.lado][arrastre_origen.indice].position, get_local_mouse_position()]


## --- ADVERTENCIAS ---

func _procesar_generador_advertencias(delta: float) -> void:
	advertencia_acumulada += delta
	if advertencia_acumulada >= INTERVALO_ADVERTENCIA:
		advertencia_acumulada = 0.0
		_lanzar_advertencia_aleatoria()


func _lanzar_advertencia_aleatoria(forzar_lado: String = "", falsa: bool = false) -> void:
	var lado: String = forzar_lado if forzar_lado != "" else LADOS[randi() % LADOS.size()]
	if advertencias.has(lado):
		return

	var requeridas := 2 if (dia == 3 and lado in LADOS_DOBLES_DIA3) else 1

	# Si el escudo de ese lado ya está conectado, la advertencia queda resuelta al instante
	var conexiones_iniciales := requeridas if conectados[lado] else 0

	advertencias[lado] = {
		"tiempo_restante": _tiempo_reaccion(),
		"conexiones_hechas": conexiones_iniciales,
		"conexiones_requeridas": requeridas,
		"falsa": falsa,
	}
	primera_advertencia = false
	indicadores[lado].visible = true


func _tiempo_reaccion() -> float:
	var transcurrido: float = DURACION.get(dia, DURACION[1]) - tiempo_restante
	match dia:
		2:
			return 2.0 if transcurrido >= 20.0 else 1.5
		3:
			return 2.5 if primera_advertencia else 1.5
		_:
			return 2.0


func _procesar_advertencias(delta: float) -> void:
	var lados_a_quitar := []
	for lado in advertencias.keys():
		var info = advertencias[lado]
		info.tiempo_restante -= delta
		if info.tiempo_restante <= 0.0:
			if not info.falsa and info.conexiones_hechas < info.conexiones_requeridas:
				_recibir_golpe()
			lados_a_quitar.append(lado)

	for lado in lados_a_quitar:
		advertencias.erase(lado)
		indicadores[lado].visible = false


func _recibir_golpe() -> void:
	vida -= DAÑO_GOLPE
	modulate = Color(1.0, 0.55, 0.55)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)


## --- CABLES (ARRASTRE) ---

func _circulo_en(posicion: Vector2):
	for lado in LADOS:
		for i in range(2):
			var c: Area2D = circulos[lado][i]
			if c.global_position.distance_to(posicion) <= RADIO_ARRASTRE:
				return {"lado": lado, "indice": i}
	return null


func _iniciar_arrastre() -> void:
	var encontrado = _circulo_en(get_global_mouse_position())
	if encontrado == null:
		return
	arrastre_origen = encontrado
	cable_arrastre.visible = true
	var origen_pos: Vector2 = circulos[encontrado.lado][encontrado.indice].position
	cable_arrastre.points = [origen_pos, origen_pos]


func _soltar_arrastre() -> void:
	if arrastre_origen == null:
		return
	cable_arrastre.visible = false

	var destino = _circulo_en(get_global_mouse_position())
	if destino != null and destino.lado == arrastre_origen.lado and destino.indice != arrastre_origen.indice:
		_alternar_cable(arrastre_origen.lado)

	arrastre_origen = null


func _alternar_cable(lado: String) -> void:
	if dia == 3 and lado in LADOS_DOBLES_DIA3:
		if conectados[lado]:
			conectados[lado] = false
			armados[lado] = false
		elif armados[lado]:
			armados[lado] = false
			conectados[lado] = true
			_registrar_conexion(lado)
		else:
			armados[lado] = true
			_registrar_conexion(lado)
	else:
		conectados[lado] = not conectados[lado]
		if conectados[lado]:
			_registrar_conexion(lado, true)

	_actualizar_visual_cable(lado)


func _registrar_conexion(lado: String, completar: bool = false) -> void:
	if not advertencias.has(lado):
		return
	var info = advertencias[lado]
	if completar:
		info.conexiones_hechas = info.conexiones_requeridas
	else:
		info.conexiones_hechas += 1


func _actualizar_visual_cable(lado: String) -> void:
	var cable: Line2D = cables[lado]
	var p0: Vector2 = circulos[lado][0].position
	var p1: Vector2 = circulos[lado][1].position

	if conectados[lado]:
		cable.visible = true
		cable.default_color = Color.WHITE
		cable.points = [p0, p1]
	elif armados[lado]:
		cable.visible = true
		cable.default_color = Color(1.0, 1.0, 1.0, 0.35)
		cable.points = [p0, p1]
	else:
		cable.visible = false


## --- VIRUS ---

func _procesar_virus(delta: float) -> void:
	var inicio: float = VIRUS_INICIO.get(dia, INF)
	var transcurrido: float = DURACION.get(dia, DURACION[1]) - tiempo_restante
	if transcurrido < inicio:
		return

	if virus_activo == null:
		virus_acumulado += delta
		if virus_acumulado >= VIRUS_INTERVALO.get(dia, 6.0):
			virus_acumulado = 0.0
			_spawnear_virus()
	else:
		_mover_virus(delta)


func _spawnear_virus() -> void:
	var origen: Vector2
	if dia == 3:
		origen = ESQUINAS[randi() % ESQUINAS.size()]
	else:
		var lado: String = LADOS[randi() % LADOS.size()]
		origen = POS_LADO[lado] * 1.3

	var etiqueta := Label.new()
	etiqueta.text = "☣"
	etiqueta.add_theme_color_override("font_color", Color(0.6, 0.1, 0.1))
	etiqueta.add_theme_font_size_override("font_size", 22)
	etiqueta.position = origen
	etiqueta.set_meta("origen", origen)
	etiqueta.set_meta("control", origen.rotated(deg_to_rad(50)) * 0.6)
	etiqueta.set_meta("tiempo", 0.0)
	etiqueta.set_meta("duracion", VIRUS_VIAJE.get(dia, 6.0))

	add_child(etiqueta)
	virus_activo = etiqueta


func _mover_virus(delta: float) -> void:
	var t_actual: float = virus_activo.get_meta("tiempo") + delta
	virus_activo.set_meta("tiempo", t_actual)

	var duracion: float = virus_activo.get_meta("duracion")
	var t: float = clamp(t_actual / duracion, 0.0, 1.0)
	var origen: Vector2 = virus_activo.get_meta("origen")
	var control: Vector2 = virus_activo.get_meta("control")

	virus_activo.position = origen.lerp(control, t).lerp(control.lerp(Vector2.ZERO, t), t)

	if _virus_toca_cable(virus_activo.position):
		virus_activo.queue_free()
		virus_activo = null
		return

	if t >= 1.0:
		_recibir_golpe()
		virus_activo.queue_free()
		virus_activo = null


func _virus_toca_cable(pos: Vector2) -> bool:
	for lado in LADOS:
		if not conectados[lado]:
			continue
		var p0: Vector2 = circulos[lado][0].position
		var p1: Vector2 = circulos[lado][1].position
		var cercano: Vector2 = Geometry2D.get_closest_point_to_segment(pos, p0, p1)
		if cercano.distance_to(pos) <= RADIO_CHOQUE_VIRUS:
			return true
	return false


## --- EVENTO ESPECIAL DÍA 3: a los 10s se rompen los cables y hay 4 advertencias falsas ---

func _procesar_evento_dia3() -> void:
	if dia != 3 or evento_ruptura_disparado:
		return

	var transcurrido: float = DURACION[3] - tiempo_restante
	if transcurrido < EVENTO_RUPTURA_DIA3:
		return

	evento_ruptura_disparado = true

	for lado in LADOS:
		conectados[lado] = false
		armados[lado] = false
		_actualizar_visual_cable(lado)
		indicadores[lado].visible = false
	advertencias.clear()

	for lado in LADOS:
		_lanzar_advertencia_aleatoria(lado, true)


## --- FIN ---

func _terminar() -> void:
	jugando = false
	ControladorJuego.terminar_minijuego(vida, PUNTOS_MINIMOS_FINAL_A, PUNTOS_MINIMOS_FINAL_B)


func _actualizar_ui() -> void:
	label_puntos.text = str(vida)
	label_tiempo.text = str(int(ceil(tiempo_restante)))
