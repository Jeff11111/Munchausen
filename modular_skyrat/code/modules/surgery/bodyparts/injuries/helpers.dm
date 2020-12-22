//injury helpers
/proc/get_injury_type(type, damage)
	switch(type)
		if(WOUND_SLASH)
			switch(damage)
				if(70 to INFINITY)
					return /datum/injury/slash/massive
				if(60 to 70)
					return /datum/injury/slash/gaping_big
				if(50 to 60)
					return /datum/injury/slash/gaping
				if(25 to 50)
					return /datum/injury/slash/flesh
				if(15 to 25)
					return /datum/injury/slash/deep
				if(0 to 15)
					return /datum/injury/slash/small
		if(WOUND_PIERCE)
			switch(damage)
				if(60 to INFINITY)
					return /datum/injury/puncture/massive
				if(50 to 60)
					return /datum/injury/puncture/gaping_big
				if(30 to 50)
					return /datum/injury/puncture/gaping
				if(15 to 30)
					return /datum/injury/puncture/flesh
				if(0 to 15)
					return /datum/injury/puncture/small
		if(WOUND_BLUNT)
			return /datum/injury/bruise
		if(WOUND_BURN)
			switch(damage)
				if(50 to INFINITY)
					return /datum/injury/burn/carbonised
				if(40 to 50)
					return /datum/injury/burn/deep
				if(30 to 40)
					return /datum/injury/burn/severe
				if(15 to 30)
					return /datum/injury/burn/large
				if(0 to 15)
					return /datum/injury/burn/moderate
	return null //no wound
