extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const OSCManager = preload("OSCManager.gd")

export var velocity = Vector2(0, 0)
export var uid = 0
export var parent_uid = 0

# [period, e, i, arg p (w), LAN, T]
export var init_data = [30, 0.02, PI, 0, 0, 0]

onready var orbit_data

var cur_time = 0

func _ready():
	if uid != 0:
		print(OrbitalMath.mu)
		var a = pow(OrbitalMath.mu * pow(init_data[0], 2) / (4 * pow(PI, 2)), 1.0/3);
		# 	return [a, e, i, omega_AP, omega_LAN, T]
		orbit_data = [
						a,
						init_data[1],
						init_data[2],
						init_data[3],
						init_data[4],
						init_data[5]
					];

func _enter_tree():
	get_owner()
	pass

func _process(delta):
	if uid != 0:
		cur_time = cur_time + delta
		#print(str(kep_to_cart(semi_major_axis, eccentricity, arg_of_pariapse, orbit_time)))
		var orbit_cart_data = OrbitalMath.kep_to_cart(orbit_data, cur_time)
		position = orbit_cart_data[0]
		velocity = orbit_cart_data[1]