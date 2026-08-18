using PowerModels; const _PM = PowerModels
using PowerModelsACDC; const _PMACDC = PowerModelsACDC
using Gurobi
using JuMP
# using Feather
using JSON
using Ipopt
import ACDC_2024_paper as _ACDC24 


gurobi = JuMP.optimizer_with_attributes(Gurobi.Optimizer)
ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer)
set_optimizer_attribute(ipopt, "max_iter", 6000)

##################################################################
## Processing input data
# personal_onedrive_folder = "/Users/giacomobastianel/Library/CloudStorage/OneDrive-KULeuven/AC_DC_2024_protections_paper/New_results"

folder_julia = dirname(@__DIR__)
folder_results = joinpath(folder_julia,"Results")

# Belgium grid with energy island
Bornholm_file = abspath(joinpath(folder_julia,"Test_cases/Case_1_AC_DC_paper.json")) # This has line 107, the energy island file does not have it
Bornholm_case = _PM.parse_file(Bornholm_file)

# Assigning zones to buses
Bornholm_case["bus"]["1"]["zone"] = "DKW1"
Bornholm_case["bus"]["3"]["zone"] = "DKW1"

Bornholm_case["bus"]["2"]["zone"] = "DE00"
Bornholm_case["bus"]["4"]["zone"] = "SE04" # Offshore wind farm

Bornholm_case["gen"]["1"]["zone"] = "DKW1"
Bornholm_case["gen"]["2"]["zone"] = "SE04"

for (g_id,g) in Bornholm_case["gen"]
    println([g_id,g["pmax"],g["type"],g["zone"]])
end

##################################################################
## Choosing the number of hours, scenario and climate year
number_of_hours = 24
startHour = 1
scenario = "DE"
year = 2030 # Can choose between 2030, 2040 and 2050
CY = 1995 # Can choose between 1995, 2008 and 2009


DE_zone = "DE00"
SE_zone = "SE04"
DK_zone = "DKW1"

##################################################################
# Processing time series
pv, wind_onshore, wind_offshore = _ACDC24.load_res_data()

wind_onshore_DE, wind_offshore_DE, solar_pv_DE = _ACDC24.make_res_time_series(wind_onshore, wind_offshore, pv, DE_zone,CY)
wind_onshore_SE, wind_offshore_SE, solar_pv_SE = _ACDC24.make_res_time_series(wind_onshore, wind_offshore, pv, SE_zone,CY)
wind_onshore_DK, wind_offshore_DK, solar_pv_DK = _ACDC24.make_res_time_series(wind_onshore, wind_offshore, pv, DK_zone,CY)


# Creating load series for Belgium from TYNDP data 
load_series_DE = _ACDC24.create_load_series(scenario,year,CY,DE_zone,startHour,number_of_hours)
load_series_SE = _ACDC24.create_load_series(scenario,year,CY,SE_zone,startHour,number_of_hours)
load_series_DK = _ACDC24.create_load_series(scenario,year,CY,DK_zone,startHour,number_of_hours)

###############################################################
# Running the OPF for the base case
#number_of_hours = 8760
s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)


function fix_hourly_loads_and_gen_interconnections(grid,hour,zone_1,zone_2) 
    for (l_id,l) in grid["load"]
        if l["zone"] == zone_1 
            l["pd"] = deepcopy(load_series_DE[hour]/100) #pu
            l["qd"] = 0#deepcopy(l["pd"]/10) #pu
        elseif l["zone"] == zone_2
            l["pd"] = deepcopy(load_series_DK[hour]/100) #pu
            l["qd"] = 0#deepcopy(l["pd"]/10) #pu
        end
    end   
end

function fix_RES_time_series(grid,hour,zone_1,zone_2,zone_3)
    for (g_id,g) in grid["gen"]
        if g["zone"] == zone_1
            if g["type"] == "Onshore Wind" 
                g["pmax"] = g["pmax"]*wind_onshore_DE[hour] #pu
            elseif g["type"] == "Offshore Wind" 
                g["pmax"] = g["pmax"]*wind_offshore_DE[hour] #pu
            elseif g["type"] == "Solar PV" 
                g["pmax"] = g["pmax"]*solar_pv_DE[hour] #pu
            end
        elseif g["zone"] == zone_2
            if g["type"] == "Onshore Wind" 
                g["pmax"] = g["pmax"]*wind_onshore_DK[hour] #pu
            elseif g["type"] == "Offshore Wind" 
                g["pmax"] = g["pmax"]*wind_offshore_DK[hour] #pu
            elseif g["type"] == "Solar PV" 
                g["pmax"] = g["pmax"]*solar_pv_DK[hour] #pu
            end
        elseif g["zone"] == zone_3
            if g["type"] == "Onshore Wind" 
                g["pmax"] = g["pmax"]*wind_onshore_SE[hour] #pu
            elseif g["type"] == "Offshore Wind" 
                g["pmax"] = g["pmax"]*wind_offshore_SE[hour] #pu
            elseif g["type"] == "Solar PV" 
                g["pmax"] = g["pmax"]*solar_pv_SE[hour] #pu
            end
        end
    end
