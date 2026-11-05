#include "script_component.hpp"
/*
 * File: fnc_saveRadioSettings.sqf
 * Author: Darojax, KrippeJaevel, Mildly_Interested, fork contributors
 * Date: 2023-08-24
 * Last Update: 2026-11-04
 * License: GNU General Public License v3.0 only - https://www.gnu.org/licenses/gpl-3.0-standalone.html
 *
 * Gets the current radio settings and saves them to the profileNamespace, under the current server.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Function reached the end [BOOL]
 *
 * Example:
 * call l6AA_acre_fnc_saveRadioSettings;
 *
 * Public: No
 */

private _baseRadios = [];
private _channels = [];
private _volumes = [];
private _spatials = [];

// get the current radio list and PTT assignments for each radio
private _radios = [] call acre_api_fnc_getCurrentRadioList;
private _pttAssignment = call acre_api_fnc_getMultiPushToTalkAssignment;

// Check if the player is carrying any radios, if not, show the hint and exit
if (_radios isEqualTo []) exitWith {
    ["acre_persistence", "ACRE Persistence", "You are not carrying any radios", "Nothing to save", 3, [1, 0.8, 0, 1]] call acre_sys_list_fnc_displayHint;
    false
};

// Rearrange the radios in the _radios array to set the PTT radios first
private _tempRadios = [];
{
    private _pttRadio = _x;
    {
        if (_pttRadio == _x) then {
            _tempRadios pushBack _x;
        };
    } forEach _radios;
} forEach _pttAssignment;

// Add any remaining radios to the end of the _tempRadios array
{
    if (_tempRadios find _x == -1) then {
        _tempRadios pushBack _x;
    };
} forEach _radios;

_radios = _tempRadios;

// Loop through each radio in the list and extract its base type, channel, volume, and spatial setting into arrays
{
    // Same maximum as the "Number of radios to restore" setting
    if (_forEachIndex >= 10) exitWith {};
    _baseRadios pushBack ([_x] call acre_api_fnc_getBaseRadio);
    _channels pushBack ([_x] call acre_api_fnc_getRadioChannel);
    _volumes pushBack ([_x] call acre_api_fnc_getRadioVolume);
    _spatials pushBack ([_x] call acre_api_fnc_getRadioSpatial);
} forEach _radios;

// Save under the current server, replacing any earlier save for that server
private _key = call FUNC(getServerKey);
private _profiles = profileNamespace getVariable [QGVAR(serverProfiles), []];
private _entry = [_key, [_baseRadios, _channels, _volumes, _spatials]];
private _index = _profiles findIf {(_x select 0) isEqualTo _key};

if (_index == -1) then {
    _profiles pushBack _entry;
} else {
    _profiles set [_index, _entry];
};

profileNamespace setVariable [QGVAR(serverProfiles), _profiles];

["acre_persistence", "ACRE Persistence", "Radio Settings Saved", format ["Server: %1", _key], 3, [0.13, 0.61, 0.12, 1]] call acre_sys_list_fnc_displayHint;

true
