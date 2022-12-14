
////////////////////////Medical////////////////////////
/datum/techweb_node/cloning
	id = "cloning"
	display_name = "Genetic Engineering"
	description = "We have the technology to make him."
	prereq_ids = list("biotech")
	design_ids = list("clonecontrol", "clonepod", "clonescanner", "scan_console", "cloning_disk")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)

/datum/techweb_node/cryotech
	id = "cryotech"
	display_name = "Cryostasis Technology"
	description = "Smart freezing of objects to preserve them!"
	prereq_ids = list("adv_engi", "biotech")
	design_ids = list("splitbeaker", "noreactsyringe", "cryotube", "cryo_Grenade")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)

/datum/techweb_node/adv_defibrillator_tec
	id = "adv_defibrillator_tec"
	display_name = "Defibrillator Upgrades"
	description = "More ways to bring back the newly dead."
	prereq_ids = list("adv_biotech", "adv_engi", "adv_power")
	design_ids = list("defib_decay", "defib_shock", "defib_heal", "defib_speed")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

//////////////////////Cybernetics/////////////////////

/datum/techweb_node/surplus_limbs
	id = "surplus_limbs"
	display_name = "Basic Prosthetics"
	description = "Basic fragile prosthetics for the impaired."
	starting_node = TRUE
	prereq_ids = list("biotech")
	design_ids = list("basic_l_arm", "basic_r_arm", "basic_r_leg", "basic_l_leg")

/datum/techweb_node/advance_limbs
	id = "advance_limbs"
	display_name = "Upgraded Prosthetics"
	description = "Reinforced prosthetics for the impaired."
	prereq_ids = list("adv_biotech", "surplus_limbs")
	design_ids = list("adv_l_arm", "adv_r_arm", "adv_r_leg", "adv_l_leg")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1250)

/datum/techweb_node/subdermal_implants
	id = "subdermal_implants"
	display_name = "Subdermal Implants"
	description = "Electronic implants buried beneath the skin."
	prereq_ids = list("biotech", "datatheory")
	design_ids = list("implanter", "implantcase", "implant_chem", "implant_tracking", "locator", "c38_trac")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/cyber_organs
	id = "cyber_organs"
	display_name = "Cybernetic Organs"
	description = "We have the technology to rebuild him."
	prereq_ids = list("adv_biotech")
	design_ids = list("cybernetic_ears", "cybernetic_heart", "cybernetic_liver", "cybernetic_lungs", "cybernetic_tongue")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/cyber_organs_upgraded
	id = "cyber_organs_upgraded"
	display_name = "Upgraded Cybernetic Organs"
	description = "We have the technology to upgrade him."
	prereq_ids = list("cyber_organs")
	design_ids = list("cybernetic_ears_u", "cybernetic_heart_u", "cybernetic_liver_u", "cybernetic_lungs_u")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)

/datum/techweb_node/cyber_implants
	id = "cyber_implants"
	display_name = "Cybernetic Implants"
	description = "Electronic implants that improve humans."
	prereq_ids = list("adv_biotech", "adv_datatheory")
	design_ids = list("ci-nutriment", "ci-breather", "ci-gloweyes", "ci-welding", "ci-medhud", "ci-sechud", "ci-service")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_cyber_implants
	id = "adv_cyber_implants"
	display_name = "Advanced Cybernetic Implants"
	description = "Upgraded and more powerful cybernetic implants."
	prereq_ids = list("neural_programming", "cyber_implants","integrated_HUDs")
	design_ids = list("ci-toolset", "ci-surgery", "ci-reviver", "ci-nutrimentplus")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/combat_cyber_implants
	id = "combat_cyber_implants"
	display_name = "Combat Cybernetic Implants"
	description = "Military grade combat implants to improve performance."
	prereq_ids = list("adv_cyber_implants","weaponry","NVGtech","high_efficiency")
	design_ids = list("ci-xray", "ci-thermals", "ci-antidrop", "ci-antistun", "ci-thrusters", "ci-shield")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/////////////////////////Advanced Surgery/////////////////////////
/datum/techweb_node/advance_surgerytools
	id = "advance_surgerytools"
	display_name = "Advanced Surgery Tools"
	description = "Refined and improved redesigns for the run-of-the-mill medical utensils."
	prereq_ids = list("adv_biotech")
	design_ids = list("drapes", "retractor_adv", "surgicaldrill_adv", "scalpel_adv", "bonesetter")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