end

formulation = DCPPowerModel
optimizer = gurobi

#Bornholm_case["branch"]["1"]["br_r"] = 0.01
#Bornholm_case["branch"]["1"]["br_x"] = 0.01
#Bornholm_case["branch"]["1"]["rate_a"] = 10.0

#Bornholm_case_cheap = deepcopy(Bornholm_case)
Bornholm_case["gen"]["1"]["cost"][1] = 5.0
Bornholm_case["gen"]["2"]["cost"][1] = 5.0

for (g_id,g) in Bornholm_case["gen"]
    println([g_id,g["type"],g["cost"][1]])
end 

results_DCCB_low = Dict()
results_preventive_decoupling_low = Dict()

results_DCCB_high = Dict()
results_preventive_decoupling_high = Dict()

# Fix load not flexible
Bornholm_case["load"]["1"]["flex"] = 0
Bornholm_case["load"]["2"]["flex"] = 0

Bornholm_case_low = deepcopy(Bornholm_case)
Bornholm_case_high = deepcopy(Bornholm_case)

function Bornholm_simulation_low(grid,DCCB,preventive_decoupling,number_of_hours)
    _ACDC24.add_Denmark_W_2040_low(grid)
    _ACDC24.add_Germany_2040_low(grid)

    gen_costs,inertia_constants,emission_factor_CO2,start_up_cost,emission_factor_NOx,emission_factor_SOx = _ACDC24.gen_values()
    _ACDC24.assigning_gen_values(grid,gen_costs,inertia_constants,emission_factor_CO2,start_up_cost,emission_factor_NOx,emission_factor_SOx)
    _ACDC24.add_VOLL_generators(grid)
    

    for hour in 1:number_of_hours
        hourly_grid = deepcopy(grid)
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_DK,"DKW1")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_DE,"DE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DE,wind_offshore_DE,solar_pv_DE,"DE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DK,wind_offshore_DK,solar_pv_DK,"DKW1")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_SE,wind_offshore_SE,solar_pv_SE,"SE04")
        hourly_results = _PMACDC.solve_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        DCCB["$hour"] = deepcopy(hourly_results)
        if (hourly_results["solution"]["convdc"]["1"]["pgrid"]*100/10^3 + hourly_results["solution"]["convdc"]["2"]["pgrid"]*100/10^3) >= 3.0
            hourly_grid["branchdc"]["3"]["status"] = 0
            hourly_result_L3 = _PMACDC.solve_acdcopf(hourly_grid,formulation, optimizer; setting = s)
            preventive_decoupling["$hour"] = deepcopy(hourly_result_L3)
        else
            preventive_decoupling["$hour"] = deepcopy(hourly_results)
        end
    end
end

function Bornholm_simulation_high(grid,DCCB,preventive_decoupling,number_of_hours)
    _ACDC24.add_Denmark_W_2040_high(grid)
    _ACDC24.add_Germany_2040_high(grid)

    gen_costs,inertia_constants,emission_factor_CO2,start_up_cost,emission_factor_NOx,emission_factor_SOx = _ACDC24.gen_values()
    _ACDC24.assigning_gen_values(grid,gen_costs,inertia_constants,emission_factor_CO2,start_up_cost,emission_factor_NOx,emission_factor_SOx)
    _ACDC24.add_VOLL_generators(grid)

    for hour in 1:number_of_hours
        hourly_grid = deepcopy(grid)
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_DK,"DKW1")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_DE,"DE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DE,wind_offshore_DE,solar_pv_DE,"DE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DK,wind_offshore_DK,solar_pv_DK,"DKW1")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_SE,wind_offshore_SE,solar_pv_SE,"SE04")
        hourly_results = _PMACDC.solve_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        DCCB["$hour"] = deepcopy(hourly_results)
        if (hourly_results["solution"]["convdc"]["1"]["pgrid"]*100/10^3 + hourly_results["solution"]["convdc"]["2"]["pgrid"]*100/10^3) >= 3.0
            hourly_grid["branchdc"]["3"]["status"] = 0
            hourly_result_L3 = _PMACDC.solve_acdcopf(hourly_grid,formulation, optimizer; setting = s)
            preventive_decoupling["$hour"] = deepcopy(hourly_result_L3)
        else
            preventive_decoupling["$hour"] = deepcopy(hourly_results)
        end
    end
