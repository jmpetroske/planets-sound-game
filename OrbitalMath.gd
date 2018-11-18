extends Node

const mu = 10000000

var current_id = 0

func get_uid():
	var retval = current_id
	current_id = current_id + 1
	return retval

func _ready():
	pass

func float_equal(a, b, epsilon = 0.000001):
	return abs(a - b) <= epsilon

func kep_to_cart(data, cur_time):
	var a = data[0]
	var e = data[1]
	var i = data[2]
	var omega_AP = data[3]
	var omega_LAN = data[4]
	var T = data[5]
	#var EA = data[6]
	
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
	nu = 2 * atan2(sqrt(1-e) * cos(EA/2), sqrt(1+e) * sin(EA/2))
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
	if float_equal(i, PI):
		i = 0
	#7
	var omega_LAN
	if float_equal(i, 0):
		omega_LAN = 0
	else:
		omega_LAN = atan2(-h_bar.y, h_bar.x)
	#8
	#beware of division by zero here
	var lat
	if float_equal(i, 0):
		lat = 0
	else:
		lat = atan2(r_vec.z / (sin(i)), r_vec.x*cos(omega_LAN) + r_vec.y*sin(omega_LAN))
	#9
	var p = a*(1-pow(e,2))
	var nu = atan2(p-r, sqrt(p/mu) * r_vec.dot(v_vec))
	#10
#	var omega_AP = lat - nu
	var e_vec = ((pow(v, 2) / mu) - (1/r)) * r_vec - ((r_vec.dot(v_vec)/mu) * v_vec)
#	var e_vec = v_vec.cross(h_bar)/mu - r_vec/r
	print(str(e_vec))
	var omega_AP = atan2(e_vec.y, e_vec.x)
	if r_vec.cross(v_vec).z < 0:
		omega_AP = 2*PI - omega_AP
	#11
	# var EA = 2*atan2(sqrt(1/(1+e)), sqrt(1-e) * tan(nu/2))
	var EA = 2*atan(sqrt((1-e)/(1+e)) * tan(nu/2))
	#12
	var n = sqrt(mu/(pow(a,3)))
	var T = (1/n)*(EA - e*sin(EA))
	return [a, e, i, omega_AP, omega_LAN, T, EA]
	
func orbit_period(data):
	var a = data[0]
	var e = data[1]
	var i = data[2]
	var omega_AP = data[3]
	var omega_LAN = data[4]
	var T = data[5]
	#var EA = data[6]
	
	return 2 * PI * sqrt(pow(a, 3) / mu)