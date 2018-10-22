extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var mu = 100000

export var mass = 0
var velocity = Vector2(0, sqrt(mu/50000))

var semimajor_axis
var eccentricity
var inclination
var longitude_ascending
var arg_of_periapsis
var orbit_time

var parent

func atan2mine(x, y):
	return atan2(y, x)

func _ready():
	add_to_group("planets")
	print(name + " called ready")
	print(name + " is of mass: " + str(mass))
	if mass != 0:
		print("calculating orbit for planet " + name)
		parent = calculate_orbit(null, null)
		var relative_position = transform.origin - parent.transform.origin
		print ("relative position: " + str(relative_position))
		var results = cart_to_kep(Vector3(relative_position.x, relative_position.y, 0),
								  Vector3(velocity.x, velocity.y, 0))
		semimajor_axis = results[0]
		eccentricity = results[1]
		inclination = results[2]
		longitude_ascending = results[3]
		arg_of_periapsis = results[4]
		orbit_time = results[5]
		
		print (str(kep_to_cart(results[0], results[1], results[2], results[3], results[4], results[5])))
	

func _enter_tree():
	print(name + " added to tree")

func _process(delta):
	if mass != 0:
		orbit_time = orbit_time + (delta * 0.5)
		#print(str(kep_to_cart(semi_major_axis, eccentricity, arg_of_pariapse, orbit_time)))
		transform.origin = kep_to_cart(semimajor_axis, eccentricity, inclination, longitude_ascending, arg_of_periapsis, orbit_time) + parent.transform.origin

func calculate_orbit(start, end):
	var planets = get_tree().get_nodes_in_group("planets")
	var massive_planet = null
	for p in planets:
		if massive_planet == null || p.mass < massive_planet.mass:
			massive_planet = p
	return massive_planet
	
func kep_to_cart(a, e, inc, omega, w, time):
	var n = sqrt(mu/pow(a, 3))
	var period = 2*PI * a * sqrt(a/mu)
	var t = fmod(time, period)
	
	
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
	nu = 2 * atan2mine(sqrt (1 - e) * cos (EA / 2), sqrt (1 + e) * sin (EA / 2));
	var r = a * (1 - e*cos(EA))
	
	var h = sqrt(mu*a*(1-pow(e, 2)))
	
	var X = r*(cos(omega)*cos(w+nu) - sin(omega)*sin(w+nu)*cos(i))
	var Y = r*(sin(omega)*cos(w+nu) + cos(omega)*sin(w+nu)*cos(i))
	var Z = r*(sin(inc)*sin(w+nu))
	var position = r * Vector2(X, Y)
	if rand_range(0, 1) < 0.1:
		print(str(r))
	return position
	pass
	
func cart_to_kep(r, v):
	var h = r.cross(v)
	var n = Vector3(0,0,1).cross(h)
	var eVector = ((v.length_squared() - mu/r.length()) * r - r.dot(v) * v) / mu
	var emag = eVector.length()
	
	var E = v.length_squared() / 2 - mu/r.length()
	# TODO does not handle non eliptical orbits
	
	var a = -mu/(2*E)
	
	var e = sqrt(1 - (h.length_squared()/(a*mu)))
	
	var inc = acos(h.z / h.length())
	#7
	var omega
	if inc == 0 || inc == PI:
		omega = 0
	else:
		omega = atan2mine(-h.y, h.x)
	#8
	var arg_lat
	if inc == 0 || inc == PI:
		arg_lat = 0
	else:
		arg_lat = atan2mine(r.x * cos(omega) + r.y * sin(omega), r.z / sin(inc))
	#9
	var nu
	if eVector.length() == 0:
		if inc == 0 || inc == PI:
			nu = acos(r.z/r.length())
		else:
			var p = a * (1 - pow(e, 2))
			nu = atan2mine(p-r.length(), sqrt(p/mu)*r.dot(v))
	else:
		nu = acos(eVector.dot(r) / (eVector.length() * r.length()))
		if r.dot(v) < 0:
			nu = 2*PI - nu
	var p = a * (1 - pow(e, 2))
	nu = atan2mine(p-r.length(), sqrt(p/mu)*r.dot(v))
	#10
	var w
	if inc == 0 || inc == PI:
		w = atan2mine(eVector.x, eVector.y)
	else:
		w = arg_lat - nu
	#11
	var EA = 2*atan(sqrt((1-e)/(1+e)) * tan(nu/2))
	#12
	var time = (EA - e * sin(EA))/sqrt(mu/pow(a,3))
	
	return [a, e, inc, omega, w, time]