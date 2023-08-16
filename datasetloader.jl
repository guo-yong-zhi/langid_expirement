struct WikiDataSet
    path
    lang_files
    data
end
function WikiDataSet(path; langs=readdir(path))
    lang_files = Dict(lang => readdir(joinpath(path, lang)) for lang in langs)
    data = [file => lang for (lang, files) in lang_files for file in files]
    return WikiDataSet(path, lang_files, data)
end
function Base.length(wd::WikiDataSet)
    return length(wd.data)
end
function Base.getindex(wd::WikiDataSet, i)
    file, lang = wd.data[i]
    fn = joinpath(wd.path, lang, file)
    return read(fn, String), lang
end
function Base.iterate(wd::WikiDataSet, i=1)
    if i > length(wd)
        return nothing
    else
        return wd[i], i+1
    end
end
struct TatoebaDataset
    path
    lang_lines
    data
end

function TatoebaDataset(path, index::AbstractDict; langs=[f[1:end-4] for f in readdir(path)])
    lang_lines = Dict(lang => index[lang] for lang in langs)
    data = Pair{String, String}[]
    for (lang, lines) in lang_lines
        text = readlines(joinpath(path, lang * ".txt"))
        for line in lines
            push!(data, text[line] => lang)
        end
    end
    return TatoebaDataset(path, lang_lines, data)
end
function TatoebaDataset(path, index::AbstractString; kwargs...)
    lang_lines = load_index(index)
    return TatoebaDataset(path, lang_lines; kwargs...)
end
function TatoebaDataset(path; langs=[f[1:end-4] for f in readdir(path)], kwargs...)
    lang_lines = Dict(lang => collect(1:countlines(joinpath(path, lang * ".txt"))) for lang in langs)
    return TatoebaDataset(path, lang_lines; kwargs...)
end
function Base.length(td::TatoebaDataset)
    return length(td.data)
end
function Base.getindex(td::TatoebaDataset, i)
    return td.data[i]
end
function Base.iterate(td::TatoebaDataset, i=1)
    if i > length(td)
        return nothing
    else
        return td[i], i+1
    end
end


using Random
struct RandomLoader
    data
    idxs
end
function RandomLoader(data)
    idxs = shuffle(1:length(data))
    return RandomLoader(data, idxs)
end
function Base.length(rl::RandomLoader)
    return length(rl.idxs)
end
function Base.getindex(rl::RandomLoader, i)
    return rl.data[rl.idxs[i]]
end
function Base.iterate(rl::RandomLoader, i=1)
    if i > length(rl)
        shuffle!(rl.idxs)
        return nothing
    else
        return rl[i], i+1
    end
end

function dump_index(index, filename)
    open(filename, "w") do f
        for (k, vs) in index
            write(f, k)
            write(f, ",")
            for v in vs
                write(f, " $v")
            end
            write(f, "\n")
        end
    end
end
function load_index(filename)
    index = Dict()
    open(filename) do f
        for line in eachline(f)
            parts = split(line, ",")
            k = parts[1]
            vs = parse.(Int, split(parts[2], " ", keepempty=false))
            index[k] = vs
        end
    end
    return index
end