end

Bornholm_simulation_low(Bornholm_case_low,results_DCCB_low,results_preventive_decoupling_low,number_of_hours)

Bornholm_simulation_high(Bornholm_case_high,results_DCCB_high,results_preventive_decoupling_high,number_of_hours)


results_folder = folder_results

json_string_1 = JSON.json(results_DCCB_low,allownan=true)
json_string_2 = JSON.json(results_preventive_decoupling_low,allownan=true)
json_string_3 = JSON.json(results_DCCB_high,allownan=true)
json_string_4 = JSON.json(results_preventive_decoupling_high,allownan=true)

open(joinpath(results_folder,"Bornholm_results_DCCB_low_$(number_of_hours).json"),"w") do f 
    write(f, json_string_1) 
end

open(joinpath(results_folder,"Bornholm_results_DCCB_high_$(number_of_hours).json"),"w") do f 
    write(f, json_string_3) 
end

open(joinpath(results_folder,"Bornholm_results_preventive_decoupling_high_$(number_of_hours).json"),"w") do f 
    write(f, json_string_4) 
end

open(joinpath(results_folder,"Bornholm_results_preventive_decoupling_low_$(number_of_hours).json"),"w") do f 
    write(f, json_string_2) 
end



obj_DCCB_low = [results_DCCB_low["$i"]["objective"]*100 for i in 1:number_of_hours]
obj_preventive_decoupling_low = [results_preventive_decoupling_low["$i"]["objective"]*100 for i in 1:number_of_hours]

sum(obj_DCCB_low)/10^9
sum(obj_preventive_decoupling_low)/10^9

DCBB_value_low = (sum(obj_preventive_decoupling_low)/10^9 - sum(obj_DCCB_low)/10^9)*10^3 # M€



Ldc_3_low = [results_DCCB_low["$i"]["solution"]["branchdc"]["3"]["pf"]*100/10^3 for i in 1:number_of_hours]
scatter(Ldc_3_low,ylabel = "Power flow through Ldc3 [GW]",legend = :none)

8760 - count(length(results_preventive_decoupling_low["$i"]["solution"]["branchdc"]) == 2 for i in 1:number_of_hours)
8760 - count(length(results_preventive_decoupling_high["$i"]["solution"]["branchdc"]) == 2 for i in 1:number_of_hours)
    

conv_dc_1_low = [results_DCCB_low["$i"]["solution"]["convdc"]["1"]["pgrid"]*100/10^3 for i in 1:number_of_hours]
conv_dc_2_low = [results_DCCB_low["$i"]["solution"]["convdc"]["2"]["pgrid"]*100/10^3 for i in 1:number_of_hours]

conv_1_2_low = conv_dc_1_low + conv_dc_2_low

scatter(conv_1_2_low,legend= :bottomright,label = "Low scenario", ylabel = "Power flow through Conv 1 and Conv 2 [GW]",xlabel = "Hours", markersize=3,grid = :none)
scatter!(conv_1_2_high,label = "High scenario",markersize=3)
limit = ones(number_of_hours)*3
plot!(limit,color=:red,linewidth=3,label = "Loss of infeed limit")

savefig(joinpath(results_folder, "Bornholm_conv_1_2_high_vs_load.pdf"))

count(conv_1_2_low .>= 3.0)


Ldc_3_hours_low = []
Ldc_3_flow_low = []
for i in 1:number_of_hours
    if length(results_preventive_decoupling_low["$i"]["solution"]["branchdc"]) == 2
        push!(Ldc_3_hours_low,i)
        push!(Ldc_3_flow_low,abs(results_DCCB_low["$i"]["solution"]["branchdc"]["3"]["pf"]*100/10^3))
    end
end
scatter(Ldc_3_flow_low)

