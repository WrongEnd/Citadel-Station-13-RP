// Returns which access is relevant to passed network. Used by the program.
/proc/get_camera_access(var/network)
	if(!network)
		return 0
	. = GLOB.using_map.get_network_access(network)
	if(.)
		return

	switch(network)
		if(NETWORK_THUNDER)
			return 0
		if(NETWORK_ENGINE,NETWORK_ALARM_ATMOS,NETWORK_ALARM_FIRE,NETWORK_ALARM_POWER)
			return ACCESS_ENGINEERING_MAIN
		if(NETWORK_CIRCUITS)
			return ACCESS_SCIENCE_MAIN
		if(NETWORK_ERT)
			return ACCESS_CENTCOM_ERT

	if(network in GLOB.using_map.station_networks)
		return ACCESS_SECURITY_EQUIPMENT // Default for all other station networks
	else
		return 999	//Inaccessible if not a station network and not mentioned above

/datum/computer_file/program/camera_monitor
	filename = "cammon"
	filedesc = "Camera Monitoring"
	tguimodule_path = /datum/tgui_module_old/camera/ntos
	program_icon_state = "cameras"
	program_key_state = "generic_key"
	program_menu_icon = "search"
	extended_desc = "This program allows remote access to the camera system. Most camera networks may have additional access requirements."
	size = 12
	available_on_ntnet = 1
	requires_ntnet = 1

// ERT Variant of the program
/datum/computer_file/program/camera_monitor/ert
	filename = "ntcammon"
	filedesc = "Advanced Camera Monitoring"
	extended_desc = "This program allows remote access to the camera system. Some camera networks may have additional access requirements. This version has an integrated database with additional encrypted keys."
	size = 14
	tguimodule_path = /datum/tgui_module_old/camera/ntos/ert
	available_on_ntnet = 0
