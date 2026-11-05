#include "script_component.hpp"
/*
 * File: fnc_scheduleAutoApply.sqf
 * Author: Mildly_Interested, fork contributors
 * Date: 2026-11-04
 * License: GNU General Public License v3.0 only - https://www.gnu.org/licenses/gpl-3.0-standalone.html
 *
 * Schedules one automatic apply. Waits until ACRE has given every new radio its unique ID and the arsenal is closed,
 * because radio settings can only be set on radios with a unique ID. Calls while a run is already waiting are ignored,
 * the waiting run looks at the state of the player's radios when it fires.
 *
 * Arguments:
 * 0: Seconds to wait for ACRE before giving up (default: 20) <NUMBER>
 *
 * Return Value:
 * A run was scheduled [BOOL]
 *
 * Example:
 * call l6AA_acre_fnc_scheduleAutoApply;
 *
 * Public: No
 */

params [["_timeout", 20, [0]]];

if (GVAR(autoApplyMode) <= 0 || {GVAR(autoApplyPending)}) exitWith {false};

GVAR(autoApplyPending) = true;

// Short delay so a burst of loadout changes settles first
[{
    params ["_timeout"];
    [
        {
            !(missionNamespace getVariable ["acre_sys_core_arsenalOpen", false]) && {[] call acre_api_fnc_isInitialized}
        },
        {
            call FUNC(autoApply);
        },
        [],
        _timeout,
        {
            GVAR(autoApplyPending) = false;
        }
    ] call CBA_fnc_waitUntilAndExecute;
}, [_timeout], 1] call CBA_fnc_waitAndExecute;

true
