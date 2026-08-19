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

formulation = DCPPowerModel
optimizer = gurobi

##################################################################
## Processing input data
folder_julia = dirname(@__DIR__)
folder_results = joinpath(folder_julia,"Results","Case_3")
folder_test_cases = joinpath(folder_julia,"Test_cases","Case_3")

# Load pre-made grid models 

Case_3_low_file = abspath(joinpath(folder_test_cases,"Case_3_low.json"))
Case_3_high_file = abspath(joinpath(folder_test_cases,"Case_3_high.json"))
Case_3_low = _PM.parse_file(Case_3_low_file)
Case_3_high = _PM.parse_file(Case_3_high_file)

###########################3
# Set case to run 
scen = "low"
fault_type = "PP"
lim_loi = "EU"

##################################################################
## Choosing the number of hours, scenario and climate year
number_of_hours = 24
startHour = 1
scenario = "DE"
year = 2040 # this is fixed
CY = 1995

DE_zone = "DE00"
BE_zone = "BE00"
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

function Case_3_PG(grid,h1=startHour,hn=number_of_hours)
    DCCB_result = Dict()
    PD_result = Dict()
    for hour in h1:hn
        hourly_grid = deepcopy(grid)
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_BE,"BE00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_FR,"FR00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_DE,"DE00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_DK,"DKW1")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_UK,"UK00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_BE,wind_offshore_BE,solar_pv_BE,"BE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_FR,wind_offshore_FR,solar_pv_FR,"FR00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DE,wind_offshore_DE,solar_pv_DE,"DE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_UK,wind_offshore_UK,solar_pv_UK,"UK00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DK,wind_offshore_DK,solar_pv_DK,"DKW1")
        hourly_results = _PMACDC.solve_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        if length(hourly_results["solution"]) > 5
            DCCB_result["$hour"] = deepcopy(hourly_results)
            BE_convs = ["7","12"]
            P_AC_BE = sum(hourly_results["solution"]["convdc"][c]["pconv"] for c in BE_convs)/2 # Power going into BE over one HVDC pole
            if P_AC_BE < -10.0 || P_AC_BE > 10.0
                hourly_grid["brachdc"]["7"]["status"] = 0
                hourly_results_pd = _PMACDC.solve_acdcopf(hourly_grid,formulation,optimizer; setting = s)
                PD_result["$hour"] = deepcopy(hourly_results_pd)
            else
                PD_result["$hour"] = deepcopy(hourly_results)
            end
        end
    end
    return DCCB_result, PD_result
end

function Case_3_PP(grid,h1=startHour,hn=number_of_hours)
    DCCB_result = Dict()
    PD_result = Dict()
    for hour in h1:hn
        hourly_grid = deepcopy(grid)
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_BE,"BE00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_FR,"FR00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_DE,"DE00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_DK,"DKW1")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_UK,"UK00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_BE,wind_offshore_BE,solar_pv_BE,"BE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_FR,wind_offshore_FR,solar_pv_FR,"FR00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DE,wind_offshore_DE,solar_pv_DE,"DE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_UK,wind_offshore_UK,solar_pv_UK,"UK00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DK,wind_offshore_DK,solar_pv_DK,"DKW1")
        hourly_results = _PMACDC.solve_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        if length(hourly_results["solution"]) > 5
            DCCB_result["$hour"] = deepcopy(hourly_results)
            EU_convs = ["7","11","12"]
            P_AC_EU = sum(hourly_results["solution"]["convdc"][c]["pconv"] for c in EU_convs) # Power going into EU over both poles
            if P_AC_EU < -30.0 || P_AC_EU > 30.0
                hourly_grid["brachdc"]["7"]["status"] = 0
                hourly_results_pd = _PMACDC.solve_acdcopf(hourly_grid,formulation,optimizer; setting = s)
                PD_result["$hour"] = deepcopy(hourly_results_pd)
            else
                PD_result["$hour"] = deepcopy(hourly_results)
            end
        end
    end
    return DCCB_result, PD_result
end