sum(Ldc_3_flow_low)


length(Ldc_3_hours)/8760

consecutive_count = 0
for i in 2:length(Ldc_3_hours)
    if Ldc_3_hours[i] == Ldc_3_hours[i-1] + 1
        consecutive_count += 1
    end
end
println("Number of consecutive values in Ldc_3_hours: $consecutive_count")

consecutive_blocks = 0
i = 1
while i < length(Ldc_3_hours_low)
    if Ldc_3_hours_low[i] == Ldc_3_hours_low[i+1] - 1
        consecutive_blocks += 1
        while i < length(Ldc_3_hours_low) && Ldc_3_hours_low[i] == Ldc_3_hours_low[i+1] - 1
            i += 1
        end
    end
    i += 1
end
println("Number of blocks with consecutive values in Ldc_3_hours: $consecutive_blocks")
blocks_with_more_than_one_consecutive = 0
i = 1
while i < length(Ldc_3_hours_low)
    if Ldc_3_hours_low[i] == Ldc_3_hours_low[i+1] - 1
        block_length = 1
        while i < length(Ldc_3_hours_low) && Ldc_3_hours_low[i] == Ldc_3_hours_low[i+1] - 1
            block_length += 1
            i += 1
        end
        if block_length > 1
            blocks_with_more_than_one_consecutive += 1
        end
    end
    i += 1
end
println("Number of blocks with more than 1 consecutive values in Ldc_3_hours_low: $blocks_with_more_than_one_consecutive")


blocks_with_more_than_one_consecutive = 0
i = 1
while i < length(Ldc_3_hours_high)
    if Ldc_3_hours_high[i] == Ldc_3_hours_high[i+1] - 1
        block_length = 1
        while i < length(Ldc_3_hours_high) && Ldc_3_hours_high[i] == Ldc_3_hours_high[i+1] - 1
            block_length += 1
            i += 1
        end
        if block_length > 1
            blocks_with_more_than_one_consecutive += 1
        end
    end
    i += 1
end
println("Number of blocks with more than 1 consecutive values in Ldc_3_hours_low: $blocks_with_more_than_one_consecutive")








consecutive_blocks = 0
i = 1
while i < length(Ldc_3_hours_high)
    if Ldc_3_hours_high[i] == Ldc_3_hours_high[i+1] - 1
        consecutive_blocks += 1
        while i < length(Ldc_3_hours_high) && Ldc_3_hours_high[i] == Ldc_3_hours_high[i+1] - 1
            i += 1
        end
    end
    i += 1
end
println("Number of blocks with consecutive values in Ldc_3_hours: $consecutive_blocks")



function compute_curtailment_gen(grid, gen_id, results, time_series, number_of_hours)
    gen_total = 0
    gen_ = 0
    for hour in 1:number_of_hours
            gen_total += grid["gen"][gen_id]["pmax"]*time_series[hour]
            gen_ += results["$hour"]["solution"]["gen"][gen_id]["pg"]
    end
    curtailment = gen_total - gen_
    return gen_total, gen_, curtailment
end

total_1_DCCB_low, gen_1_DCCB_low, curt_1_DCCB_low = compute_curtailment_gen(Bornholm_case, "1", results_DCCB_low, wind_offshore_DK, number_of_hours)
total_2_DCCB_low, gen_2_DCCB_low, curt_2_DCCB_low = compute_curtailment_gen(Bornholm_case, "2", results_DCCB_low, wind_offshore_SE, number_of_hours)

total_1_decoupling_low, gen_1_decoupling_low, curt_1_decoupling_low = compute_curtailment_gen(Bornholm_case, "1", results_preventive_decoupling_low, wind_offshore_DK, number_of_hours)
total_2_decoupling_low, gen_2_decoupling_low, curt_2_decoupling_low = compute_curtailment_gen(Bornholm_case, "2", results_preventive_decoupling_low, wind_offshore_SE, number_of_hours)

tot_gen_1_2_DCCB_low = (gen_1_DCCB_low*100 + gen_2_DCCB_low*100)/10^3
tot_gen_1_2_decoupling_low = (gen_1_decoupling_low + gen_2_decoupling_low)*100/10^3

(tot_gen_1_2_DCCB_low - tot_gen_1_2_decoupling_low)/tot_gen_1_2_DCCB_low*100 # 0.27% of the energy is lost

