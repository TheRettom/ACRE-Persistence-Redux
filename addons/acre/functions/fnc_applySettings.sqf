#include "script_component.hpp"
/*
 * File: fnc_applySettings.sqf
 * Author: Darojax, KrippeJaevel, Mildly_Interested, fork contributors
 * Date: 2023-08-24
 * Last Update: 2026-11-04
 * License: GNU General Public License v3.0 only - https://www.gnu.org/licenses/gpl-3.0-standalone.html
 *
 * Applies saved radio settings to the radios the player is carrying.
 * Shared by the manual "Restore Radio Settings" action and the automatic apply.
 *
 * Arguments:
 * 0: Saved settings [baseRadios, channels, volumes, spatials] <ARRAY>
 * 1: Radio IDs to configure, empty = all radios the player carries (default: []) <ARRAY>
 * 2: Also set the PTT assignment (default: true) <BOOL>
 *
 * Return Value:
 * -1 = player carries no radios, 0 = no matching radio types, 1 = all saved radios matched, 2 = partially matched [NUMBER]
 *
 * Example:
 * [_settings] call l6AA_acre_fnc_applySettings;
 *
 * Public: No
 */

params [
    ["_settings", [], [[]]],
    ["_targets", [], [[]]],
    ["_setPtt", true, [true]]
];

_settings params [["_baseRadios", [], [[]]], ["_channels", [], [[]]], ["_volumes", [], [[]]], ["_spatials", [], [[]]]];

private _radios = [] call acre_api_fnc_getCurrentRadioList;

if (_radios isEqualTo []) exitWith {-1};

if (_targets isEqualTo []) then {
    _targets = +_radios;
};

// Reorder radios to match the saved order, so the saved PTT1, PTT2 and PTT3 radios come first
private _sortedRadios = [];
{
    private _baseType = _x;
    private _found = _radios findIf {
        (([_x] call acre_api_fnc_getBaseRadio) isEqualTo _baseType) && {!(_x in _sortedRadios)}
    };
    if (_found != -1) then {
        _sortedRadios pushBack (_radios select _found);
    };
} forEach _baseRadios;

// Radios that are not part of the saved settings go last
_radios = _sortedRadios + (_radios - _sortedRadios);

if (_setPtt) then {
    [_radios] call acre_api_fnc_setMultiPushToTalkAssignment;
};

private _baseRadiosCopy = +_baseRadios;
private _channelsCopy = +_channels;
private _volumesCopy = +_volumes;
private _spatialsCopy = +_spatials;
private _matched = 0;

{
    if (_forEachIndex >= GVAR(amountOfRadiosToRestore)) exitWith {};

    private _radio = _x;
    private _index = _baseRadiosCopy find ([_radio] call acre_api_fnc_getBaseRadio);

    if (_index != -1) then {
        if (_radio in _targets) then {
            [_radio, _channelsCopy select _index] call acre_api_fnc_setRadioChannel;
            [_radio, _volumesCopy select _index] call acre_api_fnc_setRadioVolume;
            [_radio, _spatialsCopy select _index] call acre_api_fnc_setRadioSpatial;
            _matched = _matched + 1;
        };

        // Each saved entry is used once, also when its radio is not a target, so the saved order stays intact
        {
            _x deleteAt _index;
        } forEach [_baseRadiosCopy, _channelsCopy, _volumesCopy, _spatialsCopy];
    };
} forEach _radios;

if (_matched == 0) exitWith {0};

[2, 1] select (_baseRadiosCopy isEqualTo [])
