# Help functions to process the synthetic Belgian grid

function compute_installed_capacities(grid_m)
    types = []
    for (i_id,i) in grid_m["gen"]
        push!(types,i["type"])
    end
    unique_types = unique(types)
    installed_capacities = Dict()
    for i in eachindex(unique_types)
        b = unique_types[i]
        installed_capacities["$b"] = 0
    end
    for i in eachindex(installed_capacities)
        for (l_id,l) in grid_m["gen"]
            if l["type"] == i    
                installed_capacities["$i"] = installed_capacities["$i"] + l["pmax"]
            end
        end
    end
    return installed_capacities
end

function gen_values()
    gen_costs = Dict{String, Any}( # €/MWh
    "DSR"                         => 119,
    "Other non-RES"               => 120,
    "Offshore Wind"               => 59,
    "Onshore Wind"                => 25,
    "Solar PV"                    => 18,
    "Solar Thermal"               => 89,
    "Gas CCGT new"                => 89,
    "Gas CCGT old 1"              => 89,
    "Gas CCGT old 2"              => 89,
    "Gas CCGT present 1"          => 89,
    "Gas CCGT present 2"          => 89,
    "Reservoir"                   => 18,
    "Run-of-River"                => 18,
    "Gas conventional old 1"      => 120,
    "Gas conventional old 2"      => 120,
    "PS Closed"                   => 120,
    "PS Open"                     => 120,
    "Lignite new"                 => 120,
    "Lignite old 1"               => 120,
    "Lignite old 2"               => 120,
    "Hard coal new"               => 120,
    "Hard coal old 1"             => 120,
    "Hard coal old 2"             => 120,
    "Gas CCGT old 2 Bio"          => 120,
    "Gas conventional old 2 Bio"  => 120,
    "Hard coal new Bio"           => 120,
    "Hard coal old 1 Bio"         => 120,
    "Hard coal old 2 Bio"         => 120,
    "Heavy oil old 1 Bio"         => 120,
    "Lignite old 1 Bio"           => 120,
    "Oil shale new Bio"           => 120,
    "Gas OCGT new"                => 89,
    "Gas OCGT old"                => 120,
    "Heavy oil old 1"             => 150,
    "Heavy oil old 2"             => 120,
    "Nuclear"                     => 110,
    "Light oil"                   => 140,
    "Oil shale new"               => 150,
    "P2G"                         => 120,
    "Other non-RES DE00 P"        => 120,
    "Other non-RES DKE1 P"        => 120,
    "Other non-RES DKW1 P"        => 120,
    "Other non-RES FI00 P"        => 120,
    "Other non-RES FR00 P"        => 120,
    "Other non-RES MT00 P"        => 120,
    "Other non-RES UK00 P"        => 120,
    "Other RES"                   => 60,
    "Gas CCGT new CCS"            => 89,
    "Gas CCGT present 1 CCS"      => 60,
    "Gas CCGT present 2 CCS"      => 60,
    "Battery"                     => 119,
    "Lignite old 2 Bio"           => 120,
    "Oil shale old"               => 150,
    "Gas CCGT CCS"                => 89,
    "VOLL"                        => 10000,
    "HVDC"                        => 0
    )


    # other non-RES are assumed to have the same emissions as gas
    emission_factor_CO2 = Dict{String, Any}( #kg/netGJ -> ton/MWh
    "DSR" => 0,
    "Other non-RES"  => 0,
    "Offshore Wind"  => 0,
    "Onshore Wind"  => 0,
    "Solar PV"  => 0,
    "Solar Thermal"  => 0,
    "Gas CCGT new"        => (57*3.6)*10^(-3),
    "Gas CCGT old 1"      => (57*3.6)*10^(-3),
    "Gas CCGT old 2"      => (57*3.6)*10^(-3),
    "Gas CCGT present 1"  => (57*3.6)*10^(-3),
    "Gas CCGT present 2"  => (57*3.6)*10^(-3),
    "Reservoir"  => 0,
    "Run-of-River"  => 0,
    "Gas conventional old 1"  => (57*3.6)*10^(-3),
    "Gas conventional old 2"  => (57*3.6)*10^(-3),
    "PS Closed"  => (57*3.6)*10^(-3),
    "PS Open"  =>   (57*3.6)*10^(-3),
    "Lignite new"  =>   (101*3.6)*10^(-3),
    "Lignite old 1"  => (101*3.6)*10^(-3),
    "Lignite old 2"  => (101*3.6)*10^(-3),
    "Hard coal new"  => (94*3.6)*10^(-3),
    "Hard coal old 1"  => (94*3.6)*10^(-3),
    "Hard coal old 2"  => (94*3.6)*10^(-3),
    "Gas CCGT old 2 Bio"          => (57*3.6)*10^(-3),
    "Gas conventional old 2 Bio"  => (57*3.6)*10^(-3),
    "Hard coal new Bio"  =>   (94*3.6)*10^(-3),
    "Hard coal old 1 Bio"  => (94*3.6)*10^(-3),
    "Hard coal old 2 Bio" =>  (94*3.6)*10^(-3),
    "Heavy oil old 1 Bio"  => (94*3.6)*10^(-3),
    "Lignite old 1 Bio"  => (101*3.6)*10^(-3),
    "Oil shale new Bio"  => (100*3.6)*10^(-3),
    "Gas OCGT new"  => (57*3.6)*10^(-3),
    "Gas OCGT old"  => (57*3.6)*10^(-3),
    "Heavy oil old 1"  => (78*3.6)*10^(-3),
    "Heavy oil old 2"  => (78*3.6)*10^(-3),
    "Nuclear" => 0,
    "Light oil" => (78*3.6)*10^(-3),
    "Oil shale new" => (100*3.6)*10^(-3),
    "P2G" => 0,
    "Other non-RES DE00 P" => (57*3.6)*10^(-3),
    "Other non-RES DKE1 P" => (57*3.6)*10^(-3),
    "Other non-RES DKW1 P" => (57*3.6)*10^(-3),
    "Other non-RES FI00 P" => (57*3.6)*10^(-3),
    "Other non-RES FR00 P" => (57*3.6)*10^(-3),
    "Other non-RES MT00 P" => (57*3.6)*10^(-3),
    "Other non-RES UK00 P" => (57*3.6)*10^(-3),
    "Other RES" => 0,
    "Gas CCGT new CCS"        => (5.7*3.6)*10^(-3),
    "Gas CCGT present 1 CCS"  => (5.7*3.6)*10^(-3),
    "Gas CCGT present 2 CCS"  => (5.7*3.6)*10^(-3),
    "Battery"  => 0,
    "Lignite old 2 Bio"  => (101*3.6)*10^(-3),
    "Oil shale old"  => (100*3.6)*10^(-3),
    "Gas CCGT CCS"  => (5.7*3.6)*10^(-3),
    "VOLL" => 0,
    "HVDC" => 0
    )



    inertia_constants = Dict{String, Any}( # s
    "DSR"                       => 0,
    "Other non-RES"             => 0,
    "Offshore Wind"             => 0,
    "Onshore Wind"              => 0,
    "Solar PV"                  => 0,
    "Solar Thermal"             => 0,
    "Gas CCGT new"              => 5,
    "Gas CCGT old 1"            => 5,
    "Gas CCGT old 2"            => 5,
    "Gas CCGT present 1"        => 5,
    "Gas CCGT present 2"        => 5,
    "Reservoir"                 => 3,
    "Run-of-River"              => 3,
    "Gas conventional old 1"    => 5,
    "Gas conventional old 2"    => 5,
    "PS Closed"                 => 3,
    "PS Open"                   => 3,
    "Lignite new"               => 4,
    "Lignite old 1"             => 4,
    "Lignite old 2"             => 4,
    "Hard coal new"             => 4,
    "Hard coal old 1"           => 4,
    "Hard coal old 2"           => 4,
    "Gas CCGT old 2 Bio"        => 5,
    "Gas conventional old 2 Bio"=> 5,
    "Hard coal new Bio"         => 4,
    "Hard coal old 1 Bio"       => 4,
    "Hard coal old 2 Bio"       => 4,
    "Heavy oil old 1 Bio"       => 4,
    "Lignite old 1 Bio"         => 4,
    "Oil shale new Bio"         => 4,
    "Gas OCGT new"              => 5,
    "Gas OCGT old"              => 5,
    "Heavy oil old 1"           => 4,
    "Heavy oil old 2"           => 4,
    "Nuclear"                   => 6,
    "Light oil"                 => 4,
    "Oil shale new"             => 4,
    "P2G"                       => 0,
    "Other non-RES DE00 P"      => 0,
    "Other non-RES DKE1 P"      => 0,
    "Other non-RES DKW1 P"      => 0,
    "Other non-RES FI00 P"      => 0,
    "Other non-RES FR00 P"      => 0,
    "Other non-RES MT00 P"      => 0,
    "Other non-RES UK00 P"      => 0,
    "Other RES"                 => 0,
    "Gas CCGT new CCS"          => 5,
    "Gas CCGT present 1 CCS"    => 5,
    "Gas CCGT present 2 CCS"    => 5,
    "Battery"                   => 0,
    "Lignite old 2 Bio"         => 4,
    "Oil shale old"             => 4,
    "Gas CCGT CCS"              => 5,
    "VOLL"                      => 0,
    "HVDC"                      => 0
    )

    start_up_cost = Dict{String, Any}( #EUR/MW/start
    "DSR" => 0,
    "Other non-RES"  => 90,
    "Offshore Wind"  => 0,
    "Onshore Wind"  => 0,
    "Solar PV"  => 0,
    "Solar Thermal"  => 0,
    "Gas CCGT new"        => 90,
    "Gas CCGT old 1"      => 90,
    "Gas CCGT old 2"      => 90,
    "Gas CCGT present 1"  => 90,
    "Gas CCGT present 2"  => 90,
    "Reservoir"  => 0,
    "Run-of-River"  => 0,
    "Gas conventional old 1"  => 90,
    "Gas conventional old 2"  => 90,
    "PS Closed"  => 150,
    "PS Open"  =>   150,
    "Lignite new"  =>   175,
    "Lignite old 1"  => 175,
    "Lignite old 2"  => 175,
    "Hard coal new"  => 175,
    "Hard coal old 1"  => 175,
    "Hard coal old 2"  => 175,
    "Gas CCGT old 2 Bio"          => 90,
    "Gas conventional old 2 Bio"  => 90,
    "Hard coal new Bio"  =>   175,
    "Hard coal old 1 Bio"  => 175,
    "Hard coal old 2 Bio" =>  175,
    "Heavy oil old 1 Bio"  => 150,
    "Lignite old 1 Bio"  => 175,
    "Oil shale new Bio"  => 150,
    "Gas OCGT new"  => 90,
    "Gas OCGT old"  => 90,
    "Heavy oil old 1"  => 150,
    "Heavy oil old 2"  => 150,
    "Nuclear" => 1000,
    "Light oil" =>     150,
    "Oil shale new" => 150,
    "P2G" => 0,
    "Other non-RES DE00 P" => 175,
    "Other non-RES DKE1 P" => 175,
    "Other non-RES DKW1 P" => 175,
    "Other non-RES FI00 P" => 175,
    "Other non-RES FR00 P" => 175,
    "Other non-RES MT00 P" => 175,
    "Other non-RES UK00 P" => 175,
    "Other RES" => 0,
    "Gas CCGT new CCS"        => 90,
    "Gas CCGT present 1 CCS"  => 90,
    "Gas CCGT present 2 CCS"  => 90,
    "Battery"  => 0,
    "Lignite old 2 Bio"  => 175,
    "Oil shale old"  => 150,
    "Gas CCGT CCS"  => 90,
    "VOLL" => 0,
    "HVDC" => 0
    )

    emission_factor_NOx = Dict{String, Any}( #g/kWh == kg/MWh
    "DSR"                         => 0,
    "Other non-RES"               => 0.2587,
    "Offshore Wind"               => 0,
    "Onshore Wind"                => 0,
    "Solar PV"                    => 0,
    "Solar Thermal"               => 0,
    "Gas CCGT new"                => 0.2334,
    "Gas CCGT old 1"              => 0.2334,
    "Gas CCGT old 2"              => 0.2334,
    "Gas CCGT present 1"          => 0.2334,
    "Gas CCGT present 2"          => 0.2334,
    "Reservoir"                   => 0,
    "Run-of-River"                => 0,
    "Gas conventional old 1"      => 0.2334,
    "Gas conventional old 2"      => 0.2334,
    "PS Closed"                   => 0.2334,
    "PS Open"                     => 0.2334,
    "Lignite new"                 => 0.2587,
    "Lignite old 1"               => 0.2587,
    "Lignite old 2"               => 0.2587,
    "Hard coal new"               => 0.2587,
    "Hard coal old 1"             => 0.2587,
    "Hard coal old 2"             => 0.2587,
    "Gas CCGT old 2 Bio"          => 0.2334,
    "Gas conventional old 2 Bio"  => 0.2334,
    "Hard coal new Bio"           => 0.2587,
    "Hard coal old 1 Bio"         => 0.2587,
    "Hard coal old 2 Bio"         => 0.2587,
    "Heavy oil old 1 Bio"         => 0.8049,
    "Lignite old 1 Bio"           => 0.2587,
    "Oil shale new Bio"           => 0.8049,
    "Gas OCGT new"                => 0.2334,
    "Gas OCGT old"                => 0.2334,
    "Heavy oil old 1"             => 0.8049,
    "Heavy oil old 2"             => 0.8049,
    "Nuclear"                     => 0,
    "Light oil"                   => 0.8049,
    "Oil shale new"               => 0.8049,
    "P2G"                         => 0,
    "Other non-RES DE00 P"        => 0.2334,
    "Other non-RES DKE1 P"        => 0.2334,
    "Other non-RES DKW1 P"        => 0.2334,
    "Other non-RES FI00 P"        => 0.2334,
    "Other non-RES FR00 P"        => 0.2334,
    "Other non-RES MT00 P"        => 0.2334,
    "Other non-RES UK00 P"        => 0.2334,
    "Other RES"                   => 0.2334,
    "Gas CCGT new CCS"            => 0.2334,
    "Gas CCGT present 1 CCS"      => 0.2334,
    "Gas CCGT present 2 CCS"      => 0.2334,
    "Battery"                     => 0,
    "Lignite old 2 Bio"           => 0.2587,
    "Oil shale old"               => 0.8049,
    "Gas CCGT CCS"                => 0.2334,
    "VOLL"                        => 0,
    "HVDC"                        => 0
    )

    emission_factor_SOx = Dict{String, Any}( #g/kWh == kg/MWh
    "DSR"                         => 0,
    "Other non-RES"               => 0.3322,
    "Offshore Wind"               => 0,
    "Onshore Wind"                => 0,
    "Solar PV"                    => 0,
    "Solar Thermal"               => 0,
    "Gas CCGT new"                => 0.0046,
    "Gas CCGT old 1"              => 0.0046,
    "Gas CCGT old 2"              => 0.0046,
    "Gas CCGT present 1"          => 0.0046,
    "Gas CCGT present 2"          => 0.0046,
    "Reservoir"                   => 0,
    "Run-of-River"                => 0,
    "Gas conventional old 1"      => 0.0046,
    "Gas conventional old 2"      => 0.0046,
    "PS Closed"                   => 0.0046,
    "PS Open"                     => 0.0046,
    "Lignite new"                 => 0.3322,
    "Lignite old 1"               => 0.3322,
    "Lignite old 2"               => 0.3322,
    "Hard coal new"               => 0.3322,
    "Hard coal old 1"             => 0.3322,
    "Hard coal old 2"             => 0.3322,
    "Gas CCGT old 2 Bio"          => 0.0046,
    "Gas conventional old 2 Bio"  => 0.0046,
    "Hard coal new Bio"           => 0.3322,
    "Hard coal old 1 Bio"         => 0.3322,
    "Hard coal old 2 Bio"         => 0.3322,
    "Heavy oil old 1 Bio"         => 1.1573,
    "Lignite old 1 Bio"           => 0.3322,
    "Oil shale new Bio"           => 1.1573,
    "Gas OCGT new"                => 0.0046,
    "Gas OCGT old"                => 0.0046,
    "Heavy oil old 1"             => 1.1573,
    "Heavy oil old 2"             => 1.1573,
    "Nuclear"                     => 0,
    "Light oil"                   => 1.1573,
    "Oil shale new"               => 1.1573,
    "P2G"                         => 0,
    "Other non-RES DE00 P"        => 0.0046,
    "Other non-RES DKE1 P"        => 0.0046,
    "Other non-RES DKW1 P"        => 0.0046,
    "Other non-RES FI00 P"        => 0.0046,
    "Other non-RES FR00 P"        => 0.0046,
    "Other non-RES MT00 P"        => 0.0046,
    "Other non-RES UK00 P"        => 0.0046,
    "Other RES"                   => 0.0046,
    "Gas CCGT new CCS"            => 0.0046,
    "Gas CCGT present 1 CCS"      => 0.0046,
    "Gas CCGT present 2 CCS"      => 0.0046,
    "Battery"                     => 0,
    "Lignite old 2 Bio"           => 0.3322,
    "Oil shale old"               => 1.1573,
    "Gas CCGT CCS"                => 0.0046,
    "VOLL"                        => 0,
    "HVDC"                        => 0
    )

    return gen_costs,inertia_constants,emission_factor_CO2,start_up_cost,emission_factor_NOx,emission_factor_SOx
end

function assigning_gen_values(grid_m,gen_costs,inertia_constants,emission_factor_CO2,start_up_cost,emission_factor_NOx,emission_factor_SOx)
    for (g_id,g) in grid_m["gen"]
        for i in eachindex(gen_costs)
            if g["type"] == i
                g["cost"] = []
                push!(g["cost"],gen_costs[i])
                push!(g["cost"],0.0)
                g["ncost"] = 2
                g["C02_emission"] = emission_factor_CO2[i]
                g["NOx_emission"] = emission_factor_NOx[i]
                g["SOx_emission"] = emission_factor_SOx[i]
                g["start_up_cost"] = start_up_cost[i]
                g["inertia_constant"] = inertia_constants[i]
                g["installed_capacity"] = deepcopy(g["pmax"])
            end
        end
        if !haskey(g,"zone")
            g["zone"] = "BE00"
        end
    end
    for (l_id,l) in grid_m["load"]
        if !haskey(l,"zone")
            l["zone"] = "BE00"
        end
    end
    return grid_m
end

function create_load_series(scenario::String,year::Int64,CY::Int64,zone::String,hour_start,number_of_hours,datapath::String=dataDir)
    load_file = joinpath(datapath,"tyndpdata","scenarios",scenario,"$(year)","Demand_"*scenario*"$(year)_$(CY)"*".csv")
    df = _CSV.read(load_file,DataFrame)
    load_series = df[!,zone][hour_start:(hour_start+number_of_hours-1)]
    return load_series
end

function fix_hourly_loads_DK_DE(grid,hour,load_DE,load_DK) 
    for (l_id,l) in grid["load"]
        if l["zone"] == "DKW1" 
            l["pd"] = deepcopy(load_DK[hour]/100) #pu
            l["qd"] = deepcopy(l["pd"]/10) #pu
        elseif l["zone"] == "DE00"
            l["pd"] = deepcopy(load_DE[hour]/100)
            l["qd"] = deepcopy(l["pd"]/10)
        end
    end   
end

function fix_hourly_load(grid,hour,load,zone) 
    for (l_id,l) in grid["load"]
        if l["zone"] == zone 
            l["pd"] = deepcopy(load[hour]/100) #pu
            l["qd"] = deepcopy(l["pd"]/10) #pu
        end
    end   
end

function fix_hourly_loads_and_gen_interconnections(grid,hour,load_BE,load_UK) 
    for (l_id,l) in grid["load"]
        if l["zone"] == "UK00" 
            l["pd"] = deepcopy(load_UK[hour]/100) #pu
            l["qd"] = deepcopy(l["pd"]/10) #pu
        elseif l["zone"] == "BE00"
            l["pd"] = deepcopy(load_BE[hour]/100)
            l["qd"] = deepcopy(l["pd"]/10)
        end
    end   
end

function fix_hourly_loads_and_gen_interconnections_UK_FR(grid,hour,load_BE,load_UK,load_FR) 
    for (l_id,l) in grid["load"]
        if l["zone"] == "FR00" 
            l["pd"] = deepcopy(load_FR[hour]/100) #pu
            l["qd"] = deepcopy(l["pd"]/10) #pu
        elseif l["zone"] == "UK00"
            l["pd"] = deepcopy(load_UK[hour]/100) #pu
            l["qd"] = deepcopy(l["pd"]/10) #pu
        elseif l["zone"] == "BE00"
            l["pd"] = deepcopy(load_BE[hour]/100)
            l["qd"] = deepcopy(l["pd"]/10)
        end
    end   
end

function fix_hourly_loads_and_gen_interconnections_UK_DK(grid,hour,load_BE,load_UK,load_DK) 
    for (l_id,l) in grid["load"]
        if l["zone"] == "UK00" 
            l["pd"] = deepcopy(load_UK[hour]/100) #pu
            l["qd"] = 0#deepcopy(l["pd"]/10) #pu
        elseif l["zone"] == "DKW1"
            l["pd"] = deepcopy(load_DK[hour]/100) #pu
            l["qd"] = deepcopy(l["pd"]/10) #pu
        elseif l["zone"] == "BE00"
            l["pd"] = deepcopy(load_BE[hour]/100)
            l["qd"] = deepcopy(l["pd"]/10)
        end
    end   
end

function fix_RES_time_series(grid,hour,wind_onshore_series,wind_offshore_series,solar_pv_series)
    for (g_id,g) in grid["gen"]
        if g["type"] == "Onshore Wind" 
            g["pmax"] = g["installed_capacity"]*wind_onshore_series[hour] #pu
        elseif g["type"] == "Offshore Wind" 
            g["pmax"] = g["installed_capacity"]*wind_offshore_series[hour] #pu
        elseif g["type"] == "Onshore Wind" 
            g["pmax"] = g["installed_capacity"]*solar_pv_series[hour] #pu
        end
    end
end

function fix_RES_time_series_zone(grid,hour,wind_onshore_series,wind_offshore_series,solar_pv_series,zone)
    for (g_id,g) in grid["gen"]
        if g["zone"] == zone
            if g["type"] == "Onshore Wind" 
                g["pmax"] = g["pmax"]*wind_onshore_series[hour] #pu
            elseif g["type"] == "Offshore Wind" 
                g["pmax"] = g["pmax"]*wind_offshore_series[hour] #pu
            elseif g["type"] == "Solar PV" 
                g["pmax"] = g["pmax"]*solar_pv_series[hour] #pu
            end
        end
    end
end

function fix_RES_time_series_BE_UK(grid,hour,wind_onshore_series_BE,wind_offshore_series_BE,solar_pv_series_BE,wind_onshore_series_UK,wind_offshore_series_UK,solar_pv_series_UK)
    for (g_id,g) in grid["gen"]
        if g["zone"] == "BE00"
            if g["type"] == "Onshore Wind" 
                g["pmax"] = deepcopy(g["installed_capacity"]*wind_onshore_series_BE[hour]) #pu
            elseif g["type"] == "Offshore Wind" 
                g["pmax"] = deepcopy(g["installed_capacity"]*wind_offshore_series_BE[hour]) #pu
            elseif g["type"] == "Solar PV" 
                g["pmax"] = deepcopy(g["installed_capacity"]*solar_pv_series_BE[hour]) #pu
            end
        elseif g["zone"] == "UK00"
            if g["type"] == "Onshore Wind" 
                g["pmax"] = deepcopy(g["installed_capacity"]*wind_onshore_series_UK[hour]) #pu
            elseif g["type"] == "Offshore Wind" 
                g["pmax"] = deepcopy(g["installed_capacity"]*wind_offshore_series_UK[hour]) #pu
            elseif g["type"] == "Solar PV" 
                g["pmax"] = deepcopy(g["installed_capacity"]*solar_pv_series_UK[hour]) #pu
            end
        end
    end
end

function fix_RES_time_series_BE_UK_DK(grid,hour,wind_onshore_series_BE,wind_offshore_series_BE,solar_pv_series_BE,wind_onshore_series_UK,wind_offshore_series_UK,solar_pv_series_UK,wind_onshore_series_DK,wind_offshore_series_DK,solar_pv_series_DK)
    for (g_id,g) in grid["gen"]
        if g["zone"] == "BE00"
            if g["type"] == "Onshore Wind" 
                g["pmax"] = g["installed_capacity"]*wind_onshore_series_BE[hour] #pu
            elseif g["type"] == "Offshore Wind" 
                g["pmax"] = g["installed_capacity"]*wind_offshore_series_BE[hour] #pu
            elseif g["type"] == "Solar PV" 
                g["pmax"] = g["installed_capacity"]*solar_pv_series_BE[hour] #pu
            end
        elseif g["zone"] == "UK00"
            if g["type"] == "Onshore Wind" 
                g["pmax"] = g["installed_capacity"]*wind_onshore_series_UK[hour] #pu
            elseif g["type"] == "Offshore Wind" 
                g["pmax"] = g["installed_capacity"]*wind_offshore_series_UK[hour] #pu
            elseif g["type"] == "Solar PV" 
                g["pmax"] = g["installed_capacity"]*solar_pv_series_UK[hour] #pu
            end
        elseif g["zone"] == "DKW1"
            if g["type"] == "Onshore Wind" 
                g["pmax"] = g["installed_capacity"]*wind_onshore_series_DK[hour] #pu
            elseif g["type"] == "Offshore Wind" 
                g["pmax"] = g["installed_capacity"]*wind_offshore_series_DK[hour] #pu
            elseif g["type"] == "Solar PV" 
                g["pmax"] = g["installed_capacity"]*solar_pv_series_DK[hour] #pu
            end
        end
    end
end

function fix_RES_time_series_BE_UK_FR(grid,hour,wind_onshore_series_BE,wind_offshore_series_BE,solar_pv_series_BE,wind_onshore_series_UK,wind_offshore_series_UK,solar_pv_series_UK,wind_onshore_series_FR,wind_offshore_series_FR,solar_pv_series_FR)
    for (g_id,g) in grid["gen"]
        if g["zone"] == "BE00"
            if g["type"] == "Onshore Wind" 
                g["pmax"] = g["installed_capacity"]*wind_onshore_series_BE[hour] #pu
            elseif g["type"] == "Offshore Wind" 
                g["pmax"] = g["installed_capacity"]*wind_offshore_series_BE[hour] #pu
            elseif g["type"] == "Solar PV" 
                g["pmax"] = g["installed_capacity"]*solar_pv_series_BE[hour] #pu
            end
        elseif g["zone"] == "UK00"
            if g["type"] == "Onshore Wind" 
                g["pmax"] = g["installed_capacity"]*wind_onshore_series_UK[hour] #pu
            elseif g["type"] == "Offshore Wind" 
                g["pmax"] = g["installed_capacity"]*wind_offshore_series_UK[hour] #pu
            elseif g["type"] == "Solar PV" 
                g["pmax"] = g["installed_capacity"]*solar_pv_series_UK[hour] #pu
            end
        elseif g["zone"] == "FR00"
            if g["type"] == "Onshore Wind" 
                g["pmax"] = g["installed_capacity"]*wind_onshore_series_FR[hour] #pu
            elseif g["type"] == "Offshore Wind" 
                g["pmax"] = g["installed_capacity"]*wind_offshore_series_FR[hour] #pu
            elseif g["type"] == "Solar PV" 
                g["pmax"] = g["installed_capacity"]*solar_pv_series_FR[hour] #pu
            end
        end
    end
