-- acrostic grid

function init()
    acrostic={}
    acrostic.matrix_final={
        {52,47,48,43},
        {57,52,53,50},
        {60,55,57,59},
        {69,67,69,67},
        {60,59,60,59},
        {76,76,77,74}, 
    }
    ag_=include("gatherum/lib/acrosticgrid")
    ag=ag_:new()
end

