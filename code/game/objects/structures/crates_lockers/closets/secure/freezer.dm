/obj/structure/closet/secure_closet/freezer

/obj/structure/closet/secure_closet/freezer/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

/obj/structure/closet/secure_closet/freezer/kitchen
	name = "kitchen cabinet"
	req_access = list(ACCESS_GENERAL_KITCHEN)

	starts_with = list(
		/obj/item/reagent_containers/food/condiment/flour = 7,
		/obj/item/reagent_containers/food/condiment/sugar = 2)

/obj/structure/closet/secure_closet/freezer/kitchen/mining
	req_access = list()


/obj/structure/closet/secure_closet/freezer/meat
	name = "meat fridge"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"

	starts_with = list(
		/obj/item/reagent_containers/food/snacks/meat/monkey = 10)


/obj/structure/closet/secure_closet/freezer/fridge
	name = "refrigerator"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"

	starts_with = list(
		/obj/item/reagent_containers/food/drinks/milk = 6,
		/obj/item/reagent_containers/food/drinks/soymilk = 4,
		/obj/item/storage/fancy/egg_box = 4,
		/obj/item/reagent_containers/hypospray/autoinjector/biginjector/glucose = 2)


/obj/structure/closet/secure_closet/freezer/money
	name = "freezer"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"
	req_access = list(ACCESS_COMMAND_VAULT)


	starts_with = list(
		/obj/item/spacecash/c1000 = 3,
		/obj/item/spacecash/c500 = 4,
		/obj/item/spacecash/c200 = 5)
