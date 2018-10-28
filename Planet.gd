extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const OSCManager = preload("OSCManager.gd")

export var mass = 0
export var velocity = Vector2(0, 0)

onready var orbit_data

var cur_time = 0

var parent
onready var uid

func _ready():
	add_to_group("planets")
	if mass != 0:
		uid = OrbitalMath.get_uid()
		parent = find_parent_planet()
		var relative_position = transform.origin - parent.transform.origin
		var relative_velocity = velocity - parent.velocity
		orbit_data = OrbitalMath.cart_to_kep(Vector3(relative_position.x, relative_position.y, 0),
											 Vector3(relative_velocity.x, relative_velocity.y, 0),
											 cur_time)
		for c in get_children():
			if c is OSCManager:
				c.send_osc_ready()

func _enter_tree():
	pass

func _process(delta):
	if mass != 0:
		cur_time = cur_time + delta
		#print(str(kep_to_cart(semi_major_axis, eccentricity, arg_of_pariapse, orbit_time)))
		var orbit_cart_data = OrbitalMath.kep_to_cart(orbit_data, cur_time)
		transform.origin = orbit_cart_data[0] + parent.transform.origin
		velocity = orbit_cart_data[1]

func get_relative_position():
	return transform.origin - parent.transform.origin

func find_parent_planet():
	var planets = get_tree().get_nodes_in_group("planets")
	var massive_planet = null
	for p in planets:
		if massive_planet == null || (p.mass > massive_planet.mass && p.mass != mass):
			massive_planet = p
	return massive_planet