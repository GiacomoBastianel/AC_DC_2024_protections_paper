using PowerModels; const _PM = PowerModels
using PowerModelsACDC; const _PMACDC = PowerModelsACDC
using Gurobi
using JuMP
using JSON
using Ipopt
import ACDC_2024_paper as _ACDC24 

gurobi = JuMP.optimizer_with_attributes(Gurobi.Optimizer)
ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer)
set_optimizer_attribute(ipopt, "max_iter", 6000)

##################################################################
## Processing input data
folder_julia = dirname(@__DIR__)
folder_results = joinpath(folder_julia,"Results")

# Belgium grid with energy island
BE_grid_energy_island_file = abspath(joinpath(folder_julia,"Test_cases/Belgian_transmission_grid_synthetic_2023_with_DK.json")) # This has line 107, the energy island file does not have it
BE_grid_energy_island = _PM.parse_file(BE_grid_energy_island_file)

# New developments
BE_grid_energy_island["branchdc"]["4"]["rateA"] = 14.0
BE_grid_energy_island["branchdc"]["4"]["rateB"] = 14.0
BE_grid_energy_island["branchdc"]["4"]["rateC"] = 14.0

BE_grid_energy_island["branchdc"]["10"]["rateA"] = 20.0
BE_grid_energy_island["branchdc"]["10"]["rateB"] = 20.0
BE_grid_energy_island["branchdc"]["10"]["rateC"] = 20.0

BE_grid_energy_island["convdc"]["10"]["Pacrated"] = 20.0
BE_grid_energy_island["convdc"]["10"]["Pacmax"] = 20.0
BE_grid_energy_island["convdc"]["10"]["Pacmin"] = - 20.0
BE_grid_energy_island["convdc"]["10"]["Qacmax"] = 10.0
BE_grid_energy_island["convdc"]["10"]["Qacmin"] = - 10.0

BE_grid_energy_island["convdc"]["11"]["Pacrated"] = 20.0
BE_grid_energy_island["convdc"]["11"]["Pacmax"] = 20.0
BE_grid_energy_island["convdc"]["11"]["Pacmin"] = - 20.0
BE_grid_energy_island["convdc"]["11"]["Qacmax"] = 10.0
BE_grid_energy_island["convdc"]["11"]["Qacmin"] = - 10.0

BE_grid_energy_island["convdc"]["12"]["Pacrated"] = 20.0
BE_grid_energy_island["convdc"]["12"]["Pacmax"] = 20.0
BE_grid_energy_island["convdc"]["12"]["Pacmin"] = - 20.0
BE_grid_energy_island["convdc"]["12"]["Qacmax"] = 10.0
BE_grid_energy_island["convdc"]["12"]["Qacmin"] = - 10.0


# Adding extra connection between the wind farms in Denmark -> Removing this on 11/06/25
#BE_grid_energy_island["branchdc"]["11"] = deepcopy(BE_grid_energy_island["branchdc"]["10"])
#BE_grid_energy_island["branchdc"]["11"]["index"] = 11
#BE_grid_energy_island["branchdc"]["11"]["HVDC_link"] = "DK OFW 1382 -> DK onshore"
#BE_grid_energy_island["branchdc"]["11"]["tbusdc"] = 12
#BE_grid_energy_island["branchdc"]["11"]["fbusdc"] = 11
#BE_grid_energy_island["branchdc"]["11"]["source_id"][2] = 11
#BE_grid_energy_island["branchdc"]["11"]["rateA"] = 20.0
#BE_grid_energy_island["branchdc"]["11"]["rateB"] = 20.0
#BE_grid_energy_island["branchdc"]["11"]["rateC"] = 20.0

# Adding German and French load
BE_grid_energy_island["load"]["4"] = deepcopy(BE_grid_energy_island["load"]["1"])
BE_grid_energy_island["load"]["4"]["zone"] = "FR00"
BE_grid_energy_island["load"]["4"]["name_no_kV"] = "FR00"
BE_grid_energy_island["load"]["4"]["name"] = "FR00"
BE_grid_energy_island["load"]["4"]["full_name_kVname"] = "FR00"
BE_grid_energy_island["load"]["4"]["full_name"] = "FR00"
BE_grid_energy_island["load"]["4"]["index"] = 4
BE_grid_energy_island["load"]["4"]["source_id"][2] = 4

