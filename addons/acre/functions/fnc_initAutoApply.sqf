#include "script_component.hpp"
/*
 * File: fnc_initAutoApply.sqf
 * Author: Mildly_Interested, fork contributors
 * Date: 2026-11-04
 * License: GNU General Public License v3.0 only - https://www.gnu.org/licenses/gpl-3.0-standalone.html
 *
 * Registers the event handlers for the optional automatic apply of saved radio settings.
 * All handlers exit immediately unless the CBA setting "Automatically apply saved settings" is enabled.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Function reached the end [BOOL]
 *
 * Example:
 * call l6AA_acre_fnc_initAutoApply;
 *
 * Public: No
 */

if (!hasInterface) exitWith {false};

// Radios the player already carries when the arsenal opens are not new: leave their settings alone
["ace_arsenal_displayOpened", {
    if (GVAR(autoApplyMode) > 0) then {
        GVAR(handledRadios) append ([] call acre_api_fnc_getCurrentRadioList);
    };
}] call CBA_fnc_addEventHandler;

// Radios taken from a loadout in the arsenal are new and have default settings
["ace_arsenal_displayClosed", {
    if (GVAR(autoApplyMode) > 0) then {
        [] call FUNC(scheduleAutoApply);
    };
}] call CBA_fnc_addEventHandler;

// Mode "whenever new radios are acquired": any change of the player's loadout may have added a radio
["loadout", {
    if (GVAR(autoApplyMode) == 2) then {
        [] call FUNC(scheduleAutoApply);
    };
}] call CBA_fnc_addPlayerEventHandler;

// Radios the player spawns with. Long timeout: the player may still be in a role selection or briefing screen
if (GVAR(autoApplyMode) == 2) then {
    [120] call FUNC(scheduleAutoApply);
};

true
