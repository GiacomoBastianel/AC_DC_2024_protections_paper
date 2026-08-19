module ACDC_2024_paper

    import PowerModels; const _PM = PowerModels
    import PowerModelsACDC; const _PMACDC = PowerModelsACDC
    import Feather as ftr
    import CSV as _CSV
    using DataFrames
    # import InfrastructureModels; const _IM = InfrastructureModels

    const dataDir = joinpath(dirname(@__DIR__),"data")
    include("core/load_data.jl")
    include("core/build_grid_data.jl")
    include("core/build_case_study_functions.jl")
end