BE_grid_energy_island["load"]["5"] = deepcopy(BE_grid_energy_island["load"]["1"])
BE_grid_energy_island["load"]["5"]["zone"] = "DE00"
BE_grid_energy_island["load"]["5"]["name_no_kV"] = "DE00"
BE_grid_energy_island["load"]["5"]["name"] = "DE00"
BE_grid_energy_island["load"]["5"]["full_name_kVname"] = "DE00"
BE_grid_energy_island["load"]["5"]["full_name"] = "DE00"
BE_grid_energy_island["load"]["5"]["index"] = 5
BE_grid_energy_island["load"]["5"]["source_id"][2] = 5

for (g_id,g) in BE_grid_energy_island["gen"]
    if g["zone"] == "UK00"
        print([g_id,g["pmax"],g["type"]],"\n")
    end
end

##################################################################
## Choosing the number of hours, scenario and climate year
number_of_hours = 8760
startHour = 1
scenario = "DE"
year = 2030
CY = 1995

DE_zone = "DE00"
BE_zone = "BE_00"
DK_zone = "DKW1"
UK_zone = "UK00"
FR_zone = "FR00"

##################################################################
## Processing time series -> this needs to be fixed for Github!
# Creating RES time series for Belgium from Feather files in tyndpdata desktop folder
pv, wind_onshore, wind_offshore = _ACDC24.load_res_data()

wind_onshore_BE, wind_offshore_BE, solar_pv_BE = _ACDC24.make_res_time_series(wind_onshore, wind_offshore, pv, BE_zone,CY)
wind_onshore_UK, wind_offshore_UK, solar_pv_UK = _ACDC24.make_res_time_series(wind_onshore, wind_offshore, pv, UK_zone,CY)
wind_onshore_DK, wind_offshore_DK, solar_pv_DK = _ACDC24.make_res_time_series(wind_onshore, wind_offshore, pv, DK_zone,CY)
wind_onshore_FR, wind_offshore_FR, solar_pv_FR = _ACDC24.make_res_time_series(wind_onshore, wind_offshore, pv, FR_zone,CY)
wind_onshore_DE, wind_offshore_DE, solar_pv_DE = _ACDC24.make_res_time_series(wind_onshore, wind_offshore, pv, DE_zone,CY)

# Creating load series for Belgium from TYNDP data 
load_series_DE = _ACDC24.create_load_series(scenario,year,CY,DE_zone,startHour,number_of_hours)
load_series_FR = _ACDC24.create_load_series(scenario,year,CY,FR_zone,startHour,number_of_hours)
load_series_BE = _ACDC24.create_load_series(scenario,year,CY,BE_zone,startHour,number_of_hours)
load_series_UK = _ACDC24.create_load_series(scenario,year,CY,UK_zone,startHour,number_of_hours)
load_series_DK = _ACDC24.create_load_series(scenario,year,CY,DK_zone,startHour,number_of_hours)

###############################################################
# Running the OPF for the base case
s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

