/obj/structure/blob/resource
	name = "resource blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	desc = "A thin spire of slightly swaying tendrils."
	max_integrity = 80
	point_return = 15
	armor = list("melee" = 10, "bullet" = 10, "laser" = 0, "energy" = 0, "bomb" = 15, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 90)
	var/resource_delay = 0

/obj/structure/blob/resource/scannerreport()
	return "Gradually supplies the blob with resources, increasing the rate of expansion."

/obj/structure/blob/resource/creation_action()
	if(overmind)
		overmind.resource_blobs += src

/obj/structure/blob/resource/Destroy()
	if(overmind)
		overmind.resource_blobs -= src
	return ..()

/obj/structure/blob/resource/Be_Pulsed()
	. = ..()
	if(resource_delay > world.time)
		return
	flick("blob_resource_glow", src)
	if(overmind)
		overmind.add_points(1.5)
		resource_delay = world.time + 40 + overmind.resource_blobs.len * 2.5 //4 seconds plus a quarter second for each resource blob the overmind has
	else
		resource_delay = world.time + 40
