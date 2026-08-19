using PowerModels; const _PM = PowerModels
using PowerModelsACDC; const _PMACDC = PowerModelsACDC
using JSON
import ACDC_2024_paper as _ACDC24 

# Manually building cases for Case 2

folder_julia = dirname(@__DIR__)
folder_test_cases = joinpath(folder_julia,"Test_cases","Case_2")

Base_grid_file = abspath(joinpath(folder_julia,"Test_cases/Belgian_transmission_grid_synthetic_2023_with_DK.json"))
Base_grid = _PM.parse_file(Base_grid_file)
initial_system = deepcopy(Base_grid)

_ACDC24.Remove_badCap!(Base_grid)

_ACDC24.add_Load_Buses!(Base_grid)
_ACDC24.add_Loads!(Base_grid)

_ACDC24.fix_BE_generators!(Base_grid)
_ACDC24.fix_UK_generators!(Base_grid)

_ACDC24.fix_HVDC_capacity!(Base_grid)
# Currently, UK link capacity is 2 GW, should add something here if this is to be changed

g_low = deepcopy(Base_grid)
g_high = deepcopy(Base_grid)



_ACDC24.add_FR_high!(g_high)
_ACDC24.add_FR_low!(g_low)
_ACDC24.add_DK_high!(g_high)
_ACDC24.add_DK_low!(g_low)
_ACDC24.add_DE_high!(g_high)
_ACDC24.add_DE_low!(g_low)
_ACDC24.add_UK_low!(g_low)
_ACDC24.add_UK_high!(g_high)
_ACDC24.add_BE_low!(g_low)
_ACDC24.add_BE_high!(g_high)

_ACDC24.generator_values!(g_low)
_ACDC24.generator_values!(g_high)

_ACDC24.add_VOLL!(g_low)
_ACDC24.add_VOLL!(g_high)

filename_low = "Case_2_low.json"
filename_high = "Case_2_high.json"

open(joinpath(folder_test_cases,filename_low),"w") do f 
    write(f, JSON.json(g_low))
end

open(joinpath(folder_test_cases,filename_high),"w") do f 
    write(f, JSON.json(g_high))
end