function PEI_simulation_pole_to_ground_low(grid,DCCB,preventive_decoupling, results_folder=folder_results)
    _ACDC24.add_France_2040_low_PEI(grid)
    _ACDC24.add_UK_2040_low(grid)
    _ACDC24.add_Belgium_2040_low(grid)
    _ACDC24.add_Germany_2040_low_PEI(grid)
    _ACDC24.add_Denmark_W_2040_low_PEI(grid)

    gen_costs,inertia_constants,emission_factor_CO2,start_up_cost,emission_factor_NOx,emission_factor_SOx = _ACDC24.gen_values()
    _ACDC24.assigning_gen_values(grid,gen_costs,inertia_constants,emission_factor_CO2,start_up_cost,emission_factor_NOx,emission_factor_SOx)
    _ACDC24.add_VOLL_generators(grid)
    
    json_string_test_case = JSON.json(grid)
    open(joinpath(results_folder,"PEI_simulation_pole_to_ground_low_test_case_11_06_25.json"),"w") do f 
        write(f, json_string_test_case) 
    end

    for hour in 1:8760
        hourly_grid = deepcopy(grid)
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_BE,"BE00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_FR,"FR00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_DE,"DE00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_BE,"DKW1")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_BE,"UK00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_BE,wind_offshore_BE,solar_pv_BE,"BE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_FR,wind_offshore_FR,solar_pv_FR,"FR00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DE,wind_offshore_DE,solar_pv_DE,"DE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_UK,wind_offshore_UK,solar_pv_UK,"UK00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DK,wind_offshore_DK,solar_pv_DK,"DKW1")
        hourly_results = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        if length(hourly_results["solution"]) > 5
            DCCB["$hour"] = deepcopy(hourly_results)
            if (hourly_results["solution"]["convdc"]["7"]["pconv"] + hourly_results["solution"]["convdc"]["12"]["pconv"]) < - 20.0 || (hourly_results["solution"]["convdc"]["7"]["pconv"] + hourly_results["solution"]["convdc"]["12"]["pconv"]) > 20.0
                hourly_grid["branchdc"]["7"]["status"] = 0
                hourly_results_pd = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
                preventive_decoupling["$hour"] = deepcopy(hourly_results_pd)
            else
                preventive_decoupling["$hour"] = deepcopy(hourly_results)                
            end
        end
    end
end

function PEI_simulation_pole_to_ground_high(grid,DCCB,preventive_decoupling, results_folder = folder_results)
    add_France_2040_high_PEI(grid)
    _ACDC24.add_UK_2040_high(grid)
    _ACDC24.add_Belgium_2040_high(grid)
    _ACDC24.add_Germany_2040_high_PEI(grid)
    _ACDC24.add_Denmark_W_2040_high_PEI(grid)

    gen_costs,inertia_constants,emission_factor_CO2,start_up_cost,emission_factor_NOx,emission_factor_SOx = _ACDC24.gen_values()
    _ACDC24.assigning_gen_values(grid,gen_costs,inertia_constants,emission_factor_CO2,start_up_cost,emission_factor_NOx,emission_factor_SOx)
    _ACDC24.add_VOLL_generators(grid)
    
    json_string_test_case = JSON.json(grid)
    open(joinpath(results_folder,"PEI_simulation_pole_to_ground_high_test_case_11_06_25.json"),"w") do f 
        write(f, json_string_test_case) 
    end

    for hour in 1:8760
        hourly_grid = deepcopy(grid)
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_BE,"BE00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_FR,"FR00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_DE,"DE00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_BE,"DKW1")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_BE,"UK00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_BE,wind_offshore_BE,solar_pv_BE,"BE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_FR,wind_offshore_FR,solar_pv_FR,"FR00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DE,wind_offshore_DE,solar_pv_DE,"DE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_UK,wind_offshore_UK,solar_pv_UK,"UK00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DK,wind_offshore_DK,solar_pv_DK,"DKW1")
        hourly_results = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        if length(hourly_results["solution"]) > 5
            DCCB["$hour"] = deepcopy(hourly_results)
            if (hourly_results["solution"]["convdc"]["7"]["pconv"] + hourly_results["solution"]["convdc"]["12"]["pconv"]) < - 20.0 || (hourly_results["solution"]["convdc"]["7"]["pconv"] + hourly_results["solution"]["convdc"]["12"]["pconv"]) > 20.0
                hourly_grid["branchdc"]["7"]["status"] = 0
                hourly_results_pd = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
                preventive_decoupling["$hour"] = deepcopy(hourly_results_pd)
            else
                preventive_decoupling["$hour"] = deepcopy(hourly_results)                
            end
        end
    end
end

