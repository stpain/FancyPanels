--[[

    © 2026 Sam Pain. All Rights Reserved.
    
    No part of this work may be reproduced 
    without the prior written permission 
    of the author.

]]

local _, addon = ...;

local Defaults = {
    characterModelShowItemLinks = false,
    characterModelShowItemQuality = false,
    characterModelShowGemSockets = false,
};


local SavedVars = {};

function SavedVars:Init()

    if FancyPanelsAccount == nil then
        FancyPanelsAccount = {};
    end

    self.db = FancyPanelsAccount;

    for k, v in pairs(Defaults) do
        if self.db[k] == nil then
            self.db[k] = v;
        end
    end

    local name, realm = UnitName("player")
    if not realm then
        realm = GetNormalizedRealmName()
    end
    local characterID = string.format("%s-%s", name, realm);

end

function SavedVars:Get(key)
    if self.db and self.db[key] then
        return self.db[key];
    end
end

function SavedVars:Set(key, val)
    self.db[key] = val;
end



addon.SavedVars = SavedVars;