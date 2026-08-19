using PowerModels; const _PM = PowerModels
using PowerModelsACDC; const _PMACDC = PowerModelsACDC
using JSON
import ACDC_2024_paper as _ACDC24 

# Manually building cases for Case 3  

folder_julia = dirname(@__DIR__)
folder_test_cases = joinpath(folder_julia,"Test_cases","Case_3")

Base_grid_file = abspath(joinpath(folder_julia,"Test_cases/Belgian_transmission_grid_synthetic_2023_with_DK.json"))
Base_grid = _PM.parse_file(Base_grid_file)
initial_system = deepcopy(Base_grid)

_ACDC24.Remove_badCap!(Base_grid)

_ACDC24.add_Load_Buses!(Base_grid)
_ACDC24.add_Loads!(Base_grid)

_ACDC24.fix_BE_generators!(Base_grid)
_ACDC24.fix_UK_generators!(Base_grid)

_ACDC24.fix_dcline_datatype!(Base_grid)

function remove_PEI_AC_lines!(Base_grid)
    delete!(Base_grid["branch"],"101")
    delete!(Base_grid["branch"],"102")
    delete!(Base_grid["branch"],"103")
    delete!(Base_grid["branch"],"104")
    delete!(Base_grid["branch"],"105")
    delete!(Base_grid["branch"],"106")
end

function change_OWF_Cap!(Base_grid)

    Base_grid["gen"]["101"]["name"] = "OWF_EI_1"
    Base_grid["gen"]["101"]["installed_capacity"] = 20
    Base_grid["gen"]["101"]["pmax"] = 20

    Base_grid["gen"]["102"]["name"] = "OWF_EI_2"
    Base_grid["gen"]["102"]["installed_capacity"] = 20
    Base_grid["gen"]["102"]["pmax"] = 20

end



function new_DC_con!(Base_grid)
    # New DC node for converter 4 connection to OWF_EI_2
    Base_grid["busdc"]["15"] = deepcopy(Base_grid["busdc"]["5"])
    Base_grid["busdc"]["15"]["name_no_kV"] = "EI_DC_2"
    Base_grid["busdc"]["15"]["full_name_kV"] = "EI_DC_2_525"
    Base_grid["busdc"]["15"]["name"] = "EI_DC_2_525"
    Base_grid["busdc"]["15"]["source_id"][2] = 15
    Base_grid["busdc"]["15"]["busdc_i"] = 15
    Base_grid["busdc"]["15"]["bus_name"] = "EI_DC_2_525"
    Base_grid["busdc"]["15"]["full_name"] = "EI_DC_2"
    Base_grid["busdc"]["15"]["index"] = 15

    # New converter between AC node 133 and DC busbar 15
    Base_grid["convdc"]["4"] = deepcopy(Base_grid["convdc"]["5"])
    Base_grid["convdc"]["4"]["source_id"][2] = 4
    Base_grid["convdc"]["4"]["busac_i"] = 133
    Base_grid["convdc"]["4"]["busdc_i"] = 15
    Base_grid["convdc"]["4"]["index"] = 4 

    # new DC bracnch from converter to central DC node busdc6
    Base_grid["branchdc"]["2"] = deepcopy(Base_grid["branchdc"]["3"])
    Base_grid["branchdc"]["2"]["fbusdc"] = 15
    Base_grid["branchdc"]["2"]["source_id"][2] = 2
    Base_grid["branchdc"]["2"]["HVDC_link"] = "EI_2 -> DC Switchyard"
    Base_grid["branchdc"]["2"]["index"] = 2

end

function change_DK_connection!(Base_grid)
    # Remove DK energy island from model and connect directly to onshore converter 
    
    # Changing connection point of triton link 
    Base_grid["branchdc"]["8"]["tbusdc"] = 13
    Base_grid["branchdc"]["8"]["HVDC_link"] = "Triton link"

    # Deleting Danish energy island
    delete!(Base_grid["busdc"],"11")
    delete!(Base_grid["busdc"],"12")

    delete!(Base_grid["bus"],"1381")
    delete!(Base_grid["bus"],"1382")

    delete!(Base_grid["branch"],"201")
    delete!(Base_grid["branchdc"],"10")

    delete!(Base_grid["convdc"],"10")
    delete!(Base_grid["convdc"],"10")

    delete!(Base_grid["gen"],"1381")
    delete!(Base_grid["gen"],"1382")
end

remove_PEI_AC_lines!(Base_grid)
change_OWF_Cap!(Base_grid)
new_DC_con!(Base_grid)
change_DK_connection!(Base_grid)

_ACDC24.fix_HVDC_capacity!(Base_grid)
# Interconnector rating is set to 4 GW in this function

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

_PMACDC.process_additional_data!(g_low)
_PMACDC.process_additional_data!(g_high)

filename_low = "Case_3_low.json"
filename_high = "Case_3_high.json"

open(joinpath(folder_test_cases,filename_low),"w") do f 
    write(f, JSON.json(g_low))
end

open(joinpath(folder_test_cases,filename_high),"w") do f 
    write(f, JSON.json(g_high))
end