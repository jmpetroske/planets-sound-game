extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var mu = 10000000

export var mass = 0
var velocity = Vector2(0, -sqrt(mu/500))

var orbit_data

var cur_time = 0

var parent

func atan2mine(x, y):
	return atan2(y, x)

func _ready():
	add_to_group("planets")
	if mass != 0:
		parent = calculate_orbit(null, null)
		var relative_position = transform.origin - parent.transform.origin
		orbit_data = cart_to_kep(Vector3(relative_position.x, relative_position.y, 0),
								 Vector3(velocity.x, velocity.y, 1))
		print(str(orbit_data))

func _enter_tree():
	pass

func _process(delta):
	if mass != 0:
		cur_time = cur_time + delta
		#print(str(kep_to_cart(semi_major_axis, eccentricity, arg_of_pariapse, orbit_time)))
		transform.origin = kep_to_cart(orbit_data) + parent.transform.origin

func calculate_orbit(start, end):
	var planets = get_tree().get_nodes_in_group("planets")
	var massive_planet = null
	for p in planets:
		if massive_planet == null || p.mass < massive_planet.mass:
			massive_planet = p
	return massive_planet
	
func kep_to_cart(data):
	var a = data[0]
	var e = data[1]
	var i = data[2]
	var omega_AP = data[3]
	var omega_LAN = data[4]
	var T = data[5]
	#var EA = data[6]
	
	#1
	var n = sqrt(mu/(pow(a,3)))
	var MA = n*(cur_time - T)
	#2
	var EA = MA
	var F = e * sin(EA)
	var j = 0
	var maxIterations = 30
	var delta = 0.00000001
	while j < maxIterations && abs(F) < delta:
		EA = EA - (F / (1 - e * cos(EA)))
		F = EA - e * sin(EA) - MA
		j = j + 1
	#var MA = EA - e*sin(EA)
	#3
	var nu = 2*atan(sqrt((1+e)/(1-e)) * tan(EA/2))
	#4
	var r = a*(1 - e*cos(EA))
	#5
	var h = sqrt(mu*a * (1 - pow(e,2)))
	#6
	var Om = omega_LAN
	var w =  omega_AP
	
	var X = r*(cos(Om)*cos(w+nu) - sin(Om)*sin(w+nu)*cos(i))
	var Y = r*(sin(Om)*cos(w+nu) + cos(Om)*sin(w+nu)*cos(i))
	var Z = r*(sin(i)*sin(w+nu))
	
	#7
	var p = a*(1-pow(e, 2))
	var V_X = (X*h*e/(r*p))*sin(nu) - (h/r)*(cos(Om)*sin(w+nu) + sin(Om)*cos(w+nu)*cos(i))
	var V_Y = (Y*h*e/(r*p))*sin(nu) - (h/r)*(sin(Om)*sin(w+nu) - cos(Om)*cos(w+nu)*cos(i))
	var V_Z = (Z*h*e/(r*p))*sin(nu) - (h/r)*(cos(w+nu)*sin(i))
	
	return Vector2(X, Y)
#   return [X,Y,Z],[V_X,V_Y,V_Z]
	
func cart_to_kep(r_vec, v_vec):
	#1
	var h_bar = r_vec.cross(v_vec)
	var h = h_bar.length()
	#2
	var r = r_vec.length()
	var v = v_vec.length()
	#3
	var E = 0.5*(pow(v,2)) - mu/r
	#4
	var a = -mu/(2*E)
	#5
	var e = sqrt(1 - (pow(h,2))/(a*mu))
	#6
	var i = acos(h_bar.z/h)
	#7
	var omega_LAN
	if i == 0 || i == PI:
		omega_LAN = 0
	else:
		omega_LAN = atan2(h_bar.x, -h_bar.y)
	#8
	#beware of division by zero here
	var lat
	if i == 0 || i == PI:
		lat = 0
	else:
		lat = atan2(r_vec.z / (sin(i)), r_vec.x*cos(omega_LAN) + r_vec.y*sin(omega_LAN))
	#9
	var p = a*(1-pow(e,2))
	var nu = atan2(sqrt(p/mu) * r_vec.dot(v_vec), p-r)
	#10
	var omega_AP = lat - nu
	#11
	var EA = 2*atan(sqrt((1-e)/(1+e)) * tan(nu/2))
	#12
	var n = sqrt(mu/(pow(a,3)))
	var T = cur_time - (1/n)*(EA - e*sin(EA))
	return [a, e, i, omega_AP, omega_LAN, T, EA]