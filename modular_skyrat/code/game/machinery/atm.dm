/obj/machinery/atm
	name = "automatic teller machine"
	desc = "A terminal that will allow you to access your bank account."
	icon = 'modular_skyrat/icons/obj/machines/terminals.dmi'
	icon_state = "atm"
	var/datum/component/uplink/comicao_trading
	var/obj/item/card/id/CID = null
	var/agent = "BINGUS"
	var/emagaccount = null
	var/totalmoney = null

/obj/machinery/atm/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/multitool_emaggable)

/obj/machinery/atm/ComponentInitialize()
	. = ..()
	comicao_trading = AddComponent(/datum/component/uplink, null, TRUE, FALSE, /datum/game_mode/nuclear)
	comicao_trading.teleports_items = FALSE
	RegisterSignal(src, COMSIG_COMPONENT_UPLINK_LOCK, /atom/.proc/update_icon)
	RegisterSignal(src, COMSIG_COMPONENT_UPLINK_OPEN, /atom/.proc/update_icon)

/obj/machinery/atm/update_icon()
	. = ..()
	if(!comicao_trading || comicao_trading.locked)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-borked"

/obj/machinery/atm/attack_ghost(mob/user)
	. = ..()
	to_chat(user, "<b>Station decrees:</b>")
	for(var/i in SScommunications.decrees)
		to_chat(user, "• [i]")
	if(!length(SScommunications.decrees))
		to_chat(user, "• None.")

/obj/machinery/atm/attack_hand(mob/living/user)
	. = ..()
	if(user.canUseTopic(src, TRUE))
		if(!comicao_trading || comicao_trading.locked || !comicao_trading.purchase_log)
			to_chat(user, "<b>Station decrees:</b>")
			for(var/i in SScommunications.decrees)
				to_chat(user, "• [i]")
			if(!length(SScommunications.decrees))
				to_chat(user, "• None.")
		else
			playsound(src, 'modular_skyrat/sound/machinery/atm_beep2.ogg', 50)
			comicao_trading.interact(src, user)

/obj/machinery/atm/middle_attack_hand(mob/user)
	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	if(GLOB.uplink_purchase_logs_by_key[user.client?.key])
		var/datum/uplink_purchase_log/purchase_log = GLOB.uplink_purchase_logs_by_key[user.client?.key]
		if(purchase_log)
			playsound(src, 'modular_skyrat/sound/machinery/atm_beep1.ogg', 50)
			to_chat(src, "<span class='danger'>I start scrambling [src]'s electronics...</span>")
			if(do_after(user, 15, target = src))
				agent = user.name || "BINGUS"
				comicao_trading.purchase_log = purchase_log
				comicao_trading.telecrystals = max(0, 20 - purchase_log.total_spent)
				comicao_trading.locked = FALSE
				playsound(src, 'modular_skyrat/sound/machinery/atm_beep2.ogg', 50)
				to_chat(user, "<span class='danger'><b>##&!&$% WELCOME, AGENT [uppertext(agent)] $$#@!%</b></span>")
				user.mind?.announce_objectives()
				var/datum/antagonist/traitor/bingus = user.mind.has_antag_datum(/datum/antagonist/traitor)
				if(bingus.should_give_codewords)
					bingus.give_codewords()
				user.mind?.objectives_hidden = FALSE
	return TRUE

