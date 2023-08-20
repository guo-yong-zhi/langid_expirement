struct WikiDataSet <: AbstractVector{Pair{String, String}}
    path
    lang_files
    data
end
function WikiDataSet(path; langs=readdir(path))
    lang_files = Dict(lang => readdir(joinpath(path, get(WLANGMAP, lang, lang))) for lang in langs)
    data = [file => lang for (lang, files) in lang_files for file in files]
    return WikiDataSet(path, lang_files, data)
end
function Base.size(wd::WikiDataSet)
    return size(wd.data)
end
function Base.getindex(wd::WikiDataSet, i)
    file, lang = wd.data[i]
    fn = joinpath(wd.path, get(WLANGMAP, lang, lang), file)
    return read(fn, String) => lang
end
getlanguages(wd::WikiDataSet) = keys(wd.lang_files)
sizeoflang(wd::WikiDataSet, lang) = length(wd.lang_files[lang])
struct TatoebaDataset <: AbstractVector{Pair{String, String}}
    path
    lang_lines
    data
end

function TatoebaDataset(path, index::AbstractDict; langs=[f[1:end-4] for f in readdir(path)])
    lang_lines = Dict(lang => index[get(TLANGMAP, lang, lang)] for lang in langs)
    data = Pair{String, String}[]
    for (lang, lines) in lang_lines
        text = readlines(joinpath(path, get(TLANGMAP, lang, lang) * ".txt"))
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
function Base.size(td::TatoebaDataset)
    return size(td.data)
end
function Base.getindex(td::TatoebaDataset, i)
    return td.data[i]
end
getlanguages(td::TatoebaDataset) = keys(td.lang_lines)
sizeoflang(td::TatoebaDataset, lang) = length(td.lang_lines[lang])
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

const TLANGS = ["ara", "bel", "ben", "bul", "cat", "ces", "dan", "deu", "ell", "eng", "epo", "pes", "fin",
 "fra", "hau", "srp", "heb", "hin", "hun", "ido", "ina", "isl", "ita", "jpn", "kab", "kor", "ckb", 
 "lat", "lit", "mar", "mkd", "ind", "nds", "nld", "nob", "pol", "por", "ron", "rus", "slk", "spa", 
 "swc", "swe", "tat", "tgl", "tur", "ukr", "vie", "yid", "cmn"]
const WLANGS = ["ar", "be", "bn", "bg", "ca", "cs", "da", "de", "el", 
"en", "eo", "fa", "fi", "fr", "ha", "sr", "he", "hi", "hu", "io", 
"ia", "is", "it", "ja", "kab", "ko", "ckb", "la", "lt", "mr", "mk",
 "id", "nds", "nl", "no", "pl", "pt", "ro", "ru", "sk", "es", "sw",
  "sv", "tt", "tl", "tr", "uk", "vi", "yi", "zh"]
const LANGS = ["ara", "bel", "ben", "bul", "cat", "ces", "dan", "deu", "ell", 
"eng", "epo", "fas", "fin", "fra", "hau", "hbs", "heb", "hin", "hun", 
"ido", "ina", "isl", "ita", "jpn", "kab", "kor", "kur", "lat", "lit", 
"mar", "mkd", "msa", "nds", "nld", "nor", "pol", "por", "ron", "rus", 
"slk", "spa", "swa", "swe", "tat", "tgl", "tur", "ukr", "vie", "yid", 
"zho"]

const WLANGMAP = Dict("epo" => "eo", "jpn" => "ja", "kor" => "ko", "ron" => "ro", "nds" => "nds", "fin" => "fi", "kab" => "kab", "bel" => "be", "tgl" => "tl", "heb" => "he", "tat" => "tt", "yid" => "yi", "swa" => "sw", "ara" => "ar", "hin" => "hi", "hbs" => "sr", "bul" => "bg", "mar" => "mr", "spa" => "es", "swe" => "sv", "fra" => "fr", "hun" => "hu", "cat" => "ca", "eng" => "en", "ina" => "ia", "deu" => "de", "dan" => "da", "ben" => "bn", "fas" => "fa", "por" => "pt", "nld" => "nl", "zho" => "zh", "rus" => "ru", "lat" => "la", "ukr" => "uk", "tur" => "tr", "ita" => "it", "kur" => "ckb", "hau" => "ha", "ell" => "el", "msa" => "id", "pol" => "pl", "lit" => "lt", "slk" => "sk", "nor" => "no", "ido" => "io", "vie" => "vi", "mkd" => "mk", "isl" => "is", "ces" => "cs")
const TLANGMAP = Dict("epo" => "epo", "jpn" => "jpn", "kor" => "kor", "ron" => "ron", "nds" => "nds", "fin" => "fin", "kab" => "kab", "bel" => "bel", "tgl" => "tgl", "heb" => "heb", "tat" => "tat", "yid" => "yid", "swa" => "swc", "ara" => "ara", "hin" => "hin", "hbs" => "srp", "bul" => "bul", "mar" => "mar", "spa" => "spa", "swe" => "swe", "fra" => "fra", "hun" => "hun", "cat" => "cat", "eng" => "eng", "ina" => "ina", "deu" => "deu", "dan" => "dan", "ben" => "ben", "fas" => "pes", "por" => "por", "nld" => "nld", "zho" => "cmn", "rus" => "rus", "lat" => "lat", "ukr" => "ukr", "tur" => "tur", "ita" => "ita", "kur" => "ckb", "hau" => "hau", "ell" => "ell", "msa" => "ind", "pol" => "pol", "lit" => "lit", "slk" => "slk", "nor" => "nob", "ido" => "ido", "vie" => "vie", "mkd" => "mkd", "isl" => "isl", "ces" => "ces")
const REV_WLANGMAP = Dict(v=>k for (k,v) in WLANGMAP)
const REV_TLANGMAP = Dict(v=>k for (k,v) in TLANGMAP)
nothing