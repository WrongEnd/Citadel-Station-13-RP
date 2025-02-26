// Basically they are for the firing range
/obj/structure/target_stake
	name = "target stake"
	desc = "A thin platform with negatively-magnetized wheels."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_stake"
	density = 1
	w_class = ITEMSIZE_HUGE
	var/obj/item/target/pinned_target // the current pinned target

/obj/structure/target_stake/Moved()
	. = ..()
	if(pinned_target && (pinned_target.loc != loc))
		// Move the pinned target along with the stake
		pinned_target.forceMove(loc)

/obj/structure/target_stake/attackby(obj/item/W as obj, mob/user as mob)
	// Putting objects on the stake. Most importantly, targets
	if(pinned_target)
		return ..() // get rid of that pinned target first!

	if(istype(W, /obj/item/target))
		. = CLICKCHAIN_DO_NOT_PROPAGATE
		if(!user.attempt_insert_item_for_installation(W, loc))
			return
		W.layer = ABOVE_JUNK_LAYER
		pinned_target = W
		to_chat(user, "You slide the target into the stake.")
	else
		return ..()

/obj/structure/target_stake/attack_hand(mob/user, list/params)
	// taking pinned targets off!
	if(pinned_target)
		pinned_target.layer = OBJ_LAYER

		pinned_target.loc = user.loc
		if(ishuman(user))
			if(!user.get_active_held_item())
				user.put_in_hands(pinned_target)
				to_chat(user, "You take the target out of the stake.")
		else
			pinned_target.loc = get_turf(user)
			to_chat(user, "You take the target out of the stake.")

		pinned_target = null
	else
		return ..()

/obj/structure/target_stake/bullet_act(obj/item/projectile/P, def_zone)
	if(pinned_target)
		return pinned_target.bullet_act(P, def_zone)
	else
		return ..()
