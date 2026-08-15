--[[

    © 2026 Sam Pain. All Rights Reserved.
    
    No part of this work may be reproduced 
    without the prior written permission 
    of the author.

]]

local _, addon = ...;

local ChangeLog = {
    {
        version = "0.2",
        log = {
            "Added OnDragStart to Spellbok items, can now be dragged to action bars.",
            "Added OnDragStart to Equipment sets, can now be dragged to action bars.",
            "Started adding stats for Classic Era - Blizzard has a different system between Vanilla and TBC.",
            "Adjusted the character model inventory slots.",
            "Added options to Character model, can toggle item links, item quality borders and gem sockets.",
        },
    },
    {
        version = "0.1",
        log = {
            "Initial Release",
        },
    },
}

addon.changeLog = ChangeLog;