#include "script_component.hpp"
ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Unique radio IDs that already had their settings applied (or were deliberately left alone) this session
GVAR(handledRadios) = [];
// True while an auto-apply cycle is waiting for ACRE to finish converting radios
GVAR(autoApplyPending) = false;

#include "initSettings.sqf"

ADDON = true;
