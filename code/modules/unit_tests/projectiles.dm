/datum/unit_test/projectile_movetypes/Run()
	for(var/path in typesof(/obj/item/projectile))
		var/obj/projectile/projectile = path
		if(initial(projectile.movement_type) & MOVEMENT_PHASING)
			Fail("[path] has default movement type MOVEMENT_PHASING. Piercing projectiles should be done using the projectile piercing system, not movement_types!")