end

function hourly_opf_BE(grid,number_of_hours,load_series_BE,load_series_UK,wind_onshore, wind_offshore, solar_pv,s,optimizer,formulation)
    results = Dict()
    grid_hour = Dict()
    hourly_grid = deepcopy(grid)
    for hour in 1:number_of_hours
        fix_hourly_loads_and_gen_interconnections(hourly_grid,hour,load_series_BE,load_series_UK)
        fix_RES_time_series(hourly_grid,hour,wind_onshore, wind_offshore, solar_pv)
        hourly_results = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        results["$hour"] = deepcopy(hourly_results)
        grid_hour["$hour"] = deepcopy(hourly_grid)
    end
    return results#, grid_hour
end

function hourly_opf_BE_UK(grid,number_of_hours,load_series_BE,load_series_UK,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,s,optimizer,formulation)
    results = Dict()
    grid_hour = Dict()
    hourly_grid = deepcopy(grid)
    for hour in 1:number_of_hours
        fix_hourly_loads_and_gen_interconnections(hourly_grid,hour,load_series_BE,load_series_UK)
        fix_RES_time_series_BE_UK(hourly_grid,hour,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK)
        hourly_results = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        results["$hour"] = deepcopy(hourly_results)
        grid_hour["$hour"] = deepcopy(hourly_grid)
    end
    return results#, grid_hour
end

function hourly_opf_BE_UK_FR(grid,number_of_hours,load_series_BE,load_series_UK,load_series_FR,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK, wind_onshore_FR, wind_offshore_FR, solar_pv_FR, s, optimizer,formulation)
    results = Dict()
    grid_hour = Dict()
    hourly_grid = deepcopy(grid)
    for hour in 1:number_of_hours
        fix_hourly_loads_and_gen_interconnections_UK_FR(hourly_grid,hour,load_series_BE,load_series_UK,load_series_FR)
        fix_RES_time_series_BE_UK_FR(hourly_grid,hour,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK, wind_onshore_FR, wind_offshore_FR, solar_pv_FR)
        hourly_results = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        results["$hour"] = deepcopy(hourly_results)
        grid_hour["$hour"] = deepcopy(hourly_grid)
    end
    return results#, grid_hour
end


function hourly_opf_BE_UK_DK(grid,number_of_hours,load_series_BE,load_series_UK,load_series_DK,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_DK, wind_offshore_DK, solar_pv_DK,s,optimizer,formulation)
    results = Dict()
    grid_hour = Dict()
    hourly_grid = deepcopy(grid)
    for hour in 1:number_of_hours
        fix_hourly_loads_and_gen_interconnections_UK_DK(hourly_grid,hour,load_series_BE,load_series_UK,load_series_DK)
        fix_RES_time_series_BE_UK_DK(hourly_grid,hour,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_DK, wind_offshore_DK, solar_pv_DK)
        hourly_results = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        results["$hour"] = deepcopy(hourly_results)
        grid_hour["$hour"] = deepcopy(hourly_grid)
    end
    return results#, grid_hour
end

function hourly_opf_BE_UK_DK_pole_to_ground(grid,number_of_hours,load_series_BE,load_series_UK,load_series_DK,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_DK, wind_offshore_DK, solar_pv_DK,s,optimizer,formulation)
    results = Dict()
    grid_hour = Dict()
    hourly_grid = deepcopy(grid)
    for hour in 1:number_of_hours
        fix_hourly_loads_and_gen_interconnections_UK_DK(hourly_grid,hour,load_series_BE,load_series_UK,load_series_DK)
        fix_RES_time_series_BE_UK_DK(hourly_grid,hour,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_DK, wind_offshore_DK, solar_pv_DK)
        hourly_results = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        if length(hourly_results["solution"]) > 5
            if (hourly_results["solution"]["convdc"]["7"]["pconv"] + hourly_results["solution"]["convdc"]["9"]["pconv"]) < - 20.0 || (hourly_results["solution"]["convdc"]["7"]["pconv"] + hourly_results["solution"]["convdc"]["9"]["pconv"]) > 20.0
                hourly_grid["branchdc"]["7"]["status"] = 0
                hourly_results = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
                results["$hour"] = deepcopy(hourly_results)
                grid_hour["$hour"] = deepcopy(hourly_grid)
            else
                results["$hour"] = deepcopy(hourly_results)
                grid_hour["$hour"] = deepcopy(hourly_grid)
            end
        end
    end
    return results#, grid_hour
end

function hourly_opf_BE_UK_DK_pole_to_pole(grid,number_of_hours,load_series_BE,load_series_UK,load_series_DK,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_DK, wind_offshore_DK, solar_pv_DK,s,optimizer,formulation)
    results = Dict()
    grid_hour = Dict()
    hourly_grid = deepcopy(grid)
    for hour in 1:number_of_hours
        fix_hourly_loads_and_gen_interconnections_UK_DK(hourly_grid,hour,load_series_BE,load_series_UK,load_series_DK)
        fix_RES_time_series_BE_UK_DK(hourly_grid,hour,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_DK, wind_offshore_DK, solar_pv_DK)
        hourly_results = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        if length(hourly_results["solution"]) > 5
            if (hourly_results["solution"]["convdc"]["7"]["pconv"] + hourly_results["solution"]["convdc"]["9"]["pconv"] + hourly_results["solution"]["convdc"]["12"]["pconv"]) > 30.0 || (hourly_results["solution"]["convdc"]["7"]["pconv"] + hourly_results["solution"]["convdc"]["9"]["pconv"] + hourly_results["solution"]["convdc"]["12"]["pconv"]) < - 30.0
                hourly_grid["branchdc"]["7"]["status"] = 0
                hourly_results = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
                results["$hour"] = deepcopy(hourly_results)
                grid_hour["$hour"] = deepcopy(hourly_grid)
            else
                results["$hour"] = deepcopy(hourly_results)
                grid_hour["$hour"] = deepcopy(hourly_grid)
            end
        end
    end
    return results#, grid_hour
end

function hourly_opf_case_1(grid,number_of_hours,load_series_DE,load_series_DK, wind_offshore_SE, solar_pv_DE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_DK, wind_offshore_DK, solar_pv_DK,s,optimizer,formulation)
    results = Dict()
    grid_hour = Dict()
    hourly_grid = deepcopy(grid)
    for hour in 1:number_of_hours
        fix_hourly_loads_and_gen_interconnections_UK_DK(hourly_grid,hour,load_series_BE,load_series_UK,load_series_DK)
        fix_RES_time_series_BE_UK_DK(hourly_grid,hour,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_DK, wind_offshore_DK, solar_pv_DK)
        hourly_results = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        results["$hour"] = deepcopy(hourly_results)
        grid_hour["$hour"] = deepcopy(hourly_grid)
    end
    return results#, grid_hour
end

function hourly_opf_BE_UK_DK_AC_DC_switch(grid,number_of_hours,load_series_BE,load_series_UK,load_series_DK,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_DK, wind_offshore_DK, solar_pv_DK,s,optimizer,formulation)
    results = Dict()
    grid_hour = Dict()
    hourly_grid = deepcopy(grid)
    for hour in 1:number_of_hours
        fix_hourly_loads_and_gen_interconnections_UK_DK(hourly_grid,hour,load_series_BE,load_series_UK,load_series_DK)
        fix_RES_time_series_BE_UK_DK(hourly_grid,hour,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_DK, wind_offshore_DK, solar_pv_DK)
        hourly_results = run_acdc_AC_DC_switch_ref(hourly_grid,formulation, optimizer; setting = s)
        results["$hour"] = deepcopy(hourly_results)
        grid_hour["$hour"] = deepcopy(hourly_grid)
    end
    return results#, grid_hour
end

function hourly_opf_BE_switch(grid,number_of_hours,load_series_BE,wind_onshore, wind_offshore, solar_pv,s,optimizer,formulation)
    results = Dict()
    grid_hour = Dict()
    hourly_grid = deepcopy(grid)
    for hour in 1:number_of_hours
        fix_hourly_loads_and_gen_interconnections(hourly_grid,hour,load_series_BE)
        fix_RES_time_series(hourly_grid,hour,wind_onshore, wind_offshore, solar_pv)
        hourly_results = run_acdc_AC_switch(hourly_grid,formulation, optimizer; setting = s)
        results["$hour"] = deepcopy(hourly_results)
        grid_hour["$hour"] = deepcopy(hourly_grid)
    end
    return results#, grid_hour
end

function hourly_opf_switch(grid,number_of_hours,load_series_BE,load_series_UK,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,s,optimizer,formulation)
    results = Dict()
    grid_hour = Dict()
    hourly_grid = deepcopy(grid)
    for hour in 1:number_of_hours
        fix_hourly_loads_and_gen_interconnections(hourly_grid,hour,load_series_BE,load_series_UK)
        fix_RES_time_series(hourly_grid,hour,wind_onshore, wind_offshore, solar_pv)
        hourly_results = run_acdc_AC_switch(hourly_grid,formulation, optimizer; setting = s)
        results["$hour"] = deepcopy(hourly_results)
        grid_hour["$hour"] = deepcopy(hourly_grid)
    end
    return results#, grid_hour
end

function hourly_opf_BE_UK_switch(grid,number_of_hours,load_series_BE,load_series_UK,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,s,optimizer,formulation)
    results = Dict()
    grid_hour = Dict()
    hourly_grid = deepcopy(grid)
    for hour in 1:number_of_hours
        fix_hourly_loads_and_gen_interconnections(hourly_grid,hour,load_series_BE,load_series_UK)
        fix_RES_time_series_BE_UK(hourly_grid,hour,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK)
        hourly_results = run_acdc_AC_switch(hourly_grid,formulation, optimizer; setting = s)
        results["$hour"] = deepcopy(hourly_results)
        grid_hour["$hour"] = deepcopy(hourly_grid)
    end
    return results#, grid_hour
end

function hourly_opf_BE_UK_DK_switch(grid,number_of_hours,load_series_BE,load_series_UK,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,s,optimizer,formulation)
    results = Dict()
    grid_hour = Dict()
    hourly_grid = deepcopy(grid)
    for hour in 1:number_of_hours
        fix_hourly_loads_and_gen_interconnections_UK_DK(hourly_grid,hour,load_series_BE,load_series_UK,load_series_DK)
        fix_RES_time_series_BE_UK_DK(hourly_grid,hour,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_DK, wind_offshore_DK, solar_pv_DK)
        hourly_results = run_acdc_AC_switch_ref(hourly_grid,formulation, optimizer; setting = s)
        results["$hour"] = deepcopy(hourly_results)
        grid_hour["$hour"] = deepcopy(hourly_grid)
    end
    return results#, grid_hour
end


function hourly_opf_BE_UK_FR_switch(grid,number_of_hours,load_series_BE,load_series_UK,load_series_FR,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_FR, wind_offshore_FR, solar_pv_FR,s,optimizer,formulation)
    results = Dict()
    grid_hour = Dict()
    hourly_grid = deepcopy(grid)
    for hour in 1:number_of_hours
        fix_hourly_loads_and_gen_interconnections_UK_FR(hourly_grid,hour,load_series_BE,load_series_UK,load_series_FR)
        fix_RES_time_series_BE_UK_FR(hourly_grid,hour,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_FR, wind_offshore_FR, solar_pv_FR)
        hourly_results = _PMTP.run_acdcsw_AC_reformulation(hourly_grid,formulation, optimizer; setting = s)
        results["$hour"] = deepcopy(hourly_results)
        grid_hour["$hour"] = deepcopy(hourly_grid)
    end
    return results#, grid_hour
end

function hourly_opf_BE_UK_FR_switch_diocane(grid,number_of_hours,load_series_BE,load_series_UK,load_series_FR,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_FR, wind_offshore_FR, solar_pv_FR,s,optimizer,formulation)
    results = Dict()
    grid_hour = Dict()
    hourly_grid = deepcopy(grid)
    for hour in 1:number_of_hours
        fix_hourly_loads_and_gen_interconnections_UK_FR(hourly_grid,hour,load_series_BE,load_series_UK,load_series_FR)
        fix_RES_time_series_BE_UK_FR(hourly_grid,hour,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_FR, wind_offshore_FR, solar_pv_FR)
        hourly_results = _PMTP.run_acdcsw_AC_reformulation(hourly_grid,formulation, optimizer; setting = s)
        results["$hour"] = deepcopy(hourly_results)
        grid_hour["$hour"] = deepcopy(hourly_grid)
    end
    return results#, grid_hour
end

function hourly_feasibility_check(grid,hours,load_series_BE,load_series_UK,load_series_FR,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_FR, wind_offshore_FR, solar_pv_FR,s,optimizer,formulation)
    results = Dict()
    grid_hour = Dict()
    hourly_grid = deepcopy(grid)
    for hour in hours
        fix_hourly_loads_and_gen_interconnections_UK_FR(hourly_grid,hour,load_series_BE,load_series_UK,load_series_FR)
        fix_RES_time_series_BE_UK_FR(hourly_grid,hour,wind_onshore_BE, wind_offshore_BE, solar_pv_BE,wind_onshore_UK, wind_offshore_UK, solar_pv_UK,wind_onshore_FR, wind_offshore_FR, solar_pv_FR)
        hourly_results = _PMTP.run_acdcsw_AC_reformulation(hourly_grid,formulation, optimizer; setting = s)
        results["$hour"] = deepcopy(hourly_results)
        grid_hour["$hour"] = deepcopy(hourly_grid)
    end
    return results#, grid_hour
end

function add_energy_island_synthetic_network(grid)
    # 132 buses before the energy island
    # Add Energy island #1 AC bus
    grid["bus"]["133"] = deepcopy(grid["bus"]["26"])
    grid["bus"]["133"]["bus_i"] = 133
    grid["bus"]["133"]["bus_type"] = 2
    grid["bus"]["133"]["source_id"][2] = 133
    grid["bus"]["133"]["index"] = 133
    grid["bus"]["133"]["lat"] = 51.646504
    grid["bus"]["133"]["lon"] = 2.678687 
    grid["bus"]["133"]["full_name"] = "EI_AC_1"
    grid["bus"]["133"]["full_name_kV"] = "EI_AC_1_220"
    grid["bus"]["133"]["name"] = "EI_AC_1_220"
    grid["bus"]["133"]["name_no_kV"] = "EI_AC_1"
    grid["bus"]["133"]["zone"] = "BE01"

    #=
    # Add Energy island #2 AC bus
    grid["bus"]["133"] = deepcopy(grid["bus"]["2"])
    grid["bus"]["133"]["bus_i"] = 128
    grid["bus"]["133"]["source_id"][2] = 128
    grid["bus"]["133"]["index"] = 128
    grid["bus"]["133"]["lat"] = 51.2965
    grid["bus"]["133"]["lon"] = 1.3192
    grid["bus"]["133"]["full_name"] = "EI_AC_1"
    grid["bus"]["133"]["full_name_kV"] = "EI_AC_1_220"
    grid["bus"]["133"]["name"] = "EI_AC_1_220"
    grid["bus"]["133"]["name_no_kV"] = "EI_AC_1"
    grid["bus"]["133"]["zone"] = "BE01"
    =#

    # Add Energy island #3 AC bus
    grid["bus"]["134"] = deepcopy(grid["bus"]["26"])
    grid["bus"]["134"]["bus_i"] = 134
    grid["bus"]["134"]["bus_type"] = 2
    grid["bus"]["134"]["source_id"][2] = 134
    grid["bus"]["134"]["index"] = 134
    grid["bus"]["134"]["lat"] = 51.646504
    grid["bus"]["134"]["lon"] = 2.678687 
    grid["bus"]["134"]["full_name"] = "EI_AC_2"
    grid["bus"]["134"]["full_name_kV"] = "EI_AC_2_220"
    grid["bus"]["134"]["name"] = "EI_AC_2_220"
    grid["bus"]["134"]["name_no_kV"] = "EI_AC_2"
    grid["bus"]["134"]["zone"] = "BE01"

    #=
    # Add Energy island #4 AC bus
    grid["bus"]["133"] = deepcopy(grid["bus"]["2"])
    grid["bus"]["133"]["bus_i"] = 128
    grid["bus"]["133"]["source_id"][2] = 128
    grid["bus"]["133"]["index"] = 128
    grid["bus"]["133"]["lat"] = 51.2965
    grid["bus"]["133"]["lon"] = 1.3192
    grid["bus"]["133"]["full_name"] = "EI_AC_1"
    grid["bus"]["133"]["full_name_kV"] = "EI_AC_1_220"
    grid["bus"]["133"]["name"] = "EI_AC_1_220"
    grid["bus"]["133"]["name_no_kV"] = "EI_AC_1"
    grid["bus"]["133"]["zone"] = "BE01"
    =#

    
    # Assigning gens energy island
    # Assigning loads energy island
    grid["gen"]["101"] = deepcopy(grid["gen"]["29"])
    grid["gen"]["101"]["source_id"][2] = 101
    grid["gen"]["101"]["index"] = 101
    grid["gen"]["101"]["pmax"] = 21.0
    grid["gen"]["101"]["qmax"] = 3.0
    grid["gen"]["101"]["qmin"] = - 3.0
    #grid["gen"]["502"]["pd"] = 1.05
    grid["gen"]["101"]["installed_capacity"] = 21.0
    grid["gen"]["101"]["mbase"] = 100.0
    grid["gen"]["101"]["substation_short_name"] = "EI_AC_1"
    grid["gen"]["101"]["substation_short_name_kV"] = "EI_AC_1_220"
    grid["gen"]["101"]["substation_full_name"] = "EI_AC_1"
    grid["gen"]["101"]["substation_full_name_kV"] = "EI_AC_1_220"
    grid["gen"]["101"]["substation"] = "EI_AC_1_220"
    grid["gen"]["101"]["name"] = "OFW_EI_AC"
    grid["gen"]["101"]["gen_bus"] = 133
    grid["gen"]["101"]["zone"] = "BE00"

    grid["gen"]["102"] = deepcopy(grid["gen"]["29"])
    grid["gen"]["102"]["source_id"][2] = 102
    grid["gen"]["102"]["index"] = 102
    grid["gen"]["102"]["pmax"] = 14.0
    grid["gen"]["102"]["qmax"] = 3.0
    grid["gen"]["102"]["qmin"] = - 3.0
    #grid["gen"]["503"]["pd"] = 1.05
    grid["gen"]["102"]["installed_capacity"] = 14.0
    grid["gen"]["102"]["mbase"] = 100.0
    grid["gen"]["102"]["substation_short_name"] = "EI_AC_2"
    grid["gen"]["102"]["substation_short_name_kV"] = "EI_AC_2_220"
    grid["gen"]["102"]["substation_full_name"] = "EI_AC_2"
    grid["gen"]["102"]["substation_full_name_kV"] = "EI_AC_2_220"
    grid["gen"]["102"]["substation"] = "EI_AC_2_220"
    grid["gen"]["102"]["name"] = "OFW_EI_HVDC"
    grid["gen"]["102"]["gen_bus"] = 134
    grid["gen"]["102"]["zone"] = "BE00"

    # Adding branches to the energy island
    n_branches = 100
    for i in 1:7
        grid["branch"]["$(n_branches+i)"] = deepcopy(grid["branch"]["1"])
        grid["branch"]["$(n_branches+i)"]["source_id"][2] = deepcopy(n_branches+i)
        grid["branch"]["$(n_branches+i)"]["interconnection"] = true
        grid["branch"]["$(n_branches+i)"]["index"] = deepcopy(n_branches+i)
        grid["branch"]["$(n_branches+i)"]["rate_a"] = 4.0
        delete!(grid["branch"]["$(n_branches+i)"],"f_bus_name_kV")
        delete!(grid["branch"]["$(n_branches+i)"],"t_bus_name_kV")
        delete!(grid["branch"]["$(n_branches+i)"],"f_bus_full_name_kV")
        delete!(grid["branch"]["$(n_branches+i)"],"t_bus_full_name_kV")
        delete!(grid["branch"]["$(n_branches+i)"],"f_bus_full_name")
        delete!(grid["branch"]["$(n_branches+i)"],"t_bus_full_name")
        delete!(grid["branch"]["$(n_branches+i)"],"f_bus_name")
        delete!(grid["branch"]["$(n_branches+i)"],"t_bus_name")
    end
    # Add values from ELIA here
    # AC connections to BE
    for i in 1:6
        grid["branch"]["$(n_branches+i)"]["f_bus"] = 133 # EI_AC_1_220
        grid["branch"]["$(n_branches+i)"]["t_bus"] = 26 # GEZELLE_380 
        grid["branch"]["$(n_branches+i)"]["f_bus_full_name_kV"] = "EI_AC_1_220"
        grid["branch"]["$(n_branches+i)"]["f_bus_name_kV"] = "EI_AC_1_220"
        grid["branch"]["$(n_branches+i)"]["f_bus_full_name"] = "EI_AC_1"
        grid["branch"]["$(n_branches+i)"]["f_bus_name"] = "EI_AC_1"
        grid["branch"]["$(n_branches+i)"]["t_bus_full_name_kV"] = "GEZELLE_380"
        grid["branch"]["$(n_branches+i)"]["t_bus_name_kV"] = "GEZEL_380"
        grid["branch"]["$(n_branches+i)"]["t_bus_full_name"] = "GEZELLE"
        grid["branch"]["$(n_branches+i)"]["t_bus_name"] = "GEZEL"
    end
    # AC connections withing the energy island -> this is the switch
    for i in 7:7
        grid["branch"]["$(n_branches+i)"]["rate_a"] = 99.99
        grid["branch"]["$(n_branches+i)"]["ZIL"] = true
        grid["branch"]["$(n_branches+i)"]["f_bus"] = 133 # EI_AC_1_220
        grid["branch"]["$(n_branches+i)"]["t_bus"] = 134 # EI_AC_2_220 
        grid["branch"]["$(n_branches+i)"]["f_bus_full_name_kV"] = "EI_AC_1_220"
        grid["branch"]["$(n_branches+i)"]["f_bus_name_kV"] = "EI_AC_1_220"
        grid["branch"]["$(n_branches+i)"]["f_bus_full_name"] = "EI_AC_1"
        grid["branch"]["$(n_branches+i)"]["f_bus_name"] = "EI_AC_1"
        grid["branch"]["$(n_branches+i)"]["t_bus_full_name_kV"] = "EI_AC_2_220"
        grid["branch"]["$(n_branches+i)"]["t_bus_name_kV"] = "EI_AC_2_220"
        grid["branch"]["$(n_branches+i)"]["t_bus_full_name"] = "EI_AC_2"
        grid["branch"]["$(n_branches+i)"]["t_bus_name"] = "EI_AC_2"
    end

    ############## DC part ##################
    # 4 DC buses before the energy island (ALEGRO not in the synthetic grid)
    # Add Energy island #1 DC bus
    grid["busdc"]["5"] = deepcopy(grid["busdc"]["1"])
    grid["busdc"]["5"]["busdc_i"] = 5
    grid["busdc"]["5"]["source_id"][2] = 5
    grid["busdc"]["5"]["index"] = 5
    grid["busdc"]["5"]["lat"] = 51.6468 
    grid["busdc"]["5"]["lon"] = 2.778687 
    grid["busdc"]["5"]["full_name"] = "EI_DC_1"
    grid["busdc"]["5"]["full_name_kV"] = "EI_DC_1_525"
    grid["busdc"]["5"]["name"] = "EI_DC_1_525"
    grid["busdc"]["5"]["bus_name"] = "EI_DC_1_525"
    grid["busdc"]["5"]["name_no_kV"] = "EI_DC_1"
    grid["busdc"]["5"]["zone"] = "BE01"
    grid["busdc"]["5"]["basekVdc"] = 525

    # Add Energy island #2 DC bus (DC switchyard)
    grid["busdc"]["6"] = deepcopy(grid["busdc"]["1"])
    grid["busdc"]["6"]["busdc_i"] = 6
    grid["busdc"]["6"]["source_id"][2] = 6
    grid["busdc"]["6"]["index"] = 6
    grid["busdc"]["6"]["lat"] = 51.780669
    grid["busdc"]["6"]["lon"] = 3.006469
    grid["busdc"]["6"]["full_name"] = "EI_DC_switchyard"
    grid["busdc"]["6"]["bus_name"] = "EI_DC_switchyard"
    grid["busdc"]["6"]["full_name_kV"] = "EI_DC_switchyard_525"
    grid["busdc"]["6"]["name"] = "EI_DC_switchyard_525"
    grid["busdc"]["6"]["name_no_kV"] = "EI_DC_switchyard"
    grid["busdc"]["6"]["zone"] = "BE01"
    grid["busdc"]["6"]["basekVdc"] = 525

    # Add UK onshore DC bus 
    grid["busdc"]["7"] = deepcopy(grid["busdc"]["1"])
    grid["busdc"]["7"]["busdc_i"] = 7
    grid["busdc"]["7"]["source_id"][2] = 7
    grid["busdc"]["7"]["index"] = 7
    grid["busdc"]["7"]["lat"] = 51.888354
    grid["busdc"]["7"]["lon"] = 1.209372
    grid["busdc"]["7"]["full_name"] = "UK_EI_DC_2"
    grid["busdc"]["7"]["full_name_kV"] = "UK_EI_DC_2_525"
    grid["busdc"]["7"]["name"] = "UK_EI_DC_2_525"
    grid["busdc"]["7"]["name_no_kV"] = "UK_EI_DC_2"
    grid["busdc"]["7"]["zone"] = "BE01"
    grid["busdc"]["7"]["basekVdc"] = 525

    # Add Gezelle DC bus
    grid["busdc"]["8"] = deepcopy(grid["busdc"]["1"])
    grid["busdc"]["8"]["busdc_i"] = 8
    grid["busdc"]["8"]["source_id"][2] = 8
    grid["busdc"]["8"]["index"] = 8
    grid["busdc"]["8"]["lat"] = 51.2747
    grid["busdc"]["8"]["lon"] = 3.22923
    grid["busdc"]["8"]["full_name"] = "GEZELLE_EI_DC_1"
    grid["busdc"]["8"]["bus_name"] = "GEZELLE_EI_DC_1"
    grid["busdc"]["8"]["full_name_kV"] = "GEZELLE_EI_DC_1_525"
    grid["busdc"]["8"]["name"] = "GEZEL_EI_DC_1_525"
    grid["busdc"]["8"]["name_no_kV"] = "GEZEL_EI_DC_1"
    grid["busdc"]["8"]["zone"] = "BE01"
    grid["busdc"]["8"]["basekVdc"] = 525

    # Adding 3 converters for the energy island
    n_conv_dc = 4
    for i in 1:3
        grid["convdc"]["$(n_conv_dc+i)"] = deepcopy(grid["convdc"]["1"])
        grid["convdc"]["$(n_conv_dc+i)"]["Imax"] = 25
        grid["convdc"]["$(n_conv_dc+i)"]["source_id"][2] = deepcopy(n_conv_dc+i)
        grid["convdc"]["$(n_conv_dc+i)"]["index"] = deepcopy(n_conv_dc+i)
    end

    grid["convdc"]["5"]["busdc_i"] = 5
    grid["convdc"]["5"]["busac_i"] = 134
    grid["convdc"]["5"]["Pacmax"] = 20.0
    grid["convdc"]["5"]["Pacmin"] = - 20.0
    grid["convdc"]["5"]["Pacrated"] = 20.0

    # For later
    grid["convdc"]["6"]["busdc_i"] = 7
    grid["convdc"]["6"]["busac_i"] = 128
    grid["convdc"]["6"]["Pacmax"] = 14.0
    grid["convdc"]["6"]["Pacmin"] = - 14.0
    grid["convdc"]["6"]["Pacrated"] = 14.0

    grid["convdc"]["7"]["busdc_i"] = 8
    grid["convdc"]["7"]["busac_i"] = 26
    grid["convdc"]["7"]["Pacmax"] = 20.0
    grid["convdc"]["7"]["Pacmin"] = - 20.0
    grid["convdc"]["7"]["Pacrated"] = 20.0

    # Adding the DC branches
    n_branch_dc = 2
    for i in 1:3
        grid["branchdc"]["$(n_branch_dc+i)"] = deepcopy(grid["branchdc"]["1"])
        grid["branchdc"]["$(n_branch_dc+i)"]["source_id"][2] = deepcopy(n_branch_dc+i)
        grid["branchdc"]["$(n_branch_dc+i)"]["index"] = deepcopy(n_branch_dc+i)
    end
    grid["branchdc"]["3"]["r"] = 0.1
    grid["branchdc"]["3"]["rateA"] = 20.0
    grid["branchdc"]["3"]["rateB"] = 20.0
    grid["branchdc"]["3"]["rateC"] = 20.0
    grid["branchdc"]["3"]["fbusdc"] = 5
    grid["branchdc"]["3"]["tbusdc"] = 6
    grid["branchdc"]["3"]["HVDC_link"] = "EI -> DC Switchyard" 

    grid["branchdc"]["4"]["r"] = 0.1
    grid["branchdc"]["4"]["rateA"] = 14.0
    grid["branchdc"]["4"]["rateB"] = 14.0
    grid["branchdc"]["4"]["rateC"] = 14.0
    grid["branchdc"]["4"]["fbusdc"] = 6
    grid["branchdc"]["4"]["tbusdc"] = 7
    grid["branchdc"]["4"]["HVDC_link"] = "DC Switchyard -> UK" 

    grid["branchdc"]["5"]["r"] = 0.1
    grid["branchdc"]["5"]["rateA"] = 20.0
    grid["branchdc"]["5"]["rateB"] = 20.0
    grid["branchdc"]["5"]["rateC"] = 20.0
    grid["branchdc"]["5"]["fbusdc"] = 6
    grid["branchdc"]["5"]["tbusdc"] = 8
    grid["branchdc"]["5"]["HVDC_link"] = "DC Switchyard -> Gezelle" 