function PEI_simulation_pole_to_pole_low(grid,DCCB,preventive_decoupling,results_folder=folder_results)
    _ACDC24.add_France_2040_low_PEI(grid)
    _ACDC24.add_UK_2040_low(grid)
    _ACDC24.add_Belgium_2040_low(grid)
    _ACDC24.add_Germany_2040_low_PEI(grid)
    _ACDC24.add_Denmark_W_2040_low_PEI(grid)

    gen_costs,inertia_constants,emission_factor_CO2,start_up_cost,emission_factor_NOx,emission_factor_SOx = _WP1.gen_values()
    _ACDC24.assigning_gen_values(grid,gen_costs,inertia_constants,emission_factor_CO2,start_up_cost,emission_factor_NOx,emission_factor_SOx)
    _ACDC24.add_VOLL_generators(grid)
    
    json_string_test_case = JSON.json(grid)
    open(joinpath(results_folder,"PEI_simulation_pole_to_pole_low_test_case_11_06_25.json"),"w") do f 
        write(f, json_string_test_case) 
    end


    for hour in 1:8760
        hourly_grid = deepcopy(grid)
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_BE,"BE00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_FR,"FR00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_DE,"DE00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_BE,"DKW1")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_BE,"UK00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_BE,wind_offshore_BE,solar_pv_BE,"BE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_FR,wind_offshore_FR,solar_pv_FR,"FR00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DE,wind_offshore_DE,solar_pv_DE,"DE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_UK,wind_offshore_UK,solar_pv_UK,"UK00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DK,wind_offshore_DK,solar_pv_DK,"DKW1")
        hourly_results = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        if length(hourly_results["solution"]) > 5
            DCCB["$hour"] = deepcopy(hourly_results)
            if (hourly_results["solution"]["convdc"]["7"]["pconv"] + hourly_results["solution"]["convdc"]["9"]["pconv"] + hourly_results["solution"]["convdc"]["12"]["pconv"]) > 30.0 || (hourly_results["solution"]["convdc"]["7"]["pconv"] + hourly_results["solution"]["convdc"]["9"]["pconv"] + hourly_results["solution"]["convdc"]["12"]["pconv"]) < - 30.0
                hourly_grid["branchdc"]["7"]["status"] = 0
                hourly_results_pd = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
                preventive_decoupling["$hour"] = deepcopy(hourly_results_pd)
            else
                preventive_decoupling["$hour"] = deepcopy(hourly_results)                
            end
        end
    end
end

function PEI_simulation_pole_to_pole_high(grid,DCCB,preventive_decoupling,results_folder=folder_results)
    _ACDC24.add_France_2040_high_PEI(grid)
    _ACDC24.add_UK_2040_high(grid)
    _ACDC24.add_Belgium_2040_high(grid)
    _ACDC24.add_Germany_2040_high_PEI(grid)
    _ACDC24.add_Denmark_W_2040_high_PEI(grid)

    gen_costs,inertia_constants,emission_factor_CO2,start_up_cost,emission_factor_NOx,emission_factor_SOx = _ACDC24.gen_values()
    _ACDC24.assigning_gen_values(grid,gen_costs,inertia_constants,emission_factor_CO2,start_up_cost,emission_factor_NOx,emission_factor_SOx)
    _ACDC24.add_VOLL_generators(grid)
    
    json_string_test_case = JSON.json(grid)
    open(joinpath(results_folder,"PEI_simulation_pole_to_pole_high_test_case_11_06_25.json"),"w") do f 
        write(f, json_string_test_case) 
    end

    for hour in 1:8760
        hourly_grid = deepcopy(grid)
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_BE,"BE00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_FR,"FR00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_DE,"DE00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_BE,"DKW1")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_BE,"UK00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_BE,wind_offshore_BE,solar_pv_BE,"BE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_FR,wind_offshore_FR,solar_pv_FR,"FR00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DE,wind_offshore_DE,solar_pv_DE,"DE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_UK,wind_offshore_UK,solar_pv_UK,"UK00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DK,wind_offshore_DK,solar_pv_DK,"DKW1")
        hourly_results = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        if length(hourly_results["solution"]) > 5
            DCCB["$hour"] = deepcopy(hourly_results)
            if (hourly_results["solution"]["convdc"]["7"]["pconv"] + hourly_results["solution"]["convdc"]["9"]["pconv"] + hourly_results["solution"]["convdc"]["12"]["pconv"]) > 30.0 || (hourly_results["solution"]["convdc"]["7"]["pconv"] + hourly_results["solution"]["convdc"]["9"]["pconv"] + hourly_results["solution"]["convdc"]["12"]["pconv"]) < - 30.0
                hourly_grid["branchdc"]["7"]["status"] = 0
                hourly_results_pd = _PMACDC.run_acdcopf(hourly_grid,formulation, optimizer; setting = s)
                preventive_decoupling["$hour"] = deepcopy(hourly_results_pd)
            else
                preventive_decoupling["$hour"] = deepcopy(hourly_results)                
            end
        end
    end
