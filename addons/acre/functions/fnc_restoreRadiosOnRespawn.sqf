#include "script_component.hpp"
/*
 * File: fnc_restoreRadiosOnRespawn.sqf
 * Author: Darojax, KrippeJaevel, Mildly_Interested
 * Date: 2023-08-24
 * Last Update: 2026-11-04
 * License: License: GNU General Public License v3.0 only - https://www.gnu.org/licenses/gpl-3.0-standalone.html
 *
 * Adds respawn event handler to restore radios on respawn.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Function reached the end [BOOL]
 *
 * Example:
 * call l6AA_acre_fnc_restoreRadiosOnRespawn;
 *
 * Public: No
 */

player addEventHandler ["Respawn", {
    params ["_unit", "_corpse"];
    if !GVAR(restoreRadiosOnRespawn) exitWith {false};
    private _radioTypesToRestore = GVAR(radioTypesToRestore) splitString "', ";
    private _baseRadios = [];
    private _channels = [];
    private _volumes = [];
    private _spatials = [];
    private _radios = [];
    {_radios append ([_x, _corpse] call acre_api_fnc_getAllRadiosByType);} forEach _radioTypesToRestore;
    private _pttAssignment = [] call acre_api_fnc_getMultiPushToTalkAssignment;
    // Check if the _corpse is carrying any radios, if not, exit the script
    if (count _radios == 0) exitWith {};
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
        // Loop through maximum 6 radios
        if (_forEachIndex >= GVAR(amountOfRadiosToRestore)) exitWith {};
        _baseRadio = [_x] call acre_api_fnc_getBaseRadio;
        _baseRadios pushBack _baseRadio;
        _channel = [_x] call acre_api_fnc_getRadioChannel;
        _channels pushBack _channel;
        _volume = [_x] call acre_api_fnc_getRadioVolume;
        _volumes pushBack _volume;
        _spatial = [_x] call acre_api_fnc_getRadioSpatial;
        _spatials pushBack _spatial;
    } forEach _radios;
    [
        {
            params ["_baseRadios", "_channels", "_volumes", "_spatials", "_unit"];
            [_unit] call acre_api_fnc_hasRadio;},
        {
            params ["_baseRadios", "_channels", "_volumes", "_spatials", "_unit"];
            // Get the radio list from the player's inventory
            private _radios = [] call acre_api_fnc_getCurrentRadioList;
            // if player has no radios, exit
            if (count _radios == 0) exitWith {};
            // Reorder _radios array to match _baseRadios placing to be PTT1 PTT2 and PTT3 radios first
            private _sortedRadios = [];
            {
                _baseType = _x;
                _foundRadio = _radios findIf {
                    [_x] call acre_api_fnc_getBaseRadio isEqualTo _baseType && !(_x in _sortedRadios)
                };
                if (_foundRadio != -1) then {
                    _sortedRadios pushBack (_radios select _foundRadio);
                };
            } forEach _baseRadios;
            // Add remaining radios not in _baseRadios list
            _radios = _sortedRadios + (_radios - _sortedRadios);
            // set PTT assignments and implement restored radio settings
            private _success = [_radios] call acre_api_fnc_setMultiPushToTalkAssignment;
            private _baseRadiosCopy = +_baseRadios;
            private _channelsCopy = +_channels;
            private _volumesCopy = +_volumes;
            private _spatialsCopy = +_spatials;
            {
                if (_forEachIndex >= GVAR(amountOfRadiosToRestore)) exitWith {};
                _currentBaseRadio = [_x] call acre_api_fnc_getBaseRadio;
                _index = _baseRadiosCopy find _currentBaseRadio;
                if (_index != -1) then {
                    [_x, _channelsCopy select _index] call acre_api_fnc_setRadioChannel;
                    [_x, _volumesCopy select _index] call acre_api_fnc_setRadioVolume;
                    [_x, _spatialsCopy select _index] call acre_api_fnc_setRadioSpatial;
                    {_x deleteAt _index} forEach [_baseRadiosCopy, _channelsCopy, _volumesCopy, _spatialsCopy];
                };
            } forEach _radios;
            // These radios now carry the settings from the corpse, automatic apply must not overwrite them
            GVAR(handledRadios) append _radios;
        },
        [_baseRadios, _channels, _volumes, _spatials, _unit],
        GVAR(restoreRadiosOnRespawnDelay)
    ] call CBA_fnc_waitUntilAndExecute;

}];

true
