
GLOBAL_DATUM_INIT(using_map, /datum/map, new USING_MAP_DATUM)

var/list/all_maps = list()

/hook/startup/proc/initialise_map_list()
	for(var/type in typesof(/datum/map) - /datum/map)
		var/datum/map/M
		if(type == GLOB.using_map.type)
			M = GLOB.using_map
			M.setup_map()
		else
			M = new type
		if(!M.path)
			log_debug(SPAN_DEBUGERROR("Map '[M]' does not have a defined path, not adding to map list!"))
		else
			all_maps[M.path] = M
	return 1


/datum/map
	var/name = "Unnamed Map"
	var/full_name = "Unnamed Map"
	var/path

	var/zlevel_datum_type			 // If populated, all subtypes of this type will be instantiated and used to populate the *_levels lists.
	var/list/base_turf_by_z = list() // Custom base turf by Z-level. Defaults to world.turf for unlisted Z-levels

	// Automatically populated lists made static for faster lookups
	var/list/zlevels = list()
	var/list/station_levels = list() // Z-levels the station exists on
	var/list/admin_levels = list()   // Z-levels for admin functionality (Centcom, shuttle transit, etc)
	var/list/contact_levels = list() // Z-levels that can be contacted from the station, for eg announcements
	var/list/player_levels = list()  // Z-levels a character can typically reach
	var/list/sealed_levels = list()  // Z-levels that don't allow random transit at edge
	var/list/xenoarch_exempt_levels = list()	//Z-levels exempt from xenoarch finds and digsites spawning.
	var/list/empty_levels = null     // Empty Z-levels that may be used for various things (currently used by bluespace jump)
	// End Static Lists

	// Z-levels available to various consoles, such as the crew monitor. Defaults to station_levels if unset.
	var/list/map_levels

	// E-mail TLDs to use for NTnet modular computer e-mail addresses
	var/list/usable_email_tlds = list("freemail.nt")

	// This list contains the z-level numbers which can be accessed via space travel and the percentile chances to get there.
	var/list/accessible_z_levels = list()

	//List of additional z-levels to load above the existing .dmm file z-levels using the maploader. Must be map template >>> NAMES <<<.
	var/list/lateload_z_levels = list()

	//Similar to above, but only pick ONE to load, useful for random away missions and whatnot
	var/list/lateload_single_pick = list()

	var/list/allowed_jobs = list()	// Job datums to use.
									// Works a lot better so if we get to a point where three-ish maps are used
									// We don't have to C&P ones that are only common between two of them
									// That doesn't mean we have to include them with the rest of the jobs though, especially for map specific ones.
									// Also including them lets us override already created jobs, letting us keep the datums to a minimum mostly.
									// This is probably a lot longer explanation than it needs to be.

	var/list/holomap_smoosh		// List of lists of zlevels to smoosh into single icons
	var/list/holomap_offset_x = list()
	var/list/holomap_offset_y = list()
	var/list/holomap_legend_x = list()
	var/list/holomap_legend_y = list()
	var/list/meteor_strike_areas		 // Areas meteor strikes may choose to hit.
	var/ai_shell_restricted = FALSE		 // Are there z-levels restricted?
	var/ai_shell_allowed_levels = list() // Which z-levels ARE we allowed to visit?

	// Belter stuff
	var/list/belter_docked_z = list()
	var/list/belter_transit_z = list()
	var/list/belter_belt_z = list()

	var/list/mining_station_z = list()
	var/list/mining_outpost_z = list()

	//Lavaland Stuff
	var/list/lavaland_levels = list()

	var/station_name  = "BAD Station"
	var/station_short = "Baddy"
	var/dock_name	  = "THE PirateBay"
	var/dock_type	  = "station"	// For a list of valid types see the switch block in air_traffic.dm at line 148
	var/boss_name	  = "Captain Roger"
	var/boss_short	  = "Cap'"
	var/company_name  = "BadMan"
	var/company_short = "BM"
	var/starsys_name  = "Dull Star"

	var/shuttle_docked_message
	var/shuttle_leaving_dock
	var/shuttle_called_message
	var/shuttle_recall_message
	var/shuttle_name  = "NAS |Hawking|"
	var/emergency_shuttle_docked_message
	var/emergency_shuttle_leaving_dock
	var/emergency_shuttle_called_message
	var/emergency_shuttle_recall_message

	var/list/station_networks = list()		// Camera networks that will show up on the console.
	var/list/secondary_networks = list()	// Camera networks that exist, but don't show on regular camera monitors.

	var/bot_patrolling = TRUE				// Determines if this map supports automated bot patrols

	var/allowed_spawns = list("Arrivals Shuttle","Gateway", "Cryogenic Storage", "Cyborg Storage")

	// Persistence!
	var/datum/spawnpoint/spawnpoint_died = /datum/spawnpoint/arrivals	// Used if you end the round dead.
	var/datum/spawnpoint/spawnpoint_left = /datum/spawnpoint/arrivals	// Used of you end the round at centcom.
	var/datum/spawnpoint/spawnpoint_stayed = /datum/spawnpoint/cryo		// Used if you end the round on the station.

	var/use_overmap = 0			// If overmap should be used (including overmap space travel override)
	var/overmap_size = 20		// Dimensions of overmap zlevel if overmap is used.
	var/overmap_z = 0			// If 0 will generate overmap zlevel on init. Otherwise will populate the zlevel provided.
	var/overmap_event_areas = 0	// How many event "clouds" will be generated

	var/lobby_icon = 'icons/misc/title.dmi'			// The icon which contains the lobby image(s)
	var/list/lobby_screens = list("mockingjay00")	// The list of lobby screen to pick() from. If left unset the first icon state is always selected.

	var/default_law_type = /datum/ai_laws/nanotrasen	// The default lawset use by synth units, if not overriden by their laws var.

	// Some maps include areas for that map only and don't exist when not compiled, so Travis needs this to learn of new areas that are specific to a map.
	var/list/unit_test_exempt_areas = list()
	var/list/unit_test_exempt_from_atmos = list()
	var/list/unit_test_exempt_from_apc = list()
	var/list/unit_test_z_levels	// To test more than Z1, set your z-levels to test here.

	var/list/planet_datums_to_make = list() // Types of `/datum/planet`s that will be instantiated by SSPlanets.

