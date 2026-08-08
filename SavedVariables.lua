

local _, addon = ...;

local Defaults = {

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





addon.SavedVars = SavedVars;