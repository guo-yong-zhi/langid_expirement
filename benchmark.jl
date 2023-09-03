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
    rows = format_rows(rows)
    tb = hcat((r->vcat(r...)).(rows)...)
    hd = (header isa Bool) ? header : [""; header]
    markdown_table(Tables.table(permutedims(tb), header=hd), String)|>print
    markdown_table(Tables.table(permutedims(tb), header=hd))
end
function format_rows(rows)
    fmt(v) = v isa Real ? (v>0 ? (@sprintf "%0.2f%%" v*100) : "-") : v
    maxvs = length(rows) > 1 ? max.(last.(rows)...) : fill(nothing, length(last(rows[1])))
    [nm => [(v==mv ? "**$(fmt(v))**" : fmt(v)) for (v, mv) in zip(vs, maxvs)] for (nm, vs) in rows]
end
function showtable_of_items(items; row_name=n->"$n", col_name=n->"$n", print_raw=true)
    rows = sort(unique(first.(first.(items))))
    cols = sort(unique(last.(first.(items))))
    mat = fill(NaN, length(rows), length(cols))
    for ((i, j), v) in items
        mat[findfirst(==(i), rows), findfirst(==(j), cols)] = v
    end
    row_names = row_name.(rows)
    col_names = col_name.(cols)
    fmt(v) = v isa Real ? (v>0 ? (@sprintf "%0.2f%%" v*100) : "-") : v
    print_raw && markdown_table(Tables.table([row_names mat], header=[""; col_names]), String, formatter=fmt)|>print
    markdown_table(Tables.table([row_names mat], header=[""; col_names]), formatter=fmt)
end