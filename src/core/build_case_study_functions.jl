function fix_BE_generators!(Base_grid)
    # gen 1 = BE other RES

    # BE gas
    Base_grid["gen"]["2"]["source_id"][2] = 2
    Base_grid["gen"]["2"]["index"] = 2

    # BE VOLL
    Base_grid["gen"]["3"]["source_id"][2] = 3
    Base_grid["gen"]["3"]["index"] = 3

    # BE Oil
    Base_grid["gen"]["4"]["source_id"][2] = 4
    Base_grid["gen"]["4"]["index"] = 4

    # BE PV
    Base_grid["gen"]["7"]["source_id"][2] = 7
    Base_grid["gen"]["7"]["index"] = 7

    # BE Nuclear
    Base_grid["gen"]["8"]["source_id"][2] = 8
    Base_grid["gen"]["8"]["index"] = 8

    # BE OnWF
    Base_grid["gen"]["9"]["source_id"][2] = 9
    Base_grid["gen"]["9"]["index"] = 9
end

function fix_UK_generators!(Base_grid)
    # Change gen numbers of UK generators 
    Base_grid["gen"]["501"] = deepcopy(Base_grid["gen"]["108"])
    Base_grid["gen"]["501"]["name"] = "UK_gas_capacity"
    Base_grid["gen"]["501"]["source_id"][2] = 501 
    Base_grid["gen"]["501"]["index"] = 501

    Base_grid["gen"]["502"] = deepcopy(Base_grid["gen"]["109"])
    Base_grid["gen"]["502"]["name"] = "UK_nuclear_capacity"
    Base_grid["gen"]["502"]["source_id"][2] = 502 
    Base_grid["gen"]["502"]["index"] = 502

    Base_grid["gen"]["503"] = deepcopy(Base_grid["gen"]["110"])
    Base_grid["gen"]["503"]["name"] = "UK_OWF_capacity"
    Base_grid["gen"]["503"]["source_id"][2] = 503
    Base_grid["gen"]["503"]["index"] = 503

    Base_grid["gen"]["504"] = deepcopy(Base_grid["gen"]["111"])
    Base_grid["gen"]["504"]["name"] = "UK_OnWF_capacity"
    Base_grid["gen"]["504"]["source_id"][2] = 504 
    Base_grid["gen"]["504"]["index"] = 504

    Base_grid["gen"]["505"] = deepcopy(Base_grid["gen"]["112"])
    Base_grid["gen"]["505"]["name"] = "UK_PV_capacity"
    Base_grid["gen"]["505"]["source_id"][2] = 505 
    Base_grid["gen"]["505"]["index"] = 505

    delete!(Base_grid["gen"],"108")
    delete!(Base_grid["gen"],"109")
    delete!(Base_grid["gen"],"110")
    delete!(Base_grid["gen"],"111")
    delete!(Base_grid["gen"],"112")
end

function fix_HVDC_capacity!(Base_grid)
    # Fixing link to UK capacity
    Base_grid["branchdc"]["4"]["rateA"] = 20.0
    Base_grid["branchdc"]["4"]["rateB"] = 20.0
    Base_grid["branchdc"]["4"]["rateC"] = 20.0

    # Fixing BE2 onsh capacity 
    Base_grid["convdc"]["12"]["Pacrated"] = 20.0
    Base_grid["convdc"]["12"]["Pacmax"] = 20.0
    Base_grid["convdc"]["12"]["Pacmin"] = - 20.0
    Base_grid["convdc"]["12"]["Qacmax"] = 10.0
    Base_grid["convdc"]["12"]["Qacmin"] = - 10.0

    # Fixing DK onsh capacity 
    Base_grid["convdc"]["11"]["Pacrated"] = 20.0
    Base_grid["convdc"]["11"]["Pacmax"] = 20.0
    Base_grid["convdc"]["11"]["Pacmin"] = - 20.0
    Base_grid["convdc"]["11"]["Qacmax"] = 10.0
    Base_grid["convdc"]["11"]["Qacmin"] = - 10.0

    # Making branchdc 7 capable to transfer full power between protection zones 
    Base_grid["branchdc"]["7"]["rateA"] = 40.0
    Base_grid["branchdc"]["7"]["rateB"] = 40.0
    Base_grid["branchdc"]["7"]["rateC"] = 40.0

    if haskey(Base_grid["convdc"],"10")
        Base_grid["convdc"]["10"]["Pacrated"] = 20.0
        Base_grid["convdc"]["10"]["Pacmax"] = 20.0
        Base_grid["convdc"]["10"]["Pacmin"] = - 20.0
        Base_grid["convdc"]["10"]["Qacmax"] = 10.0
        Base_grid["convdc"]["10"]["Qacmin"] = - 10.0
    end
    if haskey(Base_grid["branchdc"],"10")
        Base_grid["branchdc"]["10"]["rateA"] = 20.0
        Base_grid["branchdc"]["10"]["rateB"] = 20.0
        Base_grid["branchdc"]["10"]["rateC"] = 20.0
    end
end

function Remove_badCap!(Base_grid)
    # removing weird generators in DK so they can be re-added Later
    delete!(Base_grid["gen"],"209")
    delete!(Base_grid["gen"],"210")
    delete!(Base_grid["gen"],"211")
    delete!(Base_grid["gen"],"212")

    # Delete VOLL generators that will be added back

    delete!(Base_grid["gen"],"1001")
    delete!(Base_grid["gen"],"1002")
    delete!(Base_grid["gen"],"1003")
    delete!(Base_grid["gen"],"1004")
    delete!(Base_grid["gen"],"1005") 
    delete!(Base_grid["gen"],"1006")
    delete!(Base_grid["gen"],"1007")
    delete!(Base_grid["gen"],"1008")
    delete!(Base_grid["gen"],"1009")
    delete!(Base_grid["gen"],"1010")


end