function Case_3_PG_3GW(grid,h1=startHour,hn=number_of_hours)
    DCCB_result = Dict()
    PD_result = Dict()
    for hour in h1:hn
        hourly_grid = deepcopy(grid)
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_BE,"BE00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_FR,"FR00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_DE,"DE00")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_DK,"DKW1")
        _ACDC24.fix_hourly_load(hourly_grid,hour,load_series_UK,"UK00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_BE,wind_offshore_BE,solar_pv_BE,"BE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_FR,wind_offshore_FR,solar_pv_FR,"FR00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DE,wind_offshore_DE,solar_pv_DE,"DE00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_UK,wind_offshore_UK,solar_pv_UK,"UK00")
        _ACDC24.fix_RES_time_series_zone(hourly_grid,hour,wind_onshore_DK,wind_offshore_DK,solar_pv_DK,"DKW1")
        hourly_results = _PMACDC.solve_acdcopf(hourly_grid,formulation, optimizer; setting = s)
        if length(hourly_results["solution"]) > 5
            DCCB_result["$hour"] = deepcopy(hourly_results)
            EU_convs = ["7","11","12"]
            P_AC_EU = sum(hourly_results["solution"]["convdc"][c]["pconv"] for c in EU_convs)/2 # Power going into EU over one pole
            if P_AC_EU < -30.0 || P_AC_EU > 30.0
                hourly_grid["brachdc"]["7"]["status"] = 0
                hourly_results_pd = _PMACDC.solve_acdcopf(hourly_grid,formulation,optimizer; setting = s)
                PD_result["$hour"] = deepcopy(hourly_results_pd)
            else
                PD_result["$hour"] = deepcopy(hourly_results)
            end
        end
    end
    return DCCB_result, PD_result
end

function run_sim(grid::Dict,fType::String)
    PP_str_opts = ["PP","pole_to_pole","P2P","PoleToPole"]
    PG_str_opts = ["PG","pole_to_ground","P2G","PoleToGround"]
    if fType in PP_str_opts
        DCCB_result, PD_result = Case_3_PP(grid)
    elseif fType in PG_str_opts
        # if no lim argument is given, it is assumed that the 1GW limit for BE is used for PG faults
        DCCB_result, PD_result = Case_3_PG(grid)
    else
        println("fType not correctly specified")
        return
    end
    return DCCB_result, PD_result
end

function run_sim(grid::Dict,PP::Bool)
    if PP 
        DCCB_result, PD_result = Case_3_PP(grid)
    else
        DCCB_result, PD_result = Case_3_PG(grid)
    end
    return DCCB_result, PD_result
end

function run_sim(grid::Dict,fType::String,lim::String)
    PP_str_opts = ["PP","pole_to_pole","P2P","PoleToPole"]
    PG_str_opts = ["PG","pole_to_ground","P2G","PoleToGround"]
    if fType in PP_str_opts
        DCCB_result, PD_result = Case_3_PP(grid)
    elseif fType in PG_str_opts
        lim_EU_str_opts = ["3GW","EU","CESA"]
        lim_BE_str_opts = ["1GW","BE","BE00"]
        if lim in lim_EU_str_opts
            DCCB_result, PD_result = Case_3_PG_3GW(grid) 
        elseif lim in lim_BE_str_opts
            DCCB_result, PD_result = Case_3_PG(grid) 
        else
            printlm("lim for PG case not correctly specified")
            return
        end
    else    
        println("fType not correctly specified")
        return
    end
    return DCCB_result, PD_result
end

function run_sim(grid::Dict,PP::Bool,EU_lim::Bool)
    if PP
        DCCB_result, PD_result = Case_3_PP(grid)
    else
        if EU_lim 
            DCCB_result, PD_result = Case_3_PG_3GW(grid)
        else
            DCCB_result, PD_result = Case_3_PG(grid)
        end
    end
    return DCCB_result, PD_result
end


if scen == "low"
    result_DCCB, result_pd = run_sim(Case_3_low,fault_type,lim_loi)
elseif scen == "high"
    result_DCCB, result_pd = run_sim(Case_3_high,fault_type,lim_loi)
end

filename_dccb = "Case_3_CB_"*scen*"_"*fault_type*"_"*lim*".json"
filename_pd = "Case_3_PD_"*scen*"_"*fault_type*"_"*lim*".json"

dccb_res_str = JSON.json(result_DCCB)
pd_res_str = JSON.json(result_pd)

open(joinpath(folder_results,filename_dccb),"w") do f 
    write(f,dccb_res_str)
end

open(joinpath(folder_results,filename_pd),"w") do f 
    write(f,pd_res_str)
end