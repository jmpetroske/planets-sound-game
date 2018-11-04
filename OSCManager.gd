extends OSCsender

export var synths = ["FM1"];

func _ready():
	pass

func _process(delta):
	send_osc_update(get_parent().global_position, get_parent().get_relative_position(), get_parent().velocity)

func send_osc_ready():
	print(str(get_parent().uid))
	print(str(get_parent().get_path()))
	msg_address("/planet/init")
	msg_add_int(get_parent().uid)
	# [a, e, i, omega_AP, omega_LAN, T, EA]
	msg_add_real(get_parent().orbit_data[0])
	msg_add_real(get_parent().orbit_data[1])
	msg_add_real(get_parent().orbit_data[2])
	msg_add_real(get_parent().orbit_data[3])
	msg_add_real(get_parent().orbit_data[4])
	msg_add_real(get_parent().orbit_data[5])
	msg_add_real(get_parent().orbit_data[6])
	msg_send()
	
	msg_address("/planet/addSynth")
	msg_add_int(get_parent().uid)
	msg_add_int(synths.size())
	for synth in synths:
		msg_add_string(synth)
	msg_send()

func send_osc_update(global_p, relative_p, v):
	msg_address("/planet/update")
	msg_add_int(get_parent().uid)
	msg_add_v2(global_p)
	msg_add_v2(relative_p)
	msg_add_v2(v)
	msg_send()

func send_osc_destory():
	pass