function add_Load_Buses!(Base_grid)
    Base_grid["bus"]["2"] = deepcopy(Base_grid["bus"]["1"])
    Base_grid["bus"]["2"]["zone"] = "FR00"
    Base_grid["bus"]["2"]["bus_i"] = 2
    Base_grid["bus"]["2"]["full_namd_kV"] = "FR_aggregated_380"
    Base_grid["bus"]["2"]["name"] = "FR_aggregated"
    Base_grid["bus"]["2"]["source_id"][2] = 2
    Base_grid["bus"]["2"]["full_name"] = "FR_aggregated"
    Base_grid["bus"]["2"]["index"] = 2 
    Base_grid["bus"]["2"]["name_kV"] = "FR_aggregated_380"

    Base_grid["bus"]["3"] = deepcopy(Base_grid["bus"]["1"])
    Base_grid["bus"]["3"]["zone"] = "DE00"
    Base_grid["bus"]["3"]["bus_i"] = 3
    Base_grid["bus"]["3"]["full_namd_kV"] = "DE_aggregated_380"
    Base_grid["bus"]["3"]["name"] = "DE_aggregated"
    Base_grid["bus"]["3"]["source_id"][2] = 3
    Base_grid["bus"]["3"]["full_name"] = "DE_aggregated"
    Base_grid["bus"]["3"]["index"] = 3 
    Base_grid["bus"]["3"]["name_kV"] = "DE_aggregated_380"

    # DK bus already defined: 1380
    Base_grid["bus"]["1380"]["name_kV"] = "DK_aggregated_380"

    # UK bus already defined 
    Base_grid["bus"]["128"]["name"] = "UK_aggregated"
    Base_grid["bus"]["128"]["name_kV"] = "UK_aggregated_380"
    Base_grid["bus"]["128"]["full_name"] = "UK_aggregated"
    Base_grid["bus"]["128"]["full_name_kV"] = "UK_aggregated_380"
    
    # Fix Gezelle bus type 
    Base_grid["bus"]["420"]["bus_type"] = 2
end


function add_Loads!(Base_grid)
    Base_grid["load"]["4"] = deepcopy(Base_grid["load"]["1"])
    Base_grid["load"]["4"]["zone"] = "FR00"
    Base_grid["load"]["4"]["name_no_kV"] = "FR00"
    Base_grid["load"]["4"]["name"] = "FR00"
    Base_grid["load"]["4"]["full_name_kV"] = "FR_aggregated_380"
    Base_grid["load"]["4"]["full_name"] = "FR_aggregated"
    Base_grid["load"]["4"]["index"] = 4
    Base_grid["load"]["4"]["source_id"][2] = 4
    Base_grid["load"]["4"]["load_bus"] = 2 
    Base_grid["load"]["4"]["pmax"] = 450.0
    Base_grid["load"]["4"]["qmax"] = 220.0
    Base_grid["load"]["4"]["qmin"] = -220.0
    Base_grid["load"]["4"]["installed_capacity"] = 450.0
    Base_grid["load"]["4"]["mbase"] = 100.0
    Base_grid["load"]["4"]["flex"] = 0

    # Adding German load
    Base_grid["load"]["5"] = deepcopy(Base_grid["load"]["1"])
    Base_grid["load"]["5"]["zone"] = "DE00"
    Base_grid["load"]["5"]["name_no_kV"] = "DE00"
    Base_grid["load"]["5"]["name"] = "DE00"
    Base_grid["load"]["5"]["full_name_kVname"] = "DE00"
    Base_grid["load"]["5"]["full_name"] = "DE00"
    Base_grid["load"]["5"]["index"] = 5
    Base_grid["load"]["5"]["source_id"][2] = 5
end

