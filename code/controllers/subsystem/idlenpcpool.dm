SUBSYSTEM_DEF(idlenpcpool)
	name = "Idling NPC Pool"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT
	priority = FIRE_PRIORITY_IDLE_NPC
	wait = 6 SECONDS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()
	var/static/list/idle_mobs_by_zlevel[][]

/datum/controller/subsystem/idlenpcpool/proc/MaxZChanged()
	if (!islist(idle_mobs_by_zlevel))
		idle_mobs_by_zlevel = new /list(world.maxz,0)
	while (SSidlenpcpool.idle_mobs_by_zlevel.len < world.maxz)
		SSidlenpcpool.idle_mobs_by_zlevel.len++
		SSidlenpcpool.idle_mobs_by_zlevel[idle_mobs_by_zlevel.len] = list()

/datum/controller/subsystem/idlenpcpool/proc/MaxZdec()
	if (!islist(idle_mobs_by_zlevel))
		idle_mobs_by_zlevel = new /list(world.maxz,0)
	while (SSidlenpcpool.idle_mobs_by_zlevel.len > world.maxz)
		SSidlenpcpool.idle_mobs_by_zlevel.len--

/datum/controller/subsystem/idlenpcpool/fire(resumed = FALSE)
	if (!resumed || !currentrun.len)
		var/list/idlelist = GLOB.simple_animals["[AI_IDLE]"]
		if(!idlelist)
			idlelist = list()
		src.currentrun = idlelist.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/current = src.currentrun

	while(current.len)
		var/mob/living/simple_animal/SA = current[current.len]
		--current.len
		if (!SA)
			GLOB.simple_animals["[AI_IDLE]"] -= SA
			continue

		if(!SA.ckey)
			if(SA.stat != DEAD)
				SA.handle_automated_movement()
			if(SA.stat != DEAD)
				SA.consider_wakeup()
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/idlenpcpool/proc/handle_automated_movement(mob/living/simple_animal/mobinput)
	if(!mobinput)
		return
	if(QDELETED(mobinput))
		return
	mobinput.handle_automated_movement()
	mobinput.move_skip = FALSE
