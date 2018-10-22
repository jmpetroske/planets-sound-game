extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export var mass = 0
export var velocity = Vector2(0, -100)

onready var orbit_data

var cur_time = 0

var parent

func _ready():
	add_to_group("planets")
	if mass != 0:
		parent = find_parent_planet()
		var relative_position = transform.origin - parent.transform.origin
		orbit_data = OrbitalMath.cart_to_kep(Vector3(relative_position.x, relative_position.y, 0),
											 Vector3(velocity.x, velocity.y, 1),
											 cur_time)

func _enter_tree():
	pass

func _process(delta):
	if mass != 0:
		cur_time = cur_time + delta
		#print(str(kep_to_cart(semi_major_axis, eccentricity, arg_of_pariapse, orbit_time)))
		transform.origin = OrbitalMath.kep_to_cart(orbit_data, cur_time) + parent.transform.origin

func find_parent_planet():
	var planets = get_tree().get_nodes_in_group("planets")
	var massive_planet = null
	for p in planets:
		if massive_planet == null || p.mass < massive_planet.mass:
			massive_planet = p
	return massive_planet