function add_FR_low!(g_low)
    # Add FR generators
    # FR Gas capacity
    g_low["gen"]["208"] = deepcopy(g_low["gen"]["2"])
    g_low["gen"]["208"]["source_id"][2] = 208
    g_low["gen"]["208"]["index"] = 208
    g_low["gen"]["208"]["pmax"] = 131.33
    g_low["gen"]["208"]["qmax"] = 56.0
    g_low["gen"]["208"]["qmin"] = - 56.0
    g_low["gen"]["208"]["installed_capacity"] = 131.33
    g_low["gen"]["208"]["mbase"] = 100.0
    g_low["gen"]["208"]["substation_short_name"] = "FR00"
    g_low["gen"]["208"]["substation_short_name_kV"] = "FR00_380"
    g_low["gen"]["208"]["substation_full_name"] = "FR00"
    g_low["gen"]["208"]["substation_full_name_kV"] = "FR00_380"
    g_low["gen"]["208"]["substation"] = "FR00_380"
    g_low["gen"]["208"]["name"] = "FR_Gas_capacity"
    g_low["gen"]["208"]["gen_bus"] = 2
    g_low["gen"]["208"]["type"] = "Gas CCGT old 2 Bio"
    g_low["gen"]["208"]["zone"] = "FR00"

    # FR Nuclear capacity
    g_low["gen"]["209"] = deepcopy(g_low["gen"]["2"])
    g_low["gen"]["209"]["source_id"][2] = 209
    g_low["gen"]["209"]["index"] = 209
    g_low["gen"]["209"]["pmax"] = 713.70
    g_low["gen"]["209"]["qmax"] = 355.0
    g_low["gen"]["209"]["qmin"] = - 355.0
    g_low["gen"]["209"]["installed_capacity"] = 713.70
    g_low["gen"]["209"]["mbase"] = 100.0
    g_low["gen"]["209"]["substation_short_name"] = "FR00"
    g_low["gen"]["209"]["substation_short_name_kV"] = "FR00_380"
    g_low["gen"]["209"]["substation_full_name"] = "FR00"
    g_low["gen"]["209"]["substation_full_name_kV"] = "FR00_380"
    g_low["gen"]["209"]["substation"] = "FR00_380"
    g_low["gen"]["209"]["name"] = "FR_Nuclear_capacity"
    g_low["gen"]["209"]["gen_bus"] = 2
    g_low["gen"]["209"]["type"] = "Nuclear"
    g_low["gen"]["209"]["zone"] = "FR00"
    g_low["gen"]["209"]["cost"][1] = 110
    g_low["gen"]["209"]["C02_emission"] = 0

    # FR OWF capacity (low)
    g_low["gen"]["210"] = deepcopy(g_low["gen"]["2"])
    g_low["gen"]["210"]["source_id"][2] = 210
    g_low["gen"]["210"]["index"] = 210
    g_low["gen"]["210"]["pmax"] = 263.75
    g_low["gen"]["210"]["qmax"] = 31.0
    g_low["gen"]["210"]["qmin"] = - 31.0
    g_low["gen"]["210"]["installed_capacity"] = 263.75
    g_low["gen"]["210"]["mbase"] = 100.0
    g_low["gen"]["210"]["substation_short_name"] = "FR00"
    g_low["gen"]["210"]["substation_short_name_kV"] = "FR00_380"
    g_low["gen"]["210"]["substation_full_name"] = "FR00"
    g_low["gen"]["210"]["substation_full_name_kV"] = "FR00_380"
    g_low["gen"]["210"]["substation"] = "FR00_380"
    g_low["gen"]["210"]["name"] = "FR_capacity"
    g_low["gen"]["210"]["gen_bus"] = 2
    g_low["gen"]["210"]["zone"] = "FR00"
    g_low["gen"]["210"]["type"] = "Offshore Wind"
    g_low["gen"]["210"]["cost"][1] = 59
    g_low["gen"]["210"]["C02_emission"] = 0

    # FR OnWF capacity (low)
    g_low["gen"]["211"] = deepcopy(g_low["gen"]["2"])
    g_low["gen"]["211"]["source_id"][2] = 211
    g_low["gen"]["211"]["index"] = 211
    g_low["gen"]["211"]["pmax"] = 305.0
    g_low["gen"]["211"]["qmax"] = 173.5
    g_low["gen"]["211"]["qmin"] = - 173.5
    g_low["gen"]["211"]["installed_capacity"] = 305.0
    g_low["gen"]["211"]["mbase"] = 100.0
    g_low["gen"]["211"]["substation_short_name"] = "FR00"
    g_low["gen"]["211"]["substation_short_name_kV"] = "FR00_380"
    g_low["gen"]["211"]["substation_full_name"] = "FR00"
    g_low["gen"]["211"]["substation_full_name_kV"] = "FR00_380"
    g_low["gen"]["211"]["substation"] = "FR00_380"
    g_low["gen"]["211"]["name"] = "FR_OnWF_capacity"
    g_low["gen"]["211"]["gen_bus"] = 2
    g_low["gen"]["211"]["zone"] = "FR00"
    g_low["gen"]["211"]["type"] = "Onshore Wind"
    g_low["gen"]["211"]["cost"][1] = 25
    g_low["gen"]["211"]["C02_emission"] = 0

    # FR PV capacity (low)
    g_low["gen"]["212"] = deepcopy(g_low["gen"]["2"])
    g_low["gen"]["212"]["source_id"][2] = 212
    g_low["gen"]["212"]["index"] = 212
    g_low["gen"]["212"]["pmax"] = 470.0
    g_low["gen"]["212"]["qmax"] = 270.0
    g_low["gen"]["212"]["qmin"] = - 270.0
    g_low["gen"]["212"]["installed_capacity"] = 470.0
    g_low["gen"]["212"]["mbase"] = 100.0
    g_low["gen"]["212"]["substation_short_name"] = "FR00"
    g_low["gen"]["212"]["substation_short_name_kV"] = "FR00_380"
    g_low["gen"]["212"]["substation_full_name"] = "FR00"
    g_low["gen"]["212"]["substation_full_name_kV"] = "FR00_380"
    g_low["gen"]["212"]["substation"] = "FR00_380"
    g_low["gen"]["212"]["name"] = "FR_PV_capacity"
    g_low["gen"]["212"]["gen_bus"] = 2
    g_low["gen"]["212"]["zone"] = "FR00"
    g_low["gen"]["212"]["type"] = "Solar PV"
    g_low["gen"]["212"]["cost"][1] = 18
    g_low["gen"]["212"]["C02_emission"] = 0
end

