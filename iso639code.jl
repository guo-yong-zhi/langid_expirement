# https://iso639-3.sil.org/code_tables/download_tables
using DataFrames
using CSV
T = DataFrame(CSV.File(raw"iso-639-3_Code_Tables_20230123\iso-639-3_20230123.tab"))
MT = DataFrame(CSV.File(raw"iso-639-3_Code_Tables_20230123\iso-639-3-macrolanguages_20230123.tab"))
T = coalesce.(T, "")
MT = coalesce.(MT, "")
part1toid(c) = T[T[!, :Part1] .== c, :][:, :Id]|>only
id2mid(c) = MT[MT[!, :I_Id] .== c, :][:, :M_Id]|>only
function normcode(c, check=false)
    if occursin("-", c)
        c = split(c, "-")[1]
    end
    if c in T[!, :Part1]
        c = part1toid(c)
    end
    if c in MT[!, :I_Id]
        c = id2mid(c)
    end
    if check
        c in T[!, :Id] || println("missing $c")
    end
    c in T[!, :Id] ? c : "?$c"
end