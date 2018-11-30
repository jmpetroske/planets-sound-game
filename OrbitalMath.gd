extends Node

const mu = 10000000

var planetBase = preload("res://basePlanet.tscn")

var _planets = {}

func _ready():
#   [uid, [period, e, i, arg p (w), LAN, T]]
	var planetInitData = [
		[1, 0, [15, 0.2, PI, 0, 0, 0]],
		[2, 0, [15, 0.1, PI, PI, 0, 0]],
		[3, 0, [3.75, 0.75, PI, PI, 0, 1.875]],
		[4, 3, [0.46875, 0, PI, PI, 0, 0]],
		[5, 0, [15, 0.05, PI, 0, 0, 0]],
		[6, 0, [7.5, 0.05, PI, 0, 0, 0]],
		
		# asteroids
		[7, 0, [30, 0.9, PI, PI, 0, 15]],
		[8, 0, [30, 0.91, PI, PI + 0.03, 0, 15 - 1]],
		[9, 0, [30, 0.895, PI, PI - 0.02, 0, 15 - 1.4]],
		[9, 0, [30, 0.905, PI, PI + 0.02, 0, 15 - 4]],
	]

#	var newP = planetBase.instance()
#	get_tree().get_root().get_node("Node2D").add_child(newP)
#	newP.position = Vector2(100, 100)
#	newP.orbit_data = 
#	newP.uid = 7

	var sun = get_tree().get_root().get_node("Node2D").get_node("Sun")
	_planets[0] = sun
	for newP in planetInitData:
		var uid = newP[0]
		var parent_uid = newP[1]
		var init_data = newP[2]
		
		var inst = planetBase.instance()
		_planets[parent_uid].add_child(inst)
		_planets[uid] = inst
		inst.uid = uid
		inst.init_data = init_data
		inst.name = str(uid)

func float_equal(a, b, epsilon = 0.000001):
	return abs(a - b) <= epsilon

func kep_to_cart(data, cur_time):
	var a = data[0]
	var e = data[1]
	var i = data[2]
	var omega_AP = data[3]
	var omega_LAN = data[4]
	var T = data[5]
	
	#1
	var n = sqrt(mu/(pow(a,3)))
	var MA = n*(cur_time + T)
	#2
#	var EA = MA
#	if e > 0.7:
#		EA = PI
#	var j = 0
#	var maxIterations = 100
#	var delta = 0.00000001
#	while j < maxIterations: # && abs(F) < delta:
#		EA = EA - ((EA - e * sin(EA) - MA) / (1 - e * cos(EA)))
#		j = j + 1
	#var MA = EA - e*sin(EA)
	
	var EA = MA
	for x in range(100):
		EA = MA + e * sin(EA)
	
	#3
	var nu = 2*atan(sqrt((1+e)/(1-e)) * tan(EA/2))
	nu = 2 * atan2(sqrt(1+e) * sin(EA/2), sqrt(1-e) * cos(EA/2))
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
	return [Vector2(X, Y), Vector2(V_X, V_Y)]
#   return [X,Y,Z],[V_X,V_Y,V_Z]

func cart_to_kep(r_vec, v_vec, cur_time):
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
#	if float_equal(i, PI):
#		i = 0
	#7
	var omega_LAN
	if float_equal(i, 0) or float_equal(i, PI):
		omega_LAN = 0
	else:
		omega_LAN = atan2(h_bar.x, -h_bar.y)
	#8
	#beware of division by zero here
	var lat
	if float_equal(i, 0) or float_equal(i, PI):
		lat = 0
	else:
		lat = atan2(r_vec.x*cos(omega_LAN) + r_vec.y*sin(omega_LAN), r_vec.z / (sin(i)))
	#9
	var p = a*(1-pow(e,2))
	var nu = atan2(sqrt(p/mu) * r_vec.dot(v_vec), p-r)
	#10
#	var omega_AP = lat - nu
	var e_vec = ((pow(v, 2) / mu) - (1/r)) * r_vec - ((r_vec.dot(v_vec)/mu) * v_vec)
#	var e_vec = v_vec.cross(h_bar)/mu - r_vec/r
	var omega_AP = atan2(e_vec.y, e_vec.x)
	if r_vec.cross(v_vec).z < 0:
		omega_AP = 2*PI - omega_AP
	#11
	# var EA = 2*atan2(sqrt(1/(1+e)), sqrt(1-e) * tan(nu/2))
	var EA = 2*atan(sqrt((1-e)/(1+e)) * tan(nu/2))
	#12
	var n = sqrt(mu/(pow(a,3)))
	var T = (1/n)*(EA - e*sin(EA))
	return [a, e, i, omega_AP, omega_LAN, T]
	
func orbit_period(data):
	var a = data[0]
	var e = data[1]
	var i = data[2]
	var omega_AP = data[3]
	var omega_LAN = data[4]
	var T = data[5]
	
	return 2 * PI * sqrt(pow(a, 3) / mu)