function add_FR_high!(g_high)
    # FR Gas capacity
    g_high["gen"]["208"] = deepcopy(g_high["gen"]["2"])
    g_high["gen"]["208"]["source_id"][2] = 208
    g_high["gen"]["208"]["index"] = 208
    g_high["gen"]["208"]["pmax"] = 131.33
    g_high["gen"]["208"]["qmax"] = 56.0
    g_high["gen"]["208"]["qmin"] = - 56.0
    g_high["gen"]["208"]["installed_capacity"] = 131.33
    g_high["gen"]["208"]["mbase"] = 100.0
    g_high["gen"]["208"]["substation_short_name"] = "FR00"
    g_high["gen"]["208"]["substation_short_name_kV"] = "FR00_380"
    g_high["gen"]["208"]["substation_full_name"] = "FR00"
    g_high["gen"]["208"]["substation_full_name_kV"] = "FR00_380"
    g_high["gen"]["208"]["substation"] = "FR00_380"
    g_high["gen"]["208"]["name"] = "FR_Gas_capacity"
    g_high["gen"]["208"]["gen_bus"] = 2
    g_high["gen"]["208"]["type"] = "Gas CCGT old 2 Bio"
    g_high["gen"]["208"]["zone"] = "FR00"

    # FR Nuclear capacity
    g_high["gen"]["209"] = deepcopy(g_high["gen"]["2"])
    g_high["gen"]["209"]["source_id"][2] = 209
    g_high["gen"]["209"]["index"] = 209
    g_high["gen"]["209"]["pmax"] = 713.70
    g_high["gen"]["209"]["qmax"] = 355.0
    g_high["gen"]["209"]["qmin"] = - 355.0
    g_high["gen"]["209"]["installed_capacity"] = 713.70
    g_high["gen"]["209"]["mbase"] = 100.0
    g_high["gen"]["209"]["substation_short_name"] = "FR00"
    g_high["gen"]["209"]["substation_short_name_kV"] = "FR00_380"
    g_high["gen"]["209"]["substation_full_name"] = "FR00"
    g_high["gen"]["209"]["substation_full_name_kV"] = "FR00_380"
    g_high["gen"]["209"]["substation"] = "FR00_380"
    g_high["gen"]["209"]["name"] = "FR_Nuclear_capacity"
    g_high["gen"]["209"]["gen_bus"] = 2
    g_high["gen"]["209"]["type"] = "Nuclear"
    g_high["gen"]["209"]["zone"] = "FR00"
    g_high["gen"]["209"]["cost"][1] = 110
    g_high["gen"]["209"]["C02_emission"] = 0

    # FR OWF capacity (high)
    g_high["gen"]["210"] = deepcopy(g_high["gen"]["2"])
    g_high["gen"]["210"]["source_id"][2] = 210
    g_high["gen"]["210"]["index"] = 210
    g_high["gen"]["210"]["pmax"] = 266.62
    g_high["gen"]["210"]["qmax"] = 31.0
    g_high["gen"]["210"]["qmin"] = - 31.0
    g_high["gen"]["210"]["installed_capacity"] = 266.62
    g_high["gen"]["210"]["mbase"] = 100.0
    g_high["gen"]["210"]["substation_short_name"] = "FR00"
    g_high["gen"]["210"]["substation_short_name_kV"] = "FR00_380"
    g_high["gen"]["210"]["substation_full_name"] = "FR00"
    g_high["gen"]["210"]["substation_full_name_kV"] = "FR00_380"
    g_high["gen"]["210"]["substation"] = "FR00_380"
    g_high["gen"]["210"]["name"] = "FR_capacity"
    g_high["gen"]["210"]["gen_bus"] = 2
    g_high["gen"]["210"]["zone"] = "FR00"
    g_high["gen"]["210"]["type"] = "Offshore Wind"
    g_high["gen"]["210"]["cost"][1] = 59
    g_high["gen"]["210"]["C02_emission"] = 0

    # FR OnWF capacity (low)
    g_high["gen"]["211"] = deepcopy(g_high["gen"]["2"])
    g_high["gen"]["211"]["source_id"][2] = 211
    g_high["gen"]["211"]["index"] = 211
    g_high["gen"]["211"]["pmax"] = 610.0
    g_high["gen"]["211"]["qmax"] = 173.5
    g_high["gen"]["211"]["qmin"] = - 173.5
    g_high["gen"]["211"]["installed_capacity"] = 610.0
    g_high["gen"]["211"]["mbase"] = 100.0
    g_high["gen"]["211"]["substation_short_name"] = "FR00"
    g_high["gen"]["211"]["substation_short_name_kV"] = "FR00_380"
    g_high["gen"]["211"]["substation_full_name"] = "FR00"
    g_high["gen"]["211"]["substation_full_name_kV"] = "FR00_380"
    g_high["gen"]["211"]["substation"] = "FR00_380"
    g_high["gen"]["211"]["name"] = "FR_OnWF_capacity"
    g_high["gen"]["211"]["gen_bus"] = 2
    g_high["gen"]["211"]["zone"] = "FR00"
    g_high["gen"]["211"]["type"] = "Onshore Wind"
    g_high["gen"]["211"]["cost"][1] = 25
    g_high["gen"]["211"]["C02_emission"] = 0

    # FR PV capacity (low)
    g_high["gen"]["212"] = deepcopy(g_high["gen"]["2"])
    g_high["gen"]["212"]["source_id"][2] = 212
    g_high["gen"]["212"]["index"] = 212
    g_high["gen"]["212"]["pmax"] = 1430.0
    g_high["gen"]["212"]["qmax"] = 270.0
    g_high["gen"]["212"]["qmin"] = - 270.0
    g_high["gen"]["212"]["installed_capacity"] = 1430.0
    g_high["gen"]["212"]["mbase"] = 100.0
    g_high["gen"]["212"]["substation_short_name"] = "FR00"
    g_high["gen"]["212"]["substation_short_name_kV"] = "FR00_380"
    g_high["gen"]["212"]["substation_full_name"] = "FR00"
    g_high["gen"]["212"]["substation_full_name_kV"] = "FR00_380"
    g_high["gen"]["212"]["substation"] = "FR00_380"
    g_high["gen"]["212"]["name"] = "FR_PV_capacity"
    g_high["gen"]["212"]["gen_bus"] = 2
    g_high["gen"]["212"]["zone"] = "FR00"
    g_high["gen"]["212"]["type"] = "Solar PV"
    g_high["gen"]["212"]["cost"][1] = 18
    g_high["gen"]["212"]["C02_emission"] = 0

end

