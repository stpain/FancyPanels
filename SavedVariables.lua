--[[

    © 2026 Sam Pain. All Rights Reserved.
    
    No part of this work may be reproduced 
    without the prior written permission 
    of the author.

]]

local _, addon = ...;

local Defaults = {
    characterModel = {
        showItemLinks = false,
        showItemQuality = false,
        showGemSockets = false,
        showItemEnchantments = false,
        suggestItemUpgrade = false,
        confirmSocketChanges = true,
    },
    specializations = {
        druidSpec1 = "",
        druidSpec2 = "",
    }
};


local SavedVars = {};

function SavedVars:Init(reset)

    if (reset == true) then
        FancyPanelsAccount = nil;
    end

    if FancyPanelsAccount == nil then
        FancyPanelsAccount = {};
    end

    self.db = FancyPanelsAccount;

    for k, v in pairs(Defaults) do
        if self.db[k] == nil then
            self.db[k] = v;
        end

        if type(v) == "table" then
            for k2, v2 in pairs(v) do
                if self.db[k][k2] == nil then
                    self.db[k][k2] = v2;
                end
            end
        end
    end

    if (reset == true) then
        addon.CallbackRegistry:TriggerEvent(addon.Callbacks.SavedVariables_OnChanged)
    end

    local name, realm = UnitName("player")
    if not realm then
        realm = GetNormalizedRealmName()
    end
    local characterID = string.format("%s-%s", name, realm);

    --DevTools_Dump({self.db});

end

function SavedVars:Get(key)
    if string.find(key, ".", nil, true) then
        local k1, k2 = strsplit(".", key);
        if self.db and self.db[k1] and self.db[k1][k2] then
            return self.db[k1][k2];
        end
    else
        if self.db and self.db[key] then
            return self.db[key];
        end
    end
end

function SavedVars:Set(key, val)
    if string.find(key, ".", nil, true) then
        local k1, k2 = strsplit(".", key);
        if (self.db[k1] == nil) then
            self.db[k1] = {};
        end
        self.db[k1][k2] = val;
        --print("db val", self.db[k1][k2])

        --addon.CallbackRegistry:TriggerEvent(addon.Callbacks.SavedVariables_OnChanged, k1, k2, val)
    else
        self.db[key] = val;

        --addon.CallbackRegistry:TriggerEvent(addon.Callbacks.SavedVariables_OnChanged, key, val)
    end
end



addon.SavedVars = SavedVars;