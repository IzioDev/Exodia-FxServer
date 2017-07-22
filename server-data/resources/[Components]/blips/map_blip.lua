local blipConfig = {
    airport = { caption = "Aéroport", color=3 },
    barber= { caption = "Barbier", color=69, enable = false },
    store = { caption = "Superette", color=2 },
    clothing = { caption = "Magasin de vêtement", color=11 },
    --ammunation = { caption = "Magasin d'arme", color=75 },
    gang = { caption = "Zone dangereuse", color=76, enable = true },
    gasStation = { caption = "Station d'essence ", color=49 },
    stationPolice = { caption = "LSPD", color=38 },
    prison = { caption = "Prison", color=38 },
    hospital = { caption = "Hopital", color=61 },
    lsCustom = { caption = "LS Custom", color=64 },
    simeonVehicleShop = { caption = "Concessionnaire", color=2 },
    stripBar = { caption = "Club de Strip-Tease", color=8 },
    downTownCabCo = { caption = "DownTown Cab Co", color=40},
    fourriere = { caption = "Fourrière"},
    bateau = { caption = "Bateau", color=77},
    camion = { caption = "Camion", color=77},
    medecin = { caption = "Médecin", color=77},
    mairie = { caption = "Mairie", color=69}

}

-- ##### TABLEAUX SANS CONDITIONS ##### --