function add_DK_low!(g_low)

    # DK gas capacity
    g_low["gen"]["401"] = deepcopy(g_low["gen"]["2"])
    g_low["gen"]["401"]["source_id"][2] = 401
    g_low["gen"]["401"]["index"] = 401
    g_low["gen"]["401"]["pmax"] = 95.00
    g_low["gen"]["401"]["qmax"] = 42.50
    g_low["gen"]["401"]["qmin"] = - 42.5
    g_low["gen"]["401"]["installed_capacity"] = 95.00
    g_low["gen"]["401"]["mbase"] = 100.0
    g_low["gen"]["401"]["substation_short_name"] = "DKW1"
    g_low["gen"]["401"]["substation_short_name_kV"] = "DKW1_380"
    g_low["gen"]["401"]["substation_full_name"] = "DKW1"
    g_low["gen"]["401"]["substation_full_name_kV"] = "DKW1_380"
    g_low["gen"]["401"]["substation"] = "DKW1_380"
    g_low["gen"]["401"]["name"] = "DK_Gas_capacity"
    g_low["gen"]["401"]["gen_bus"] = 1380
    g_low["gen"]["401"]["type"] = "Gas CCGT old 2 Bio"
    g_low["gen"]["401"]["zone"] = "DKW1"

    #DK OWF capacity
    g_low["gen"]["402"] = deepcopy(g_low["gen"]["2"])
    g_low["gen"]["402"]["source_id"][2] = 402
    g_low["gen"]["402"]["index"] = 402
    g_low["gen"]["402"]["pmax"] = 100.72
    g_low["gen"]["402"]["qmax"] = 5.23
    g_low["gen"]["402"]["qmin"] = - 5.23
    g_low["gen"]["402"]["installed_capacity"] = 100.72
    g_low["gen"]["402"]["mbase"] = 100.0
    g_low["gen"]["402"]["substation_short_name"] = "DKW1"
    g_low["gen"]["402"]["substation_short_name_kV"] = "DKW1_380"
    g_low["gen"]["402"]["substation_full_name"] = "DKW1"
    g_low["gen"]["402"]["substation_full_name_kV"] = "DKW1_380"
    g_low["gen"]["402"]["substation"] = "DKW1_380"
    g_low["gen"]["402"]["name"] = "DK_OWF_capacity"
    g_low["gen"]["402"]["gen_bus"] = 1380
    g_low["gen"]["402"]["zone"] = "DKW1"
    g_low["gen"]["402"]["type"] = "Offshore Wind"
    g_low["gen"]["402"]["cost"][1] = 59.0
    g_low["gen"]["402"]["C02_emission"] = 0

    g_low["gen"]["403"] = deepcopy(g_low["gen"]["2"])
    g_low["gen"]["403"]["source_id"][2] = 403
    g_low["gen"]["403"]["index"] = 403
    g_low["gen"]["403"]["pmax"] = 35.00
    g_low["gen"]["403"]["qmax"] = 3.74
    g_low["gen"]["403"]["qmin"] = - 3.74
    g_low["gen"]["403"]["installed_capacity"] = 35.00
    g_low["gen"]["403"]["mbase"] = 100.0
    g_low["gen"]["403"]["substation_short_name"] = "DKW1"
    g_low["gen"]["403"]["substation_short_name_kV"] = "DKW1_380"
    g_low["gen"]["403"]["substation_full_name"] = "DKW1"
    g_low["gen"]["403"]["substation_full_name_kV"] = "DKW1_380"
    g_low["gen"]["403"]["substation"] = "DKW1_380"
    g_low["gen"]["403"]["name"] = "DK_OnWF_capacity"
    g_low["gen"]["403"]["gen_bus"] = 1380
    g_low["gen"]["403"]["zone"] = "DKW1"
    g_low["gen"]["403"]["type"] = "Onshore Wind"
    g_low["gen"]["403"]["cost"][1] = 25.0
    g_low["gen"]["403"]["C02_emission"] = 0

    g_low["gen"]["404"] = deepcopy(g_low["gen"]["2"])
    g_low["gen"]["404"]["source_id"][2] = 404
    g_low["gen"]["404"]["index"] = 404
    g_low["gen"]["404"]["pmax"] = 43.51
    g_low["gen"]["404"]["qmax"] = 4.96
    g_low["gen"]["404"]["qmin"] = - 4.96
    g_low["gen"]["404"]["installed_capacity"] = 43.51
    g_low["gen"]["404"]["mbase"] = 100.0
    g_low["gen"]["404"]["substation_short_name"] = "DKW1"
    g_low["gen"]["404"]["substation_short_name_kV"] = "DKW1_380"
    g_low["gen"]["404"]["substation_full_name"] = "DKW1"
    g_low["gen"]["404"]["substation_full_name_kV"] = "DKW1_380"
    g_low["gen"]["404"]["substation"] = "DKW1_380"
    g_low["gen"]["404"]["name"] = "DK_PV_capacity"
    g_low["gen"]["404"]["gen_bus"] = 1380
    g_low["gen"]["404"]["zone"] = "DKW1"
    g_low["gen"]["404"]["type"] = "Solar PV"
    g_low["gen"]["404"]["cost"][1] = 18.0
    g_low["gen"]["404"]["C02_emission"] = 0
end

function add_DK_high!(g_high)

    # DK gas capacity
    g_high["gen"]["401"] = deepcopy(g_high["gen"]["2"])
    g_high["gen"]["401"]["source_id"][2] = 401
    g_high["gen"]["401"]["index"] = 401
    g_high["gen"]["401"]["pmax"] = 95.00
    g_high["gen"]["401"]["qmax"] = 42.50
    g_high["gen"]["401"]["qmin"] = - 42.5
    g_high["gen"]["401"]["installed_capacity"] = 95.00
    g_high["gen"]["401"]["mbase"] = 100.0
    g_high["gen"]["401"]["substation_short_name"] = "DKW1"
    g_high["gen"]["401"]["substation_short_name_kV"] = "DKW1_380"
    g_high["gen"]["401"]["substation_full_name"] = "DKW1"
    g_high["gen"]["401"]["substation_full_name_kV"] = "DKW1_380"
    g_high["gen"]["401"]["substation"] = "DKW1_380"
    g_high["gen"]["401"]["name"] = "DK_Gas_capacity"
    g_high["gen"]["401"]["gen_bus"] = 1380
    g_high["gen"]["401"]["type"] = "Gas CCGT old 2 Bio"
    g_high["gen"]["401"]["zone"] = "DKW1"

    #DK OWF capacity
    g_high["gen"]["402"] = deepcopy(g_high["gen"]["2"])
    g_high["gen"]["402"]["source_id"][2] = 402
    g_high["gen"]["402"]["index"] = 402
    g_high["gen"]["402"]["pmax"] = 1000.246
    g_high["gen"]["402"]["qmax"] = 5.23
    g_high["gen"]["402"]["qmin"] = - 5.23
    g_high["gen"]["402"]["installed_capacity"] = 1000.246
    g_high["gen"]["402"]["mbase"] = 100.0
    g_high["gen"]["402"]["substation_short_name"] = "DKW1"
    g_high["gen"]["402"]["substation_short_name_kV"] = "DKW1_380"
    g_high["gen"]["402"]["substation_full_name"] = "DKW1"
    g_high["gen"]["402"]["substation_full_name_kV"] = "DKW1_380"
    g_high["gen"]["402"]["substation"] = "DKW1_380"
    g_high["gen"]["402"]["name"] = "DK_OWF_capacity"
    g_high["gen"]["402"]["gen_bus"] = 1380
    g_high["gen"]["402"]["zone"] = "DKW1"
    g_high["gen"]["402"]["type"] = "Offshore Wind"
    g_high["gen"]["402"]["cost"][1] = 59.0
    g_high["gen"]["402"]["C02_emission"] = 0

    g_high["gen"]["403"] = deepcopy(g_high["gen"]["2"])
    g_high["gen"]["403"]["source_id"][2] = 403
    g_high["gen"]["403"]["index"] = 403
    g_high["gen"]["403"]["pmax"] = 100.722
    g_high["gen"]["403"]["qmax"] = 3.74
    g_high["gen"]["403"]["qmin"] = - 3.74
    g_high["gen"]["403"]["installed_capacity"] = 100.722
    g_high["gen"]["403"]["mbase"] = 100.0
    g_high["gen"]["403"]["substation_short_name"] = "DKW1"
    g_high["gen"]["403"]["substation_short_name_kV"] = "DKW1_380"
    g_high["gen"]["403"]["substation_full_name"] = "DKW1"
    g_high["gen"]["403"]["substation_full_name_kV"] = "DKW1_380"
    g_high["gen"]["403"]["substation"] = "DKW1_380"
    g_high["gen"]["403"]["name"] = "DK_OnWF_capacity"
    g_high["gen"]["403"]["gen_bus"] = 1380
    g_high["gen"]["403"]["zone"] = "DKW1"
    g_high["gen"]["403"]["type"] = "Onshore Wind"
    g_high["gen"]["403"]["cost"][1] = 25.0
    g_high["gen"]["403"]["C02_emission"] = 0

    g_high["gen"]["404"] = deepcopy(g_high["gen"]["2"])
    g_high["gen"]["404"]["source_id"][2] = 404
    g_high["gen"]["404"]["index"] = 404
    g_high["gen"]["404"]["pmax"] = 478.10
    g_high["gen"]["404"]["qmax"] = 4.96
    g_high["gen"]["404"]["qmin"] = - 4.96
    g_high["gen"]["404"]["installed_capacity"] = 478.10
    g_high["gen"]["404"]["mbase"] = 100.0
    g_high["gen"]["404"]["substation_short_name"] = "DKW1"
    g_high["gen"]["404"]["substation_short_name_kV"] = "DKW1_380"
    g_high["gen"]["404"]["substation_full_name"] = "DKW1"
    g_high["gen"]["404"]["substation_full_name_kV"] = "DKW1_380"
    g_high["gen"]["404"]["substation"] = "DKW1_380"
    g_high["gen"]["404"]["name"] = "DK_PV_capacity"
    g_high["gen"]["404"]["gen_bus"] = 1380
    g_high["gen"]["404"]["zone"] = "DKW1"
    g_high["gen"]["404"]["type"] = "Solar PV"
    g_high["gen"]["404"]["cost"][1] = 18.0
    g_high["gen"]["404"]["C02_emission"] = 0
