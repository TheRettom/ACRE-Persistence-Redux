#include "script_component.hpp"
/*
 * File: fnc_getServerKey.sqf
 * Author: Mildly_Interested, fork contributors
 * Date: 2026-11-04
 * License: GNU General Public License v3.0 only - https://www.gnu.org/licenses/gpl-3.0-standalone.html
 *
 * Returns the key under which radio settings are saved for the server the player is currently on.
 *
 * Arma 3 scripting cannot read the IP address or domain name a client connected to, so the key is
 * resolved in this order (first non-empty wins):
 * 1. Client CBA setting "Server profile name" (player types the IP/domain or any label)
 * 2. Server CBA setting "Server ID" (set once by the server owner, e.g. the domain name)
 * 3. serverName (the hostname from server.cfg)
 * 4. "local" (singleplayer / player hosted / editor)
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Server key, lower case [STRING]
 *
 * Example:
 * private _key = call l6AA_acre_fnc_getServerKey;
 *
 * Public: No
 */

private _key = [GVAR(serverKeyOverride)] call CBA_fnc_trim;

if (_key isEqualTo "") then {
    _key = [GVAR(serverId)] call CBA_fnc_trim;
};

if (_key isEqualTo "") then {
    _key = [serverName] call CBA_fnc_trim;
};

if (_key isEqualTo "") then {
    _key = "local";
};

toLower _key