local principal = {

    -- specific item example
    {parent=blipConfig.airport, id=90, x=-1032.690, y=-2728.141, z=13.757, color=5, caption="Aéroport centrale", enable = true},
    -- end example

    {parent=blipConfig.fourriere, id=68, x= 377.137, y= -1613.56, z= 29.2919},
    {parent=blipConfig.bateau, id=427, x= 107.2117, y= -3085.819, z= 5.9999},
    {parent=blipConfig.camion, id=318, x= -31.124, y= -2653.691, z= 5.0162},
    {parent=blipConfig.medecin, id=153, x= 392.398, y= -1434.503, z= 28.4475},
    {parent=blipConfig.mairie, id=419, x= -427.924, y= 1115.1776, z= 326.772},
    {parent=blipConfig.downTownCabCo, id=198, x=900.461, y=-181.466, z=73.89},
    {parent=blipConfig.stripBar, id=121, x=134.476, y=-1307.887, z=28.983},
    {parent=blipConfig.airport, id=90, x=1743.6820, y=3286.2510, z=40.087},

    {parent=blipConfig.barber, id=71, x=-827.333, y=-190.916, z=37.599},
    {parent=blipConfig.barber, id=71, x=130.512, y=-1715.535, z=29.226},
    {parent=blipConfig.barber, id=71, x=-1291.472, y=-1117.230, z=6.641},
    {parent=blipConfig.barber, id=71, x=1936.451, y=3720.533, z=32.638},
    {parent=blipConfig.barber, id=71, x=1200.214, y=-468.822, z=66.268},
    {parent=blipConfig.barber, id=71, x=-30.109, y=-141.693, z=57.041},
    {parent=blipConfig.barber, id=71, x=-285.238, y=6236.365, z=31.455},

    {parent=blipConfig.store, id=52, x=28.463, y=-1353.033, z=29.340},
    {parent=blipConfig.store, id=52, x=-54.937, y=-1759.108, z=29.005},
    {parent=blipConfig.store, id=52, x=375.858, y=320.097, z=103.433},
    {parent=blipConfig.store, id=52, x=1143.813, y=-980.601, z=46.205},
    {parent=blipConfig.store, id=52, x=1695.284, y=4932.052, z=42.078},
    {parent=blipConfig.store, id=52, x=2686.051, y=3281.089, z=55.241},
    {parent=blipConfig.store, id=52, x=1967.648, y=3735.871, z=32.221},
    {parent=blipConfig.store, id=52, x=-2977.137, y=390.652, z=15.024},
    {parent=blipConfig.store, id=52, x=1160.269, y=-333.137, z=68.783},
    {parent=blipConfig.store, id=52, x=-1492.784, y=-386.306, z=39.798},
    {parent=blipConfig.store, id=52, x=-1229.355, y=-899.230, z=12.263},
    {parent=blipConfig.store, id=52, x=-712.091, y=-923.820, z=19.014},
    {parent=blipConfig.store, id=52, x=-1816.544, y=782.072, z=137.600},
    {parent=blipConfig.store, id=52, x=1729.689, y=6405.970, z=34.453},
    {parent=blipConfig.store, id=52, x=2565.705, y=385.228, z=108.463},

    {parent=blipConfig.clothing, id=73, x=88.291, y=-1391.929, z=29.200},
    {parent=blipConfig.clothing, id=73, x=-718.985, y=-158.059, z=36.996},
    {parent=blipConfig.clothing, id=73, x=-151.204, y=-306.837, z=38.724},
    {parent=blipConfig.clothing, id=73, x=414.646, y=-807.452, z=29.338},
    {parent=blipConfig.clothing, id=73, x=-815.193, y=-1083.333, z=11.022},
    {parent=blipConfig.clothing, id=73, x=-1208.098, y=-782.020, z=17.163},
    {parent=blipConfig.clothing, id=73, x=-1457.954, y=-229.426, z=49.185},
    {parent=blipConfig.clothing, id=73, x=-2.777, y=6518.491, z=31.533},
    {parent=blipConfig.clothing, id=73, x=1681.586, y=4820.133, z=42.046},
    {parent=blipConfig.clothing, id=73, x=130.216, y=-202.940, z=54.505},
    {parent=blipConfig.clothing, id=73, x=618.701, y=2740.564, z=41.905},
    {parent=blipConfig.clothing, id=73, x=1199.169, y=2694.895, z=37.866},
    {parent=blipConfig.clothing, id=73, x=-3164.172, y=1063.927, z=20.674},
    {parent=blipConfig.clothing, id=73, x=-1091.373, y=2702.356, z=19.422}--,

    --[[{parent=blipConfig.ammunation, id=110, x=1701.292, y=3750.450, z=34.365},
    {parent=blipConfig.ammunation, id=110, x=237.428, y=-43.655, z=69.698},
    {parent=blipConfig.ammunation, id=110, x=843.604, y=-1017.784, z=27.546},
    {parent=blipConfig.ammunation, id=110, x=-321.524, y=6072.479, z=31.299},
    {parent=blipConfig.ammunation, id=110, x=-664.218, y=-950.097, z=21.509},
    {parent=blipConfig.ammunation, id=110, x=-1320.983, y=-389.260, z=36.483},
    {parent=blipConfig.ammunation, id=110, x=-1109.053, y=2686.300, z=18.775},
    {parent=blipConfig.ammunation, id=110, x=2568.379, y=309.629, z=108.461},
    {parent=blipConfig.ammunation, id=110, x=-3157.450, y=1079.633, z=20.692}]]
}
--
local gasStation = {
    {parent=blipConfig.gasStation, id=361, x=49.4187,   y=2778.793,  z=58.043},
    {parent=blipConfig.gasStation, id=361, x=263.894,   y=2606.463,  z=44.983},
    {parent=blipConfig.gasStation, id=361, x=1039.958,  y=2671.134,  z=39.550},
    {parent=blipConfig.gasStation, id=361, x=1207.260,  y=2660.175,  z=37.899},
    {parent=blipConfig.gasStation, id=361, x=2539.685,  y=2594.192,  z=37.944},
    {parent=blipConfig.gasStation, id=361, x=2679.858,  y=3263.946,  z=55.240},
    {parent=blipConfig.gasStation, id=361, x=2005.055,  y=3773.887,  z=32.403},
    {parent=blipConfig.gasStation, id=361, x=1687.156,  y=4929.392,  z=42.078},
    {parent=blipConfig.gasStation, id=361, x=1701.314,  y=6416.028,  z=32.763},
    {parent=blipConfig.gasStation, id=361, x=179.857,   y=6602.839,  z=31.868},
    {parent=blipConfig.gasStation, id=361, x=-94.4619,  y=6419.594,  z=31.489},
    {parent=blipConfig.gasStation, id=361, x=-2554.996, y=2334.40,  z=33.078},
    {parent=blipConfig.gasStation, id=361, x=-1800.375, y=803.661,  z=138.651},
    {parent=blipConfig.gasStation, id=361, x=-1437.622, y=-276.747,  z=46.207},
    {parent=blipConfig.gasStation, id=361, x=-2096.243, y=-320.286,  z=13.168},
    {parent=blipConfig.gasStation, id=361, x=-724.619, y=-935.1631,  z=19.213},
    {parent=blipConfig.gasStation, id=361, x=-526.019, y=-1211.003,  z=18.184},
    {parent=blipConfig.gasStation, id=361, x=-70.2148, y=-1761.792,  z=29.534},
    {parent=blipConfig.gasStation, id=361, x=265.648,  y=-1261.309,  z=29.292},
    {parent=blipConfig.gasStation, id=361, x=819.653,  y=-1028.846,  z=26.403},
    {parent=blipConfig.gasStation, id=361, x=1208.951, y= -1402.567, z=35.224},
    {parent=blipConfig.gasStation, id=361, x=1181.381, y= -330.847,  z=69.316},
    {parent=blipConfig.gasStation, id=361, x=620.843,  y= 269.100,  z=103.089},
    {parent=blipConfig.gasStation, id=361, x=2581.321, y=362.039, 108.468}
}
--
local stationPolice = {
    {parent=blipConfig.stationPolice, id=60, x=425.130, y=-979.558, z=30.711},
    {parent=blipConfig.stationPolice, id=60, x=1859.234, y= 3678.742, z=33.690},
    {parent=blipConfig.stationPolice, id=60, x=-438.862, y=6020.768, z=31.490},
    {parent=blipConfig.stationPolice, id=60, x=818.221, y=-1289.883, z=26.300},
    {parent=blipConfig.prison, id=285, x=1679.049, y=2513.711, z=45.565}
}
--
local hospital = {
    {parent=blipConfig.hospital, id=61, x= 1839.6, y= 3672.93, z= 34.28},
    {parent=blipConfig.hospital, id=61, x= -247.76, y= 6331.23, z=32.43},
    {parent=blipConfig.hospital, id=61, x= -449.67, y= -340.83, z= 34.50},
    {parent=blipConfig.hospital, id=61, x= 357.43, y= -593.36, z= 28.79},
    {parent=blipConfig.hospital, id=61, x= 295.83, y= -1446.94, z= 29.97},
    {parent=blipConfig.hospital, id=61, x= -676.98, y= 310.68, z= 83.08},
    {parent=blipConfig.hospital, id=61, x= 1151.21, y= -1529.62, z= 35.37},
    {parent=blipConfig.hospital, id=61, x= -874.64, y= -307.71, z= 39.58}
}
--
local lsCustom = {
    {parent=blipConfig.lsCustom, id=72, x= -362.796, y= -132.400, z= 38.252},
    {parent=blipConfig.lsCustom, id=72, x= -1140.19, y= -1985.478, z= 12.729},
    {parent=blipConfig.lsCustom, id=72, x= 716.464, y= -1088.869, z= 21.929},
    {parent=blipConfig.lsCustom, id=72, x= 1174.81, y= 2649.954, z= 37.371},
    {parent=blipConfig.lsCustom, id=72, x= 118.485, y= 6619.560, z= 31.802}
}
--

