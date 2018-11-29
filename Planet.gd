extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const OSCManager = preload("OSCManager.gd")

export var velocity = Vector2(0, 0)
export var uid = 0
export var parent_uid = 0

onready var orbit_data

var cur_time = 0

var parent

func _ready():
	add_to_group("planets")
	if uid != 0:
		parent = find_parent_planet()
		var relative_position = transform.origin - parent.transform.origin
		var relative_velocity = velocity - parent.velocity
		orbit_data = OrbitalMath.cart_to_kep(Vector3(relative_position.x, relative_position.y, 0),
											 Vector3(relative_velocity.x, relative_velocity.y, 0),
											 cur_time)
				
		print(str(uid) + ": " + str(get_path()) + ": " + str(OrbitalMath.orbit_period(orbit_data)))

func _enter_tree():
	pass

func _process(delta):
	if uid != 0:
		cur_time = cur_time + delta
		#print(str(kep_to_cart(semi_major_axis, eccentricity, arg_of_pariapse, orbit_time)))
		var orbit_cart_data = OrbitalMath.kep_to_cart(orbit_data, cur_time)
		transform.origin = orbit_cart_data[0] + parent.transform.origin
		velocity = orbit_cart_data[1]

func get_relative_position():
	return transform.origin - parent.transform.origin

func find_parent_planet():
	var planets = get_tree().get_nodes_in_group("planets")
	for p in planets:
		if p.uid == parent_uid:
			return p
	return null