#include "script_component.hpp"
/*
 * File: fnc_restoreRadioSettings.sqf
 * Author: Darojax, KrippeJaevel, Mildly_Interested, fork contributors
 * Date: 2023-08-24
 * Last Update: 2026-11-04
 * License: GNU General Public License v3.0 only - https://www.gnu.org/licenses/gpl-3.0-standalone.html
 *
 * Get radio config for the current server from profileNamespace and apply to radios in player's inventory.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Function reached the end [BOOL]
 *
 * Example:
 * call l6AA_acre_fnc_restoreRadioSettings;
 *
 * Public: No
 */

private _settings = call FUNC(getSavedSettings);

if (_settings isEqualTo []) exitWith {
    ["acre_persistence", "ACRE Persistence", "There are no saved settings", format ["Server: %1", call FUNC(getServerKey)], 3, [1, 0.8, 0, 1]] call acre_sys_list_fnc_displayHint;
    false
};

private _key = _settings select 4;
private _subtitle = [format ["Server: %1", _key], format ["Server: %1 (older shared save)", _key]] select (_settings select 5);

// Apply to all radios and set PTT. A manual restore counts as handled, so auto-apply never touches these radios afterwards
private _result = [_settings] call FUNC(applySettings);
GVAR(handledRadios) append ([] call acre_api_fnc_getCurrentRadioList);

switch (_result) do {
    case -1: {
        ["acre_persistence", "ACRE Persistence", "You are not carrying any radios", "", 3, [1, 0.29, 0.16, 1]] call acre_sys_list_fnc_displayHint;
    };
    case 0: {
        ["acre_persistence", "ACRE Persistence", "No matching radio types found", _subtitle, 3, [1, 0.29, 0.16, 1]] call acre_sys_list_fnc_displayHint;
    };
    case 1: {
        ["acre_persistence", "ACRE Persistence", "Radio Settings restored", _subtitle, 3, [0.29, 1, 0.16, 1]] call acre_sys_list_fnc_displayHint;
    };
    default {
        ["acre_persistence", "ACRE Persistence", "Radio Settings partially restored", "Missing radios in your inventory", 3, [1, 0.8, 0, 1]] call acre_sys_list_fnc_displayHint;
    };
};

true
