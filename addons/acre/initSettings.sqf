#pragma sls disable file SQFVM-10005 //disable duplicate MACRO definition warning
#include "script_component.hpp"
/*
 * File: initSettings.sqf
 * Author: Mildly_Interested, 3Mydlo3
 * Date: 2023-08-01
 * Last Update: 2026-11-04
 * License: GNU General Public License v3.0 only - https://www.gnu.org/licenses/gpl-3.0-standalone.html
 *
 * Sets up CBA settings for the ACRE submodule.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * None
 *
 * Public: No
 */

private _category = "ACRE Persistence";

//Amount of radios to restore
[
    QGVAR(amountOfRadiosToRestore),
    "SLIDER",
    [
        "Number of radios to restore",
        "How many radio configurations to restore, applies to respawn and persistence. PTT assigned radios are first in the list."
    ],
    _category,
    [1, 10, 6, 0, false]
] call CBA_fnc_addSetting;
//Restore radios on respawn?
[
    QGVAR(restoreRadiosOnRespawn),
    "CHECKBOX",
    [
        "Restore radio configuration",
        "Restore radios on respawn. Works best if units spawn with the same gear they died with."
    ],
    [_category, "On respawn"],
    true
] call CBA_fnc_addSetting;
//Which Radios to restore on respawn
[
    QGVAR(radioTypesToRestore),
    "EDITBOX",
    [
        "Radio types to restore",
        "In format: 'name1','name2', ...."
    ],
    [_category, "On respawn"],
    ["'ACRE_PRC77', 'ACRE_PRC117F', 'ACRE_PRC148', 'ACRE_PRC152', 'ACRE_PRC343', 'ACRE_SEM52SL', 'ACRE_SEM70', 'ACRE_BF888S'"]

] call CBA_fnc_addSetting;
//Respawn restore timeout
[
    QGVAR(restoreRadiosOnRespawnDelay),
    "SLIDER",
    [
        "Timeout for restoring radios",
        "Skip restoring radios if unit has no radios equipped after x seconds. Useful if you add radios to units after they spawn. Set to -1 to never timeout."
    ],
    [_category, "On respawn"],
    [-1, 15, 5, 0, false]
] call CBA_fnc_addSetting;
//Default speech volume normal bod
[
    QGVAR(defaultSpeechVolume),
    "LIST",
    [
        "Default volume",
        "Speech volume of players after spawning in."
    ],
    [_category, "Volume"],
    [
        [0, 1, 2, 3, 4],
        ["Whisper", "Quiet", "Normal", "Loud", "Shout"],
        2
    ]
] call CBA_fnc_addSetting;
//Default speech volume group leader
[
    QGVAR(defaultSpeechVolumeLeader),
    "LIST",
    [
        "Default volume leader",
        "Speech volume of group leaders after spawning in. Whoever spawns in first in a group is group leader until the 'true' group leader spawns."
    ],
    [_category, "Volume"],
    [
        [0, 1, 2, 3, 4],
        ["Whisper", "Quiet", "Normal", "Loud", "Shout"],
        2
    ]
] call CBA_fnc_addSetting;

//Server profile name (client)
[
    QGVAR(serverKeyOverride),
    "EDITBOX",
    [
        "Server profile name",
        "Radio settings are saved separately per server. Arma 3 scripts cannot read the IP address or domain you connected to, so by default the server's name is used. Enter the IP or domain here to use that instead (it is the name your saved settings are filed under). Leave empty for the default."
    ],
    [_category, "Server profiles"],
    [""]
] call CBA_fnc_addSetting;
//Server ID (set by the server)
[
    QGVAR(serverId),
    "EDITBOX",
    [
        "Server ID (server setting)",
        "For server owners: set this to your domain or IP (in the CBA server settings or in the server's cba_settings.sqf) so every player files their settings under the same name, even if the server is renamed. A 'Server profile name' entered by the player takes priority."
    ],
    [_category, "Server profiles"],
    [""],
    1
] call CBA_fnc_addSetting;
//Auto-apply mode
[
    QGVAR(autoApplyMode),
    "LIST",
    [
        "Automatically apply saved settings",
        "Apply the settings saved for this server to radios you newly get. Radios you already have keep their settings, so changes you made by hand are not overwritten. 'After ACE Arsenal' covers radios from an arsenal loadout. 'Whenever new radios are acquired' also covers spawning, respawning and picking up radios."
    ],
    [_category, "Auto-apply"],
    [
        [0, 1, 2],
        ["Off", "After ACE Arsenal", "Whenever new radios are acquired"],
        0
    ]
] call CBA_fnc_addSetting;
//Auto-apply hint
[
    QGVAR(autoApplyHint),
    "CHECKBOX",
    [
        "Show hint when applied",
        "Show a hint when saved settings were applied automatically."
    ],
    [_category, "Auto-apply"],
    true
] call CBA_fnc_addSetting;
