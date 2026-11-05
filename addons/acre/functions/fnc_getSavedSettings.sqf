#include "script_component.hpp"
/*
 * File: fnc_getSavedSettings.sqf
 * Author: Mildly_Interested, fork contributors
 * Date: 2026-11-04
 * License: GNU General Public License v3.0 only - https://www.gnu.org/licenses/gpl-3.0-standalone.html
 *
 * Gets the radio settings saved for a server from the profileNamespace.
 * If nothing was saved for that server yet, falls back to the single shared set of settings that
 * versions before per-server profiles wrote (so existing saves keep working until the player saves on that server).
 *
 * Arguments:
 * 0: Server key (default: key of the current server) <STRING>
 *
 * Return Value:
 * [baseRadios, channels, volumes, spatials, serverKey, isLegacy], or [] if nothing is saved [ARRAY]
 *
 * Example:
 * private _settings = call l6AA_acre_fnc_getSavedSettings;
 *
 * Public: No
 */

params [["_key", call FUNC(getServerKey), [""]]];

private _profiles = profileNamespace getVariable [QGVAR(serverProfiles), []];
private _index = _profiles findIf {(_x select 0) isEqualTo _key};

if (_index != -1) exitWith {
    private _result = +((_profiles select _index) select 1);
    _result append [_key, false];
    _result
};

// Fallback: settings saved by versions without server profiles
private _baseRadios = profileNamespace getVariable [QGVAR(baseRadios), []];

if (_baseRadios isEqualTo []) exitWith {[]};

[
    _baseRadios,
    profileNamespace getVariable [QGVAR(channels), []],
    profileNamespace getVariable [QGVAR(volumes), []],
    profileNamespace getVariable [QGVAR(spatials), []],
    _key,
    true
]