/datum/map/New()
	..()
	if(zlevel_datum_type)
		for(var/type in subtypesof(zlevel_datum_type))
			new type(src)
	if(!map_levels)
		map_levels = station_levels.Copy()
	if(!allowed_jobs || !allowed_jobs.len)
		allowed_jobs = subtypesof(/datum/role/job)

// Gets the current time on a current zlevel, and returns a time datum
/datum/map/proc/get_zlevel_time(var/z)
	if(!z)
		z = 1
	var/datum/planet/P = z <= SSplanets.z_to_planet.len ? SSplanets.z_to_planet[z] : null
	// We found a planet tied to that zlevel, give them the time
	if(P?.current_time)
		return P.current_time

	// We have to invent a time
	else
		var/datum/time/T = new (station_time_in_ds)
		return T

// Returns a boolean for if it's night or not on a particular zlevel
/datum/map/proc/get_night(var/z)
	if(!z)
		z = 1
	var/datum/time/now = get_zlevel_time(z)
	var/percent = now.seconds_stored / now.seconds_in_day //practically all of these are in DS
	testing("get_night is [percent] through the day on [z]")

	// First quarter, last quarter
	if(percent < 0.25 || percent > 0.75)
		return TRUE
	// Second quarter, third quarter
	else
		return FALSE

// Boolean for if we should use SSnightshift night hours
/datum/map/proc/get_nightshift()
	return get_night(1) //Defaults to z1, customize however you want on your own maps

/datum/map/proc/setup_map()
	return

/datum/map/proc/perform_map_generation()
	return

/datum/map/proc/get_network_access(var/network)
	return 0

// By default transition randomly to another zlevel
/datum/map/proc/get_transit_zlevel(var/current_z_level)
	var/list/candidates = GLOB.using_map.accessible_z_levels.Copy()
	candidates.Remove(num2text(current_z_level))

	if(!candidates.len)
		return current_z_level
	return text2num(pickweight(candidates))

/datum/map/proc/get_empty_zlevel()
	if(empty_levels == null)
		world.increment_max_z()
		empty_levels = list(world.maxz)
		if(islist(player_levels))
			player_levels |= world.maxz
		else
			player_levels = list(world.maxz)
	return pick(empty_levels)

// Get the list of zlevels that a computer on srcz can see maps of (for power/crew monitor, cameras, etc)
// The long_range parameter expands the coverage.  Default is to return map_levels for long range otherwise just srcz.
// zLevels outside station_levels will return an empty list.
/datum/map/proc/get_map_levels(var/srcz, var/long_range = TRUE, var/om_range = 0)
	// Overmap behavior
	if(use_overmap)
		var/obj/effect/overmap/visitable/O = get_overmap_sector(srcz)
		if(!istype(O))
			return list(srcz)

		// Just the sector we're in
		if(!long_range || (om_range < 0))
			return O.map_z.Copy()

		// Otherwise every sector we're on top of
		var/list/connections = list()
		var/turf/T = get_turf(O)
		for(var/obj/effect/overmap/visitable/V in range(om_range, T))
			connections |= V.map_z	// Adding list to list adds contents
		return connections

	// Traditional behavior
	else
		if (long_range && (srcz in map_levels))
			return map_levels
		else if (srcz in station_levels)
			return list(srcz)
		else
			return list(srcz)

/datum/map/proc/get_zlevel_name(var/index)
	var/datum/map_z_level/Z = zlevels["[index]"]
	return Z?.name