/obj/machinery/atm/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/card/id))
		CID = W
		if(!CID.registered_account.account_password)
			var/passchoice = input(user, "Please select a password:", "Password Selection") as null|text
			if(!passchoice)
				invalid_number()
				return
			CID.registered_account.account_password = passchoice
			return
		var/enteredpass = input(user, "Please enter your password:", "Password Entry") as null|text
		if(!enteredpass)
			invalid_number()
			return
		if(enteredpass != CID.registered_account.account_password)
			playsound(loc, 'sound/machines/beeping_alarm.ogg', 50, 1, -1)
			visible_message("<span class='warning'>Incorrect Password.</span>", null, null, 5, null, null, null, null, TRUE)
			return
		var/nextquestion = input(user, "Please select a function:", "Function Selection") as null|anything in list("withdraw", "change password", "direct deposit")
		switch(nextquestion)
			if("withdraw")
				var/withdrawfund = input(user, "Please select the amount to withdraw:", "Withdraw Money") as null|num 
				if(!withdrawfund)
					invalid_number()
					return
				if(withdrawfund <= 0 || withdrawfund > CID.registered_account.account_balance)
					invalid_number()
					return
				CID.registered_account.account_balance -= withdrawfund
				var/obj/item/stack/spacecash/c1/cash = new (get_turf(src), withdrawfund)
				user.put_in_inactive_hand(cash)
				successful_transaction()
			if("change password")
				var/passchoicenew = input(user, "Please select a password:", "Password Selection") as null|text
				if(!passchoicenew)
					invalid_number()
					return
				CID.registered_account.account_password = passchoicenew
				return
			if("direct deposit")
				var/selectaccount = input(user, "Please enter an account number:", "Account Selection") as null|num
				if(!selectaccount)
					not_selected_account()
					return
				for(var/datum/bank_account/BA in SSeconomy.bank_accounts)
					if(selectaccount != BA.account_id)
						continue
					var/ddeposit = input(user, "Please select the amount to withdraw:", "Withdraw Money") as null|num 
					if(!ddeposit)
						invalid_number()
						return
					if(ddeposit <= 0 || ddeposit > CID.registered_account.account_balance)
						invalid_number()
						return
					CID.registered_account.account_balance -= ddeposit
					totalmoney = ddeposit
					emagcheck()
					if(!emagaccount)
						BA.account_balance += totalmoney
					successful_transaction()
					break
	if(istype(W, /obj/item/holochip))
		var/obj/item/holochip/HC = W
		if(HC.credits <= 0 || !HC.credits)
			return
		var/selectaccount = input(user, "Please enter an account number:", "Account Selection") as null|num
		var/chosenitem = user.get_active_held_item()
		if(!chosenitem)
			return
		if(!selectaccount)
			not_selected_account()
			return
		for(var/datum/bank_account/BA in SSeconomy.bank_accounts)
			if(selectaccount != BA.account_id)
				continue
			totalmoney = HC.credits
			emagcheck()
			if(!emagaccount)
				BA.account_balance += totalmoney
			successful_transaction()
			QDEL_NULL(HC)
			break
	if(istype(W, /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/SC = W
		if(SC.get_item_credit_value() <= 0 || !SC.get_item_credit_value())
			return
		var/selectaccount = input(user, "Please enter an account number:", "Account Selection") as null|num
		var/chosenitem = user.get_active_held_item()
		if(!chosenitem)
			return
		if(!selectaccount)
			not_selected_account()
			return
		for(var/datum/bank_account/BA in SSeconomy.bank_accounts)
			if(selectaccount != BA.account_id)
				continue
			totalmoney = SC.get_item_credit_value()
			emagcheck()
			if(!emagaccount)
				BA.account_balance += totalmoney
			successful_transaction()
			QDEL_NULL(SC)
			break
	if(istype(W, /obj/item/coin))
		var/obj/item/coin/CM = W
		if(CM.get_item_credit_value() <= 0 || !CM.get_item_credit_value())
			return
		var/selectaccount = input(user, "Please enter an account number:", "Account Selection") as null|num
		var/chosenitem = user.get_active_held_item()
		if(!chosenitem)
			return
		if(!selectaccount)
			not_selected_account()
			return
		for(var/datum/bank_account/BA in SSeconomy.bank_accounts)
			if(selectaccount != BA.account_id)
				continue
			totalmoney = CM.get_item_credit_value()
			emagcheck()
			if(!emagaccount)
				BA.account_balance += totalmoney
			successful_transaction()
			QDEL_NULL(CM)
			break
	if(istype(W, /obj/item/storage/bag/money))
		var/selectaccount = input(user, "Please enter an account number:", "Account Selection") as null|num
		if(!selectaccount)
			not_selected_account()
			return
		for(var/datum/bank_account/BA in SSeconomy.bank_accounts)
			if(selectaccount != BA.account_id)
				continue
			var/obj/item/storage/bag/money/money_bag = W
			var/list/money_contained = money_bag.contents
			var/total = 0
			for (var/obj/item/physical_money in money_contained)
				var/cash_money = physical_money.get_item_credit_value()
				total += cash_money
				QDEL_NULL(physical_money)
			totalmoney = total
			emagcheck()
			if(!emagaccount)
				BA.account_balance += totalmoney
			successful_transaction()
			break
	else
		return ..()
		
/obj/machinery/atm/proc/invalid_number()
	playsound(loc, 'sound/machines/synth_no.ogg', 50, 1, -1)
	visible_message("<span class='warning'>Invalid number entered.</span>", null, null, 5, null, null, null, null, TRUE)

/obj/machinery/atm/proc/successful_transaction()
	playsound(loc, 'sound/machines/synth_yes.ogg', 50, 1, -1)
	visible_message("<span class='warning'>Successful Transaction.</span>", null, null, 5, null, null, null, null, TRUE)

/obj/machinery/atm/proc/not_selected_account()
	playsound(loc, 'sound/machines/synth_no.ogg', 50, 1, -1)
	visible_message("<span class='warning'>You must select an account to deposit.</span>", null, null, 5, null, null, null, null, TRUE)
	return

/obj/machinery/atm/emag_act(mob/user)
	. = ..()
	if(emagaccount)
		to_chat(user, "<span class='warning'>This ATM is already emagged!</span>")
		return FALSE
	emagaccount = input("Choose which account to deposit to:", "Safety Protocols Disengaged") as null|num
	if(!emagaccount)
		to_chat(user, "<span class='warning'>You failed to select an account!</span>")
	playsound(src, 'modular_skyrat/sound/machinery/atm_emag.ogg', 50)
	flick("atm_emagging", src)
	icon_state = "atm_emag"
	return TRUE

/obj/machinery/atm/proc/emagcheck()
	if(emagaccount)
		for(var/datum/bank_account/BA in SSeconomy.bank_accounts)
			if(emagaccount != BA.account_id)
				continue
			BA.account_balance += totalmoney
			break
