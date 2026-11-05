#include "script_component.hpp"
/*
 * File: fnc_showSavedRadioSettings.sqf
 * Author: Darojax, KrippeJaevel, Mildly_Interested, fork contributors
 * Date: 2023-08-28
 * Last Update: 2026-11-04
 * License: GNU General Public License v3.0 only - https://www.gnu.org/licenses/gpl-3.0-standalone.html
 *
 * Get the saved radio settings for the current server from the profileNamespace and display them as a hint.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Function reached the end [BOOL]
 *
 * Example:
 * call l6AA_acre_fnc_showSavedRadioSettings;
 *
 * Public: No
 */

private _settings = call FUNC(getSavedSettings);

// Check if previous settings exist, if not exit with a hint
if (_settings isEqualTo []) exitWith {
    ["acre_persistence", "ACRE Persistence", "There are no saved settings", format ["Server: %1", call FUNC(getServerKey)], 3, [1, 0.8, 0, 1]] call acre_sys_list_fnc_displayHint;
    false
};

_settings params ["_baseRadios", "_channels", "_volumes", "_spatials", "_key", "_isLegacy"];

// Create a formatted string with the radio information and the Push To Talk assignment and Display as hint
private _hintString = [["SAVED RADIO SETTINGS", 1.2]];
_hintString pushBack [format ["Server: %1%2", _key, [""," (older shared save)"] select _isLegacy]];
{
    private _index = _forEachIndex;
    private _baseRadio = (_x splitString "_" joinString " ") select [4];
    private _pttText = if (_index < 3) then { format [" - <t color='#2B7319'>PTT %1</t>", _index + 1] } else { "" };
    private _spatialText = switch (_spatials select _index) do {
        case "LEFT": {"Left Ear"};
        case "RIGHT": {"Right Ear"};
        default {"Both Ears"};
    };
    private _volumeText = str round ((_volumes select _index) * 100);
    _hintString pushBack [format ["Radio %1%2: %3 - Channel %4 Volume: %5%% - %6", _index + 1, _pttText, _baseRadio, _channels select _index, _volumeText, _spatialText]];
} forEach _baseRadios;
_hintString call CBA_fnc_notify;

true