end

function add_DE_low!(g_low)

    # DE Gas
    g_low["gen"]["301"] = deepcopy(g_low["gen"]["2"])
    g_low["gen"]["301"]["source_id"][2] = 301
    g_low["gen"]["301"]["index"] = 301
    g_low["gen"]["301"]["pmax"] = 463.30
    g_low["gen"]["301"]["qmax"] = 181.65
    g_low["gen"]["301"]["qmin"] = - 181.65
    g_low["gen"]["301"]["installed_capacity"] = 463.30
    g_low["gen"]["301"]["mbase"] = 100.0
    g_low["gen"]["301"]["substation_short_name"] = "DE00"
    g_low["gen"]["301"]["substation_short_name_kV"] = "DE00_380"
    g_low["gen"]["301"]["substation_full_name"] = "DE00"
    g_low["gen"]["301"]["substation_full_name_kV"] = "DE00_380"
    g_low["gen"]["301"]["substation"] = "DE00_380"
    g_low["gen"]["301"]["name"] = "DK_gas_capacity"
    g_low["gen"]["301"]["gen_bus"] = 3
    g_low["gen"]["301"]["type"] = "Gas CCGT old 2 Bio"
    g_low["gen"]["301"]["zone"] = "DE00"

    # DE OWF
    g_low["gen"]["302"] = deepcopy(g_low["gen"]["2"])
    g_low["gen"]["302"]["source_id"][2] = 302
    g_low["gen"]["302"]["index"] = 302
    g_low["gen"]["302"]["pmax"] = 742.48
    g_low["gen"]["302"]["qmax"] = 5.23
    g_low["gen"]["302"]["qmin"] = - 5.23
    g_low["gen"]["302"]["installed_capacity"] = 742.48
    g_low["gen"]["302"]["mbase"] = 100.0
    g_low["gen"]["302"]["substation_short_name"] = "DE00"
    g_low["gen"]["302"]["substation_short_name_kV"] = "DE00_380"
    g_low["gen"]["302"]["substation_full_name"] = "DE00"
    g_low["gen"]["302"]["substation_full_name_kV"] = "DE00_380"
    g_low["gen"]["302"]["substation"] = "DE00_380"
    g_low["gen"]["302"]["name"] = "DK_OWF_capacity"
    g_low["gen"]["302"]["gen_bus"] = 3
    g_low["gen"]["302"]["zone"] = "DE00"
    g_low["gen"]["302"]["type"] = "Offshore Wind"
    g_low["gen"]["302"]["cost"][1] = 59.0
    g_low["gen"]["302"]["C02_emission"] = 0

    # DE OnWF
    g_low["gen"]["303"] = deepcopy(g_low["gen"]["2"])
    g_low["gen"]["303"]["source_id"][2] = 303
    g_low["gen"]["303"]["index"] = 303
    g_low["gen"]["303"]["pmax"] = 1588.75
    g_low["gen"]["303"]["qmax"] = 3.74
    g_low["gen"]["303"]["qmin"] = - 3.74
    g_low["gen"]["303"]["installed_capacity"] = 1588.75
    g_low["gen"]["303"]["mbase"] = 100.0
    g_low["gen"]["303"]["substation_short_name"] = "DE00"
    g_low["gen"]["303"]["substation_short_name_kV"] = "DE00_380"
    g_low["gen"]["303"]["substation_full_name"] = "DE00"
    g_low["gen"]["303"]["substation_full_name_kV"] = "DE00_380"
    g_low["gen"]["303"]["substation"] = "DE00_380"
    g_low["gen"]["303"]["name"] = "DK_OnWF_capacity"
    g_low["gen"]["303"]["gen_bus"] = 3
    g_low["gen"]["303"]["zone"] = "DE00"
    g_low["gen"]["303"]["type"] = "Onshore Wind"
    g_low["gen"]["303"]["cost"][1] = 25.0
    g_low["gen"]["303"]["C02_emission"] = 0

    g_low["gen"]["304"] = deepcopy(g_low["gen"]["2"])
    g_low["gen"]["304"]["source_id"][2] = 304
    g_low["gen"]["304"]["index"] = 304
    g_low["gen"]["304"]["pmax"] = 36587.5
    g_low["gen"]["304"]["qmax"] = 4.96
    g_low["gen"]["304"]["qmin"] = - 4.96
    g_low["gen"]["304"]["installed_capacity"] = 36587.5
    g_low["gen"]["304"]["mbase"] = 100.0
    g_low["gen"]["304"]["substation_short_name"] = "DE00"
    g_low["gen"]["304"]["substation_short_name_kV"] = "DE00_380"
    g_low["gen"]["304"]["substation_full_name"] = "DE00"
    g_low["gen"]["304"]["substation_full_name_kV"] = "DE00_380"
    g_low["gen"]["304"]["substation"] = "DE00_380"
    g_low["gen"]["304"]["name"] = "DK_PV_capacity"
    g_low["gen"]["304"]["gen_bus"] = 3
    g_low["gen"]["304"]["zone"] = "DE00"
    g_low["gen"]["304"]["type"] = "Solar PV"
    g_low["gen"]["304"]["cost"][1] = 18.0
    g_low["gen"]["304"]["C02_emission"] = 0

    g_low["gen"]["305"] = deepcopy(g_low["gen"]["2"])
    g_low["gen"]["305"]["source_id"][2] = 305
    g_low["gen"]["305"]["index"] = 305
    g_low["gen"]["305"]["pmax"] = 650.0
    g_low["gen"]["305"]["qmax"] = 4.96
    g_low["gen"]["305"]["qmin"] = - 4.96
    g_low["gen"]["305"]["installed_capacity"] = 650.0
    g_low["gen"]["305"]["mbase"] = 100.0
    g_low["gen"]["305"]["substation_short_name"] = "DE00"
    g_low["gen"]["305"]["substation_short_name_kV"] = "DE00_380"
    g_low["gen"]["305"]["substation_full_name"] = "DE00"
    g_low["gen"]["305"]["substation_full_name_kV"] = "DE00_380"
    g_low["gen"]["305"]["substation"] = "DE00_380"
    g_low["gen"]["305"]["name"] = "DK_capacity"
    g_low["gen"]["305"]["gen_bus"] = 3
    g_low["gen"]["305"]["zone"] = "DE00"
    g_low["gen"]["305"]["type"] = "Hard coal old 2 Bio"
    g_low["gen"]["305"]["type_tyndp"] = "Hard coal old 2 Bio"
    g_low["gen"]["305"]["cost"][1] = 180.0
