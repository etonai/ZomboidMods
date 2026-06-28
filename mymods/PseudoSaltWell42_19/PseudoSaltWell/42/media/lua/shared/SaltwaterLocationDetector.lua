--***********************************************************
--** PseudoSaltWellB42 Part 4: Location-Based Hole Type
--** SaltwaterLocationDetector.lua
--***********************************************************
--** Detects if a location should have a saltwater well
--***********************************************************

SaltwaterLocationDetector = {};

-- Define saltwater well locations. Exact points use matching x1/x2 and y1/y2;
-- larger saltwater areas use rectangular coordinate ranges.
SaltwaterLocationDetector.locations = {
    { x1=8165, y1=12212, x2=8165, y2=12212 },
    { x1=8175, y1=12216, x2=8175, y2=12216 },
    { x1=10985, y1=10248, x2=10985, y2=10248 }, -- Muldraugh
    { x1=10102, y1=8352, x2=10102, y2=8352 }, -- McCoy Estate
    { x1=10109, y1=8279, x2=10109, y2=8279 }, -- McCoy Estate
    { x1=13901, y1=7387, x2=13924, y2=7399 }, -- Start of Salt River
    { x1=13836, y1=7383, x2=13857, y2=7386 },
    { x1=13659, y1=7320, x2=13659, y2=7320 }, -- Salt River
    { x1=12921, y1=6908, x2=12921, y2=6908 }, -- Bridge 2
    { x1=12922, y1=6855, x2=12922, y2=6855 }, -- Bridge 2
    { x1=12880, y1=6910, x2=12880, y2=6910 }, -- Bridge 2
    { x1=12880, y1=6888, x2=12880, y2=6888 }, -- Bridge 2
    { x1=13177, y1=6858, x2=13177, y2=6858 }, -- Bend
    { x1=13881, y1=6701, x2=13881, y2=6701 }, -- Camp
    { x1=12798, y1=5872, x2=12798, y2=5872 },
    { x1=12788, y1=5786, x2=12788, y2=5786 },
    { x1=12989, y1=5274, x2=12989, y2=5274 },
    { x1=12874, y1=5006, x2=12874, y2=5006 },
    { x1=12303, y1=6711, x2=12303, y2=6711 }, -- Bridge 1
    { x1=12301, y1=6755, x2=12301, y2=6755 }, -- Bridge 1
    { x1=12239, y1=6751, x2=12239, y2=6751 },
    { x1=12474, y1=8955, x2=12474, y2=8955 }, -- Campground
    { x1=12746, y1=8776, x2=12746, y2=8776 }, -- Lakehouse
    { x1=10701, y1=9245, x2=10701, y2=9245 }, -- Muldraugh
    { x1=8490, y1=14447, x2=8490, y2=14447 }, -- Resort
    { x1=8757, y1=14237, x2=8757, y2=14237 }, -- Resort
    { x1=7825, y1=14600, x2=7825, y2=14600 }, -- Resort
    { x1=1983, y1=8609, x2=1983, y2=8609 }, -- Private retreat
    { x1=7378, y1=8335, x2=7378, y2=8335 }, -- Fallas Lake
    { x1=13225, y1=2601, x2=13225, y2=2601 }, -- Louisville central park
    { x1=14189, y1=2669, x2=14189, y2=2669 }, -- Three mansions
};

--************************************************************************--
--** SaltwaterLocationDetector.isSaltwaterLocation
--** Check if given coordinates are in a saltwater zone
--************************************************************************--
function SaltwaterLocationDetector.isSaltwaterLocation(x, y)
    for _, zone in ipairs(SaltwaterLocationDetector.locations) do
        if x >= zone.x1 and x <= zone.x2 and y >= zone.y1 and y <= zone.y2 then
            return true;
        end
    end

    return false;
end
