//Return values for the how_open() proc
#define SURGERY_INCISED (1<<0)
#define SURGERY_RETRACTED (1<<1)
#define SURGERY_BROKEN (1<<2)
#define SURGERY_DRILLED (1<<3)
#define SURGERY_SET_BONES (1<<3)

//Flags for requirements for a surgery step
#define STEP_NEEDS_INCISED (1<<0)
#define STEP_NEEDS_RETRACTED (1<<1)
#define STEP_NEEDS_BROKEN (1<<2)
#define STEP_NEEDS_DRILLED (1<<3)
#define STEP_NEEDS_ENCASED (1<<4)
#define STEP_NEEDS_SET_BONES (1<<5)