end

function add_VOLL_generators(grid)
    buses = []
    for l in eachindex(grid["bus"])
        push!(buses,l)
    end
    
    for i in 1001:(1001+length(buses)-1)
        grid["gen"]["$i"] = deepcopy(grid["gen"]["1"])
        grid["gen"]["$i"]["gen_bus"] = parse(Int64,buses[i-1000])
        grid["gen"]["$i"]["index"] = i
        grid["gen"]["$i"]["qmax"] = 99.99
        grid["gen"]["$i"]["cost"][1] = 200.0
        grid["gen"]["$i"]["pmax"] = 99.99
        grid["gen"]["$i"]["gen_type"] = "VOLL"
        grid["gen"]["$i"]["fuel_type"] = "VOLL"
        grid["gen"]["$i"]["type"] = "VOLL"
        grid["gen"]["$i"]["source_id"][2] = i-1000
    end
end

function add_energy_island_uk(grid)
    grid["bus"]["128"]["zone"] = "UK00"

    # Add UK generator
    grid["gen"]["108"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["108"]["source_id"][2] = 108
    grid["gen"]["108"]["index"] = 108
    grid["gen"]["108"]["pmax"] = 700.0
    grid["gen"]["108"]["qmax"] = 218.0
    grid["gen"]["108"]["qmin"] = - 218.0
    grid["gen"]["108"]["installed_capacity"] = 700.0
    grid["gen"]["108"]["mbase"] = 100.0
    grid["gen"]["108"]["substation_short_name"] = "UK00"
    grid["gen"]["108"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["108"]["substation_full_name"] = "UK00"
    grid["gen"]["108"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["108"]["substation"] = "UK00_380"
    grid["gen"]["108"]["name"] = "UK_capacity"
    grid["gen"]["108"]["gen_bus"] = 128
    grid["gen"]["108"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["108"]["zone"] = "UK00"

    grid["gen"]["109"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["109"]["source_id"][2] = 109
    grid["gen"]["109"]["index"] = 109
    grid["gen"]["109"]["pmax"] = 59.0
    grid["gen"]["109"]["qmax"] = 29.5
    grid["gen"]["109"]["qmin"] = - 29.5
    grid["gen"]["109"]["installed_capacity"] = 59.0
    grid["gen"]["109"]["mbase"] = 100.0
    grid["gen"]["109"]["substation_short_name"] = "UK00"
    grid["gen"]["109"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["109"]["substation_full_name"] = "UK00"
    grid["gen"]["109"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["109"]["substation"] = "UK00_380"
    grid["gen"]["109"]["name"] = "UK_capacity"
    grid["gen"]["109"]["gen_bus"] = 128
    grid["gen"]["109"]["type"] = "Nuclear"
    grid["gen"]["109"]["zone"] = "UK00"

    grid["gen"]["110"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["110"]["source_id"][2] = 110
    grid["gen"]["110"]["index"] = 110
    grid["gen"]["110"]["pmax"] = 44.0
    grid["gen"]["110"]["qmax"] = 22.0
    grid["gen"]["110"]["qmin"] = - 22.0
    grid["gen"]["110"]["installed_capacity"] = 44.0
    grid["gen"]["110"]["mbase"] = 100.0
    grid["gen"]["110"]["substation_short_name"] = "UK00"
    grid["gen"]["110"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["110"]["substation_full_name"] = "UK00"
    grid["gen"]["110"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["110"]["substation"] = "UK00_380"
    grid["gen"]["110"]["name"] = "UK_capacity"
    grid["gen"]["110"]["gen_bus"] = 128
    grid["gen"]["110"]["zone"] = "UK00"
    grid["gen"]["110"]["type"] = "Offshore Wind"

    grid["gen"]["111"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["111"]["source_id"][2] = 111
    grid["gen"]["111"]["index"] = 111
    grid["gen"]["111"]["pmax"] = 80.0
    grid["gen"]["111"]["qmax"] = 40.0
    grid["gen"]["111"]["qmin"] = - 40.0
    grid["gen"]["111"]["installed_capacity"] = 80.0
    grid["gen"]["111"]["mbase"] = 100.0
    grid["gen"]["111"]["substation_short_name"] = "UK00"
    grid["gen"]["111"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["111"]["substation_full_name"] = "UK00"
    grid["gen"]["111"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["111"]["substation"] = "UK00_380"
    grid["gen"]["111"]["name"] = "UK_capacity"
    grid["gen"]["111"]["gen_bus"] = 128
    grid["gen"]["111"]["zone"] = "UK00"
    grid["gen"]["111"]["type"] = "Onshore Wind"


    grid["gen"]["112"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["112"]["source_id"][2] = 112
    grid["gen"]["112"]["index"] = 112
    grid["gen"]["112"]["pmax"] = 25.0
    grid["gen"]["112"]["qmax"] = 12.5
    grid["gen"]["112"]["qmin"] = - 12.5
    grid["gen"]["112"]["installed_capacity"] = 25.0
    grid["gen"]["112"]["mbase"] = 100.0
    grid["gen"]["112"]["substation_short_name"] = "UK00"
    grid["gen"]["112"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["112"]["substation_full_name"] = "UK00"
    grid["gen"]["112"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["112"]["substation"] = "UK00_380"
    grid["gen"]["112"]["name"] = "UK_capacity"
    grid["gen"]["112"]["gen_bus"] = 128
    grid["gen"]["112"]["zone"] = "UK00"
    grid["gen"]["112"]["type"] = "Solar PV"


    # Add UK load
    grid["load"]["2"] = deepcopy(grid["load"]["1"])
    grid["load"]["2"]["source_id"][2] = 2
    grid["load"]["2"]["index"] = 2
    grid["load"]["2"]["load_bus"] = 128
    grid["load"]["2"]["pmax"] = 450.0
    grid["load"]["2"]["qmax"] = 220.0
    grid["load"]["2"]["qmin"] = - 220.0
    grid["load"]["2"]["installed_capacity"] = 4500.0
    grid["load"]["2"]["mbase"] = 100.0
    grid["load"]["2"]["zone"] = "UK00"
    grid["load"]["2"]["full_name"] = "UK_aggregated"
    grid["load"]["2"]["full_name_kV"] = "UK_aggregated_380"
    grid["load"]["2"]["name"] = "UK_aggregated_380"
    grid["load"]["2"]["name_no_kV"] = "UK_aggregated"
end 

function add_energy_island_uk_2035(grid)
    grid["bus"]["128"]["zone"] = "UK00"

    # Add UK generator
    grid["gen"]["108"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["108"]["source_id"][2] = 108
    grid["gen"]["108"]["index"] = 108
    grid["gen"]["108"]["pmax"] = 700.0
    grid["gen"]["108"]["qmax"] = 218.0
    grid["gen"]["108"]["qmin"] = - 218.0
    grid["gen"]["108"]["installed_capacity"] = 700.0
    grid["gen"]["108"]["mbase"] = 100.0
    grid["gen"]["108"]["substation_short_name"] = "UK00"
    grid["gen"]["108"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["108"]["substation_full_name"] = "UK00"
    grid["gen"]["108"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["108"]["substation"] = "UK00_380"
    grid["gen"]["108"]["name"] = "UK_capacity"
    grid["gen"]["108"]["gen_bus"] = 128
    grid["gen"]["108"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["108"]["zone"] = "UK00"

    grid["gen"]["109"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["109"]["source_id"][2] = 109
    grid["gen"]["109"]["index"] = 109
    grid["gen"]["109"]["pmax"] = 59.0
    grid["gen"]["109"]["qmax"] = 29.5
    grid["gen"]["109"]["qmin"] = - 29.5
    grid["gen"]["109"]["installed_capacity"] = 59.0
    grid["gen"]["109"]["mbase"] = 100.0
    grid["gen"]["109"]["substation_short_name"] = "UK00"
    grid["gen"]["109"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["109"]["substation_full_name"] = "UK00"
    grid["gen"]["109"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["109"]["substation"] = "UK00_380"
    grid["gen"]["109"]["name"] = "UK_capacity"
    grid["gen"]["109"]["gen_bus"] = 128
    grid["gen"]["109"]["type"] = "Nuclear"
    grid["gen"]["109"]["zone"] = "UK00"

    grid["gen"]["110"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["110"]["source_id"][2] = 110
    grid["gen"]["110"]["index"] = 110
    grid["gen"]["110"]["pmax"] = 600.0
    grid["gen"]["110"]["qmax"] = 22.0
    grid["gen"]["110"]["qmin"] = - 22.0
    grid["gen"]["110"]["installed_capacity"] = 600.0
    grid["gen"]["110"]["mbase"] = 100.0
    grid["gen"]["110"]["substation_short_name"] = "UK00"
    grid["gen"]["110"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["110"]["substation_full_name"] = "UK00"
    grid["gen"]["110"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["110"]["substation"] = "UK00_380"
    grid["gen"]["110"]["name"] = "UK_capacity"
    grid["gen"]["110"]["gen_bus"] = 128
    grid["gen"]["110"]["zone"] = "UK00"
    grid["gen"]["110"]["type"] = "Offshore Wind"

    grid["gen"]["111"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["111"]["source_id"][2] = 111
    grid["gen"]["111"]["index"] = 111
    grid["gen"]["111"]["pmax"] = 300.0
    grid["gen"]["111"]["qmax"] = 40.0
    grid["gen"]["111"]["qmin"] = - 40.0
    grid["gen"]["111"]["installed_capacity"] = 300.0
    grid["gen"]["111"]["mbase"] = 100.0
    grid["gen"]["111"]["substation_short_name"] = "UK00"
    grid["gen"]["111"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["111"]["substation_full_name"] = "UK00"
    grid["gen"]["111"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["111"]["substation"] = "UK00_380"
    grid["gen"]["111"]["name"] = "UK_capacity"
    grid["gen"]["111"]["gen_bus"] = 128
    grid["gen"]["111"]["zone"] = "UK00"
    grid["gen"]["111"]["type"] = "Onshore Wind"

    grid["gen"]["112"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["112"]["source_id"][2] = 112
    grid["gen"]["112"]["index"] = 112
    grid["gen"]["112"]["pmax"] = 500.0
    grid["gen"]["112"]["qmax"] = 12.5
    grid["gen"]["112"]["qmin"] = - 12.5
    grid["gen"]["112"]["installed_capacity"] = 500.0
    grid["gen"]["112"]["mbase"] = 100.0
    grid["gen"]["112"]["substation_short_name"] = "UK00"
    grid["gen"]["112"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["112"]["substation_full_name"] = "UK00"
    grid["gen"]["112"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["112"]["substation"] = "UK00_380"
    grid["gen"]["112"]["name"] = "UK_capacity"
    grid["gen"]["112"]["gen_bus"] = 128
    grid["gen"]["112"]["zone"] = "UK00"
    grid["gen"]["112"]["type"] = "Solar PV"


    # Add UK load
    grid["load"]["2"] = deepcopy(grid["load"]["1"])
    grid["load"]["2"]["source_id"][2] = 2
    grid["load"]["2"]["index"] = 2
    grid["load"]["2"]["load_bus"] = 128
    grid["load"]["2"]["pmax"] = 450.0
    grid["load"]["2"]["qmax"] = 220.0
    grid["load"]["2"]["qmin"] = - 220.0
    grid["load"]["2"]["installed_capacity"] = 4500.0
    grid["load"]["2"]["mbase"] = 100.0
    grid["load"]["2"]["zone"] = "UK00"
    grid["load"]["2"]["full_name"] = "UK_aggregated"
    grid["load"]["2"]["full_name_kV"] = "UK_aggregated_380"
    grid["load"]["2"]["name"] = "UK_aggregated_380"
    grid["load"]["2"]["name_no_kV"] = "UK_aggregated"
end 

function add_France_2030(grid)
    # Source: https://transparency.entsoe.eu/generation/r2/installedGenerationCapacityAggregation/show?name=&defaultValue=true&viewType=TABLE&areaType=BZN&atch=false&dateTime.dateTime=01.01.2024+00:00|UTC|YEAR&dateTime.endDateTime=01.01.2024+00:00|UTC|YEAR&area.values=CTY|10YFR-RTE------C!BZN|10YFR-RTE------C&productionType.values=B01&productionType.values=B25&productionType.values=B02&productionType.values=B03&productionType.values=B04&productionType.values=B05&productionType.values=B06&productionType.values=B07&productionType.values=B08&productionType.values=B09&productionType.values=B10&productionType.values=B11&productionType.values=B12&productionType.values=B13&productionType.values=B14&productionType.values=B20&productionType.values=B15&productionType.values=B16&productionType.values=B17&productionType.values=B18&productionType.values=B19 
    # Source: https://energy.ec.europa.eu/system/files/2022-08/fr_final_necp_main_en.pdf
    # Source: https://www.enerdata.net/publications/daily-energy-news/france-targets-41-renewables-its-final-energy-mix-2030.html#:~:text=Specifically%2C%20France%20aims%20for%20a,should%20be%20committed%20by%202026.(National Energy and Climate Plan (NECP))
    grid["bus"]["2"]["zone"] = "FR00"

    # Add FR generators
    grid["gen"]["208"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["208"]["source_id"][2] = 208
    grid["gen"]["208"]["index"] = 208
    grid["gen"]["208"]["pmax"] = 131.33
    grid["gen"]["208"]["qmax"] = 56.0
    grid["gen"]["208"]["qmin"] = - 56.0
    grid["gen"]["208"]["installed_capacity"] = 131.33
    grid["gen"]["208"]["mbase"] = 100.0
    grid["gen"]["208"]["substation_short_name"] = "FR00"
    grid["gen"]["208"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["208"]["substation_full_name"] = "FR00"
    grid["gen"]["208"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["208"]["substation"] = "FR00_380"
    grid["gen"]["208"]["name"] = "FR_capacity"
    grid["gen"]["208"]["gen_bus"] = 2
    grid["gen"]["208"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["208"]["zone"] = "FR00"

    grid["gen"]["209"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["209"]["source_id"][2] = 209
    grid["gen"]["209"]["index"] = 209
    grid["gen"]["209"]["pmax"] = 713.70
    grid["gen"]["209"]["qmax"] = 355.0
    grid["gen"]["209"]["qmin"] = - 355.0
    grid["gen"]["209"]["installed_capacity"] = 713.70
    grid["gen"]["209"]["mbase"] = 100.0
    grid["gen"]["209"]["substation_short_name"] = "FR00"
    grid["gen"]["209"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["209"]["substation_full_name"] = "FR00"
    grid["gen"]["209"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["209"]["substation"] = "FR00_380"
    grid["gen"]["209"]["name"] = "FR_capacity"
    grid["gen"]["209"]["gen_bus"] = 2
    grid["gen"]["209"]["type"] = "Nuclear"
    grid["gen"]["209"]["zone"] = "FR00"
    grid["gen"]["209"]["cost"][1] = 110
    grid["gen"]["209"]["C02_emission"] = 0

    grid["gen"]["210"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["210"]["source_id"][2] = 210
    grid["gen"]["210"]["index"] = 210
    grid["gen"]["210"]["pmax"] = 62.0
    grid["gen"]["210"]["qmax"] = 31.0
    grid["gen"]["210"]["qmin"] = - 31.0
    grid["gen"]["210"]["installed_capacity"] = 62.0
    grid["gen"]["210"]["mbase"] = 100.0
    grid["gen"]["210"]["substation_short_name"] = "FR00"
    grid["gen"]["210"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["210"]["substation_full_name"] = "FR00"
    grid["gen"]["210"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["210"]["substation"] = "FR00_380"
    grid["gen"]["210"]["name"] = "FR_capacity"
    grid["gen"]["210"]["gen_bus"] = 2
    grid["gen"]["210"]["zone"] = "FR00"
    grid["gen"]["210"]["type"] = "Offshore Wind"
    grid["gen"]["210"]["cost"][1] = 59
    grid["gen"]["210"]["C02_emission"] = 0

    grid["gen"]["211"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["211"]["source_id"][2] = 211
    grid["gen"]["211"]["index"] = 211
    grid["gen"]["211"]["pmax"] = 347.0
    grid["gen"]["211"]["qmax"] = 173.5
    grid["gen"]["211"]["qmin"] = - 173.5
    grid["gen"]["211"]["installed_capacity"] = 347.0
    grid["gen"]["211"]["mbase"] = 100.0
    grid["gen"]["211"]["substation_short_name"] = "FR00"
    grid["gen"]["211"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["211"]["substation_full_name"] = "FR00"
    grid["gen"]["211"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["211"]["substation"] = "FR00_380"
    grid["gen"]["211"]["name"] = "FR_capacity"
    grid["gen"]["211"]["gen_bus"] = 2
    grid["gen"]["211"]["zone"] = "FR00"
    grid["gen"]["211"]["type"] = "Onshore Wind"
    grid["gen"]["211"]["cost"][1] = 25
    grid["gen"]["211"]["C02_emission"] = 0

    grid["gen"]["212"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["212"]["source_id"][2] = 212
    grid["gen"]["212"]["index"] = 212
    grid["gen"]["212"]["pmax"] = 540.0
    grid["gen"]["212"]["qmax"] = 270.0
    grid["gen"]["212"]["qmin"] = - 270.0
    grid["gen"]["212"]["installed_capacity"] = 540.0
    grid["gen"]["212"]["mbase"] = 100.0
    grid["gen"]["212"]["substation_short_name"] = "FR00"
    grid["gen"]["212"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["212"]["substation_full_name"] = "FR00"
    grid["gen"]["212"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["212"]["substation"] = "FR00_380"
    grid["gen"]["212"]["name"] = "FR_capacity"
    grid["gen"]["212"]["gen_bus"] = 2
    grid["gen"]["212"]["zone"] = "FR00"
    grid["gen"]["212"]["type"] = "Solar PV"
    grid["gen"]["212"]["cost"][1] = 18
    grid["gen"]["212"]["C02_emission"] = 0

    # Add FR load
    grid["load"]["3"] = deepcopy(grid["load"]["1"])
    grid["load"]["3"]["source_id"][2] = 3
    grid["load"]["3"]["index"] = 3
    grid["load"]["3"]["load_bus"] = 2 
    grid["load"]["3"]["pmax"] = 450.0
    grid["load"]["3"]["qmax"] = 220.0
    grid["load"]["3"]["qmin"] = - 220.0
    grid["load"]["3"]["installed_capacity"] = 450.0
    grid["load"]["3"]["mbase"] = 100.0
    grid["load"]["3"]["zone"] = "FR00"
    grid["load"]["3"]["full_name"] = "FR_aggregated"
    grid["load"]["3"]["full_name_kV"] = "FR_aggregated_380"
    grid["load"]["3"]["name"] = "FR_aggregated_380"
    grid["load"]["3"]["name_no_kV"] = "FR_aggregated"
end 

function add_France_2040_high(grid)
    # Source: https://transparency.entsoe.eu/generation/r2/installedGenerationCapacityAggregation/show?name=&defaultValue=true&viewType=TABLE&areaType=BZN&atch=false&dateTime.dateTime=01.01.2024+00:00|UTC|YEAR&dateTime.endDateTime=01.01.2024+00:00|UTC|YEAR&area.values=CTY|10YFR-RTE------C!BZN|10YFR-RTE------C&productionType.values=B01&productionType.values=B25&productionType.values=B02&productionType.values=B03&productionType.values=B04&productionType.values=B05&productionType.values=B06&productionType.values=B07&productionType.values=B08&productionType.values=B09&productionType.values=B10&productionType.values=B11&productionType.values=B12&productionType.values=B13&productionType.values=B14&productionType.values=B20&productionType.values=B15&productionType.values=B16&productionType.values=B17&productionType.values=B18&productionType.values=B19 
    # Source: https://energy.ec.europa.eu/system/files/2022-08/fr_final_necp_main_en.pdf
    # Source: https://www.enerdata.net/publications/daily-energy-news/france-targets-41-renewables-its-final-energy-mix-2030.html#:~:text=Specifically%2C%20France%20aims%20for%20a,should%20be%20committed%20by%202026.(National Energy and Climate Plan (NECP))
    grid["bus"]["2"]["zone"] = "FR00"

    # Add FR generators
    grid["gen"]["308"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["308"]["source_id"][2] = 308
    grid["gen"]["308"]["index"] = 308
    grid["gen"]["308"]["pmax"] = 131.33
    grid["gen"]["308"]["qmax"] = 56.0
    grid["gen"]["308"]["qmin"] = - 56.0
    grid["gen"]["308"]["installed_capacity"] = 131.33
    grid["gen"]["308"]["mbase"] = 100.0
    grid["gen"]["308"]["substation_short_name"] = "FR00"
    grid["gen"]["308"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["308"]["substation_full_name"] = "FR00"
    grid["gen"]["308"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["308"]["substation"] = "FR00_380"
    grid["gen"]["308"]["name"] = "FR_capacity"
    grid["gen"]["308"]["gen_bus"] = 2
    grid["gen"]["308"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["308"]["zone"] = "FR00"

    grid["gen"]["309"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["309"]["source_id"][2] = 309
    grid["gen"]["309"]["index"] = 309
    grid["gen"]["309"]["pmax"] = 713.70
    grid["gen"]["309"]["qmax"] = 355.0
    grid["gen"]["309"]["qmin"] = - 355.0
    grid["gen"]["309"]["installed_capacity"] = 713.70
    grid["gen"]["309"]["mbase"] = 100.0
    grid["gen"]["309"]["substation_short_name"] = "FR00"
    grid["gen"]["309"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["309"]["substation_full_name"] = "FR00"
    grid["gen"]["309"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["309"]["substation"] = "FR00_380"
    grid["gen"]["309"]["name"] = "FR_capacity"
    grid["gen"]["309"]["gen_bus"] = 2
    grid["gen"]["309"]["type"] = "Nuclear"
    grid["gen"]["309"]["zone"] = "FR00"
    grid["gen"]["309"]["cost"][1] = 110
    grid["gen"]["309"]["C02_emission"] = 0

    grid["gen"]["310"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["310"]["source_id"][2] = 310
    grid["gen"]["310"]["index"] = 310
    grid["gen"]["310"]["pmax"] = 266.62
    grid["gen"]["310"]["qmax"] = 31.0
    grid["gen"]["310"]["qmin"] = - 31.0
    grid["gen"]["310"]["installed_capacity"] = 62.0
    grid["gen"]["310"]["mbase"] = 100.0
    grid["gen"]["310"]["substation_short_name"] = "FR00"
    grid["gen"]["310"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["310"]["substation_full_name"] = "FR00"
    grid["gen"]["310"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["310"]["substation"] = "FR00_380"
    grid["gen"]["310"]["name"] = "FR_capacity"
    grid["gen"]["310"]["gen_bus"] = 2
    grid["gen"]["310"]["zone"] = "FR00"
    grid["gen"]["310"]["type"] = "Offshore Wind"
    grid["gen"]["310"]["cost"][1] = 59
    grid["gen"]["310"]["C02_emission"] = 0

    grid["gen"]["311"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["311"]["source_id"][2] = 311
    grid["gen"]["311"]["index"] = 311
    grid["gen"]["311"]["pmax"] = 610.0
    grid["gen"]["311"]["qmax"] = 173.5
    grid["gen"]["311"]["qmin"] = - 173.5
    grid["gen"]["311"]["installed_capacity"] = 347.0
    grid["gen"]["311"]["mbase"] = 100.0
    grid["gen"]["311"]["substation_short_name"] = "FR00"
    grid["gen"]["311"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["311"]["substation_full_name"] = "FR00"
    grid["gen"]["311"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["311"]["substation"] = "FR00_380"
    grid["gen"]["311"]["name"] = "FR_capacity"
    grid["gen"]["311"]["gen_bus"] = 2
    grid["gen"]["311"]["zone"] = "FR00"
    grid["gen"]["311"]["type"] = "Onshore Wind"
    grid["gen"]["311"]["cost"][1] = 25
    grid["gen"]["311"]["C02_emission"] = 0

    grid["gen"]["312"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["312"]["source_id"][2] = 312
    grid["gen"]["312"]["index"] = 312
    grid["gen"]["312"]["pmax"] = 1430.0
    grid["gen"]["312"]["qmax"] = 270.0
    grid["gen"]["312"]["qmin"] = - 270.0
    grid["gen"]["312"]["installed_capacity"] = 540.0
    grid["gen"]["312"]["mbase"] = 100.0
    grid["gen"]["312"]["substation_short_name"] = "FR00"
    grid["gen"]["312"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["312"]["substation_full_name"] = "FR00"
    grid["gen"]["312"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["312"]["substation"] = "FR00_380"
    grid["gen"]["312"]["name"] = "FR_capacity"
    grid["gen"]["312"]["gen_bus"] = 2
    grid["gen"]["312"]["zone"] = "FR00"
    grid["gen"]["312"]["type"] = "Solar PV"
    grid["gen"]["312"]["cost"][1] = 18
    grid["gen"]["312"]["C02_emission"] = 0

    # Add FR load
    grid["load"]["3"] = deepcopy(grid["load"]["1"])
    grid["load"]["3"]["source_id"][2] = 3
    grid["load"]["3"]["index"] = 3
    grid["load"]["3"]["load_bus"] = 2 
    grid["load"]["3"]["pmax"] = 450.0
    grid["load"]["3"]["qmax"] = 220.0
    grid["load"]["3"]["qmin"] = - 220.0
    grid["load"]["3"]["installed_capacity"] = 450.0
    grid["load"]["3"]["mbase"] = 100.0
    grid["load"]["3"]["zone"] = "FR00"
    grid["load"]["3"]["full_name"] = "FR_aggregated"
    grid["load"]["3"]["full_name_kV"] = "FR_aggregated_380"
    grid["load"]["3"]["name"] = "FR_aggregated_380"
    grid["load"]["3"]["name_no_kV"] = "FR_aggregated"
end 

function add_France_2040_low(grid)
    # Source: https://transparency.entsoe.eu/generation/r2/installedGenerationCapacityAggregation/show?name=&defaultValue=true&viewType=TABLE&areaType=BZN&atch=false&dateTime.dateTime=01.01.2024+00:00|UTC|YEAR&dateTime.endDateTime=01.01.2024+00:00|UTC|YEAR&area.values=CTY|10YFR-RTE------C!BZN|10YFR-RTE------C&productionType.values=B01&productionType.values=B25&productionType.values=B02&productionType.values=B03&productionType.values=B04&productionType.values=B05&productionType.values=B06&productionType.values=B07&productionType.values=B08&productionType.values=B09&productionType.values=B10&productionType.values=B11&productionType.values=B12&productionType.values=B13&productionType.values=B14&productionType.values=B20&productionType.values=B15&productionType.values=B16&productionType.values=B17&productionType.values=B18&productionType.values=B19 
    # Source: https://energy.ec.europa.eu/system/files/2022-08/fr_final_necp_main_en.pdf
    # Source: https://www.enerdata.net/publications/daily-energy-news/france-targets-41-renewables-its-final-energy-mix-2030.html#:~:text=Specifically%2C%20France%20aims%20for%20a,should%20be%20committed%20by%202026.(National Energy and Climate Plan (NECP))
    #grid["bus"]["2"]["zone"] = "FR00"

    # Add FR generators
    grid["gen"]["308"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["308"]["source_id"][2] = 308
    grid["gen"]["308"]["index"] = 308
    grid["gen"]["308"]["pmax"] = 131.33
    grid["gen"]["308"]["qmax"] = 56.0
    grid["gen"]["308"]["qmin"] = - 56.0
    grid["gen"]["308"]["installed_capacity"] = 131.33
    grid["gen"]["308"]["mbase"] = 100.0
    grid["gen"]["308"]["substation_short_name"] = "FR00"
    grid["gen"]["308"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["308"]["substation_full_name"] = "FR00"
    grid["gen"]["308"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["308"]["substation"] = "FR00_380"
    grid["gen"]["308"]["name"] = "FR_capacity"
    grid["gen"]["308"]["gen_bus"] = 2
    grid["gen"]["308"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["308"]["zone"] = "FR00"

    grid["gen"]["309"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["309"]["source_id"][2] = 309
    grid["gen"]["309"]["index"] = 309
    grid["gen"]["309"]["pmax"] = 713.70
    grid["gen"]["309"]["qmax"] = 355.0
    grid["gen"]["309"]["qmin"] = - 355.0
    grid["gen"]["309"]["installed_capacity"] = 713.70
    grid["gen"]["309"]["mbase"] = 100.0
    grid["gen"]["309"]["substation_short_name"] = "FR00"
    grid["gen"]["309"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["309"]["substation_full_name"] = "FR00"
    grid["gen"]["309"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["309"]["substation"] = "FR00_380"
    grid["gen"]["309"]["name"] = "FR_capacity"
    grid["gen"]["309"]["gen_bus"] = 2
    grid["gen"]["309"]["type"] = "Nuclear"
    grid["gen"]["309"]["zone"] = "FR00"
    grid["gen"]["309"]["cost"][1] = 110
    grid["gen"]["309"]["C02_emission"] = 0

    grid["gen"]["310"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["310"]["source_id"][2] = 310
    grid["gen"]["310"]["index"] = 310
    grid["gen"]["310"]["pmax"] = 263.75
    grid["gen"]["310"]["qmax"] = 31.0
    grid["gen"]["310"]["qmin"] = - 31.0
    grid["gen"]["310"]["installed_capacity"] = 62.0
    grid["gen"]["310"]["mbase"] = 100.0
    grid["gen"]["310"]["substation_short_name"] = "FR00"
    grid["gen"]["310"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["310"]["substation_full_name"] = "FR00"
    grid["gen"]["310"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["310"]["substation"] = "FR00_380"
    grid["gen"]["310"]["name"] = "FR_capacity"
    grid["gen"]["310"]["gen_bus"] = 2
    grid["gen"]["310"]["zone"] = "FR00"
    grid["gen"]["310"]["type"] = "Offshore Wind"
    grid["gen"]["310"]["cost"][1] = 59
    grid["gen"]["310"]["C02_emission"] = 0

    grid["gen"]["311"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["311"]["source_id"][2] = 311
    grid["gen"]["311"]["index"] = 311
    grid["gen"]["311"]["pmax"] = 305.0
    grid["gen"]["311"]["qmax"] = 173.5
    grid["gen"]["311"]["qmin"] = - 173.5
    grid["gen"]["311"]["installed_capacity"] = 347.0
    grid["gen"]["311"]["mbase"] = 100.0
    grid["gen"]["311"]["substation_short_name"] = "FR00"
    grid["gen"]["311"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["311"]["substation_full_name"] = "FR00"
    grid["gen"]["311"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["311"]["substation"] = "FR00_380"
    grid["gen"]["311"]["name"] = "FR_capacity"
    grid["gen"]["311"]["gen_bus"] = 2
    grid["gen"]["311"]["zone"] = "FR00"
    grid["gen"]["311"]["type"] = "Onshore Wind"
    grid["gen"]["311"]["cost"][1] = 25
    grid["gen"]["311"]["C02_emission"] = 0

    grid["gen"]["312"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["312"]["source_id"][2] = 312
    grid["gen"]["312"]["index"] = 312
    grid["gen"]["312"]["pmax"] = 470.0
    grid["gen"]["312"]["qmax"] = 270.0
    grid["gen"]["312"]["qmin"] = - 270.0
    grid["gen"]["312"]["installed_capacity"] = 540.0
    grid["gen"]["312"]["mbase"] = 100.0
    grid["gen"]["312"]["substation_short_name"] = "FR00"
    grid["gen"]["312"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["312"]["substation_full_name"] = "FR00"
    grid["gen"]["312"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["312"]["substation"] = "FR00_380"
    grid["gen"]["312"]["name"] = "FR_capacity"
    grid["gen"]["312"]["gen_bus"] = 2
    grid["gen"]["312"]["zone"] = "FR00"
    grid["gen"]["312"]["type"] = "Solar PV"
    grid["gen"]["312"]["cost"][1] = 18
    grid["gen"]["312"]["C02_emission"] = 0

    # Add FR load
    grid["load"]["3"] = deepcopy(grid["load"]["1"])
    grid["load"]["3"]["source_id"][2] = 3
    grid["load"]["3"]["index"] = 3
    grid["load"]["3"]["load_bus"] = 2 
    grid["load"]["3"]["pmax"] = 450.0
    grid["load"]["3"]["qmax"] = 220.0
    grid["load"]["3"]["qmin"] = - 220.0
    grid["load"]["3"]["installed_capacity"] = 450.0
    grid["load"]["3"]["mbase"] = 100.0
    grid["load"]["3"]["zone"] = "FR00"
    grid["load"]["3"]["full_name"] = "FR_aggregated"
    grid["load"]["3"]["full_name_kV"] = "FR_aggregated_380"
    grid["load"]["3"]["name"] = "FR_aggregated_380"
    grid["load"]["3"]["name_no_kV"] = "FR_aggregated"
end 

function add_France_2040_high_PEI(grid)
    # Source: https://transparency.entsoe.eu/generation/r2/installedGenerationCapacityAggregation/show?name=&defaultValue=true&viewType=TABLE&areaType=BZN&atch=false&dateTime.dateTime=01.01.2024+00:00|UTC|YEAR&dateTime.endDateTime=01.01.2024+00:00|UTC|YEAR&area.values=CTY|10YFR-RTE------C!BZN|10YFR-RTE------C&productionType.values=B01&productionType.values=B25&productionType.values=B02&productionType.values=B03&productionType.values=B04&productionType.values=B05&productionType.values=B06&productionType.values=B07&productionType.values=B08&productionType.values=B09&productionType.values=B10&productionType.values=B11&productionType.values=B12&productionType.values=B13&productionType.values=B14&productionType.values=B20&productionType.values=B15&productionType.values=B16&productionType.values=B17&productionType.values=B18&productionType.values=B19 
    # Source: https://energy.ec.europa.eu/system/files/2022-08/fr_final_necp_main_en.pdf
    # Source: https://www.enerdata.net/publications/daily-energy-news/france-targets-41-renewables-its-final-energy-mix-2030.html#:~:text=Specifically%2C%20France%20aims%20for%20a,should%20be%20committed%20by%202026.(National Energy and Climate Plan (NECP))
    #grid["bus"]["2"]["zone"] = "FR00"

    # Add FR generators
    grid["gen"]["308"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["308"]["source_id"][2] = 308
    grid["gen"]["308"]["index"] = 308
    grid["gen"]["308"]["pmax"] = 131.33
    grid["gen"]["308"]["qmax"] = 56.0
    grid["gen"]["308"]["qmin"] = - 56.0
    grid["gen"]["308"]["installed_capacity"] = 131.33
    grid["gen"]["308"]["mbase"] = 100.0
    grid["gen"]["308"]["substation_short_name"] = "FR00"
    grid["gen"]["308"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["308"]["substation_full_name"] = "FR00"
    grid["gen"]["308"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["308"]["substation"] = "FR00_380"
    grid["gen"]["308"]["name"] = "FR_capacity"
    grid["gen"]["308"]["gen_bus"] = 1
    grid["gen"]["308"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["308"]["zone"] = "FR00"

    grid["gen"]["309"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["309"]["source_id"][2] = 309
    grid["gen"]["309"]["index"] = 309
    grid["gen"]["309"]["pmax"] = 713.70
    grid["gen"]["309"]["qmax"] = 355.0
    grid["gen"]["309"]["qmin"] = - 355.0
    grid["gen"]["309"]["installed_capacity"] = 713.70
    grid["gen"]["309"]["mbase"] = 100.0
    grid["gen"]["309"]["substation_short_name"] = "FR00"
    grid["gen"]["309"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["309"]["substation_full_name"] = "FR00"
    grid["gen"]["309"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["309"]["substation"] = "FR00_380"
    grid["gen"]["309"]["name"] = "FR_capacity"
    grid["gen"]["309"]["gen_bus"] = 1
    grid["gen"]["309"]["type"] = "Nuclear"
    grid["gen"]["309"]["zone"] = "FR00"
    grid["gen"]["309"]["cost"][1] = 110
    grid["gen"]["309"]["C02_emission"] = 0

    grid["gen"]["310"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["310"]["source_id"][2] = 310
    grid["gen"]["310"]["index"] = 310
    grid["gen"]["310"]["pmax"] = 266.62
    grid["gen"]["310"]["qmax"] = 31.0
    grid["gen"]["310"]["qmin"] = - 31.0
    grid["gen"]["310"]["installed_capacity"] = 62.0
    grid["gen"]["310"]["mbase"] = 100.0
    grid["gen"]["310"]["substation_short_name"] = "FR00"
    grid["gen"]["310"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["310"]["substation_full_name"] = "FR00"
    grid["gen"]["310"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["310"]["substation"] = "FR00_380"
    grid["gen"]["310"]["name"] = "FR_capacity"
    grid["gen"]["310"]["gen_bus"] = 1
    grid["gen"]["310"]["zone"] = "FR00"
    grid["gen"]["310"]["type"] = "Offshore Wind"
    grid["gen"]["310"]["cost"][1] = 59
    grid["gen"]["310"]["C02_emission"] = 0

    grid["gen"]["311"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["311"]["source_id"][2] = 311
    grid["gen"]["311"]["index"] = 311
    grid["gen"]["311"]["pmax"] = 610.0
    grid["gen"]["311"]["qmax"] = 173.5
    grid["gen"]["311"]["qmin"] = - 173.5
    grid["gen"]["311"]["installed_capacity"] = 347.0
    grid["gen"]["311"]["mbase"] = 100.0
    grid["gen"]["311"]["substation_short_name"] = "FR00"
    grid["gen"]["311"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["311"]["substation_full_name"] = "FR00"
    grid["gen"]["311"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["311"]["substation"] = "FR00_380"
    grid["gen"]["311"]["name"] = "FR_capacity"
    grid["gen"]["311"]["gen_bus"] = 1
    grid["gen"]["311"]["zone"] = "FR00"
    grid["gen"]["311"]["type"] = "Onshore Wind"
    grid["gen"]["311"]["cost"][1] = 25
    grid["gen"]["311"]["C02_emission"] = 0

    grid["gen"]["312"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["312"]["source_id"][2] = 312
    grid["gen"]["312"]["index"] = 312
    grid["gen"]["312"]["pmax"] = 1430.0
    grid["gen"]["312"]["qmax"] = 270.0
    grid["gen"]["312"]["qmin"] = - 270.0
    grid["gen"]["312"]["installed_capacity"] = 540.0
    grid["gen"]["312"]["mbase"] = 100.0
    grid["gen"]["312"]["substation_short_name"] = "FR00"
    grid["gen"]["312"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["312"]["substation_full_name"] = "FR00"
    grid["gen"]["312"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["312"]["substation"] = "FR00_380"
    grid["gen"]["312"]["name"] = "FR_capacity"
    grid["gen"]["312"]["gen_bus"] = 1
    grid["gen"]["312"]["zone"] = "FR00"
    grid["gen"]["312"]["type"] = "Solar PV"
    grid["gen"]["312"]["cost"][1] = 18
    grid["gen"]["312"]["C02_emission"] = 0

    # Add FR load
    grid["load"]["3"] = deepcopy(grid["load"]["1"])
    grid["load"]["3"]["source_id"][2] = 3
    grid["load"]["3"]["index"] = 3
    grid["load"]["3"]["load_bus"] = 2 
    grid["load"]["3"]["pmax"] = 450.0
    grid["load"]["3"]["qmax"] = 220.0
    grid["load"]["3"]["qmin"] = - 220.0
    grid["load"]["3"]["installed_capacity"] = 450.0
    grid["load"]["3"]["mbase"] = 100.0
    grid["load"]["3"]["zone"] = "FR00"
    grid["load"]["3"]["full_name"] = "FR_aggregated"
    grid["load"]["3"]["full_name_kV"] = "FR_aggregated_380"
    grid["load"]["3"]["name"] = "FR_aggregated_380"
    grid["load"]["3"]["name_no_kV"] = "FR_aggregated"
end 

function add_France_2040_low_PEI(grid)
    # Source: https://transparency.entsoe.eu/generation/r2/installedGenerationCapacityAggregation/show?name=&defaultValue=true&viewType=TABLE&areaType=BZN&atch=false&dateTime.dateTime=01.01.2024+00:00|UTC|YEAR&dateTime.endDateTime=01.01.2024+00:00|UTC|YEAR&area.values=CTY|10YFR-RTE------C!BZN|10YFR-RTE------C&productionType.values=B01&productionType.values=B25&productionType.values=B02&productionType.values=B03&productionType.values=B04&productionType.values=B05&productionType.values=B06&productionType.values=B07&productionType.values=B08&productionType.values=B09&productionType.values=B10&productionType.values=B11&productionType.values=B12&productionType.values=B13&productionType.values=B14&productionType.values=B20&productionType.values=B15&productionType.values=B16&productionType.values=B17&productionType.values=B18&productionType.values=B19 
    # Source: https://energy.ec.europa.eu/system/files/2022-08/fr_final_necp_main_en.pdf
    # Source: https://www.enerdata.net/publications/daily-energy-news/france-targets-41-renewables-its-final-energy-mix-2030.html#:~:text=Specifically%2C%20France%20aims%20for%20a,should%20be%20committed%20by%202026.(National Energy and Climate Plan (NECP))
    #grid["bus"]["2"]["zone"] = "FR00"

    # Add FR generators
    grid["gen"]["308"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["308"]["source_id"][2] = 308
    grid["gen"]["308"]["index"] = 308
    grid["gen"]["308"]["pmax"] = 131.33
    grid["gen"]["308"]["qmax"] = 56.0
    grid["gen"]["308"]["qmin"] = - 56.0
    grid["gen"]["308"]["installed_capacity"] = 131.33
    grid["gen"]["308"]["mbase"] = 100.0
    grid["gen"]["308"]["substation_short_name"] = "FR00"
    grid["gen"]["308"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["308"]["substation_full_name"] = "FR00"
    grid["gen"]["308"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["308"]["substation"] = "FR00_380"
    grid["gen"]["308"]["name"] = "FR_capacity"
    grid["gen"]["308"]["gen_bus"] = 1
    grid["gen"]["308"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["308"]["zone"] = "FR00"

    grid["gen"]["309"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["309"]["source_id"][2] = 309
    grid["gen"]["309"]["index"] = 309
    grid["gen"]["309"]["pmax"] = 713.70
    grid["gen"]["309"]["qmax"] = 355.0
    grid["gen"]["309"]["qmin"] = - 355.0
    grid["gen"]["309"]["installed_capacity"] = 713.70
    grid["gen"]["309"]["mbase"] = 100.0
    grid["gen"]["309"]["substation_short_name"] = "FR00"
    grid["gen"]["309"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["309"]["substation_full_name"] = "FR00"
    grid["gen"]["309"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["309"]["substation"] = "FR00_380"
    grid["gen"]["309"]["name"] = "FR_capacity"
    grid["gen"]["309"]["gen_bus"] = 1
    grid["gen"]["309"]["type"] = "Nuclear"
    grid["gen"]["309"]["zone"] = "FR00"
    grid["gen"]["309"]["cost"][1] = 110
    grid["gen"]["309"]["C02_emission"] = 0

    grid["gen"]["310"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["310"]["source_id"][2] = 310
    grid["gen"]["310"]["index"] = 310
    grid["gen"]["310"]["pmax"] = 263.75
    grid["gen"]["310"]["qmax"] = 31.0
    grid["gen"]["310"]["qmin"] = - 31.0
    grid["gen"]["310"]["installed_capacity"] = 62.0
    grid["gen"]["310"]["mbase"] = 100.0
    grid["gen"]["310"]["substation_short_name"] = "FR00"
    grid["gen"]["310"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["310"]["substation_full_name"] = "FR00"
    grid["gen"]["310"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["310"]["substation"] = "FR00_380"
    grid["gen"]["310"]["name"] = "FR_capacity"
    grid["gen"]["310"]["gen_bus"] = 1
    grid["gen"]["310"]["zone"] = "FR00"
    grid["gen"]["310"]["type"] = "Offshore Wind"
    grid["gen"]["310"]["cost"][1] = 59
    grid["gen"]["310"]["C02_emission"] = 0

    grid["gen"]["311"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["311"]["source_id"][2] = 311
    grid["gen"]["311"]["index"] = 311
    grid["gen"]["311"]["pmax"] = 305.0
    grid["gen"]["311"]["qmax"] = 173.5
    grid["gen"]["311"]["qmin"] = - 173.5
    grid["gen"]["311"]["installed_capacity"] = 347.0
    grid["gen"]["311"]["mbase"] = 100.0
    grid["gen"]["311"]["substation_short_name"] = "FR00"
    grid["gen"]["311"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["311"]["substation_full_name"] = "FR00"
    grid["gen"]["311"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["311"]["substation"] = "FR00_380"
    grid["gen"]["311"]["name"] = "FR_capacity"
    grid["gen"]["311"]["gen_bus"] = 1
    grid["gen"]["311"]["zone"] = "FR00"
    grid["gen"]["311"]["type"] = "Onshore Wind"
    grid["gen"]["311"]["cost"][1] = 25
    grid["gen"]["311"]["C02_emission"] = 0

    grid["gen"]["312"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["312"]["source_id"][2] = 312
    grid["gen"]["312"]["index"] = 312
    grid["gen"]["312"]["pmax"] = 470.0
    grid["gen"]["312"]["qmax"] = 270.0
    grid["gen"]["312"]["qmin"] = - 270.0
    grid["gen"]["312"]["installed_capacity"] = 540.0
    grid["gen"]["312"]["mbase"] = 100.0
    grid["gen"]["312"]["substation_short_name"] = "FR00"
    grid["gen"]["312"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["312"]["substation_full_name"] = "FR00"
    grid["gen"]["312"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["312"]["substation"] = "FR00_380"
    grid["gen"]["312"]["name"] = "FR_capacity"
    grid["gen"]["312"]["gen_bus"] = 1
    grid["gen"]["312"]["zone"] = "FR00"
    grid["gen"]["312"]["type"] = "Solar PV"
    grid["gen"]["312"]["cost"][1] = 18
    grid["gen"]["312"]["C02_emission"] = 0

    # Add FR load
    grid["load"]["3"] = deepcopy(grid["load"]["1"])
    grid["load"]["3"]["source_id"][2] = 3
    grid["load"]["3"]["index"] = 3
    grid["load"]["3"]["load_bus"] = 2 
    grid["load"]["3"]["pmax"] = 450.0
    grid["load"]["3"]["qmax"] = 220.0
    grid["load"]["3"]["qmin"] = - 220.0
    grid["load"]["3"]["installed_capacity"] = 450.0
    grid["load"]["3"]["mbase"] = 100.0
    grid["load"]["3"]["zone"] = "FR00"
    grid["load"]["3"]["full_name"] = "FR_aggregated"
    grid["load"]["3"]["full_name_kV"] = "FR_aggregated_380"
    grid["load"]["3"]["name"] = "FR_aggregated_380"
    grid["load"]["3"]["name_no_kV"] = "FR_aggregated"
end 


function add_Belgium_2040_low(grid)
   # Onshore wind -> g_id 9
   # Solar V -> g_id 7
   # Offshore wind -> g_id 29
   grid["gen"]["7"]["pmax"] = 200.0
   grid["gen"]["9"]["pmax"] = 65.00
   grid["gen"]["29"]["pmax"] = 43.60
end

function add_Belgium_2040_high(grid)
    grid["gen"]["7"]["pmax"] = 350.0
    grid["gen"]["9"]["pmax"] = 93.50
    grid["gen"]["29"]["pmax"] = 43.60
end


function add_UK_2040_low(grid)
    # Onshore wind -> g_id 111
    # Solar V -> g_id 112
    # Offshore wind -> g_id 110
    grid["gen"]["112"]["pmax"] = 258.90
    grid["gen"]["111"]["pmax"] = 222.71
    grid["gen"]["110"]["pmax"] = 951.58
end
 
function add_UK_2040_high(grid)
     grid["gen"]["112"]["pmax"] = 350.0
     grid["gen"]["111"]["pmax"] = 420.40
     grid["gen"]["110"]["pmax"] = 973.89
end

function add_Denmark_W_2040_high_PEI(grid)

    # Add DK generators
    grid["gen"]["1010"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["1010"]["source_id"][2] = 1010
    grid["gen"]["1010"]["index"] = 1010
    grid["gen"]["1010"]["pmax"] = 95.00
    grid["gen"]["1010"]["qmax"] = 42.50
    grid["gen"]["1010"]["qmin"] = - 42.5
    grid["gen"]["1010"]["installed_capacity"] = 95.00
    grid["gen"]["1010"]["mbase"] = 100.0
    grid["gen"]["1010"]["substation_short_name"] = "DKW1"
    grid["gen"]["1010"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["1010"]["substation_full_name"] = "DKW1"
    grid["gen"]["1010"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["1010"]["substation"] = "DKW1_380"
    grid["gen"]["1010"]["name"] = "DK_capacity"
    grid["gen"]["1010"]["gen_bus"] = 1380
    grid["gen"]["1010"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["1010"]["zone"] = "DKW1"


    grid["gen"]["1020"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["1020"]["source_id"][2] = 1020
    grid["gen"]["1020"]["index"] = 1020
    grid["gen"]["1020"]["pmax"] = 1000.246
    grid["gen"]["1020"]["qmax"] = 5.23
    grid["gen"]["1020"]["qmin"] = - 5.23
    grid["gen"]["1020"]["installed_capacity"] = 10.45
    grid["gen"]["1020"]["mbase"] = 100.0
    grid["gen"]["1020"]["substation_short_name"] = "DKW1"
    grid["gen"]["1020"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["1020"]["substation_full_name"] = "DKW1"
    grid["gen"]["1020"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["1020"]["substation"] = "DKW1_380"
    grid["gen"]["1020"]["name"] = "DK_capacity"
    grid["gen"]["1020"]["gen_bus"] = 1380
    grid["gen"]["1020"]["zone"] = "DKW1"
    grid["gen"]["1020"]["type"] = "Offshore Wind"
    grid["gen"]["1020"]["cost"][1] = 59.0
    grid["gen"]["1020"]["C02_emission"] = 0

    grid["gen"]["1030"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["1030"]["source_id"][2] = 1030
    grid["gen"]["1030"]["index"] = 1030
    grid["gen"]["1030"]["pmax"] = 100.722
    grid["gen"]["1030"]["qmax"] = 3.74
    grid["gen"]["1030"]["qmin"] = - 3.74
    grid["gen"]["1030"]["installed_capacity"] = 7.48
    grid["gen"]["1030"]["mbase"] = 100.0
    grid["gen"]["1030"]["substation_short_name"] = "DKW1"
    grid["gen"]["1030"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["1030"]["substation_full_name"] = "DKW1"
    grid["gen"]["1030"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["1030"]["substation"] = "DKW1_380"
    grid["gen"]["1030"]["name"] = "DK_capacity"
    grid["gen"]["1030"]["gen_bus"] = 1380
    grid["gen"]["1030"]["zone"] = "DKW1"
    grid["gen"]["1030"]["type"] = "Onshore Wind"
    grid["gen"]["1030"]["cost"][1] = 25.0
    grid["gen"]["1030"]["C02_emission"] = 0

    grid["gen"]["1040"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["1040"]["source_id"][2] = 1040
    grid["gen"]["1040"]["index"] = 1040
    grid["gen"]["1040"]["pmax"] = 478.10
    grid["gen"]["1040"]["qmax"] = 4.96
    grid["gen"]["1040"]["qmin"] = - 4.96
    grid["gen"]["1040"]["installed_capacity"] = 9.92
    grid["gen"]["1040"]["mbase"] = 100.0
    grid["gen"]["1040"]["substation_short_name"] = "DKW1"
    grid["gen"]["1040"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["1040"]["substation_full_name"] = "DKW1"
    grid["gen"]["1040"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["1040"]["substation"] = "DKW1_380"
    grid["gen"]["1040"]["name"] = "DK_capacity"
    grid["gen"]["1040"]["gen_bus"] = 1380
    grid["gen"]["1040"]["zone"] = "DKW1"
    grid["gen"]["1040"]["type"] = "Solar PV"
    grid["gen"]["1040"]["cost"][1] = 18.0
    grid["gen"]["1040"]["C02_emission"] = 0
end

function add_Denmark_W_2040_low_PEI(grid)

    # Add DK generators
    grid["gen"]["1010"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["1010"]["source_id"][2] = 1010
    grid["gen"]["1010"]["index"] = 1010
    grid["gen"]["1010"]["pmax"] = 95.00
    grid["gen"]["1010"]["qmax"] = 42.50
    grid["gen"]["1010"]["qmin"] = - 42.5
    grid["gen"]["1010"]["installed_capacity"] = 95.00
    grid["gen"]["1010"]["mbase"] = 100.0
    grid["gen"]["1010"]["substation_short_name"] = "DKW1"
    grid["gen"]["1010"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["1010"]["substation_full_name"] = "DKW1"
    grid["gen"]["1010"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["1010"]["substation"] = "DKW1_380"
    grid["gen"]["1010"]["name"] = "DK_capacity"
    grid["gen"]["1010"]["gen_bus"] = 1380
    grid["gen"]["1010"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["1010"]["zone"] = "DKW1"


    grid["gen"]["1020"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["1020"]["source_id"][2] = 1020
    grid["gen"]["1020"]["index"] = 1020
    grid["gen"]["1020"]["pmax"] = 100.72
    grid["gen"]["1020"]["qmax"] = 5.23
    grid["gen"]["1020"]["qmin"] = - 5.23
    grid["gen"]["1020"]["installed_capacity"] = 10.45
    grid["gen"]["1020"]["mbase"] = 100.0
    grid["gen"]["1020"]["substation_short_name"] = "DKW1"
    grid["gen"]["1020"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["1020"]["substation_full_name"] = "DKW1"
    grid["gen"]["1020"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["1020"]["substation"] = "DKW1_380"
    grid["gen"]["1020"]["name"] = "DK_capacity"
    grid["gen"]["1020"]["gen_bus"] = 1380
    grid["gen"]["1020"]["zone"] = "DKW1"
    grid["gen"]["1020"]["type"] = "Offshore Wind"
    grid["gen"]["1020"]["cost"][1] = 59.0
    grid["gen"]["1020"]["C02_emission"] = 0

    grid["gen"]["1030"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["1030"]["source_id"][2] = 1030
    grid["gen"]["1030"]["index"] = 1030
    grid["gen"]["1030"]["pmax"] = 35.00
    grid["gen"]["1030"]["qmax"] = 3.74
    grid["gen"]["1030"]["qmin"] = - 3.74
    grid["gen"]["1030"]["installed_capacity"] = 7.48
    grid["gen"]["1030"]["mbase"] = 100.0
    grid["gen"]["1030"]["substation_short_name"] = "DKW1"
    grid["gen"]["1030"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["1030"]["substation_full_name"] = "DKW1"
    grid["gen"]["1030"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["1030"]["substation"] = "DKW1_380"
    grid["gen"]["1030"]["name"] = "DK_capacity"
    grid["gen"]["1030"]["gen_bus"] = 1380
    grid["gen"]["1030"]["zone"] = "DKW1"
    grid["gen"]["1030"]["type"] = "Onshore Wind"
    grid["gen"]["1030"]["cost"][1] = 25.0
    grid["gen"]["1030"]["C02_emission"] = 0

    grid["gen"]["1040"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["1040"]["source_id"][2] = 1040
    grid["gen"]["1040"]["index"] = 1040
    grid["gen"]["1040"]["pmax"] = 43.51
    grid["gen"]["1040"]["qmax"] = 4.96
    grid["gen"]["1040"]["qmin"] = - 4.96
    grid["gen"]["1040"]["installed_capacity"] = 9.92
    grid["gen"]["1040"]["mbase"] = 100.0
    grid["gen"]["1040"]["substation_short_name"] = "DKW1"
    grid["gen"]["1040"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["1040"]["substation_full_name"] = "DKW1"
    grid["gen"]["1040"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["1040"]["substation"] = "DKW1_380"
    grid["gen"]["1040"]["name"] = "DK_capacity"
    grid["gen"]["1040"]["gen_bus"] = 1380
    grid["gen"]["1040"]["zone"] = "DKW1"
    grid["gen"]["1040"]["type"] = "Solar PV"
    grid["gen"]["1040"]["cost"][1] = 18.0
    grid["gen"]["1040"]["C02_emission"] = 0
end

function add_Denmark_W_2040_high(grid)

    # Add DK generators
    grid["gen"]["101"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["101"]["source_id"][2] = 101
    grid["gen"]["101"]["index"] = 101
    grid["gen"]["101"]["pmax"] = 95.00
    grid["gen"]["101"]["qmax"] = 42.50
    grid["gen"]["101"]["qmin"] = - 42.5
    grid["gen"]["101"]["installed_capacity"] = 95.00
    grid["gen"]["101"]["mbase"] = 100.0
    grid["gen"]["101"]["substation_short_name"] = "DKW1"
    grid["gen"]["101"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["101"]["substation_full_name"] = "DKW1"
    grid["gen"]["101"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["101"]["substation"] = "DKW1_380"
    grid["gen"]["101"]["name"] = "DK_capacity"
    grid["gen"]["101"]["gen_bus"] = 1
    grid["gen"]["101"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["101"]["zone"] = "DKW1"


    grid["gen"]["102"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["102"]["source_id"][2] = 102
    grid["gen"]["102"]["index"] = 102
    grid["gen"]["102"]["pmax"] = 1000.246
    grid["gen"]["102"]["qmax"] = 5.23
    grid["gen"]["102"]["qmin"] = - 5.23
    grid["gen"]["102"]["installed_capacity"] = 10.45
    grid["gen"]["102"]["mbase"] = 100.0
    grid["gen"]["102"]["substation_short_name"] = "DKW1"
    grid["gen"]["102"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["102"]["substation_full_name"] = "DKW1"
    grid["gen"]["102"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["102"]["substation"] = "DKW1_380"
    grid["gen"]["102"]["name"] = "DK_capacity"
    grid["gen"]["102"]["gen_bus"] = 1
    grid["gen"]["102"]["zone"] = "DKW1"
    grid["gen"]["102"]["type"] = "Offshore Wind"
    grid["gen"]["102"]["cost"][1] = 59.0
    grid["gen"]["102"]["C02_emission"] = 0

    grid["gen"]["103"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["103"]["source_id"][2] = 103
    grid["gen"]["103"]["index"] = 103
    grid["gen"]["103"]["pmax"] = 100.722
    grid["gen"]["103"]["qmax"] = 3.74
    grid["gen"]["103"]["qmin"] = - 3.74
    grid["gen"]["103"]["installed_capacity"] = 7.48
    grid["gen"]["103"]["mbase"] = 100.0
    grid["gen"]["103"]["substation_short_name"] = "DKW1"
    grid["gen"]["103"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["103"]["substation_full_name"] = "DKW1"
    grid["gen"]["103"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["103"]["substation"] = "DKW1_380"
    grid["gen"]["103"]["name"] = "DK_capacity"
    grid["gen"]["103"]["gen_bus"] = 1
    grid["gen"]["103"]["zone"] = "DKW1"
    grid["gen"]["103"]["type"] = "Onshore Wind"
    grid["gen"]["103"]["cost"][1] = 25.0
    grid["gen"]["103"]["C02_emission"] = 0

    grid["gen"]["104"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["104"]["source_id"][2] = 104
    grid["gen"]["104"]["index"] = 104
    grid["gen"]["104"]["pmax"] = 478.10
    grid["gen"]["104"]["qmax"] = 4.96
    grid["gen"]["104"]["qmin"] = - 4.96
    grid["gen"]["104"]["installed_capacity"] = 9.92
    grid["gen"]["104"]["mbase"] = 100.0
    grid["gen"]["104"]["substation_short_name"] = "DKW1"
    grid["gen"]["104"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["104"]["substation_full_name"] = "DKW1"
    grid["gen"]["104"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["104"]["substation"] = "DKW1_380"
    grid["gen"]["104"]["name"] = "DK_capacity"
    grid["gen"]["104"]["gen_bus"] = 1
    grid["gen"]["104"]["zone"] = "DKW1"
    grid["gen"]["104"]["type"] = "Solar PV"
    grid["gen"]["104"]["cost"][1] = 18.0
    grid["gen"]["104"]["C02_emission"] = 0
end

function add_Denmark_W_2040_low(grid)

    # Add DK generators
    grid["gen"]["101"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["101"]["source_id"][2] = 101
    grid["gen"]["101"]["index"] = 101
    grid["gen"]["101"]["pmax"] = 95.00
    grid["gen"]["101"]["qmax"] = 42.50
    grid["gen"]["101"]["qmin"] = - 42.5
    grid["gen"]["101"]["installed_capacity"] = 95.00
    grid["gen"]["101"]["mbase"] = 100.0
    grid["gen"]["101"]["substation_short_name"] = "DKW1"
    grid["gen"]["101"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["101"]["substation_full_name"] = "DKW1"
    grid["gen"]["101"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["101"]["substation"] = "DKW1_380"
    grid["gen"]["101"]["name"] = "DK_capacity"
    grid["gen"]["101"]["gen_bus"] = 1
    grid["gen"]["101"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["101"]["zone"] = "DKW1"


    grid["gen"]["102"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["102"]["source_id"][2] = 102
    grid["gen"]["102"]["index"] = 102
    grid["gen"]["102"]["pmax"] = 100.72
    grid["gen"]["102"]["qmax"] = 5.23
    grid["gen"]["102"]["qmin"] = - 5.23
    grid["gen"]["102"]["installed_capacity"] = 10.45
    grid["gen"]["102"]["mbase"] = 100.0
    grid["gen"]["102"]["substation_short_name"] = "DKW1"
    grid["gen"]["102"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["102"]["substation_full_name"] = "DKW1"
    grid["gen"]["102"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["102"]["substation"] = "DKW1_380"
    grid["gen"]["102"]["name"] = "DK_capacity"
    grid["gen"]["102"]["gen_bus"] = 1
    grid["gen"]["102"]["zone"] = "DKW1"
    grid["gen"]["102"]["type"] = "Offshore Wind"
    grid["gen"]["102"]["cost"][1] = 59.0
    grid["gen"]["102"]["C02_emission"] = 0

    grid["gen"]["103"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["103"]["source_id"][2] = 103
    grid["gen"]["103"]["index"] = 103
    grid["gen"]["103"]["pmax"] = 35.00
    grid["gen"]["103"]["qmax"] = 3.74
    grid["gen"]["103"]["qmin"] = - 3.74
    grid["gen"]["103"]["installed_capacity"] = 7.48
    grid["gen"]["103"]["mbase"] = 100.0
    grid["gen"]["103"]["substation_short_name"] = "DKW1"
    grid["gen"]["103"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["103"]["substation_full_name"] = "DKW1"
    grid["gen"]["103"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["103"]["substation"] = "DKW1_380"
    grid["gen"]["103"]["name"] = "DK_capacity"
    grid["gen"]["103"]["gen_bus"] = 1
    grid["gen"]["103"]["zone"] = "DKW1"
    grid["gen"]["103"]["type"] = "Onshore Wind"
    grid["gen"]["103"]["cost"][1] = 25.0
    grid["gen"]["103"]["C02_emission"] = 0

    grid["gen"]["104"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["104"]["source_id"][2] = 104
    grid["gen"]["104"]["index"] = 104
    grid["gen"]["104"]["pmax"] = 43.51
    grid["gen"]["104"]["qmax"] = 4.96
    grid["gen"]["104"]["qmin"] = - 4.96
    grid["gen"]["104"]["installed_capacity"] = 9.92
    grid["gen"]["104"]["mbase"] = 100.0
    grid["gen"]["104"]["substation_short_name"] = "DKW1"
    grid["gen"]["104"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["104"]["substation_full_name"] = "DKW1"
    grid["gen"]["104"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["104"]["substation"] = "DKW1_380"
    grid["gen"]["104"]["name"] = "DK_capacity"
    grid["gen"]["104"]["gen_bus"] = 1
    grid["gen"]["104"]["zone"] = "DKW1"
    grid["gen"]["104"]["type"] = "Solar PV"
    grid["gen"]["104"]["cost"][1] = 18.0
    grid["gen"]["104"]["C02_emission"] = 0
end

function add_Denmark_2030(grid)
    # Source: 
    
    # Add FR generators
    grid["gen"]["101"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["101"]["source_id"][2] = 101
    grid["gen"]["101"]["index"] = 101
    grid["gen"]["101"]["pmax"] = 95.00
    grid["gen"]["101"]["qmax"] = 42.50
    grid["gen"]["101"]["qmin"] = - 42.5
    grid["gen"]["101"]["installed_capacity"] = 95.00
    grid["gen"]["101"]["mbase"] = 100.0
    grid["gen"]["101"]["substation_short_name"] = "DKE1"
    grid["gen"]["101"]["substation_short_name_kV"] = "DKE1_380"
    grid["gen"]["101"]["substation_full_name"] = "DKE1"
    grid["gen"]["101"]["substation_full_name_kV"] = "DKE1_380"
    grid["gen"]["101"]["substation"] = "DKE1_380"
    grid["gen"]["101"]["name"] = "DK_capacity"
    grid["gen"]["101"]["gen_bus"] = 1
    grid["gen"]["101"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["101"]["zone"] = "DKE1"


    grid["gen"]["102"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["102"]["source_id"][2] = 102
    grid["gen"]["102"]["index"] = 102
    grid["gen"]["102"]["pmax"] = 10.45
    grid["gen"]["102"]["qmax"] = 5.23
    grid["gen"]["102"]["qmin"] = - 5.23
    grid["gen"]["102"]["installed_capacity"] = 10.45
    grid["gen"]["102"]["mbase"] = 100.0
    grid["gen"]["102"]["substation_short_name"] = "DKE1"
    grid["gen"]["102"]["substation_short_name_kV"] = "DKE1_380"
    grid["gen"]["102"]["substation_full_name"] = "DKE1"
    grid["gen"]["102"]["substation_full_name_kV"] = "DKE1_380"
    grid["gen"]["102"]["substation"] = "DKE1_380"
    grid["gen"]["102"]["name"] = "DK_capacity"
    grid["gen"]["102"]["gen_bus"] = 1
    grid["gen"]["102"]["zone"] = "DKE1"
    grid["gen"]["102"]["type"] = "Offshore Wind"
    grid["gen"]["102"]["cost"][1] = 59.0
    grid["gen"]["102"]["C02_emission"] = 0

    grid["gen"]["103"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["103"]["source_id"][2] = 103
    grid["gen"]["103"]["index"] = 103
    grid["gen"]["103"]["pmax"] = 7.48
    grid["gen"]["103"]["qmax"] = 3.74
    grid["gen"]["103"]["qmin"] = - 3.74
    grid["gen"]["103"]["installed_capacity"] = 7.48
    grid["gen"]["103"]["mbase"] = 100.0
    grid["gen"]["103"]["substation_short_name"] = "DKE1"
    grid["gen"]["103"]["substation_short_name_kV"] = "DKE1_380"
    grid["gen"]["103"]["substation_full_name"] = "DKE1"
    grid["gen"]["103"]["substation_full_name_kV"] = "DKE1_380"
    grid["gen"]["103"]["substation"] = "DKE1_380"
    grid["gen"]["103"]["name"] = "DK_capacity"
    grid["gen"]["103"]["gen_bus"] = 1
    grid["gen"]["103"]["zone"] = "DKE1"
    grid["gen"]["103"]["type"] = "Onshore Wind"
    grid["gen"]["103"]["cost"][1] = 25.0
    grid["gen"]["103"]["C02_emission"] = 0

    grid["gen"]["104"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["104"]["source_id"][2] = 104
    grid["gen"]["104"]["index"] = 104
    grid["gen"]["104"]["pmax"] = 9.92
    grid["gen"]["104"]["qmax"] = 4.96
    grid["gen"]["104"]["qmin"] = - 4.96
    grid["gen"]["104"]["installed_capacity"] = 9.92
    grid["gen"]["104"]["mbase"] = 100.0
    grid["gen"]["104"]["substation_short_name"] = "DKE1"
    grid["gen"]["104"]["substation_short_name_kV"] = "DKE1_380"
    grid["gen"]["104"]["substation_full_name"] = "DKE1"
    grid["gen"]["104"]["substation_full_name_kV"] = "DKE1_380"
    grid["gen"]["104"]["substation"] = "DKE1_380"
    grid["gen"]["104"]["name"] = "DK_capacity"
    grid["gen"]["104"]["gen_bus"] = 1
    grid["gen"]["104"]["zone"] = "DKE1"
    grid["gen"]["104"]["type"] = "Solar PV"
    grid["gen"]["104"]["cost"][1] = 18.0
    grid["gen"]["104"]["C02_emission"] = 0
end

function add_Germany_2030(grid)
    # Source: 
    
    # Add FR generators
    grid["gen"]["201"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["201"]["source_id"][2] = 201
    grid["gen"]["201"]["index"] = 201
    grid["gen"]["201"]["pmax"] = 463.30
    grid["gen"]["201"]["qmax"] = 181.65
    grid["gen"]["201"]["qmin"] = - 181.65
    grid["gen"]["201"]["installed_capacity"] = 463.30
    grid["gen"]["201"]["mbase"] = 100.0
    grid["gen"]["201"]["substation_short_name"] = "DE00"
    grid["gen"]["201"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["201"]["substation_full_name"] = "DE00"
    grid["gen"]["201"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["201"]["substation"] = "DE00_380"
    grid["gen"]["201"]["name"] = "DK_capacity"
    grid["gen"]["201"]["gen_bus"] = 2
    grid["gen"]["201"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["201"]["zone"] = "DE00"

    grid["gen"]["202"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["202"]["source_id"][2] = 202
    grid["gen"]["202"]["index"] = 202
    grid["gen"]["202"]["pmax"] = 84.56
    grid["gen"]["202"]["qmax"] = 5.23
    grid["gen"]["202"]["qmin"] = - 5.23
    grid["gen"]["202"]["installed_capacity"] = 84.56
    grid["gen"]["202"]["mbase"] = 100.0
    grid["gen"]["202"]["substation_short_name"] = "DE00"
    grid["gen"]["202"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["202"]["substation_full_name"] = "DE00"
    grid["gen"]["202"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["202"]["substation"] = "DE00_380"
    grid["gen"]["202"]["name"] = "DK_capacity"
    grid["gen"]["202"]["gen_bus"] = 2
    grid["gen"]["202"]["zone"] = "DE00"
    grid["gen"]["202"]["type"] = "Offshore Wind"
    grid["gen"]["202"]["cost"][1] = 59.0
    grid["gen"]["202"]["C02_emission"] = 0

    grid["gen"]["203"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["203"]["source_id"][2] = 203
    grid["gen"]["203"]["index"] = 203
    grid["gen"]["203"]["pmax"] = 600.49
    grid["gen"]["203"]["qmax"] = 3.74
    grid["gen"]["203"]["qmin"] = - 3.74
    grid["gen"]["203"]["installed_capacity"] = 600.49
    grid["gen"]["203"]["mbase"] = 100.0
    grid["gen"]["203"]["substation_short_name"] = "DE00"
    grid["gen"]["203"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["203"]["substation_full_name"] = "DE00"
    grid["gen"]["203"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["203"]["substation"] = "DE00_380"
    grid["gen"]["203"]["name"] = "DK_capacity"
    grid["gen"]["203"]["gen_bus"] = 2
    grid["gen"]["203"]["zone"] = "DE00"
    grid["gen"]["203"]["type"] = "Onshore Wind"
    grid["gen"]["203"]["cost"][1] = 25.0
    grid["gen"]["203"]["C02_emission"] = 0

    grid["gen"]["204"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["204"]["source_id"][2] = 204
    grid["gen"]["204"]["index"] = 204
    grid["gen"]["204"]["pmax"] = 770.16
    grid["gen"]["204"]["qmax"] = 4.96
    grid["gen"]["204"]["qmin"] = - 4.96
    grid["gen"]["204"]["installed_capacity"] = 770.16
    grid["gen"]["204"]["mbase"] = 100.0
    grid["gen"]["204"]["substation_short_name"] = "DE00"
    grid["gen"]["204"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["204"]["substation_full_name"] = "DE00"
    grid["gen"]["204"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["204"]["substation"] = "DE00_380"
    grid["gen"]["204"]["name"] = "DK_capacity"
    grid["gen"]["204"]["gen_bus"] = 2
    grid["gen"]["204"]["zone"] = "DE00"
    grid["gen"]["204"]["type"] = "Solar PV"
    grid["gen"]["204"]["cost"][1] = 18.0
    grid["gen"]["204"]["C02_emission"] = 0

    grid["gen"]["205"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["205"]["source_id"][2] = 205
    grid["gen"]["205"]["index"] = 205
    grid["gen"]["205"]["pmax"] = 650.0
    grid["gen"]["205"]["qmax"] = 4.96
    grid["gen"]["205"]["qmin"] = - 4.96
    grid["gen"]["205"]["installed_capacity"] = 650.0
    grid["gen"]["205"]["mbase"] = 100.0
    grid["gen"]["205"]["substation_short_name"] = "DE00"
    grid["gen"]["205"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["205"]["substation_full_name"] = "DE00"
    grid["gen"]["205"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["205"]["substation"] = "DE00_380"
    grid["gen"]["205"]["name"] = "DK_capacity"
    grid["gen"]["205"]["gen_bus"] = 2
    grid["gen"]["205"]["zone"] = "DE00"
    grid["gen"]["205"]["type"] = "Hard coal old 2 Bio"
    grid["gen"]["205"]["type_tyndp"] = "Hard coal old 2 Bio"
    grid["gen"]["205"]["cost"][1] = 180.0
    grid["gen"]["205"]["C02_emission"] = 0
end

function add_Germany_2040_low(grid)
    # Source: 
    
    # Add DE generators
    grid["gen"]["201"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["201"]["source_id"][2] = 201
    grid["gen"]["201"]["index"] = 201
    grid["gen"]["201"]["pmax"] = 463.30
    grid["gen"]["201"]["qmax"] = 181.65
    grid["gen"]["201"]["qmin"] = - 181.65
    grid["gen"]["201"]["installed_capacity"] = 463.30
    grid["gen"]["201"]["mbase"] = 100.0
    grid["gen"]["201"]["substation_short_name"] = "DE00"
    grid["gen"]["201"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["201"]["substation_full_name"] = "DE00"
    grid["gen"]["201"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["201"]["substation"] = "DE00_380"
    grid["gen"]["201"]["name"] = "DK_capacity"
    grid["gen"]["201"]["gen_bus"] = 2
    grid["gen"]["201"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["201"]["zone"] = "DE00"

    grid["gen"]["202"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["202"]["source_id"][2] = 202
    grid["gen"]["202"]["index"] = 202
    grid["gen"]["202"]["pmax"] = 702.48
    grid["gen"]["202"]["qmax"] = 5.23
    grid["gen"]["202"]["qmin"] = - 5.23
    grid["gen"]["202"]["installed_capacity"] = 84.56
    grid["gen"]["202"]["mbase"] = 100.0
    grid["gen"]["202"]["substation_short_name"] = "DE00"
    grid["gen"]["202"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["202"]["substation_full_name"] = "DE00"
    grid["gen"]["202"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["202"]["substation"] = "DE00_380"
    grid["gen"]["202"]["name"] = "DK_capacity"
    grid["gen"]["202"]["gen_bus"] = 2
    grid["gen"]["202"]["zone"] = "DE00"
    grid["gen"]["202"]["type"] = "Offshore Wind"
    grid["gen"]["202"]["cost"][1] = 59.0
    grid["gen"]["202"]["C02_emission"] = 0

    grid["gen"]["203"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["203"]["source_id"][2] = 203
    grid["gen"]["203"]["index"] = 203
    grid["gen"]["203"]["pmax"] = 1588.75
    grid["gen"]["203"]["qmax"] = 3.74
    grid["gen"]["203"]["qmin"] = - 3.74
    grid["gen"]["203"]["installed_capacity"] = 600.49
    grid["gen"]["203"]["mbase"] = 100.0
    grid["gen"]["203"]["substation_short_name"] = "DE00"
    grid["gen"]["203"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["203"]["substation_full_name"] = "DE00"
    grid["gen"]["203"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["203"]["substation"] = "DE00_380"
    grid["gen"]["203"]["name"] = "DK_capacity"
    grid["gen"]["203"]["gen_bus"] = 2
    grid["gen"]["203"]["zone"] = "DE00"
    grid["gen"]["203"]["type"] = "Onshore Wind"
    grid["gen"]["203"]["cost"][1] = 25.0
    grid["gen"]["203"]["C02_emission"] = 0

    grid["gen"]["204"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["204"]["source_id"][2] = 204
    grid["gen"]["204"]["index"] = 204
    grid["gen"]["204"]["pmax"] = 36587.5
    grid["gen"]["204"]["qmax"] = 4.96
    grid["gen"]["204"]["qmin"] = - 4.96
    grid["gen"]["204"]["installed_capacity"] = 770.16
    grid["gen"]["204"]["mbase"] = 100.0
    grid["gen"]["204"]["substation_short_name"] = "DE00"
    grid["gen"]["204"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["204"]["substation_full_name"] = "DE00"
    grid["gen"]["204"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["204"]["substation"] = "DE00_380"
    grid["gen"]["204"]["name"] = "DK_capacity"
    grid["gen"]["204"]["gen_bus"] = 2
    grid["gen"]["204"]["zone"] = "DE00"
    grid["gen"]["204"]["type"] = "Solar PV"
    grid["gen"]["204"]["cost"][1] = 18.0
    grid["gen"]["204"]["C02_emission"] = 0

    grid["gen"]["205"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["205"]["source_id"][2] = 205
    grid["gen"]["205"]["index"] = 205
    grid["gen"]["205"]["pmax"] = 650.0
    grid["gen"]["205"]["qmax"] = 4.96
    grid["gen"]["205"]["qmin"] = - 4.96
    grid["gen"]["205"]["installed_capacity"] = 650.0
    grid["gen"]["205"]["mbase"] = 100.0
    grid["gen"]["205"]["substation_short_name"] = "DE00"
    grid["gen"]["205"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["205"]["substation_full_name"] = "DE00"
    grid["gen"]["205"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["205"]["substation"] = "DE00_380"
    grid["gen"]["205"]["name"] = "DK_capacity"
    grid["gen"]["205"]["gen_bus"] = 2
    grid["gen"]["205"]["zone"] = "DE00"
    grid["gen"]["205"]["type"] = "Hard coal old 2 Bio"
    grid["gen"]["205"]["type_tyndp"] = "Hard coal old 2 Bio"
    grid["gen"]["205"]["cost"][1] = 180.0
    grid["gen"]["205"]["C02_emission"] = 0
end

function add_Germany_2040_high(grid)
    # Source: 
    
    # Add FR generators
    grid["gen"]["201"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["201"]["source_id"][2] = 201
    grid["gen"]["201"]["index"] = 201
    grid["gen"]["201"]["pmax"] = 463.30
    grid["gen"]["201"]["qmax"] = 181.65
    grid["gen"]["201"]["qmin"] = - 181.65
    grid["gen"]["201"]["installed_capacity"] = 463.30
    grid["gen"]["201"]["mbase"] = 100.0
    grid["gen"]["201"]["substation_short_name"] = "DE00"
    grid["gen"]["201"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["201"]["substation_full_name"] = "DE00"
    grid["gen"]["201"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["201"]["substation"] = "DE00_380"
    grid["gen"]["201"]["name"] = "DK_capacity"
    grid["gen"]["201"]["gen_bus"] = 2
    grid["gen"]["201"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["201"]["zone"] = "DE00"

    grid["gen"]["202"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["202"]["source_id"][2] = 202
    grid["gen"]["202"]["index"] = 202
    grid["gen"]["202"]["pmax"] = 742.48
    grid["gen"]["202"]["qmax"] = 5.23
    grid["gen"]["202"]["qmin"] = - 5.23
    grid["gen"]["202"]["installed_capacity"] = 84.56
    grid["gen"]["202"]["mbase"] = 100.0
    grid["gen"]["202"]["substation_short_name"] = "DE00"
    grid["gen"]["202"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["202"]["substation_full_name"] = "DE00"
    grid["gen"]["202"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["202"]["substation"] = "DE00_380"
    grid["gen"]["202"]["name"] = "DK_capacity"
    grid["gen"]["202"]["gen_bus"] = 2
    grid["gen"]["202"]["zone"] = "DE00"
    grid["gen"]["202"]["type"] = "Offshore Wind"
    grid["gen"]["202"]["cost"][1] = 59.0
    grid["gen"]["202"]["C02_emission"] = 0

    grid["gen"]["203"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["203"]["source_id"][2] = 203
    grid["gen"]["203"]["index"] = 203
    grid["gen"]["203"]["pmax"] = 1685.00
    grid["gen"]["203"]["qmax"] = 3.74
    grid["gen"]["203"]["qmin"] = - 3.74
    grid["gen"]["203"]["installed_capacity"] = 600.49
    grid["gen"]["203"]["mbase"] = 100.0
    grid["gen"]["203"]["substation_short_name"] = "DE00"
    grid["gen"]["203"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["203"]["substation_full_name"] = "DE00"
    grid["gen"]["203"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["203"]["substation"] = "DE00_380"
    grid["gen"]["203"]["name"] = "DK_capacity"
    grid["gen"]["203"]["gen_bus"] = 2
    grid["gen"]["203"]["zone"] = "DE00"
    grid["gen"]["203"]["type"] = "Onshore Wind"
    grid["gen"]["203"]["cost"][1] = 25.0
    grid["gen"]["203"]["C02_emission"] = 0

    grid["gen"]["204"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["204"]["source_id"][2] = 204
    grid["gen"]["204"]["index"] = 204
    grid["gen"]["204"]["pmax"] = 40000.00
    grid["gen"]["204"]["qmax"] = 4.96
    grid["gen"]["204"]["qmin"] = - 4.96
    grid["gen"]["204"]["installed_capacity"] = 770.16
    grid["gen"]["204"]["mbase"] = 100.0
    grid["gen"]["204"]["substation_short_name"] = "DE00"
    grid["gen"]["204"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["204"]["substation_full_name"] = "DE00"
    grid["gen"]["204"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["204"]["substation"] = "DE00_380"
    grid["gen"]["204"]["name"] = "DK_capacity"
    grid["gen"]["204"]["gen_bus"] = 2
    grid["gen"]["204"]["zone"] = "DE00"
    grid["gen"]["204"]["type"] = "Solar PV"
    grid["gen"]["204"]["cost"][1] = 18.0
    grid["gen"]["204"]["C02_emission"] = 0

    grid["gen"]["205"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["205"]["source_id"][2] = 205
    grid["gen"]["205"]["index"] = 205
    grid["gen"]["205"]["pmax"] = 650.0
    grid["gen"]["205"]["qmax"] = 4.96
    grid["gen"]["205"]["qmin"] = - 4.96
    grid["gen"]["205"]["installed_capacity"] = 650.0
    grid["gen"]["205"]["mbase"] = 100.0
    grid["gen"]["205"]["substation_short_name"] = "DE00"
    grid["gen"]["205"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["205"]["substation_full_name"] = "DE00"
    grid["gen"]["205"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["205"]["substation"] = "DE00_380"
    grid["gen"]["205"]["name"] = "DK_capacity"
    grid["gen"]["205"]["gen_bus"] = 2
    grid["gen"]["205"]["zone"] = "DE00"
    grid["gen"]["205"]["type"] = "Hard coal old 2 Bio"
    grid["gen"]["205"]["type_tyndp"] = "Hard coal old 2 Bio"
    grid["gen"]["205"]["cost"][1] = 180.0
    grid["gen"]["205"]["C02_emission"] = 0
end

function add_Germany_2040_low_PEI(grid)
    # Source: 
    
    # Add DE generators
    grid["gen"]["201"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["201"]["source_id"][2] = 201
    grid["gen"]["201"]["index"] = 201
    grid["gen"]["201"]["pmax"] = 463.30
    grid["gen"]["201"]["qmax"] = 181.65
    grid["gen"]["201"]["qmin"] = - 181.65
    grid["gen"]["201"]["installed_capacity"] = 463.30
    grid["gen"]["201"]["mbase"] = 100.0
    grid["gen"]["201"]["substation_short_name"] = "DE00"
    grid["gen"]["201"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["201"]["substation_full_name"] = "DE00"
    grid["gen"]["201"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["201"]["substation"] = "DE00_380"
    grid["gen"]["201"]["name"] = "DK_capacity"
    grid["gen"]["201"]["gen_bus"] = 1
    grid["gen"]["201"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["201"]["zone"] = "DE00"

    grid["gen"]["202"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["202"]["source_id"][2] = 202
    grid["gen"]["202"]["index"] = 202
    grid["gen"]["202"]["pmax"] = 742.48
    grid["gen"]["202"]["qmax"] = 5.23
    grid["gen"]["202"]["qmin"] = - 5.23
    grid["gen"]["202"]["installed_capacity"] = 84.56
    grid["gen"]["202"]["mbase"] = 100.0
    grid["gen"]["202"]["substation_short_name"] = "DE00"
    grid["gen"]["202"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["202"]["substation_full_name"] = "DE00"
    grid["gen"]["202"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["202"]["substation"] = "DE00_380"
    grid["gen"]["202"]["name"] = "DK_capacity"
    grid["gen"]["202"]["gen_bus"] = 1
    grid["gen"]["202"]["zone"] = "DE00"
    grid["gen"]["202"]["type"] = "Offshore Wind"
    grid["gen"]["202"]["cost"][1] = 59.0
    grid["gen"]["202"]["C02_emission"] = 0

    grid["gen"]["203"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["203"]["source_id"][2] = 203
    grid["gen"]["203"]["index"] = 203
    grid["gen"]["203"]["pmax"] = 1588.75
    grid["gen"]["203"]["qmax"] = 3.74
    grid["gen"]["203"]["qmin"] = - 3.74
    grid["gen"]["203"]["installed_capacity"] = 600.49
    grid["gen"]["203"]["mbase"] = 100.0
    grid["gen"]["203"]["substation_short_name"] = "DE00"
    grid["gen"]["203"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["203"]["substation_full_name"] = "DE00"
    grid["gen"]["203"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["203"]["substation"] = "DE00_380"
    grid["gen"]["203"]["name"] = "DK_capacity"
    grid["gen"]["203"]["gen_bus"] = 1
    grid["gen"]["203"]["zone"] = "DE00"
    grid["gen"]["203"]["type"] = "Onshore Wind"
    grid["gen"]["203"]["cost"][1] = 25.0
    grid["gen"]["203"]["C02_emission"] = 0

    grid["gen"]["204"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["204"]["source_id"][2] = 204
    grid["gen"]["204"]["index"] = 204
    grid["gen"]["204"]["pmax"] = 36587.5
    grid["gen"]["204"]["qmax"] = 4.96
    grid["gen"]["204"]["qmin"] = - 4.96
    grid["gen"]["204"]["installed_capacity"] = 770.16
    grid["gen"]["204"]["mbase"] = 100.0
    grid["gen"]["204"]["substation_short_name"] = "DE00"
    grid["gen"]["204"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["204"]["substation_full_name"] = "DE00"
    grid["gen"]["204"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["204"]["substation"] = "DE00_380"
    grid["gen"]["204"]["name"] = "DK_capacity"
    grid["gen"]["204"]["gen_bus"] = 1
    grid["gen"]["204"]["zone"] = "DE00"
    grid["gen"]["204"]["type"] = "Solar PV"
    grid["gen"]["204"]["cost"][1] = 18.0
    grid["gen"]["204"]["C02_emission"] = 0

    grid["gen"]["205"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["205"]["source_id"][2] = 205
    grid["gen"]["205"]["index"] = 205
    grid["gen"]["205"]["pmax"] = 650.0
    grid["gen"]["205"]["qmax"] = 4.96
    grid["gen"]["205"]["qmin"] = - 4.96
    grid["gen"]["205"]["installed_capacity"] = 650.0
    grid["gen"]["205"]["mbase"] = 100.0
    grid["gen"]["205"]["substation_short_name"] = "DE00"
    grid["gen"]["205"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["205"]["substation_full_name"] = "DE00"
    grid["gen"]["205"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["205"]["substation"] = "DE00_380"
    grid["gen"]["205"]["name"] = "DK_capacity"
    grid["gen"]["205"]["gen_bus"] = 1
    grid["gen"]["205"]["zone"] = "DE00"
    grid["gen"]["205"]["type"] = "Hard coal old 2 Bio"
    grid["gen"]["205"]["type_tyndp"] = "Hard coal old 2 Bio"
    grid["gen"]["205"]["cost"][1] = 180.0
    grid["gen"]["205"]["C02_emission"] = 0
end

function add_Germany_2040_high_PEI(grid)
    # Source: 
    
    # Add FR generators
    grid["gen"]["201"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["201"]["source_id"][2] = 201
    grid["gen"]["201"]["index"] = 201
    grid["gen"]["201"]["pmax"] = 463.30
    grid["gen"]["201"]["qmax"] = 181.65
    grid["gen"]["201"]["qmin"] = - 181.65
    grid["gen"]["201"]["installed_capacity"] = 463.30
    grid["gen"]["201"]["mbase"] = 100.0
    grid["gen"]["201"]["substation_short_name"] = "DE00"
    grid["gen"]["201"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["201"]["substation_full_name"] = "DE00"
    grid["gen"]["201"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["201"]["substation"] = "DE00_380"
    grid["gen"]["201"]["name"] = "DK_capacity"
    grid["gen"]["201"]["gen_bus"] = 1
    grid["gen"]["201"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["201"]["zone"] = "DE00"

    grid["gen"]["202"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["202"]["source_id"][2] = 202
    grid["gen"]["202"]["index"] = 202
    grid["gen"]["202"]["pmax"] = 742.48
    grid["gen"]["202"]["qmax"] = 5.23
    grid["gen"]["202"]["qmin"] = - 5.23
    grid["gen"]["202"]["installed_capacity"] = 84.56
    grid["gen"]["202"]["mbase"] = 100.0
    grid["gen"]["202"]["substation_short_name"] = "DE00"
    grid["gen"]["202"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["202"]["substation_full_name"] = "DE00"
    grid["gen"]["202"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["202"]["substation"] = "DE00_380"
    grid["gen"]["202"]["name"] = "DK_capacity"
    grid["gen"]["202"]["gen_bus"] = 1
    grid["gen"]["202"]["zone"] = "DE00"
    grid["gen"]["202"]["type"] = "Offshore Wind"
    grid["gen"]["202"]["cost"][1] = 59.0
    grid["gen"]["202"]["C02_emission"] = 0

    grid["gen"]["203"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["203"]["source_id"][2] = 203
    grid["gen"]["203"]["index"] = 203
    grid["gen"]["203"]["pmax"] = 1685.00
    grid["gen"]["203"]["qmax"] = 3.74
    grid["gen"]["203"]["qmin"] = - 3.74
    grid["gen"]["203"]["installed_capacity"] = 600.49
    grid["gen"]["203"]["mbase"] = 100.0
    grid["gen"]["203"]["substation_short_name"] = "DE00"
    grid["gen"]["203"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["203"]["substation_full_name"] = "DE00"
    grid["gen"]["203"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["203"]["substation"] = "DE00_380"
    grid["gen"]["203"]["name"] = "DK_capacity"
    grid["gen"]["203"]["gen_bus"] = 1
    grid["gen"]["203"]["zone"] = "DE00"
    grid["gen"]["203"]["type"] = "Onshore Wind"
    grid["gen"]["203"]["cost"][1] = 25.0
    grid["gen"]["203"]["C02_emission"] = 0

    grid["gen"]["204"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["204"]["source_id"][2] = 204
    grid["gen"]["204"]["index"] = 204
    grid["gen"]["204"]["pmax"] = 40000.00
    grid["gen"]["204"]["qmax"] = 4.96
    grid["gen"]["204"]["qmin"] = - 4.96
    grid["gen"]["204"]["installed_capacity"] = 770.16
    grid["gen"]["204"]["mbase"] = 100.0
    grid["gen"]["204"]["substation_short_name"] = "DE00"
    grid["gen"]["204"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["204"]["substation_full_name"] = "DE00"
    grid["gen"]["204"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["204"]["substation"] = "DE00_380"
    grid["gen"]["204"]["name"] = "DK_capacity"
    grid["gen"]["204"]["gen_bus"] = 1
    grid["gen"]["204"]["zone"] = "DE00"
    grid["gen"]["204"]["type"] = "Solar PV"
    grid["gen"]["204"]["cost"][1] = 18.0
    grid["gen"]["204"]["C02_emission"] = 0

    grid["gen"]["205"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["205"]["source_id"][2] = 205
    grid["gen"]["205"]["index"] = 205
    grid["gen"]["205"]["pmax"] = 650.0
    grid["gen"]["205"]["qmax"] = 4.96
    grid["gen"]["205"]["qmin"] = - 4.96
    grid["gen"]["205"]["installed_capacity"] = 650.0
    grid["gen"]["205"]["mbase"] = 100.0
    grid["gen"]["205"]["substation_short_name"] = "DE00"
    grid["gen"]["205"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["205"]["substation_full_name"] = "DE00"
    grid["gen"]["205"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["205"]["substation"] = "DE00_380"
    grid["gen"]["205"]["name"] = "DK_capacity"
    grid["gen"]["205"]["gen_bus"] = 1
    grid["gen"]["205"]["zone"] = "DE00"
    grid["gen"]["205"]["type"] = "Hard coal old 2 Bio"
    grid["gen"]["205"]["type_tyndp"] = "Hard coal old 2 Bio"
    grid["gen"]["205"]["cost"][1] = 180.0
    grid["gen"]["205"]["C02_emission"] = 0
end

function add_France_2030_AC_DC_paper(grid)
    # Source: https://transparency.entsoe.eu/generation/r2/installedGenerationCapacityAggregation/show?name=&defaultValue=true&viewType=TABLE&areaType=BZN&atch=false&dateTime.dateTime=01.01.2024+00:00|UTC|YEAR&dateTime.endDateTime=01.01.2024+00:00|UTC|YEAR&area.values=CTY|10YFR-RTE------C!BZN|10YFR-RTE------C&productionType.values=B01&productionType.values=B25&productionType.values=B02&productionType.values=B03&productionType.values=B04&productionType.values=B05&productionType.values=B06&productionType.values=B07&productionType.values=B08&productionType.values=B09&productionType.values=B10&productionType.values=B11&productionType.values=B12&productionType.values=B13&productionType.values=B14&productionType.values=B20&productionType.values=B15&productionType.values=B16&productionType.values=B17&productionType.values=B18&productionType.values=B19 
    # Source: https://energy.ec.europa.eu/system/files/2022-08/fr_final_necp_main_en.pdf
    # Source: https://www.enerdata.net/publications/daily-energy-news/france-targets-41-renewables-its-final-energy-mix-2030.html#:~:text=Specifically%2C%20France%20aims%20for%20a,should%20be%20committed%20by%202026.(National Energy and Climate Plan (NECP))
    #grid["bus"]["2"]["zone"] = "FR00"

    # Add FR generators
    grid["gen"]["208"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["208"]["source_id"][2] = 208
    grid["gen"]["208"]["index"] = 208
    grid["gen"]["208"]["pmax"] = 131.33
    grid["gen"]["208"]["qmax"] = 56.0
    grid["gen"]["208"]["qmin"] = - 56.0
    grid["gen"]["208"]["installed_capacity"] = 131.33
    grid["gen"]["208"]["mbase"] = 100.0
    grid["gen"]["208"]["substation_short_name"] = "FR00"
    grid["gen"]["208"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["208"]["substation_full_name"] = "FR00"
    grid["gen"]["208"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["208"]["substation"] = "FR00_380"
    grid["gen"]["208"]["name"] = "FR_capacity"
    grid["gen"]["208"]["gen_bus"] = 1
    grid["gen"]["208"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["208"]["zone"] = "FR00"

    grid["gen"]["209"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["209"]["source_id"][2] = 209
    grid["gen"]["209"]["index"] = 209
    grid["gen"]["209"]["pmax"] = 713.70
    grid["gen"]["209"]["qmax"] = 355.0
    grid["gen"]["209"]["qmin"] = - 355.0
    grid["gen"]["209"]["installed_capacity"] = 713.70
    grid["gen"]["209"]["mbase"] = 100.0
    grid["gen"]["209"]["substation_short_name"] = "FR00"
    grid["gen"]["209"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["209"]["substation_full_name"] = "FR00"
    grid["gen"]["209"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["209"]["substation"] = "FR00_380"
    grid["gen"]["209"]["name"] = "FR_capacity"
    grid["gen"]["209"]["gen_bus"] = 1
    grid["gen"]["209"]["type"] = "Nuclear"
    grid["gen"]["209"]["zone"] = "FR00"
    grid["gen"]["209"]["cost"][1] = 110
    grid["gen"]["209"]["C02_emission"] = 0

    grid["gen"]["210"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["210"]["source_id"][2] = 210
    grid["gen"]["210"]["index"] = 210
    grid["gen"]["210"]["pmax"] = 62.0
    grid["gen"]["210"]["qmax"] = 31.0
    grid["gen"]["210"]["qmin"] = - 31.0
    grid["gen"]["210"]["installed_capacity"] = 62.0
    grid["gen"]["210"]["mbase"] = 100.0
    grid["gen"]["210"]["substation_short_name"] = "FR00"
    grid["gen"]["210"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["210"]["substation_full_name"] = "FR00"
    grid["gen"]["210"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["210"]["substation"] = "FR00_380"
    grid["gen"]["210"]["name"] = "FR_capacity"
    grid["gen"]["210"]["gen_bus"] = 1
    grid["gen"]["210"]["zone"] = "FR00"
    grid["gen"]["210"]["type"] = "Offshore Wind"
    grid["gen"]["210"]["cost"][1] = 59
    grid["gen"]["210"]["C02_emission"] = 0

    grid["gen"]["211"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["211"]["source_id"][2] = 211
    grid["gen"]["211"]["index"] = 211
    grid["gen"]["211"]["pmax"] = 347.0
    grid["gen"]["211"]["qmax"] = 173.5
    grid["gen"]["211"]["qmin"] = - 173.5
    grid["gen"]["211"]["installed_capacity"] = 347.0
    grid["gen"]["211"]["mbase"] = 100.0
    grid["gen"]["211"]["substation_short_name"] = "FR00"
    grid["gen"]["211"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["211"]["substation_full_name"] = "FR00"
    grid["gen"]["211"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["211"]["substation"] = "FR00_380"
    grid["gen"]["211"]["name"] = "FR_capacity"
    grid["gen"]["211"]["gen_bus"] = 1
    grid["gen"]["211"]["zone"] = "FR00"
    grid["gen"]["211"]["type"] = "Onshore Wind"
    grid["gen"]["211"]["cost"][1] = 25
    grid["gen"]["211"]["C02_emission"] = 0

    grid["gen"]["212"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["212"]["source_id"][2] = 212
    grid["gen"]["212"]["index"] = 212
    grid["gen"]["212"]["pmax"] = 540.0
    grid["gen"]["212"]["qmax"] = 270.0
    grid["gen"]["212"]["qmin"] = - 270.0
    grid["gen"]["212"]["installed_capacity"] = 540.0
    grid["gen"]["212"]["mbase"] = 100.0
    grid["gen"]["212"]["substation_short_name"] = "FR00"
    grid["gen"]["212"]["substation_short_name_kV"] = "FR00_380"
    grid["gen"]["212"]["substation_full_name"] = "FR00"
    grid["gen"]["212"]["substation_full_name_kV"] = "FR00_380"
    grid["gen"]["212"]["substation"] = "FR00_380"
    grid["gen"]["212"]["name"] = "FR_capacity"
    grid["gen"]["212"]["gen_bus"] = 1
    grid["gen"]["212"]["zone"] = "FR00"
    grid["gen"]["212"]["type"] = "Solar PV"
    grid["gen"]["212"]["cost"][1] = 18
    grid["gen"]["212"]["C02_emission"] = 0

    # Add FR load
    grid["load"]["3"] = deepcopy(grid["load"]["1"])
    grid["load"]["3"]["source_id"][2] = 3
    grid["load"]["3"]["index"] = 3
    grid["load"]["3"]["load_bus"] = 2 
    grid["load"]["3"]["pmax"] = 450.0
    grid["load"]["3"]["qmax"] = 220.0
    grid["load"]["3"]["qmin"] = - 220.0
    grid["load"]["3"]["installed_capacity"] = 450.0
    grid["load"]["3"]["mbase"] = 100.0
    grid["load"]["3"]["zone"] = "FR00"
    grid["load"]["3"]["full_name"] = "FR_aggregated"
    grid["load"]["3"]["full_name_kV"] = "FR_aggregated_380"
    grid["load"]["3"]["name"] = "FR_aggregated_380"
    grid["load"]["3"]["name_no_kV"] = "FR_aggregated"
end 

function add_Germany_2030_AC_DC_paper(grid)
    # Source: 
    
    # Add FR generators
    grid["gen"]["201"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["201"]["source_id"][2] = 201
    grid["gen"]["201"]["index"] = 201
    grid["gen"]["201"]["pmax"] = 463.30
    grid["gen"]["201"]["qmax"] = 181.65
    grid["gen"]["201"]["qmin"] = - 181.65
    grid["gen"]["201"]["installed_capacity"] = 463.30
    grid["gen"]["201"]["mbase"] = 100.0
    grid["gen"]["201"]["substation_short_name"] = "DE00"
    grid["gen"]["201"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["201"]["substation_full_name"] = "DE00"
    grid["gen"]["201"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["201"]["substation"] = "DE00_380"
    grid["gen"]["201"]["name"] = "DK_capacity"
    grid["gen"]["201"]["gen_bus"] = 1
    grid["gen"]["201"]["type"] = "Gas CCGT old 2 Bio"
    grid["gen"]["201"]["zone"] = "DE00"

    grid["gen"]["202"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["202"]["source_id"][2] = 202
    grid["gen"]["202"]["index"] = 202
    grid["gen"]["202"]["pmax"] = 84.56
    grid["gen"]["202"]["qmax"] = 5.23
    grid["gen"]["202"]["qmin"] = - 5.23
    grid["gen"]["202"]["installed_capacity"] = 84.56
    grid["gen"]["202"]["mbase"] = 100.0
    grid["gen"]["202"]["substation_short_name"] = "DE00"
    grid["gen"]["202"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["202"]["substation_full_name"] = "DE00"
    grid["gen"]["202"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["202"]["substation"] = "DE00_380"
    grid["gen"]["202"]["name"] = "DK_capacity"
    grid["gen"]["202"]["gen_bus"] = 1
    grid["gen"]["202"]["zone"] = "DE00"
    grid["gen"]["202"]["type"] = "Offshore Wind"
    grid["gen"]["202"]["cost"][1] = 59.0
    grid["gen"]["202"]["C02_emission"] = 0

    grid["gen"]["203"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["203"]["source_id"][2] = 203
    grid["gen"]["203"]["index"] = 203
    grid["gen"]["203"]["pmax"] = 600.49
    grid["gen"]["203"]["qmax"] = 3.74
    grid["gen"]["203"]["qmin"] = - 3.74
    grid["gen"]["203"]["installed_capacity"] = 600.49
    grid["gen"]["203"]["mbase"] = 100.0
    grid["gen"]["203"]["substation_short_name"] = "DE00"
    grid["gen"]["203"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["203"]["substation_full_name"] = "DE00"
    grid["gen"]["203"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["203"]["substation"] = "DE00_380"
    grid["gen"]["203"]["name"] = "DK_capacity"
    grid["gen"]["203"]["gen_bus"] = 1
    grid["gen"]["203"]["zone"] = "DE00"
    grid["gen"]["203"]["type"] = "Onshore Wind"
    grid["gen"]["203"]["cost"][1] = 25.0
    grid["gen"]["203"]["C02_emission"] = 0

    grid["gen"]["204"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["204"]["source_id"][2] = 204
    grid["gen"]["204"]["index"] = 204
    grid["gen"]["204"]["pmax"] = 770.16
    grid["gen"]["204"]["qmax"] = 4.96
    grid["gen"]["204"]["qmin"] = - 4.96
    grid["gen"]["204"]["installed_capacity"] = 770.16
    grid["gen"]["204"]["mbase"] = 100.0
    grid["gen"]["204"]["substation_short_name"] = "DE00"
    grid["gen"]["204"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["204"]["substation_full_name"] = "DE00"
    grid["gen"]["204"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["204"]["substation"] = "DE00_380"
    grid["gen"]["204"]["name"] = "DK_capacity"
    grid["gen"]["204"]["gen_bus"] = 1
    grid["gen"]["204"]["zone"] = "DE00"
    grid["gen"]["204"]["type"] = "Solar PV"
    grid["gen"]["204"]["cost"][1] = 18.0
    grid["gen"]["204"]["C02_emission"] = 0

    grid["gen"]["205"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["205"]["source_id"][2] = 205
    grid["gen"]["205"]["index"] = 205
    grid["gen"]["205"]["pmax"] = 650.0
    grid["gen"]["205"]["qmax"] = 4.96
    grid["gen"]["205"]["qmin"] = - 4.96
    grid["gen"]["205"]["installed_capacity"] = 650.0
    grid["gen"]["205"]["mbase"] = 100.0
    grid["gen"]["205"]["substation_short_name"] = "DE00"
    grid["gen"]["205"]["substation_short_name_kV"] = "DE00_380"
    grid["gen"]["205"]["substation_full_name"] = "DE00"
    grid["gen"]["205"]["substation_full_name_kV"] = "DE00_380"
    grid["gen"]["205"]["substation"] = "DE00_380"
    grid["gen"]["205"]["name"] = "DK_capacity"
    grid["gen"]["205"]["gen_bus"] = 1
    grid["gen"]["205"]["zone"] = "DE00"
    grid["gen"]["205"]["type"] = "Hard coal old 2 Bio"
    grid["gen"]["205"]["type_tyndp"] = "Hard coal old 2 Bio"
    grid["gen"]["205"]["cost"][1] = 180.0
    grid["gen"]["205"]["C02_emission"] = 0
end


function add_parallel_lines_onshore_BE(grid)    
    grid["bus"]["260"] = deepcopy(grid["bus"]["26"])
    grid["bus"]["260"]["bus_i"] = 260
    grid["bus"]["260"]["bus_type"] = 2
    grid["bus"]["260"]["source_id"][2] = 260
    grid["bus"]["260"]["index"] = 260
    grid["bus"]["260"]["lat"] = 51.263
    grid["bus"]["260"]["lon"] = 3.201 
    grid["bus"]["260"]["full_name"] = "GEZELLE-MERCATOR"
    grid["bus"]["260"]["full_name_kV"] = "GEZELLE-MERCATOR_380"
    grid["bus"]["260"]["name"] = "GEZELLE-MERCATOR_380"
    grid["bus"]["260"]["name_no_kV"] = "GEZELLE-MERCATOR"
    grid["bus"]["260"]["zone"] = "BE00"

    grid["bus"]["261"] = deepcopy(grid["bus"]["26"])
    grid["bus"]["261"]["bus_i"] = 261
    grid["bus"]["261"]["bus_type"] = 2
    grid["bus"]["261"]["source_id"][2] = 261
    grid["bus"]["261"]["index"] = 261
    grid["bus"]["261"]["lat"] = 51.263
    grid["bus"]["261"]["lon"] = 3.201 
    grid["bus"]["261"]["full_name"] = "GEZELLE-VENTILUS-BDH"
    grid["bus"]["261"]["full_name_kV"] = "GEZELLE-VENTILUS-BDH_380"
    grid["bus"]["261"]["name"] = "GEZELLE-VENTILUS-BDH_380"
    grid["bus"]["261"]["name_no_kV"] = "GEZELLE-VENTILUS-BDH"
    grid["bus"]["261"]["zone"] = "BE00"
    
    grid["branch"]["260"] = deepcopy(grid["branch"]["1"])
    grid["branch"]["260"]["source_id"][2] = 260
    grid["branch"]["260"]["interconnection"] = false
    grid["branch"]["260"]["index"] = 260
    grid["branch"]["260"]["f_bus"] = 26 
    grid["branch"]["260"]["t_bus"] = 260 
    grid["branch"]["260"]["t_bus_name_kV"]      = "GEZELLE-MERCATOR_380"
    grid["branch"]["260"]["t_bus_full_name_kV"] = "GEZELLE-MERCATOR_380"
    grid["branch"]["260"]["t_bus_full_name"]    = "GEZELLE-MERCATOR"
    grid["branch"]["260"]["t_bus_name"]         = "GEZELLE-MERCATOR"

    grid["branch"]["261"] = deepcopy(grid["branch"]["1"])
    grid["branch"]["261"]["source_id"][2] = 261
    grid["branch"]["261"]["interconnection"] = false
    grid["branch"]["261"]["index"] = 261
    grid["branch"]["261"]["f_bus"] = 26 
    grid["branch"]["261"]["t_bus"] = 261 
    grid["branch"]["261"]["t_bus_name_kV"]      = "GEZELLE-VENTILUS-BDH_380"
    grid["branch"]["261"]["t_bus_full_name_kV"] = "GEZELLE-VENTILUS-BDH_380"
    grid["branch"]["261"]["t_bus_full_name"]    = "GEZELLE-VENTILUS-BDH"
    grid["branch"]["261"]["t_bus_name"]         = "GEZELLE-VENTILUS-BDH"

    grid["branch"]["262"] = deepcopy(grid["branch"]["1"])
    grid["branch"]["262"]["source_id"][2] = 262
    grid["branch"]["262"]["interconnection"] = false
    grid["branch"]["262"]["index"] = 262
    grid["branch"]["262"]["f_bus"] = 260 
    grid["branch"]["262"]["f_bus_name_kV"]      = "GEZELLE-MERCATOR_380"
    grid["branch"]["262"]["f_bus_full_name_kV"] = "GEZELLE-MERCATOR_380"
    grid["branch"]["262"]["f_bus_full_name"]    = "GEZELLE-MERCATOR"
    grid["branch"]["262"]["f_bus_name"]         = "GEZELLE-MERCATOR"

    grid["branch"]["263"] = deepcopy(grid["branch"]["1"])
    grid["branch"]["263"]["source_id"][2] = 263
    grid["branch"]["263"]["interconnection"] = false
    grid["branch"]["263"]["index"] = 263
    grid["branch"]["263"]["f_bus"] = 261 
    grid["branch"]["263"]["f_bus_name_kV"]      = "GEZELLE-VENTILUS-BDH_380"
    grid["branch"]["263"]["f_bus_full_name_kV"] = "GEZELLE-VENTILUS-BDH_380"
    grid["branch"]["263"]["f_bus_full_name"]    = "GEZELLE-VENTILUS-BDH"
    grid["branch"]["263"]["f_bus_name"]         = "GEZELLE-VENTILUS-BDH"

    delete!(grid["branch"],"1")
end

function add_energy_island_denmark(grid)
    # Denmark zonal model
    grid["bus"]["1380"] = deepcopy(grid["bus"]["26"])
    grid["bus"]["1380"]["bus_i"] = 1380
    grid["bus"]["1380"]["bus_type"] = 2
    grid["bus"]["1380"]["source_id"][2] = 1380
    grid["bus"]["1380"]["index"] = 1380
    grid["bus"]["1380"]["lat"] = 55.937774
    grid["bus"]["1380"]["lon"] = 8.523240 
    grid["bus"]["1380"]["full_name"] = "DK_aggregated"
    grid["bus"]["1380"]["full_name_kV"] = "DK_aggregated_380"
    grid["bus"]["1380"]["name"] = "DK_aggregated_380"
    grid["bus"]["1380"]["name_no_kV"] = "DK_aggregated"
    grid["bus"]["1380"]["zone"] = "DKW1"

    grid["bus"]["1381"] = deepcopy(grid["bus"]["26"])
    grid["bus"]["1381"]["bus_i"] = 1381
    grid["bus"]["1381"]["bus_type"] = 2
    grid["bus"]["1381"]["source_id"][2] = 1381
    grid["bus"]["1381"]["index"] = 1381
    grid["bus"]["1381"]["lat"] = 55.348421
    grid["bus"]["1381"]["lon"] = 6.223355 
    grid["bus"]["1381"]["full_name"] = "DK_OFW_1381"
    grid["bus"]["1381"]["full_name_kV"] = "DK_OFW_1381_220"
    grid["bus"]["1381"]["name"] = "DK_OFW_1381_220"
    grid["bus"]["1381"]["name_no_kV"] = "DK_OFW_1381"
    grid["bus"]["1381"]["zone"] = "DKW1"

    grid["bus"]["1382"] = deepcopy(grid["bus"]["26"])
    grid["bus"]["1382"]["bus_i"] = 1382
    grid["bus"]["1382"]["bus_type"] = 2
    grid["bus"]["1382"]["source_id"][2] = 1382
    grid["bus"]["1382"]["index"] = 1382
    grid["bus"]["1382"]["lat"] = 55.167871
    grid["bus"]["1382"]["lon"] = 7.044743
    grid["bus"]["1382"]["full_name"] = "DK_OFW_1382"
    grid["bus"]["1382"]["full_name_kV"] = "DK_OFW_1382_220"
    grid["bus"]["1382"]["name"] = "DK_OFW_1382_220"
    grid["bus"]["1382"]["name_no_kV"] = "DK_OFW_1382"
    grid["bus"]["1382"]["zone"] = "DKW1"

    grid["bus"]["420"] = deepcopy(grid["bus"]["26"])
    grid["bus"]["420"]["bus_i"] = 420
    grid["bus"]["420"]["bus_type"] = 2
    grid["bus"]["420"]["source_id"][2] = 420
    grid["bus"]["420"]["index"] = 420
    grid["bus"]["420"]["lat"] = 51.158495
    grid["bus"]["420"]["lon"] = 3.889211
    grid["bus"]["420"]["full_name"] = "BE_Phase_3"
    grid["bus"]["420"]["full_name_kV"] = "BE_Phase_3_380"
    grid["bus"]["420"]["name"] = "BE_Phase_3_380"
    grid["bus"]["420"]["name_no_kV"] = "BE_Phase_3"
    grid["bus"]["420"]["zone"] = "BE00"


    # Add DK generators
    grid["gen"]["208"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["208"]["source_id"][2] = 208
    grid["gen"]["208"]["index"] = 208
    grid["gen"]["208"]["pmax"] = 40.03
    grid["gen"]["208"]["qmax"] = 20.0
    grid["gen"]["208"]["qmin"] = - 20.0
    grid["gen"]["208"]["installed_capacity"] = 40.03
    grid["gen"]["208"]["mbase"] = 100.0
    grid["gen"]["208"]["substation_short_name"] = "DKW1"
    grid["gen"]["208"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["208"]["substation_full_name"] = "DKW1"
    grid["gen"]["208"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["208"]["substation"] = "DKW1_380"
    grid["gen"]["208"]["name"] = "DK_capacity"
    grid["gen"]["208"]["gen_bus"] = 1380
    grid["gen"]["208"]["zone"] = "DKW1"

    grid["gen"]["209"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["209"]["source_id"][2] = 209
    grid["gen"]["209"]["index"] = 209
    grid["gen"]["209"]["pmax"] = 0.0
    grid["gen"]["209"]["qmax"] = 0.0
    grid["gen"]["209"]["qmin"] = - 0.0
    grid["gen"]["209"]["installed_capacity"] = 0.0
    grid["gen"]["209"]["mbase"] = 100.0
    grid["gen"]["209"]["substation_short_name"] = "DKW1"
    grid["gen"]["209"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["209"]["substation_full_name"] = "DKW1"
    grid["gen"]["209"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["209"]["substation"] = "DKW1_380"
    grid["gen"]["209"]["name"] = "DK_capacity"
    grid["gen"]["209"]["gen_bus"] = 1380
    grid["gen"]["209"]["type"] = "Nuclear"
    grid["gen"]["209"]["zone"] = "DKW1"

    grid["gen"]["210"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["210"]["source_id"][2] = 210
    grid["gen"]["210"]["index"] = 210
    grid["gen"]["210"]["pmax"] = 39.55
    grid["gen"]["210"]["qmax"] = 0.0
    grid["gen"]["210"]["qmin"] = - 0.0
    grid["gen"]["210"]["installed_capacity"] = 39.55
    grid["gen"]["210"]["mbase"] = 100.0
    grid["gen"]["210"]["substation_short_name"] = "DKW1"
    grid["gen"]["210"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["210"]["substation_full_name"] = "DKW1"
    grid["gen"]["210"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["210"]["substation"] = "DKW1_380"
    grid["gen"]["210"]["name"] = "DK_capacity"
    grid["gen"]["210"]["gen_bus"] = 1380
    grid["gen"]["210"]["zone"] = "DKW1"
    grid["gen"]["210"]["type"] = "Offshore Wind"

    grid["gen"]["211"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["211"]["source_id"][2] = 211
    grid["gen"]["211"]["index"] = 211
    grid["gen"]["211"]["pmax"] = 12.78
    grid["gen"]["211"]["qmax"] = 6.0
    grid["gen"]["211"]["qmin"] = - 6.0
    grid["gen"]["211"]["installed_capacity"] = 12.78
    grid["gen"]["211"]["mbase"] = 100.0
    grid["gen"]["211"]["substation_short_name"] = "DKW1"
    grid["gen"]["211"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["211"]["substation_full_name"] = "DKW1"
    grid["gen"]["211"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["211"]["substation"] = "DKW1_380"
    grid["gen"]["211"]["name"] = "DK_capacity"
    grid["gen"]["211"]["gen_bus"] = 1380
    grid["gen"]["211"]["zone"] = "DKW1"
    grid["gen"]["211"]["type"] = "Onshore Wind"

    grid["gen"]["212"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["212"]["source_id"][2] = 212
    grid["gen"]["212"]["index"] = 212
    grid["gen"]["212"]["pmax"] = 17.02
    grid["gen"]["212"]["qmax"] = 8.51
    grid["gen"]["212"]["qmin"] = - 8.51
    grid["gen"]["212"]["installed_capacity"] = 17.02
    grid["gen"]["212"]["mbase"] = 100.0
    grid["gen"]["212"]["substation_short_name"] = "DKW1"
    grid["gen"]["212"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["212"]["substation_full_name"] = "DKW1"
    grid["gen"]["212"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["212"]["substation"] = "DKW1_380"
    grid["gen"]["212"]["name"] = "DK_capacity"
    grid["gen"]["212"]["gen_bus"] = 1380
    grid["gen"]["212"]["zone"] = "DKW1"
    grid["gen"]["212"]["type"] = "Solar PV"

    # DK Offshore wind farms
    grid["gen"]["1381"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["1381"]["source_id"][2] = 1381
    grid["gen"]["1381"]["index"] = 1381
    grid["gen"]["1381"]["pmax"] = 14.00
    grid["gen"]["1381"]["qmax"] = 7.00
    grid["gen"]["1381"]["qmin"] = - 7.00
    grid["gen"]["1381"]["installed_capacity"] = 14.00
    grid["gen"]["1381"]["mbase"] = 100.0
    grid["gen"]["1381"]["substation_short_name"] = "DKW1"
    grid["gen"]["1381"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["1381"]["substation_full_name"] = "DKW1"
    grid["gen"]["1381"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["1381"]["substation"] = "DKW1_380"
    grid["gen"]["1381"]["name"] = "DK_capacity"
    grid["gen"]["1381"]["gen_bus"] = 1381
    grid["gen"]["1381"]["zone"] = "DKW1"
    grid["gen"]["1381"]["type"] = "Offshore Wind"

    grid["gen"]["1382"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["1382"]["source_id"][2] = 1382
    grid["gen"]["1382"]["index"] = 1382
    grid["gen"]["1382"]["pmax"] = 20.00
    grid["gen"]["1382"]["qmax"] = 10.00
    grid["gen"]["1382"]["qmin"] = - 10.00
    grid["gen"]["1382"]["installed_capacity"] = 20.00
    grid["gen"]["1382"]["mbase"] = 100.0
    grid["gen"]["1382"]["substation_short_name"] = "DKW1"
    grid["gen"]["1382"]["substation_short_name_kV"] = "DKW1_380"
    grid["gen"]["1382"]["substation_full_name"] = "DKW1"
    grid["gen"]["1382"]["substation_full_name_kV"] = "DKW1_380"
    grid["gen"]["1382"]["substation"] = "DKW1_380"
    grid["gen"]["1382"]["name"] = "DK_capacity"
    grid["gen"]["1382"]["gen_bus"] = 1382
    grid["gen"]["1382"]["zone"] = "DKW1"
    grid["gen"]["1382"]["type"] = "Offshore Wind"


    # Add DK load
    grid["load"]["3"] = deepcopy(grid["load"]["1"])
    grid["load"]["3"]["source_id"][2] = 3
    grid["load"]["3"]["index"] = 2
    grid["load"]["3"]["load_bus"] = 1380
    grid["load"]["3"]["pmax"] = 45.0
    grid["load"]["3"]["qmax"] = 22.0
    grid["load"]["3"]["qmin"] = - 22.0
    grid["load"]["3"]["installed_capacity"] = 45.0
    grid["load"]["3"]["mbase"] = 100.0
    grid["load"]["3"]["zone"] = "DKW1"
    grid["load"]["3"]["full_name"] = "DK_aggregated"
    grid["load"]["3"]["full_name_kV"] = "DK_aggregated_380"
    grid["load"]["3"]["name"] = "DK_aggregated_380"
    grid["load"]["3"]["name_no_kV"] = "DK_aggregated"

    # Add DC buses
    # DK switchyard
    grid["busdc"]["10"] = deepcopy(grid["busdc"]["1"])
    grid["busdc"]["10"]["busdc_i"] = 10
    grid["busdc"]["10"]["source_id"][2] = 10
    grid["busdc"]["10"]["index"] = 10
    grid["busdc"]["10"]["lat"] = 52.589515
    grid["busdc"]["10"]["lon"] = 3.173568
    grid["busdc"]["10"]["bus_name"] = "DK_Switchyard_525"
    grid["busdc"]["10"]["zone"] = "DKW1"
    grid["busdc"]["10"]["basekVdc"] = 525

    # DK OFW 1382
    grid["busdc"]["11"] = deepcopy(grid["busdc"]["1"])
    grid["busdc"]["11"]["busdc_i"] = 11
    grid["busdc"]["11"]["source_id"][2] = 11
    grid["busdc"]["11"]["index"] = 11
    grid["busdc"]["11"]["lat"] = 55.167871
    grid["busdc"]["11"]["lon"] = 7.044743 
    grid["busdc"]["11"]["bus_name"] = "DK_OFW_1382"
    grid["busdc"]["11"]["zone"] = "DKW1"
    grid["busdc"]["11"]["basekVdc"] = 525

    # DK OFW 1381
    grid["busdc"]["12"] = deepcopy(grid["busdc"]["1"])
    grid["busdc"]["12"]["busdc_i"] = 12
    grid["busdc"]["12"]["source_id"][2] = 12
    grid["busdc"]["12"]["index"] = 12
    grid["busdc"]["12"]["lat"] = 55.348421
    grid["busdc"]["12"]["lon"] = 6.223355 
    grid["busdc"]["12"]["bus_name"] = "DK_OFW_1381"
    grid["busdc"]["12"]["zone"] = "DKW1"
    grid["busdc"]["12"]["basekVdc"] = 525

    # DK Onshore
    grid["busdc"]["13"] = deepcopy(grid["busdc"]["1"])
    grid["busdc"]["13"]["busdc_i"] = 13
    grid["busdc"]["13"]["source_id"][2] = 13
    grid["busdc"]["13"]["index"] = 13
    grid["busdc"]["13"]["lat"] = 55.937774
    grid["busdc"]["13"]["lon"] = 8.523240 
    grid["busdc"]["13"]["bus_name"] = "DK_Onshore"
    grid["busdc"]["13"]["zone"] = "DKW1"
    grid["busdc"]["13"]["basekVdc"] = 525

    # BE Onshore - Phase 3
    grid["busdc"]["14"] = deepcopy(grid["busdc"]["1"])
    grid["busdc"]["14"]["busdc_i"] = 14
    grid["busdc"]["14"]["source_id"][2] = 14
    grid["busdc"]["14"]["index"] = 14
    grid["busdc"]["14"]["lat"] = 51.158495
    grid["busdc"]["14"]["lon"] = 3.889211 
    grid["busdc"]["14"]["bus_name"] = "BE_Onshore_Phase_3"
    grid["busdc"]["14"]["zone"] = "BE00"
    grid["busdc"]["14"]["basekVdc"] = 525

    n_conv_dc = 8
    for i in 1:4
        grid["convdc"]["$(n_conv_dc+i)"] = deepcopy(grid["convdc"]["1"])
        grid["convdc"]["$(n_conv_dc+i)"]["Imax"] = 25
        grid["convdc"]["$(n_conv_dc+i)"]["source_id"][2] = deepcopy(n_conv_dc+i)
        grid["convdc"]["$(n_conv_dc+i)"]["index"] = deepcopy(n_conv_dc+i)
    end

    grid["convdc"]["9"]["busdc_i"] = 11
    grid["convdc"]["9"]["busac_i"] = 1382
    grid["convdc"]["9"]["Pacmax"] = 20.0
    grid["convdc"]["9"]["Pacmin"] = - 20.0
    grid["convdc"]["9"]["Pacrated"] = 20.0

    grid["convdc"]["10"]["busdc_i"] = 12
    grid["convdc"]["10"]["busac_i"] = 1381
    grid["convdc"]["10"]["Pacmax"] = 14.0
    grid["convdc"]["10"]["Pacmin"] = - 14.0
    grid["convdc"]["10"]["Pacrated"] = 14.0

    grid["convdc"]["11"]["busdc_i"] = 13
    grid["convdc"]["11"]["busac_i"] = 1380
    grid["convdc"]["11"]["Pacmax"] = 14.0
    grid["convdc"]["11"]["Pacmin"] = - 14.0
    grid["convdc"]["11"]["Pacrated"] = 14.0

    grid["convdc"]["12"]["busdc_i"] = 14
    grid["convdc"]["12"]["busac_i"] = 420
    grid["convdc"]["12"]["Pacmax"] = 14.0
    grid["convdc"]["12"]["Pacmin"] = - 14.0
    grid["convdc"]["12"]["Pacrated"] = 14.0

    n_branch_dc = 6
    for i in 1:4
        grid["branchdc"]["$(n_branch_dc+i)"] = deepcopy(grid["branchdc"]["1"])
        grid["branchdc"]["$(n_branch_dc+i)"]["source_id"][2] = deepcopy(n_branch_dc+i)
        grid["branchdc"]["$(n_branch_dc+i)"]["index"] = deepcopy(n_branch_dc+i)
    end
    grid["branchdc"]["7"]["r"] = 2.6e-5
    grid["branchdc"]["7"]["rateA"] = 20.0
    grid["branchdc"]["7"]["rateB"] = 20.0
    grid["branchdc"]["7"]["rateC"] = 20.0
    grid["branchdc"]["7"]["fbusdc"] = 6
    grid["branchdc"]["7"]["tbusdc"] = 10
    grid["branchdc"]["7"]["HVDC_link"] = "BE Switchyard -> DK Switchyard" 

    grid["branchdc"]["8"]["r"] = 2.6e-5
    grid["branchdc"]["8"]["rateA"] = 20.0
    grid["branchdc"]["8"]["rateB"] = 20.0
    grid["branchdc"]["8"]["rateC"] = 20.0
    grid["branchdc"]["8"]["fbusdc"] = 10
    grid["branchdc"]["8"]["tbusdc"] = 11
    grid["branchdc"]["8"]["HVDC_link"] = "DK Switchyard -> DK OFW 1382" 

    grid["branchdc"]["9"]["r"] = 2.6e-5
    grid["branchdc"]["9"]["rateA"] = 20.0
    grid["branchdc"]["9"]["rateB"] = 20.0
    grid["branchdc"]["9"]["rateC"] = 20.0
    grid["branchdc"]["9"]["fbusdc"] = 10
    grid["branchdc"]["9"]["tbusdc"] = 14
    grid["branchdc"]["9"]["HVDC_link"] = "DK Switchyard -> BE_Onshore_Phase_3" 

    grid["branchdc"]["10"]["r"] = 2.6e-5
    grid["branchdc"]["10"]["rateA"] = 14.0
    grid["branchdc"]["10"]["rateB"] = 14.0
    grid["branchdc"]["10"]["rateC"] = 14.0
    grid["branchdc"]["10"]["fbusdc"] = 12
    grid["branchdc"]["10"]["tbusdc"] = 13
    grid["branchdc"]["10"]["HVDC_link"] = "DK OFW 1381 -> DK_Onshore" 

    # Adding branches to the energy island
    n_branches = 200
    for i in 1:2
        grid["branch"]["$(n_branches+i)"] = deepcopy(grid["branch"]["1"])
        grid["branch"]["$(n_branches+i)"]["source_id"][2] = deepcopy(n_branches+i)
        grid["branch"]["$(n_branches+i)"]["interconnection"] = true
        grid["branch"]["$(n_branches+i)"]["index"] = deepcopy(n_branches+i)
        grid["branch"]["$(n_branches+i)"]["rate_a"] = 20.0
        delete!(grid["branch"]["$(n_branches+i)"],"f_bus_name_kV")
        delete!(grid["branch"]["$(n_branches+i)"],"t_bus_name_kV")
        delete!(grid["branch"]["$(n_branches+i)"],"f_bus_full_name_kV")
        delete!(grid["branch"]["$(n_branches+i)"],"t_bus_full_name_kV")
        delete!(grid["branch"]["$(n_branches+i)"],"f_bus_full_name")
        delete!(grid["branch"]["$(n_branches+i)"],"t_bus_full_name")
        delete!(grid["branch"]["$(n_branches+i)"],"f_bus_name")
        delete!(grid["branch"]["$(n_branches+i)"],"t_bus_name")
    end
    # Add values for DK
    # AC connections DK 1382 - 1381
    for i in 1:1
        grid["branch"]["$(n_branches+i)"]["f_bus"] = 1381 # EI_AC_1_220
        grid["branch"]["$(n_branches+i)"]["t_bus"] = 1382 # GEZELLE_380 
        grid["branch"]["$(n_branches+i)"]["f_bus_full_name_kV"] = "DK_OFW_1381_220"
        grid["branch"]["$(n_branches+i)"]["f_bus_name_kV"] = "DK_OFW_1381_220"
        grid["branch"]["$(n_branches+i)"]["f_bus_full_name"] = "DK_OFW_1381"
        grid["branch"]["$(n_branches+i)"]["f_bus_name"] = "DK_OFW_1381"
        grid["branch"]["$(n_branches+i)"]["t_bus_full_name_kV"] = "DK_OFW_1382_220"
        grid["branch"]["$(n_branches+i)"]["t_bus_name_kV"] = "DK_OFW_1382_220"
        grid["branch"]["$(n_branches+i)"]["t_bus_full_name"] = "DK_OFW_1382"
        grid["branch"]["$(n_branches+i)"]["t_bus_name"] = "DK_OFW_1382"
    end
    # AC connections withing the energy island -> this is the switch
    for i in 2:2
        grid["branch"]["$(n_branches+i)"]["rate_a"] = 99.99
        grid["branch"]["$(n_branches+i)"]["ZIL"] = true
        grid["branch"]["$(n_branches+i)"]["f_bus"] = 420 # BE
        grid["branch"]["$(n_branches+i)"]["t_bus"] = 1 # EI_AC_2_220 
        grid["branch"]["$(n_branches+i)"]["f_bus_full_name_kV"] = "BE_Onshore_Phase_3"
        grid["branch"]["$(n_branches+i)"]["f_bus_name_kV"] = "BE_Onshore_Phase_3"
        grid["branch"]["$(n_branches+i)"]["f_bus_full_name"] = "BE_Onshore_Phase_3"
        grid["branch"]["$(n_branches+i)"]["f_bus_name"] = "BE_Onshore_Phase_3"
        grid["branch"]["$(n_branches+i)"]["t_bus_full_name_kV"] = "BE_aggregated"
        grid["branch"]["$(n_branches+i)"]["t_bus_name_kV"] = "BE_aggregated"
        grid["branch"]["$(n_branches+i)"]["t_bus_full_name"] = "BE_aggregated"
        grid["branch"]["$(n_branches+i)"]["t_bus_name"] = "BE_aggregated"
    end
end 

function add_energy_island_uk_with_wind_turbine(grid)
    grid["bus"]["128"]["zone"] = "UK00"

    grid["bus"]["1280"] = deepcopy(grid["bus"]["26"])
    grid["bus"]["1280"]["bus_i"] = 1280
    grid["bus"]["1280"]["bus_type"] = 2
    grid["bus"]["1280"]["source_id"][2] = 1280
    grid["bus"]["1280"]["index"] = 1280
    grid["bus"]["1280"]["lat"] = 51.751972
    grid["bus"]["1280"]["lon"] = 1.897911 
    grid["bus"]["1280"]["full_name"] = "EI_AC_2"
    grid["bus"]["1280"]["full_name_kV"] = "EI_AC_2_220"
    grid["bus"]["1280"]["name"] = "EI_AC_2_220"
    grid["bus"]["1280"]["name_no_kV"] = "EI_AC_2"
    grid["bus"]["1280"]["zone"] = "UK00"

    # Add bus dc for UK wind farm
    grid["busdc"]["9"] = deepcopy(grid["busdc"]["1"])
    grid["busdc"]["9"]["busdc_i"] = 9
    grid["busdc"]["9"]["source_id"][2] = 9
    grid["busdc"]["9"]["index"] = 9
    grid["busdc"]["9"]["lat"] = 51.751972
    grid["busdc"]["9"]["lon"] = 1.897911
    grid["busdc"]["9"]["bus_name"] = "UK Switchyard_525"
    grid["busdc"]["9"]["zone"] = "UK00"
    grid["busdc"]["9"]["basekVdc"] = 525

    n_branch_dc = 5
    for i in 1:1
        grid["branchdc"]["$(n_branch_dc+i)"] = deepcopy(grid["branchdc"]["1"])
        grid["branchdc"]["$(n_branch_dc+i)"]["source_id"][2] = deepcopy(n_branch_dc+i)
        grid["branchdc"]["$(n_branch_dc+i)"]["index"] = deepcopy(n_branch_dc+i)
    end
    grid["branchdc"]["6"]["r"] = 0.1
    grid["branchdc"]["6"]["rateA"] = 14.0
    grid["branchdc"]["6"]["rateB"] = 14.0
    grid["branchdc"]["6"]["rateC"] = 14.0
    grid["branchdc"]["6"]["fbusdc"] = 9
    grid["branchdc"]["6"]["tbusdc"] = 7
    grid["branchdc"]["6"]["HVDC_link"] = "UK Switchyard -> UK offshore" 

    grid["branchdc"]["4"]["fbusdc"] = 9
    grid["branchdc"]["4"]["tbusdc"] = 6

    n_conv_dc = 7
    for i in 1:1
        grid["convdc"]["$(n_conv_dc+i)"] = deepcopy(grid["convdc"]["1"])
        grid["convdc"]["$(n_conv_dc+i)"]["Imax"] = 25
        grid["convdc"]["$(n_conv_dc+i)"]["source_id"][2] = deepcopy(n_conv_dc+i)
        grid["convdc"]["$(n_conv_dc+i)"]["index"] = deepcopy(n_conv_dc+i)
    end

    grid["convdc"]["8"]["busdc_i"] = 9
    grid["convdc"]["8"]["busac_i"] = 1280
    grid["convdc"]["8"]["Pacmax"] = 14.5
    grid["convdc"]["8"]["Pacmin"] = - 14.5
    grid["convdc"]["8"]["Pacrated"] = 14.5


    # Add UK generator
    grid["gen"]["108"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["108"]["source_id"][2] = 108
    grid["gen"]["108"]["index"] = 108
    grid["gen"]["108"]["pmax"] = 435.0
    grid["gen"]["108"]["qmax"] = 218.0
    grid["gen"]["108"]["qmin"] = - 218.0
    grid["gen"]["108"]["installed_capacity"] = 435.0
    grid["gen"]["108"]["mbase"] = 100.0
    grid["gen"]["108"]["substation_short_name"] = "UK00"
    grid["gen"]["108"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["108"]["substation_full_name"] = "UK00"
    grid["gen"]["108"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["108"]["substation"] = "UK00_380"
    grid["gen"]["108"]["name"] = "UK_capacity"
    grid["gen"]["108"]["gen_bus"] = 128
    grid["gen"]["108"]["zone"] = "UK00"

    grid["gen"]["109"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["109"]["source_id"][2] = 109
    grid["gen"]["109"]["index"] = 109
    grid["gen"]["109"]["pmax"] = 59.0
    grid["gen"]["109"]["qmax"] = 29.5
    grid["gen"]["109"]["qmin"] = - 29.5
    grid["gen"]["109"]["installed_capacity"] = 59.0
    grid["gen"]["109"]["mbase"] = 100.0
    grid["gen"]["109"]["substation_short_name"] = "UK00"
    grid["gen"]["109"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["109"]["substation_full_name"] = "UK00"
    grid["gen"]["109"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["109"]["substation"] = "UK00_380"
    grid["gen"]["109"]["name"] = "UK_capacity"
    grid["gen"]["109"]["gen_bus"] = 128
    grid["gen"]["109"]["type"] = "Nuclear"
    grid["gen"]["109"]["zone"] = "UK00"

    grid["gen"]["110"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["110"]["source_id"][2] = 110
    grid["gen"]["110"]["index"] = 110
    grid["gen"]["110"]["pmax"] = 140.0
    grid["gen"]["110"]["qmax"] = 70.0
    grid["gen"]["110"]["qmin"] = - 70.0
    grid["gen"]["110"]["installed_capacity"] = 140.0
    grid["gen"]["110"]["mbase"] = 100.0
    grid["gen"]["110"]["substation_short_name"] = "UK00"
    grid["gen"]["110"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["110"]["substation_full_name"] = "UK00"
    grid["gen"]["110"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["110"]["substation"] = "UK00_380"
    grid["gen"]["110"]["name"] = "UK_capacity"
    grid["gen"]["110"]["gen_bus"] = 128
    grid["gen"]["110"]["zone"] = "UK00"
    grid["gen"]["110"]["type"] = "Offshore Wind"

    grid["gen"]["111"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["111"]["source_id"][2] = 111
    grid["gen"]["111"]["index"] = 111
    grid["gen"]["111"]["pmax"] = 140.0
    grid["gen"]["111"]["qmax"] = 70.0
    grid["gen"]["111"]["qmin"] = - 70.0
    grid["gen"]["111"]["installed_capacity"] = 140.0
    grid["gen"]["111"]["mbase"] = 100.0
    grid["gen"]["111"]["substation_short_name"] = "UK00"
    grid["gen"]["111"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["111"]["substation_full_name"] = "UK00"
    grid["gen"]["111"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["111"]["substation"] = "UK00_380"
    grid["gen"]["111"]["name"] = "UK_capacity"
    grid["gen"]["111"]["gen_bus"] = 128
    grid["gen"]["111"]["zone"] = "UK00"
    grid["gen"]["111"]["type"] = "Onshore Wind"

    grid["gen"]["112"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["112"]["source_id"][2] = 112
    grid["gen"]["112"]["index"] = 112
    grid["gen"]["112"]["pmax"] = 150.0
    grid["gen"]["112"]["qmax"] = 75.0
    grid["gen"]["112"]["qmin"] = - 75.0
    grid["gen"]["112"]["installed_capacity"] = 150.0
    grid["gen"]["112"]["mbase"] = 100.0
    grid["gen"]["112"]["substation_short_name"] = "UK00"
    grid["gen"]["112"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["112"]["substation_full_name"] = "UK00"
    grid["gen"]["112"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["112"]["substation"] = "UK00_380"
    grid["gen"]["112"]["name"] = "UK_capacity"
    grid["gen"]["112"]["gen_bus"] = 128
    grid["gen"]["112"]["zone"] = "UK00"
    grid["gen"]["112"]["type"] = "Solar PV"

    grid["gen"]["1280"] = deepcopy(grid["gen"]["2"])
    grid["gen"]["1280"]["source_id"][2] = 1280
    grid["gen"]["1280"]["index"] = 1280
    grid["gen"]["1280"]["pmax"] = 14.0
    grid["gen"]["1280"]["qmax"] = 0.0
    grid["gen"]["1280"]["qmin"] = - 0.0
    grid["gen"]["1280"]["installed_capacity"] = 14.0
    grid["gen"]["1280"]["mbase"] = 100.0
    grid["gen"]["1280"]["substation_short_name"] = "UK00"
    grid["gen"]["1280"]["substation_short_name_kV"] = "UK00_380"
    grid["gen"]["1280"]["substation_full_name"] = "UK00"
    grid["gen"]["1280"]["substation_full_name_kV"] = "UK00_380"
    grid["gen"]["1280"]["substation"] = "UK00_380"
    grid["gen"]["1280"]["name"] = "UK_offshore_wind"
    grid["gen"]["1280"]["gen_bus"] = 1280
    grid["gen"]["1280"]["zone"] = "UK00"
    grid["gen"]["1280"]["type"] = "Offshore Wind"


    # Add UK load
    grid["load"]["2"] = deepcopy(grid["load"]["1"])
    grid["load"]["2"]["source_id"][2] = 2
    grid["load"]["2"]["index"] = 2
    grid["load"]["2"]["load_bus"] = 128
    grid["load"]["2"]["pmax"] = 450.0
    grid["load"]["2"]["qmax"] = 220.0
    grid["load"]["2"]["qmin"] = - 220.0
    grid["load"]["2"]["installed_capacity"] = 4500.0
    grid["load"]["2"]["mbase"] = 100.0
    grid["load"]["2"]["zone"] = "UK00"
    grid["load"]["2"]["full_name"] = "UK_aggregated"
    grid["load"]["2"]["full_name_kV"] = "UK_aggregated_380"
    grid["load"]["2"]["name"] = "UK_aggregated_380"
    grid["load"]["2"]["name_no_kV"] = "UK_aggregated"
end 
 

function add_switch(data,ac_bus_from,ac_bus_to,pmax)
    n_switch = deepcopy(length(data["switch"]))
    switch_id = n_switch + 1
    data["switch"]["$switch_id"] = Dict{String,Any}()
    data["switch"]["$switch_id"]["f_bus"] = deepcopy(ac_bus_from) # assigning from and to bus to each switch. One switch for each key in the extremes_ZIL
    data["switch"]["$switch_id"]["t_bus"] = deepcopy(ac_bus_to)
    data["switch"]["$switch_id"]["index"] = switch_id
    data["switch"]["$switch_id"]["psw"] = pmax # assuming a maximum active power for the switch
    data["switch"]["$switch_id"]["qsw"] = pmax/2 # assuming a maximum reactive power for the switch
    data["switch"]["$switch_id"]["thermal_rating"] = sqrt(pmax^2+(pmax/2)^2) 
    data["switch"]["$switch_id"]["state"] = 1
    data["switch"]["$switch_id"]["status"] = 1
    data["switch"]["$switch_id"]["source_id"] = []
    push!(data["switch"]["$switch_id"]["source_id"],"switch")
    push!(data["switch"]["$switch_id"]["source_id"],switch_id)
    data["switch"]["$switch_id"]["ZIL"] = true
    data["switch"]["$switch_id"]["maximum_angle"] = pi/6 # 30 degrees
end

function add_dcswitch(data,dc_bus_from,dc_bus_to,pmax)
    n_switch = deepcopy(length(data["dcswitch"]))
    switch_id = n_switch + 1
    data["dcswitch"]["$switch_id"] = Dict{String,Any}()
    data["dcswitch"]["$switch_id"]["f_busdc"] = deepcopy(dc_bus_from) # assigning from and to bus to each switch. One switch for each key in the extremes_ZIL
    data["dcswitch"]["$switch_id"]["t_busdc"] = deepcopy(dc_bus_to)
    data["dcswitch"]["$switch_id"]["index"] = switch_id
    data["dcswitch"]["$switch_id"]["psw"] = pmax # assuming a maximum active power for the switch
    data["dcswitch"]["$switch_id"]["thermal_rating"] = pmax # assuming a maximum active power for the switch
    data["switch"]["$switch_id"]["state"] = 1
    data["switch"]["$switch_id"]["status"] = 1
    data["dcswitch"]["$switch_id"]["source_id"] = []
    push!(data["dcswitch"]["$switch_id"]["source_id"],"dcswitch")
    push!(data["dcswitch"]["$switch_id"]["source_id"],switch_id)
    data["dcswitch"]["$switch_id"]["ZIL"] = true
end

#function add_reactive_power(grid)

function reactive_power_parameters()

    # Reactive power parameters
    BE_grid_energy_island["gen"]["103"] = deepcopy(BE_grid_energy_island["gen"]["101"])
    BE_grid_energy_island["gen"]["103"]["installed_capacity"] = 0.00 
    BE_grid_energy_island["gen"]["103"]["pmax"] = 0.0
    BE_grid_energy_island["gen"]["103"]["mbase"] = 0.0
    BE_grid_energy_island["gen"]["103"]["qmax"] = 3.0
    BE_grid_energy_island["gen"]["103"]["source_id"][2] = 103
    BE_grid_energy_island["gen"]["103"]["name"] = "Q_EI_HVDC"
    BE_grid_energy_island["gen"]["103"]["gen_type"] = "NG"
    BE_grid_energy_island["gen"]["103"]["fuel_type"] = "WKK"
    BE_grid_energy_island["gen"]["103"]["index"] = 103
    BE_grid_energy_island["gen"]["103"]["type"] = "Gas CCGT new"
    BE_grid_energy_island["gen"]["103"]["cost"][1] = 0.0

    BE_grid_energy_island["gen"]["104"] = deepcopy(BE_grid_energy_island["gen"]["102"])
    BE_grid_energy_island["gen"]["104"]["installed_capacity"] = 0.00 
    BE_grid_energy_island["gen"]["104"]["pmax"] = 0.0
    BE_grid_energy_island["gen"]["104"]["mbase"] = 0.0
    BE_grid_energy_island["gen"]["104"]["qmax"] = 3.0
    BE_grid_energy_island["gen"]["104"]["source_id"][2] = 104
    BE_grid_energy_island["gen"]["104"]["name"] = "Q_EI_HVDC"
    BE_grid_energy_island["gen"]["104"]["gen_type"] = "NG"
    BE_grid_energy_island["gen"]["104"]["fuel_type"] = "WKK"
    BE_grid_energy_island["gen"]["104"]["index"] = 104
    BE_grid_energy_island["gen"]["104"]["type"] = "Gas CCGT new"
    BE_grid_energy_island["gen"]["104"]["cost"][1] = 0.0

    BE_grid_energy_island["gen"]["105"] = deepcopy(BE_grid_energy_island["gen"]["101"])
    BE_grid_energy_island["gen"]["105"]["installed_capacity"] = 0.00 
    BE_grid_energy_island["gen"]["105"]["pmax"] = 0.0
    BE_grid_energy_island["gen"]["105"]["mbase"] = 0.0
    BE_grid_energy_island["gen"]["105"]["qmax"] = 4.0
    BE_grid_energy_island["gen"]["105"]["source_id"][2] = 105
    BE_grid_energy_island["gen"]["105"]["name"] = "Q_onshore_HVDC"
    BE_grid_energy_island["gen"]["105"]["substation_full_name"] = deepcopy(BE_grid_energy_island["bus"]["26"]["full_name"])
    BE_grid_energy_island["gen"]["105"]["substation_full_name_kV"] = deepcopy(BE_grid_energy_island["bus"]["26"]["full_name_kV"])
    BE_grid_energy_island["gen"]["105"]["substation_short_name"] = deepcopy(BE_grid_energy_island["bus"]["26"]["name"])
    BE_grid_energy_island["gen"]["105"]["substation_short_name_kV"] = deepcopy(BE_grid_energy_island["bus"]["26"]["name_kV"])
    BE_grid_energy_island["gen"]["105"]["substation"] = deepcopy(BE_grid_energy_island["bus"]["26"]["name"])
    BE_grid_energy_island["gen"]["105"]["gen_bus"] = 26
    BE_grid_energy_island["gen"]["105"]["gen_type"] = "NG"
    BE_grid_energy_island["gen"]["105"]["fuel_type"] = "WKK"
    BE_grid_energy_island["gen"]["105"]["index"] = 105 
    BE_grid_energy_island["gen"]["105"]["type"] = "Gas CCGT new"
    BE_grid_energy_island["gen"]["105"]["cost"][1] = 0.0

    BE_grid_energy_island["gen"]["106"] = deepcopy(BE_grid_energy_island["gen"]["101"])
    BE_grid_energy_island["gen"]["106"]["installed_capacity"] = 0.00 
    BE_grid_energy_island["gen"]["106"]["pmax"] = 0.0
    BE_grid_energy_island["gen"]["106"]["mbase"] = 0.0
    BE_grid_energy_island["gen"]["106"]["qmax"] = 4.0
    BE_grid_energy_island["gen"]["106"]["source_id"][2] = 106
    BE_grid_energy_island["gen"]["106"]["name"] = "Q_onshore_HVDC"
    BE_grid_energy_island["gen"]["106"]["substation_full_name"] = deepcopy(BE_grid_energy_island["bus"]["26"]["full_name"])
    BE_grid_energy_island["gen"]["106"]["substation_full_name_kV"] = deepcopy(BE_grid_energy_island["bus"]["26"]["full_name_kV"])
    BE_grid_energy_island["gen"]["106"]["substation_short_name"] = deepcopy(BE_grid_energy_island["bus"]["26"]["name"])
    BE_grid_energy_island["gen"]["106"]["substation_short_name_kV"] = deepcopy(BE_grid_energy_island["bus"]["26"]["name_kV"])
    BE_grid_energy_island["gen"]["106"]["substation"] = deepcopy(BE_grid_energy_island["bus"]["26"]["name"])
    BE_grid_energy_island["gen"]["106"]["gen_bus"] = 26
    BE_grid_energy_island["gen"]["106"]["gen_type"] = "NG"
    BE_grid_energy_island["gen"]["106"]["fuel_type"] = "WKK"
    BE_grid_energy_island["gen"]["106"]["index"] = 106 
    BE_grid_energy_island["gen"]["106"]["type"] = "Gas CCGT new"
    BE_grid_energy_island["gen"]["106"]["cost"][1] = 0.0

    BE_grid_energy_island["gen"]["107"] = deepcopy(BE_grid_energy_island["gen"]["101"])
    BE_grid_energy_island["gen"]["107"]["installed_capacity"] = 0.00 
    BE_grid_energy_island["gen"]["107"]["pmax"] = 0.0
    BE_grid_energy_island["gen"]["107"]["mbase"] = 0.0
    BE_grid_energy_island["gen"]["107"]["qmax"] = 99.99
    BE_grid_energy_island["gen"]["107"]["source_id"][2] = 107
    BE_grid_energy_island["gen"]["107"]["name"] = "Q_BE_aggregated"
    BE_grid_energy_island["gen"]["107"]["substation_full_name"] = deepcopy(BE_grid_energy_island["bus"]["1"]["full_name"])
    BE_grid_energy_island["gen"]["107"]["substation_full_name_kV"] = deepcopy(BE_grid_energy_island["bus"]["1"]["full_name_kV"])
    BE_grid_energy_island["gen"]["107"]["substation_short_name"] = deepcopy(BE_grid_energy_island["bus"]["1"]["name"])
    BE_grid_energy_island["gen"]["107"]["substation_short_name_kV"] = deepcopy(BE_grid_energy_island["bus"]["1"]["name_kV"])
    BE_grid_energy_island["gen"]["107"]["substation"] = deepcopy(BE_grid_energy_island["bus"]["1"]["name"])
    BE_grid_energy_island["gen"]["107"]["gen_bus"] = 1
    BE_grid_energy_island["gen"]["107"]["gen_type"] = "NG"
    BE_grid_energy_island["gen"]["107"]["fuel_type"] = "WKK"
    BE_grid_energy_island["gen"]["107"]["index"] = 107 
    BE_grid_energy_island["gen"]["107"]["type"] = "Gas CCGT new"
    BE_grid_energy_island["gen"]["107"]["cost"][1] = 0.0
end

function compute_hourly_gen(data,number_of_hours,results)
    generators_output = Dict{String,Any}()
    for (g_id,g) in data["gen"]
        generators_output[g_id] = Dict{String,Any}()
        generators_output[g_id]["type"] = g["type"]
        generators_output[g_id]["pg"] = Dict{String,Any}()
        generators_output[g_id]["qg"] = Dict{String,Any}()
        for i in 1:number_of_hours
            generators_output[g_id]["pg"]["$i"] = deepcopy(results["$i"]["solution"]["gen"][g_id]["pg"])
            generators_output[g_id]["qg"]["$i"] = deepcopy(results["$i"]["solution"]["gen"][g_id]["qg"])
        end
    end
    return generators_output
end


function compute_hourly_capacity(data,number_of_hours,results)
    gen_types = []
    for (g_id,g) in data["gen"]
        push!(gen_types,g["type"])
    end
    uniques = unique(gen_types)
    hourly_generation = Dict{String,Any}()
    for l in uniques
        hourly_generation["$l"] = Dict{String,Any}()
        hourly_generation["$l"]["pg"] = Dict{String,Any}()
        for i in 1:number_of_hours
            hourly_generation["$l"]["pg"]["$i"] = 0
        end
    end
    for l in uniques
        for (g_id,g) in data["gen"]
            if g["type"] == l
                for i in 1:number_of_hours
                    hourly_generation["$l"]["pg"]["$i"] = hourly_generation["$l"]["pg"]["$i"] + results["$i"]["solution"]["gen"][g_id]["pg"]
                end
            end
        end
    end
    return hourly_generation
end

function compute_hourly_capacity_BE(data,number_of_hours,results)
    gen_types = []
    for (g_id,g) in data["gen"]
        push!(gen_types,g["type"])
    end
    uniques = unique(gen_types)
    hourly_generation = Dict{String,Any}()
    for l in uniques
        hourly_generation["$l"] = Dict{String,Any}()
        hourly_generation["$l"]["pg"] = Dict{String,Any}()
        for i in 1:number_of_hours
            hourly_generation["$l"]["pg"]["$i"] = 0
        end
    end
    for l in uniques
        for (g_id,g) in data["gen"]
            if g["type"] == l && g["zone"] == "BE00"
                for i in 1:number_of_hours
                    hourly_generation["$l"]["pg"]["$i"] = hourly_generation["$l"]["pg"]["$i"] + results["$i"]["solution"]["gen"][g_id]["pg"]
                end
            end
        end
    end
    return hourly_generation
end


function compute_AC_branch_power_flow(data,number_of_hours,results)
    AC_branches = Dict{String,Any}()
    for (br_id,br) in data["branch"]
        if br["br_status"] == 1
            AC_branches["$br_id"] = Dict{String,Any}()
            AC_branches["$br_id"]["pf"] = Dict{String,Any}()
            AC_branches["$br_id"]["qf"] = Dict{String,Any}()
            AC_branches["$br_id"]["f_bus"] = br["f_bus"] 
            AC_branches["$br_id"]["t_bus"] = br["t_bus"] # pf is the power transmitted from f_bus to t_bus
            for i in 1:number_of_hours
                AC_branches["$br_id"]["pf"]["$i"] = results["$i"]["solution"]["branch"][br_id]["pf"]
                AC_branches["$br_id"]["qf"]["$i"] = results["$i"]["solution"]["branch"][br_id]["qf"]
            end
        end
    end
    return AC_branches
end


function compute_DC_branch_power_flow(data,number_of_hours,results)
    DC_branches = Dict{String,Any}()
    for (br_id,br) in data["branchdc"]
        if br["status"] != 0
            DC_branches["$br_id"] = Dict{String,Any}()
            DC_branches["$br_id"]["pf"] = Dict{String,Any}()
            DC_branches["$br_id"]["fbusdc"] = br["fbusdc"] 
            DC_branches["$br_id"]["tbusdc"] = br["tbusdc"] # pf is the power transmitted from fbusdc to tbusdc
            for i in 1:number_of_hours
                DC_branches["$br_id"]["pf"]["$i"] = results["$i"]["solution"]["branchdc"][br_id]["pf"]
            end
        end
    end
    return DC_branches
end


function compute_AC_branch_power_flow_contingencies(data,number_of_hours,results)
    AC_branches = Dict{String,Any}()
    for (br_id,br) in data["branch"]
        if br["br_status"] == 1
            AC_branches["$br_id"] = Dict{String,Any}()
            AC_branches["$br_id"]["pf"] = Dict{String,Any}()
            AC_branches["$br_id"]["qf"] = Dict{String,Any}()
            AC_branches["$br_id"]["f_bus"] = br["f_bus"] 
            AC_branches["$br_id"]["t_bus"] = br["t_bus"] # pf is the power transmitted from f_bus to t_bus
            for i in 1:number_of_hours
                AC_branches["$br_id"]["pf"]["$i"] = results["$i"]["solution"]["branch"][br_id]["pf"]
                AC_branches["$br_id"]["qf"]["$i"] = results["$i"]["solution"]["branch"][br_id]["qf"]
            end
        end
    end
    return AC_branches
end