// Access check is of the type requires one. These have been carefully selected to avoid allowing the janitor to see channels he shouldn't
// This list needs to be purged but people insist on adding more cruft to the radio.
/datum/map/proc/default_internal_channels()
	return list(
		num2text(PUB_FREQ)   = list(),
		num2text(AI_FREQ)    = list(ACCESS_SPECIAL_SILICONS),
		num2text(ENT_FREQ)   = list(),
		num2text(ERT_FREQ)   = list(ACCESS_CENTCOM_ERT),
		num2text(COMM_FREQ)  = list(ACCESS_COMMAND_BRIDGE),
		num2text(ENG_FREQ)   = list(ACCESS_ENGINEERING_ENGINE, ACCESS_ENGINEERING_ATMOS),
		num2text(MED_FREQ)   = list(ACCESS_MEDICAL_EQUIPMENT),
		num2text(MED_I_FREQ) = list(ACCESS_MEDICAL_EQUIPMENT),
		num2text(SEC_FREQ)   = list(ACCESS_SECURITY_EQUIPMENT),
		num2text(SEC_I_FREQ) = list(ACCESS_SECURITY_EQUIPMENT),
		num2text(SCI_FREQ)   = list(ACCESS_SCIENCE_FABRICATION,ACCESS_SCIENCE_ROBOTICS,ACCESS_SCIENCE_XENOBIO),
		num2text(SUP_FREQ)   = list(ACCESS_SUPPLY_BAY),
		num2text(SRV_FREQ)   = list(ACCESS_GENERAL_JANITOR, ACCESS_GENERAL_BOTANY),
	)

// Another way to setup the map datum that can be convenient.  Just declare all your zlevels as subtypes of a common
// 	subtype of /datum/map_z_level and set zlevel_datum_type on /datum/map to have the lists auto-initialized.

// Structure to hold zlevel info together in one nice convenient package.
/datum/map_z_level
	var/z = 0				// Actual z-index of the zlevel. This had better be right!
	var/name				// Friendly name of the zlevel
	var/flags = 0			// Bitflag of which *_levels lists this z should be put into.
	var/turf/base_turf = /turf/space // Type path of the base turf for this z

	var/transit_chance = 0	// Percentile chance this z will be chosen for map-edge space transit.

// Holomaps
	var/holomap_offset_x = -1	// Number of pixels to offset the map right (for centering) for this z
	var/holomap_offset_y = -1	// Number of pixels to offset the map up (for centering) for this z
	var/holomap_legend_x = 96	// x position of the holomap legend for this z
	var/holomap_legend_y = 96	// y position of the holomap legend for this z

// Default constructor applies itself to the parent map datum
/datum/map_z_level/New(var/datum/map/map, _z)
	if(_z)
		src.z = _z
	if(!z)
		return
	map.zlevels["[z]"] = src
	if(flags & MAP_LEVEL_STATION) map.station_levels |= z
	if(flags & MAP_LEVEL_ADMIN) map.admin_levels |= z
	if(flags & MAP_LEVEL_CONTACT) map.contact_levels |= z
	if(flags & MAP_LEVEL_PLAYER) map.player_levels |= z
	if(flags & MAP_LEVEL_SEALED) map.sealed_levels |= z
	if(flags & MAP_LEVEL_XENOARCH_EXEMPT) map.xenoarch_exempt_levels |= z
	if(flags & MAP_LEVEL_EMPTY)
		if(!map.empty_levels) map.empty_levels = list()
		map.empty_levels |= z
	if(flags & MAP_LEVEL_CONSOLES)
		if (!map.map_levels)
			map.map_levels = list()
		map.map_levels |= z
	if(base_turf)
		map.base_turf_by_z["[z]"] = base_turf
	if(transit_chance)
		map.accessible_z_levels["[z]"] = transit_chance
	// Holomaps
	// Auto-center the map if needed (Guess based on maxx/maxy)
	if (holomap_offset_x < 0)
		holomap_offset_x = ((HOLOMAP_ICON_SIZE - world.maxx) / 2)
	if (holomap_offset_x < 0)
		holomap_offset_y = ((HOLOMAP_ICON_SIZE - world.maxy) / 2)
	// Assign them to the map lists
	LIST_NUMERIC_SET(map.holomap_offset_x, z, holomap_offset_x)
	LIST_NUMERIC_SET(map.holomap_offset_y, z, holomap_offset_y)
	LIST_NUMERIC_SET(map.holomap_legend_x, z, holomap_legend_x)
	LIST_NUMERIC_SET(map.holomap_legend_y, z, holomap_legend_y)

/datum/map_z_level/Destroy(var/force)
	stack_trace("Attempt to delete a map_z_level instance [log_info_line(src)]")
	if(!force)
		return QDEL_HINT_LETMELIVE // No.
	if (GLOB.using_map.zlevels["[z]"] == src)
		GLOB.using_map.zlevels -= "[z]"
	return ..()
