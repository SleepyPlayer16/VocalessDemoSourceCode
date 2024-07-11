extends Node2D

var angle = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotacion(240,135,30*2,0.5,90,180)

#funcione
func rotacion(_pivot_x,_pivot_y,_radio,_velocidad,_start_degree,_end_degree):
	#//pivotX pivotY: coordenadas de el punto al cual estara rotando
	#//radio: pixeles del pivot al objeto que rota
	#//velocidad: frames para que haga una rotacion completa (60 es 1 segundo por defecto)
	#//_start_degree: angulo de spawn o donde se resetea
	#//_end_degree: angulo donde hace reset o borrado

	if angle >= get_radian_angle(_end_degree) or angle == 0:
		modulate.a -= 0.02
	var _delta = get_process_delta_time()
	angle += _delta*(_end_degree*(PI/_start_degree)) * _velocidad
	position.x = _pivot_x + (cos(angle)* _radio)
	position.y = _pivot_y - (sin(angle)* _radio)
	#print(get_radian_angle(_end_degree))
#

func get_radian_angle(_degree):
	return (_degree*(PI/180))