--
-- -- ##### TABLEAUX AVEC CONDITIONS ##### --
--



if blipConfig.gang.enable then

    gang = {
        {parent=blipConfig.gang, id=437, x=298.68, y=-2010.10, z=20.07},
        {parent=blipConfig.gang, id=437, x=86.64, y=-1924.60, z=20.79},
        {parent=blipConfig.gang, id=437, x=-183.52, y=-1632.62, z=33.34},
        {parent=blipConfig.gang, id=437, x=989.37, y=-1777.56, z=31.32},
        {parent=blipConfig.gang, id=437, x=960.24, y=-140.31, z=74.50},
        {parent=blipConfig.gang, id=437, x=-1042.29, y=4910.17, z=94.92}
    }

end

if blipConfig.simeonVehicleShop.enable then
    simeonVehicleShop = {
      parent=blipConfig.simeonVehicleShop, id=120, x=-33.803, y=-1102.322, z=25.422
    }

end



Citizen.CreateThread(function()

    function Merge(t1, tableList)
      for _, mytable in ipairs(tableList) do
        for _, item in ipairs(mytable) do
            table.insert(t1, item)
        end
      end

      return t1
    end

   local table = Merge(principal, {gasStation, stationPolice, hospital, lsCustom} )

    if blipConfig.gang.enable then
        table = Merge(principal, {gang})
    end

    if simeonVehicleShopEnable then
        table = Merge(principal, {simeonVehicleShop})
    end

    for _, item in pairs(table) do

        -- permet d'avoir deux blips avec un parent mais pouvant ajuster les couleurs le texte de chacun sans avoir besoin
        -- de recréer une list.
        if item.color == nil then
          item.color = item.parent.color
        end
        if item.caption == nil then
          item.caption = item.parent.caption
        end
        if item.enable == nil then
          item.enable = item.parent.enable
        end


        if item.enable ~= false then
          item.blip = AddBlipForCoord(item.x, item.y, item.z)
          SetBlipSprite(item.blip, item.id)
          SetBlipColour(item.blip, item.color)
          SetBlipAsShortRange(item.blip, true)
          BeginTextCommandSetBlipName("STRING")
          AddTextComponentString(item.caption)
          EndTextCommandSetBlipName(item.blip)
        end

    end

end)
