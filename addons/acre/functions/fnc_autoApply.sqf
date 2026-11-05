#include "script_component.hpp"
/*
 * File: fnc_autoApply.sqf
 * Author: Mildly_Interested, fork contributors
 * Date: 2026-11-04
 * License: GNU General Public License v3.0 only - https://www.gnu.org/licenses/gpl-3.0-standalone.html
 *
 * Applies the saved radio settings of the current server to radios that were not handled yet this session.
 * Radios that were already configured (manual restore, earlier auto-apply, respawn restore, or carried when the
 * arsenal opened) keep their settings, so manual changes are never overwritten.
 * The PTT assignment is only set when every radio the player carries is new.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Settings were applied [BOOL]
 *
 * Example:
 * call l6AA_acre_fnc_autoApply;
 *
 * Public: No
 */

GVAR(autoApplyPending) = false;

if (GVAR(autoApplyMode) <= 0) exitWith {false};

private _current = [] call acre_api_fnc_getCurrentRadioList;
private _new = _current - GVAR(handledRadios);

if (_new isEqualTo []) exitWith {false};

private _settings = call FUNC(getSavedSettings);

// Remember these radios either way, so a save made later does not get applied over a radio the player is already using
GVAR(handledRadios) append _new;

// Keep the list from growing without bound over a long session
if (count GVAR(handledRadios) > 100) then {
    GVAR(handledRadios) = GVAR(handledRadios) select [(count GVAR(handledRadios)) - 100, 100];
};

if (_settings isEqualTo []) exitWith {false};

private _result = [_settings, _new, count _new == count _current] call FUNC(applySettings);

if (GVAR(autoApplyHint) && {_result > 0}) then {
    private _title = ["Radio Settings partially applied", "Radio Settings applied"] select (_result == 1);
    private _key = _settings select 4;
    ["acre_persistence", "ACRE Persistence", _title, format ["Server: %1", _key], 3, [0.29, 1, 0.16, 1]] call acre_sys_list_fnc_displayHint;
};

_result > 0
