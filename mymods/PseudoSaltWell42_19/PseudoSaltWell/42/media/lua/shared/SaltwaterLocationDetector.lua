--***********************************************************
--** PseudoSaltWellB42 Part 4: Location-Based Hole Type
--** SaltwaterLocationDetector.lua
--***********************************************************
--** Detects if a location should have a saltwater well
--***********************************************************

SaltwaterLocationDetector = {};

-- Define saltwater well X coordinates (any Y coordinate is valid)
SaltwaterLocationDetector.saltwaterXCoordinates = {
    8163, -- Any Y coordinate with X=8163 is a saltwater well
};

-- Define saltwater well locations (specific X,Y coordinates)
SaltwaterLocationDetector.locations = {
    { x1=8165, y1=12212, x2=8165, y2=12212 }, -- Second saltwater well location
    { x1=8175, y1=12216, x2=8175, y2=12216 }, -- Third saltwater well location
};

--************************************************************************--
--** SaltwaterLocationDetector.isSaltwaterLocation
--** Check if given coordinates are in a saltwater zone
--************************************************************************--
function SaltwaterLocationDetector.isSaltwaterLocation(x, y)
    -- Check if X coordinate matches any saltwater X coordinates
    for _, saltwaterX in ipairs(SaltwaterLocationDetector.saltwaterXCoordinates) do
        if x == saltwaterX then
            return true;
        end
    end

    -- Check specific zones
    for _, zone in ipairs(SaltwaterLocationDetector.locations) do
        if x >= zone.x1 and x <= zone.x2 and y >= zone.y1 and y <= zone.y2 then
            return true;
        end
    end

    return false;
end