compute_curtailment_gen(Bornholm_case, "1", results_DCCB_high, wind_offshore_DK, number_of_hours)
compute_curtailment_gen(Bornholm_case, "2", results_DCCB_high, wind_offshore_SE, number_of_hours)

compute_curtailment_gen(Bornholm_case, "1", results_preventive_decoupling_high, wind_offshore_DK, number_of_hours)
compute_curtailment_gen(Bornholm_case, "2", results_preventive_decoupling_high, wind_offshore_SE, number_of_hours)



obj_DCCB_high = [results_DCCB_high["$i"]["objective"]*100 for i in 1:number_of_hours]
obj_preventive_decoupling_high = [results_preventive_decoupling_high["$i"]["objective"]*100 for i in 1:number_of_hours]

DCBB_value_high = (sum(obj_preventive_decoupling_high)/10^9 - sum(obj_DCCB_high)/10^9)*10^3 # M€








conv_dc_1_high = [results_DCCB_high["$i"]["solution"]["convdc"]["1"]["pgrid"]*100/10^3 for i in 1:number_of_hours]
conv_dc_2_high = [results_DCCB_high["$i"]["solution"]["convdc"]["2"]["pgrid"]*100/10^3 for i in 1:number_of_hours]

conv_1_2_high = conv_dc_1_high + conv_dc_2_high

scatter(conv_1_2_high,legend=false,ylabel = "Power fhigh through Conv 1 and Conv 2 [GW]",xlabel = "Hour",xticks = :none)
limit = ones(number_of_hours)*3
plot!(limit,color=:red,linewidth=5)

count(conv_1_2_high .>= 3.0)
60/8760


total_1_DCCB_high, gen_1_DCCB_high, curt_1_DCCB_high = compute_curtailment_gen(Bornholm_case, "1", results_DCCB_high, wind_offshore_DK, number_of_hours)
total_2_DCCB_high, gen_2_DCCB_high, curt_2_DCCB_high = compute_curtailment_gen(Bornholm_case, "2", results_DCCB_high, wind_offshore_SE, number_of_hours)

total_1_decoupling_high, gen_1_decoupling_high, curt_1_decoupling_high = compute_curtailment_gen(Bornholm_case, "1", results_preventive_decoupling_high, wind_offshore_DK, number_of_hours)
total_2_decoupling_high, gen_2_decoupling_high, curt_2_decoupling_high = compute_curtailment_gen(Bornholm_case, "2", results_preventive_decoupling_high, wind_offshore_SE, number_of_hours)

tot_gen_1_2_DCCB_high = (gen_1_DCCB_high*100 + gen_2_DCCB_high*100)/10^3
tot_gen_1_2_decoupling_high = (gen_1_decoupling_high + gen_2_decoupling_high)*100/10^3

(tot_gen_1_2_DCCB_high - tot_gen_1_2_decoupling_high)/tot_gen_1_2_DCCB_high*100 # 0.27% of the energy is lost

compute_curtailment_gen(Bornholm_case, "1", results_DCCB_high, wind_offshore_DK, number_of_hours)
compute_curtailment_gen(Bornholm_case, "2", results_DCCB_high, wind_offshore_SE, number_of_hours)

compute_curtailment_gen(Bornholm_case, "1", results_preventive_decoupling_high, wind_offshore_DK, number_of_hours)
compute_curtailment_gen(Bornholm_case, "2", results_preventive_decoupling_high, wind_offshore_SE, number_of_hours)



obj_DCCB_high = [results_DCCB_high["$i"]["objective"]*100 for i in 1:number_of_hours]
obj_preventive_decoupling_high = [results_preventive_decoupling_high["$i"]["objective"]*100 for i in 1:number_of_hours]

DCBB_value_high = (sum(obj_preventive_decoupling_high)/10^9 - sum(obj_DCCB_high)/10^9)*10^3 # M€
(DCBB_value_high/10^3)/(sum(obj_DCCB_high)/10^9)*100

(DCBB_value_low/10^3)/(sum(obj_DCCB_low)/10^9)*100


Ldc_3_hours_high = []
Ldc_3_flow_high = []
for i in 1:number_of_hours
    if conv_1_2_high[i] >= 3.0
        push!(Ldc_3_hours_high,i)
        push!(Ldc_3_flow_high,abs(results_DCCB_high["$i"]["solution"]["branchdc"]["3"]["pf"]*100/10^3))
    end
end
sum(Ldc_3_flow_high)