end

function add_DE_high!(g_high)

    # DE Gas
    g_high["gen"]["301"] = deepcopy(g_high["gen"]["2"])
    g_high["gen"]["301"]["source_id"][2] = 301
    g_high["gen"]["301"]["index"] = 301
    g_high["gen"]["301"]["pmax"] = 463.30
    g_high["gen"]["301"]["qmax"] = 181.65
    g_high["gen"]["301"]["qmin"] = - 181.65
    g_high["gen"]["301"]["installed_capacity"] = 463.30
    g_high["gen"]["301"]["mbase"] = 100.0
    g_high["gen"]["301"]["substation_short_name"] = "DE00"
    g_high["gen"]["301"]["substation_short_name_kV"] = "DE00_380"
    g_high["gen"]["301"]["substation_full_name"] = "DE00"
    g_high["gen"]["301"]["substation_full_name_kV"] = "DE00_380"
    g_high["gen"]["301"]["substation"] = "DE00_380"
    g_high["gen"]["301"]["name"] = "DK_gas_capacity"
    g_high["gen"]["301"]["gen_bus"] = 3
    g_high["gen"]["301"]["type"] = "Gas CCGT old 2 Bio"
    g_high["gen"]["301"]["zone"] = "DE00"

    # DE OWF
    g_high["gen"]["302"] = deepcopy(g_high["gen"]["2"])
    g_high["gen"]["302"]["source_id"][2] = 302
    g_high["gen"]["302"]["index"] = 302
    g_high["gen"]["302"]["pmax"] = 742.48
    g_high["gen"]["302"]["qmax"] = 5.23
    g_high["gen"]["302"]["qmin"] = - 5.23
    g_high["gen"]["302"]["installed_capacity"] = 742.48
    g_high["gen"]["302"]["mbase"] = 100.0
    g_high["gen"]["302"]["substation_short_name"] = "DE00"
    g_high["gen"]["302"]["substation_short_name_kV"] = "DE00_380"
    g_high["gen"]["302"]["substation_full_name"] = "DE00"
    g_high["gen"]["302"]["substation_full_name_kV"] = "DE00_380"
    g_high["gen"]["302"]["substation"] = "DE00_380"
    g_high["gen"]["302"]["name"] = "DK_OWF_capacity"
    g_high["gen"]["302"]["gen_bus"] = 3
    g_high["gen"]["302"]["zone"] = "DE00"
    g_high["gen"]["302"]["type"] = "Offshore Wind"
    g_high["gen"]["302"]["cost"][1] = 59.0
    g_high["gen"]["302"]["C02_emission"] = 0

    # DE OnWF
    g_high["gen"]["303"] = deepcopy(g_high["gen"]["2"])
    g_high["gen"]["303"]["source_id"][2] = 303
    g_high["gen"]["303"]["index"] = 303
    g_high["gen"]["303"]["pmax"] = 1685.00
    g_high["gen"]["303"]["qmax"] = 3.74
    g_high["gen"]["303"]["qmin"] = - 3.74
    g_high["gen"]["303"]["installed_capacity"] = 1685.00
    g_high["gen"]["303"]["mbase"] = 100.0
    g_high["gen"]["303"]["substation_short_name"] = "DE00"
    g_high["gen"]["303"]["substation_short_name_kV"] = "DE00_380"
    g_high["gen"]["303"]["substation_full_name"] = "DE00"
    g_high["gen"]["303"]["substation_full_name_kV"] = "DE00_380"
    g_high["gen"]["303"]["substation"] = "DE00_380"
    g_high["gen"]["303"]["name"] = "DK_OnWF_capacity"
    g_high["gen"]["303"]["gen_bus"] = 3
    g_high["gen"]["303"]["zone"] = "DE00"
    g_high["gen"]["303"]["type"] = "Onshore Wind"
    g_high["gen"]["303"]["cost"][1] = 25.0
    g_high["gen"]["303"]["C02_emission"] = 0

    g_high["gen"]["304"] = deepcopy(g_high["gen"]["2"])
    g_high["gen"]["304"]["source_id"][2] = 304
    g_high["gen"]["304"]["index"] = 304
    g_high["gen"]["304"]["pmax"] = 40000.00
    g_high["gen"]["304"]["qmax"] = 4.96
    g_high["gen"]["304"]["qmin"] = - 4.96
    g_high["gen"]["304"]["installed_capacity"] = 40000.0
    g_high["gen"]["304"]["mbase"] = 100.0
    g_high["gen"]["304"]["substation_short_name"] = "DE00"
    g_high["gen"]["304"]["substation_short_name_kV"] = "DE00_380"
    g_high["gen"]["304"]["substation_full_name"] = "DE00"
    g_high["gen"]["304"]["substation_full_name_kV"] = "DE00_380"
    g_high["gen"]["304"]["substation"] = "DE00_380"
    g_high["gen"]["304"]["name"] = "DK_PV_capacity"
    g_high["gen"]["304"]["gen_bus"] = 3
    g_high["gen"]["304"]["zone"] = "DE00"
    g_high["gen"]["304"]["type"] = "Solar PV"
    g_high["gen"]["304"]["cost"][1] = 18.0
    g_high["gen"]["304"]["C02_emission"] = 0

    g_high["gen"]["305"] = deepcopy(g_high["gen"]["2"])
    g_high["gen"]["305"]["source_id"][2] = 305
    g_high["gen"]["305"]["index"] = 305
    g_high["gen"]["305"]["pmax"] = 650.0
    g_high["gen"]["305"]["qmax"] = 4.96
    g_high["gen"]["305"]["qmin"] = - 4.96
    g_high["gen"]["305"]["installed_capacity"] = 650.0
    g_high["gen"]["305"]["mbase"] = 100.0
    g_high["gen"]["305"]["substation_short_name"] = "DE00"
    g_high["gen"]["305"]["substation_short_name_kV"] = "DE00_380"
    g_high["gen"]["305"]["substation_full_name"] = "DE00"
    g_high["gen"]["305"]["substation_full_name_kV"] = "DE00_380"
    g_high["gen"]["305"]["substation"] = "DE00_380"
    g_high["gen"]["305"]["name"] = "DK_capacity"
    g_high["gen"]["305"]["gen_bus"] = 3
    g_high["gen"]["305"]["zone"] = "DE00"
    g_high["gen"]["305"]["type"] = "Hard coal old 2 Bio"
    g_high["gen"]["305"]["type_tyndp"] = "Hard coal old 2 Bio"
    g_high["gen"]["305"]["cost"][1] = 180.0
