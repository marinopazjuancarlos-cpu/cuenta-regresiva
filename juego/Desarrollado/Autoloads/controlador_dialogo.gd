extends CanvasLayer

## Autoload: muestra líneas de diálogo con efecto de escritura sobre un panel inferior.
## Uso: await ControladorDialogo.mostrar_dialogo(["Primera línea", "Segunda línea"])

signal linea_avanzada
signal _peticion_completada(id: int)

@export var tiempo_escritura: float = 0.03

@onready var panel: Control = $Panel
@onready var etiqueta: RichTextLabel = $Panel/RichTextLabel

var esta_mostrando: bool = false
var saltar_escritura: bool = false

var _cola: Array = []
var _procesando: bool = false
var _siguiente_id: int = 0

func _ready() -> void:
	layer = 20
	panel.visible = false
	etiqueta.bbcode_enabled = true

func _unhandled_input(event: InputEvent) -> void:
	if not esta_mostrando:
		return
	if event.is_action_pressed("click"):
		if saltar_escritura:
			linea_avanzada.emit()
		else:
			saltar_escritura = true

## Encola las líneas y espera a que le toque su turno y termine de mostrarse.
## Si ya hay un diálogo en curso, esta llamada NO pisa su estado: espera en
## fila. Esto evita que dos disparadores simultáneos (p. ej. fin de jornada
## + zona de diálogo) corrompan esta_mostrando/panel y dejen un await
## colgado para siempre.
func mostrar_dialogo(lineas: Array) -> void:
	if lineas.is_empty():
		return

	var id := _siguiente_id
	_siguiente_id += 1
	_cola.append({"id": id, "lineas": lineas})

	if not _procesando:
		_procesar_cola()

	while true:
		var completado_id: int = await _peticion_completada
		if completado_id == id:
			break

func _procesar_cola() -> void:
	_procesando = true
	while not _cola.is_empty():
		var peticion: Dictionary = _cola.pop_front()
		await _mostrar_dialogo_inmediato(peticion["lineas"])
		_peticion_completada.emit(peticion["id"])
	_procesando = false

func _mostrar_dialogo_inmediato(lineas: Array) -> void:
	esta_mostrando = true
	panel.visible = true

	for linea in lineas:
		await _mostrar_linea(tr(linea))
		await linea_avanzada

	panel.visible = false
	esta_mostrando = false


func _mostrar_linea(texto: String) -> void:
	etiqueta.text = texto
	etiqueta.visible_characters = 0
	saltar_escritura = false

	var total := etiqueta.get_total_character_count()
	while etiqueta.visible_characters < total:
		if saltar_escritura:
			etiqueta.visible_characters = total
			break
		etiqueta.visible_characters += 1
		await get_tree().create_timer(tiempo_escritura).timeout

	#YA SE TERMINO DE ESCRIBIR: EL SIGUIENTE CLIC AVANZA DE LINEA EN VEZ DE ADELANTAR TEXTO
	saltar_escritura = true
