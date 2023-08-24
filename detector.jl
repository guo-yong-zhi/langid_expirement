include("ngrams.jl")
const PACKAGE_PATH = "."
const ALL_LANGUAGES = [f[1:end-4] for f in readdir(joinpath(PACKAGE_PATH, "ngrams"))]
const LANGUAGES = String[]
const PROFILES = Vector{Dict{Vector{UInt8}, Float32}}()
DEFAULT_LOGP::Float32 = typemin(Float32)
NGRAM::Int = 0

function get_supported_languages()
    return ALL_LANGUAGES
end

function initialize(;languages=get_supported_languages(), ngram=4, cutoff=0.85)
    empty!(LANGUAGES)
    append!(LANGUAGES, languages)
    empty!(PROFILES)
    for lang in LANGUAGES
        push!(PROFILES, load_profile(lang, ngram, cutoff))
    end
    global DEFAULT_LOGP = minimum(minimum.(values.(PROFILES)))
    global NGRAM = ngram
    nothing
end

function load_profile(lang, ngram, cutoff)
    hd, rows = ngram_table(joinpath(PACKAGE_PATH, "ngrams", lang * ".txt"))
    total = sum(hd[1:ngram])
    threshold = cutoff * total
    cums = 0.0
    P = Pair{Vector{UInt8}, Float32}[]
    for (k, v) in rows
        if length(k) <= ngram
            cums += v
            push!(P, k => v)
            if cums >= threshold
                break
            end
        end
    end
    cums >= threshold || @info "$lang: cutoff($cutoff) not reached. current: $(cums / total). vocab size: $(length(P))"
    normalize_profile!(Dict(P))
end

function normalize_profile!(P)
    vs = sum(values(P))
    map!(v -> log(v / vs), values(P))
    P
end

function loglikelihood(t, logt, default_logp=DEFAULT_LOGP)
    sc = 0.0
    for (code, p) in t
        logq = get(logt, code, default_logp)
        sc += p * logq
    end
    sc
end

function langid(text; ngram=NGRAM, languages=LANGUAGES, profiles=PROFILES)
    p = count_one_to_ngrams(text, ngram)
    lls = loglikelihood.(Ref(p), profiles)
    languages[argmax(lls)]
end

function langprob(text; candidates=5, ngram=NGRAM, languages=LANGUAGES, profiles=PROFILES)
    p = count_one_to_ngrams(text, ngram)
    vs = sum(values(p))
    map!(v -> v / vs, values(p))
    lls = loglikelihood.(Ref(p), profiles)
    ls = exp.(lls)
    ls = ls ./ sum(ls)
    si = sortperm(ls, rev=true)[1:candidates]
    [k => v for (k, v) in zip(languages[si], ls[si])]
end