end



results_DCCB_PEI_ptg_low = Dict()
results_preventive_decoupling_PEI_ptg_low = Dict()
results_DCCB_PEI_ptg_high = Dict()
results_preventive_decoupling_PEI_ptg_high = Dict()

results_DCCB_PEI_ptp_low = Dict()
results_preventive_decoupling_PEI_ptp_low = Dict()
results_DCCB_PEI_ptp_high = Dict()
results_preventive_decoupling_PEI_ptp_high = Dict()


PEI_ptg_low = deepcopy(BE_grid_energy_island)
PEI_ptg_high = deepcopy(BE_grid_energy_island)

PEI_ptp_low = deepcopy(BE_grid_energy_island)
PEI_ptp_high = deepcopy(BE_grid_energy_island)

formulation = DCPPowerModel
optimizer = gurobi

PEI_simulation_pole_to_ground_low(PEI_ptg_low,results_DCCB_PEI_ptg_low,results_preventive_decoupling_PEI_ptg_low)
PEI_simulation_pole_to_ground_high(PEI_ptg_high,results_DCCB_PEI_ptg_high,results_preventive_decoupling_PEI_ptg_high)

PEI_simulation_pole_to_pole_low(PEI_ptp_low,results_DCCB_PEI_ptp_low,results_preventive_decoupling_PEI_ptp_low)
PEI_simulation_pole_to_pole_high(PEI_ptp_high,results_DCCB_PEI_ptp_high,results_preventive_decoupling_PEI_ptp_high)


json_string_1 = JSON.json(results_DCCB_PEI_ptg_low)
json_string_2 = JSON.json(results_preventive_decoupling_PEI_ptg_low)
json_string_3 = JSON.json(results_DCCB_PEI_ptg_high)
json_string_4 = JSON.json(results_preventive_decoupling_PEI_ptg_high)

json_string_5 = JSON.json(results_DCCB_PEI_ptp_low)
json_string_6 = JSON.json(results_preventive_decoupling_PEI_ptp_low)
json_string_7 = JSON.json(results_DCCB_PEI_ptp_high)
json_string_8 = JSON.json(results_preventive_decoupling_PEI_ptp_high)

json_string_test_case = JSON.json(BE_grid_energy_island)

results_folder = folder_results
open(joinpath(results_folder,"PEI_test_case_11_06_25.json"),"w") do f 
    write(f, json_string_test_case) 
end

results_folder = folder_results
open(joinpath(results_folder,"PEI_results_DCCB_ptg_low_$(number_of_hours)_11_06_25.json"),"w") do f 
    write(f, json_string_1) 
end
open(joinpath(results_folder,"PEI_results_preventive_decoupling_PEI_ptg_low_$(number_of_hours)_11_06_25.json"),"w") do f 
    write(f, json_string_2) 
end
open(joinpath(results_folder,"PEI_results_DCCB_ptg_high_$(number_of_hours)_11_06_25.json"),"w") do f 
    write(f, json_string_3) 
end
open(joinpath(results_folder,"PEI_results_preventive_decoupling_PEI_ptg_high_$(number_of_hours)_11_06_25.json"),"w") do f 
    write(f, json_string_4) 
end

open(joinpath(results_folder,"PEI_results_DCCB_ptp_low_$(number_of_hours)_11_06_25.json"),"w") do f 
    write(f, json_string_5) 
end
open(joinpath(results_folder,"PEI_results_preventive_decoupling_PEI_ptp_low_$(number_of_hours)_11_06_25.json"),"w") do f 
    write(f, json_string_6) 
end
open(joinpath(results_folder,"PEI_results_DCCB_ptp_high_$(number_of_hours)_11_06_25.json"),"w") do f 
    write(f, json_string_7) 
end
open(joinpath(results_folder,"PEI_results_preventive_decoupling_PEI_ptp_high_$(number_of_hours)_11_06_25.json"),"w") do f 
    write(f, json_string_8) 
end

