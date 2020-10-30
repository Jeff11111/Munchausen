// Everyone, but Civilian and Service
#define NOCIV_ROLES list(\
						"Chief Enforcer", "Captain", "Head of Personnel", "Senior Engineer", "Research Director", "Chief Medical Officer", "Quartermaster",\
						"Medical Doctor", "Chemist", "Paramedic", "Virologist", "Geneticist", "Scientist", "Roboticist", "Psychologist",\
						"Atmospheric Technician", "Station Engineer", "Warden", "Detective", "Enforcer", "Blueshield", "Brig Physician",\
						"Cargo Technician", "Shaft Miner", "Mining Foreman", "Mining Technician"\
						)

// Literally everyone, but Prisoners. Hopefully tempoary, until proper blacklist.
#define NOPRISON_ROLES list(\
							"Chief Enforcer", "Captain", "Head of Personnel", "Senior Engineer", "Research Director", "Chief Medical Officer", "Quartermaster",\
							"Medical Doctor", "Chemist", "Paramedic", "Virologist", "Geneticist", "Scientist", "Roboticist", "Psychologist",\
							"Atmospheric Technician", "Station Engineer", "Warden", "Detective", "Enforcer", "Blueshield", "Brig Physician",\
							"Cargo Technician", "Shaft Miner", "Mining Foreman", "Mining Technician",\
							"Bartender", "Botanist", "Cook", "Curator", "Chaplain", "Janitor",\
							"Clown", "Mime", "Lawyer", "Stowaway"\
							)

// Some of these might be left unused, but still it's nice to have them around.
#define CMD_ROLES list("Captain", "Head of Personnel", "Chief Enforcer", "Senior Engineer", "Research Director", "Chief Medical Officer", "Quartermaster")
#define MED_ROLES list("Chief Medical Officer", "Medical Doctor", "Virologist", "Chemist", "Geneticist", "Paramedic", "Brig Physician", "Psychologist")
#define SCI_ROLES list("Research Director", "Scientist", "Roboticist")
#define SEC_ROLES list("Chief Enforcer", "Enforcer", "Warden", "Brig Physician", "Blueshield")
#define ENG_ROLES list("Senior Engineer", "Atmospheric Technician", "Station Engineer")
#define CRG_ROLES list("Quartermaster", "Cargo Technician", "Shaft Miner", "Mining Foreman", "Mining Technician")
#define CIV_ROLES list("Head of Personnel", "Bartender", "Botanist", "Cook", "Curator", "Chaplain", "Janitor", "Clown", "Mime", "Lawyer", "Stowaway")
#define FUN_ROLES list("Clown", "Mime")

// Hybrids. Might be left unused even more, aside from OrviTrek-like stuff. As for OPRS it is ENG+SEC+CRG.
#define MEDSCI_ROLES list(\
						"Chief Medical Officer", "Medical Doctor", "Virologist", "Chemist", "Geneticist", "Paramedic", "Psychologist",\
						"Research Director", "Scientist", "Roboticist"\
						)
#define OPRS_ROLES list(\
						"Chief Enforcer", "Enforcer", "Warden", "Brig Physician", "Blueshield",\
						"Senior Engineer", "Atmospheric Technician", "Station Engineer",\
						"Quartermaster", "Cargo Technician", "Shaft Miner", "Mining Foreman", "Mining Technician"\
						)
