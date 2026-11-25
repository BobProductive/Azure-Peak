/obj/item/disguise_kit
	name = "disguise kit"
	desc = "An arcyne mirror imbued with the magicka of fae, allowing the user to change the look of their face and the way they are percieved by others for a number of glances."
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "cream"
	w_class = WEIGHT_CLASS_SMALL
	var/disguise_owner
	var/disguised = FALSE
	var/fake_name = FALSE
	var/fake_job = FALSE
	var/number_of_examines = 0
	var/list/examine_cooldowns = list()
	var/actual_name
	var/actual_job
	grid_width = 32
	grid_height = 32

/obj/item/disguise_kit/dropped(mob/user, silent = FALSE)
	. = ..()
	if(!isturf(loc))
		return
	if(disguised && disguise_owner)
		end_disguise(disguise_owner)
		to_chat(disguise_owner, span_warning("Your disguise is gone!"))

/obj/item/disguise_kit/proc/register_examine(mob/examiner, mob/living/carbon/human/disguised_human)
	if(!disguised || !examiner?.client || examiner == disguised_human)
		return

	var/examiner_ckey = examiner.ckey
	if(!examiner_ckey || world.time < examine_cooldowns[examiner_ckey])
		return

	number_of_examines++
	to_chat(examiner, span_warning("[number_of_examines]"))
	examine_cooldowns[examiner_ckey] = world.time + 20 SECONDS

	if(number_of_examines > 5)
		end_disguise(disguised_human)
		to_chat(disguised_human, span_warning("Your disguise is gone!"))

/obj/item/disguise_kit/proc/end_disguise(mob/living/carbon/human/H)
	H.real_name = actual_name
	H.fake_title = actual_job
	if(H.active_disguise_kit == src)
		H.active_disguise_kit = null
	disguised = FALSE
	fake_name = FALSE
	fake_job = FALSE
	disguise_owner = FALSE
	number_of_examines = 0

/obj/item/disguise_kit/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(disguised)
		end_disguise(H)
		return

	if(!disguised)
		disguised = TRUE
		disguise_owner = H
		H.active_disguise_kit = src
		actual_name = H.real_name
		actual_job = H.fake_title

		var/name_bool = alert(user, "Do you wish to change your name?", "Disguise kit", "Yes", "No")
		if(!name_bool)
			name_bool = "No"
		if(name_bool == "Yes")
			fake_name = sanitize(input(user, "Do you wish to change how you look?", "Disguise kit"))
			if(fake_name)
				H.real_name = fake_name

		var/list/towner_jobs = list()
		towner_jobs += GLOB.peasant_positions
		towner_jobs += GLOB.burgher_positions
		towner_jobs += GLOB.atc_positions
		towner_jobs += GLOB.bathhouse_positions
		towner_jobs += GLOB.tavern_positions
		towner_jobs += GLOB.courtier_positions
		towner_jobs += GLOB.retinue_positions
		towner_jobs += GLOB.garrison_positions
		towner_jobs += GLOB.church_positions
		towner_jobs += GLOB.burgher_positions
		towner_jobs += GLOB.peasant_positions

		var/job_bool = alert(user, "Do you wish to change your job?", "Disguise kit", "Yes", "No")
		if(!job_bool)
			job_bool = "No"
		if(job_bool == "Yes")
			var/selected_job = input(user, "Do you wish to change how others percieve your position?", "Disguise kit") as anything in towner_jobs
			if(selected_job)
				fake_job = TRUE
				H.fake_title = selected_job

