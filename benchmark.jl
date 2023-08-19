using Tables
using MarkdownTables
using Printf
include("iso639code.jl")
function bmk(detector, D, langs)
    tp = zeros(length(langs))
    total = zeros(length(langs))
    for (x, y) in D
        y = normcode(y, true)
        if y in langs
            ind = findfirst(isequal(y), langs)
            y_ = ""
            try
                y_ = normcode(detector(x))
            catch
                # println("Error: $detector($(repr(x)))")
            end
            if y_ == y
                tp[ind] += 1
            end
            total[ind] += 1
        end
    end
    tp ./ total
end
function benchmark(name_detector...; dataset, languages)
    name_bmk = []
    for (name, detector) in name_detector
        print(name)
        @time b = bmk(detector, dataset, languages)
        push!(name_bmk, name=>b)
    end
    name_bmk
end
function showtable(rows, header=true; average=true, threshold=-1)
    if threshold >= 0
        mask = true
        for (nm, vs) in rows
            mask = mask .& (vs .> threshold)
        end
        rows = [nm=>vs[mask] for (nm, vs) in rows]
        header = header[mask]
        println(length(mask), " columns in total, ", length(header), " columns left.")
    end
    if average
        rows = [nm=>[sum(vs)/length(vs); vs] for (nm, vs) in rows]
        header = ["Average"; header]
    end
    fmt(v) = v isa Real ? (v!=0 ? (@sprintf "%0.2f%%" v*100) : "-") : v
    tb = hcat((r->vcat(r...)).(rows)...)
    hd = (header isa Bool) ? header : [""; header]
    markdown_table(Tables.table(permutedims(tb), header=hd), String, formatter=fmt)|>print
    markdown_table(Tables.table(permutedims(tb), header=hd), formatter=fmt)
end