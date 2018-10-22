extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export var mass = 0
export var velocity = Vector2(10, 100)

var semi_major_axis
var eccentricity
var arg_of_pariapse
var orbit_time
var omega_lan
var parent

var mu = 100000

func _ready():
	add_to_group("planets")
	print(name + " called ready")
	print(name + " is of mass: " + str(mass))
	if mass != 0:
		print("calculating orbit for planet " + name)
		parent = calculate_orbit(null, null)
		var relative_position = transform.origin - parent.transform.origin
		print ("relative position: " + str(relative_position))
		var velocity = Vector2(0, 1)
#		semi_major_axis = 200
#		eccentricity = 0
		#http://ccar.colorado.edu/asen5070/handouts/cart2kep2002.pdf
		var results = cart_to_kep(relative_position, velocity)
		semi_major_axis = results[0]
		eccentricity = results[1]
		arg_of_pariapse = results[2]
		omega_lan = results[3]
		orbit_time = results[4]
		print(str([semi_major_axis, eccentricity, arg_of_pariapse, omega_lan, orbit_time]))

func _enter_tree():
	print(name + " added to tree")

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if mass != 0:
		orbit_time = orbit_time + (delta * 0.5)
		#print(str(kep_to_cart(semi_major_axis, eccentricity, arg_of_pariapse, orbit_time)))
		transform.origin = kep_to_cart(semi_major_axis, eccentricity, arg_of_pariapse, omega_lan, orbit_time) + parent.transform.origin
	
func calculate_orbit(start, end):
	var planets = get_tree().get_nodes_in_group("planets")
	var massive_planet = null
	for p in planets:
		if massive_planet == null || p.mass < massive_planet.mass:
			massive_planet = p
	return massive_planet
	
func kep_to_cart(a, e, w, om_lan, t):
	var n = sqrt(mu/pow(a, 3))
	var period = 2*PI * a * sqrt(a/mu)
	t = fmod(t, period)
	var M = t
	
	var MA = sqrt(mu/pow(a, 3)) * t
	var EA = MA
	var F = e * sin(EA)
	var i = 0
	var maxIterations = 25
	var delta = 0.0000001
	while i < maxIterations && abs(F) < delta:
		EA = EA - (F / (1 - e * cos(EA)))
		F = EA - e * sin(EA) - MA
		i = i + 1
	
	var nu = 2 * atan(sqrt((1+e)/(1-e)) * tan(EA/2))
	#nu = 2 * atan2(sqrt (1 - e) * cos (EA / 2), sqrt (1 + e) * sin (EA / 2));
	var r = a * (1 - e*cos(EA))
	
	var h = sqrt(mu*a*(1-pow(e, 2)))
	var position = r * Vector2(cos(om_lan)*cos(w+nu) - sin(om_lan)*sin(w + nu),
							   sin(om_lan)*sin(w+nu) - cos(om_lan)*cos(w + nu))
	if rand_range(0, 1) < 0.1:
		print(str(r))
	return position
	
	# Mean anomaly
#	var MA = sqrt(mu/pow(a, 3)) * t
#
#	# Calculate eccentric anomoly (newton's method)
#	# https://space.stackexchange.com/questions/19322/converting-orbital-elements-to-cartesian-state-vectors
#	var EA = MA
#	var F = e * sin(EA)
#	var i = 0
#	var maxIterations = 25
#	var delta = 0.0000001
#	while i < maxIterations && abs(F) < delta:
#		EA = EA - (F / (1 - e * cos(EA)))
#		F = EA - e * sin(EA) - MA
#		i = i + 1
#
#	# True anomaly
#	# TODO: use atan2 instead?
#	var nu = 2 * atan(sqrt((1+e)/(1-e)) * tan(EA/2))
#
#	var radius = a * (1 - e * cos(EA))
#
#	# calculate angular momentum
#	var h = sqrt(mu * a * (1 - pow(e, 2)))
#
#	# Compute position in cartesian coordinates
#	# Note that since we are in 2d, inclination = 0 and argument of periapsis = 0 (by the convention we follow)
#	var position = radius * Vector2(cos(w + nu), sin(w + nu))
#	return position
	
# note that since this is strictly 2d, we forgo the argument of periapsis and set it to 0 by convention
func cart_to_kep(position, velocity):
	#1
	var h_bar = Vector2(position.x * velocity.x, position.y * velocity.y)
	var h = h_bar.length()
	#2
	var r = position.length()
	var v = velocity.length()
	#3
	var E = 0.5 * pow(v, 2) - mu/r
	#4
	var a = -mu/(2*E)
	#5
	var e = sqrt(1 - pow(h, 2)/(a*mu))
	#6
	var i = 0 # 2D, no vertical component
	#7
	var omega_LAN = atan2(-h_bar.y, h_bar.x)
	#8
	var lat = 0 # no inclination
	#9
	var p = a * (1 - pow(e, 2))
	var nu = atan2(p-r, sqrt(p/mu) * position.dot(velocity))
	#10
	var omega_AP = lat - nu
	#11
	var EA = 2 * atan(sqrt((1-e)/(1+e)) * tan(nu/2))
	#12
	var n = sqrt(mu/pow(a, 3))
	var T = (1/n)*(EA - e*sin(EA))
	return [a, e, omega_AP, omega_LAN, T]
	
	#http://ccar.colorado.edu/asen5070/handouts/cart2kep2002.pdf
#	var h = sqrt(pow(velocity.x * position.x, 2) + pow(velocity.y * position.y, 2))
#	var r = sqrt(pow(position.x, 2) + pow(position.y, 2))
#	var v_mag = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
#	var E = (velocity.length_squared() / 2) - (mu / position.length())
#	var a = -1 * mu/(2*E)
#	var e = sqrt(1 - (pow(h, 2) / (a*mu)))
#	# true anomaly
##	var nu = acos((a*(1 - pow(e, 2)) - r) / (e * r))
##	if position.dot(velocity) > 0 && nu >= 180:
##		print("ERROR")
#	var p = a*(1-pow(e,2))
#	var nu = atan2(p-r, sqrt(p/mu) * position.dot(velocity))
#	var EA = atan(sqrt((1-e)/(1+e)) * tan(nu/2)) * 2
#	# Time since passing pariapse
#	var T = (1/sqrt(mu/pow(a, 3))) * (EA - e * sin(EA))
#
#	# calculate arg of pariapse
#	# https://en.wikipedia.org/wiki/Argument_of_periapsis
#	var e_vec = position * ((velocity.length_squared()/mu) - (1/position.length())) - velocity * (position.dot(velocity) / mu)
#	var w = atan2(e_vec.x, e_vec.y)
#	return [a, e, w, T]