end

function add_UK_low!(g_low)
    # UK OWF
    g_low["gen"]["503"]["pmax"] = 951.58
    g_low["gen"]["503"]["installed_capacity"] = 951.58

    # UK OnWF
    g_low["gen"]["504"]["pmax"] = 222.71
    g_low["gen"]["504"]["installed_capacity"] = 222.71

    # UK PV
    g_low["gen"]["505"]["pmax"] = 258.90
    g_low["gen"]["505"]["installed_capacity"] = 258.90
end

function add_UK_high!(g_high)
    # UK OWF
    g_high["gen"]["503"]["pmax"] = 973.89
    g_high["gen"]["503"]["installed_capacity"] = 973.89

    # UK OnWF
    g_high["gen"]["504"]["pmax"] = 420.40
    g_high["gen"]["504"]["installed_capacity"] = 420.40

    # UK PV
    g_high["gen"]["505"]["pmax"] = 350.0
    g_high["gen"]["505"]["installed_capacity"] = 350.0
end

function add_BE_low!(g_low)
    # BE PV
    g_low["gen"]["7"]["pmax"] = 200.0
    g_low["gen"]["7"]["installed_capacity"] = 200.0

    # BE OnWF
    g_low["gen"]["9"]["pmax"] = 65.00
    g_low["gen"]["9"]["installed_capacity"] = 65.00

    # BE OWF (MOG1)
    g_low["gen"]["29"]["pmax"] = 43.60
    g_low["gen"]["29"]["installed_capacity"] = 43.60
end

function add_BE_high!(g_high)
    # BE PV
    g_high["gen"]["7"]["pmax"] = 350.0
    g_high["gen"]["7"]["installed_capacity"] = 350.0

    # BE OnWF
    g_high["gen"]["9"]["pmax"] = 93.50
    g_high["gen"]["9"]["installed_capacity"] = 93.50

    # BE OWF (MOG1)
    g_high["gen"]["29"]["pmax"] = 43.60
    g_high["gen"]["29"]["installed_capacity"] = 43.60
end

function add_VOLL!(grid)
    buses = [] 
    for l in eachindex(grid["bus"])
        push!(buses,l)
    end

    nB = length(buses)
    if nB < 100 
        ind_base = 9900
    elseif nB < 1000
        ind_base = 99000
    else
        println("too many buses")
    end
    for n in 1:nB
        i = ind_base+n 
        grid["gen"]["$i"] = deepcopy(grid["gen"]["1"])
        grid["gen"]["$i"]["gen_bus"] = parse(Int64,buses[n])
        grid["gen"]["$i"]["index"] = i
        grid["gen"]["$i"]["qmax"] = 99.99
        grid["gen"]["$i"]["cost"][1] = 200.0
        grid["gen"]["$i"]["pmax"] = 99.99
        grid["gen"]["$i"]["gen_type"] = "VOLL"
        grid["gen"]["$i"]["fuel_type"] = "VOLL"
        grid["gen"]["$i"]["type"] = "VOLL"
        grid["gen"]["$i"]["source_id"][2] = n
    end

end

function generator_values!(grid)
    gen_costs,inertia_constants,emission_factor_CO2,start_up_cost,emission_factor_NOx,emission_factor_SOx = gen_values()
    for (g_id,g) in grid["gen"]
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
    for (l_id,l) in grid["load"]
        if !haskey(l,"zone")
            l["zone"] = "BE00"
        end
        if !haskey(l,"flex")
            l["flex"] = 0
        end
    end
end

function fix_dcline_datatype!(Base_grid)
    Base_grid["dcline"] = Dict()
end