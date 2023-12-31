include("datasetloader.jl")
include("ngrams.jl")

function cutoff_point(D, r)
    cs = cumsum(last.(D))
    findfirst(x -> x >= r * cs[end], cs)
end
function sum_ngrams(D)
    counter = Float32[]
    for (k, v) in D
        n = length(k)
        while length(counter) < n
            push!(counter, 0.0)
        end
        counter[n] += v
    end
    counter
end
function norm_ngrams_dict(Ds, ratio, minfreq, maxsize)
    S = mergewith(+, Ds...)
    tokens_list = []
    vocab_list = []
    for D in Ds
        tokens = sum(v for (k, v) in D if length(k) == 1)
        push!(tokens_list, tokens)
        push!(vocab_list, length(D))
        sc = log(tokens) / tokens
        for (k, v) in D
            D[k] *= sc
        end
    end
    G = mergewith(+, Ds...)
    sG = sort(collect(G), by=i -> (-last(i), length(first(i)), first(i)))
    cp1 = cutoff_point(sG, ratio)
    cp2 = findfirst(k -> S[k] < minfreq, first.(sG)) - 1
    cp = min(cp1, cp2, maxsize)
    println("total vocab: $(length(S)/1000)k; tokens: $(sum(vocab_list)/1e6)M;",
    " dataset ratio: $(vocab_list[1:end]/sum(vocab_list))(vocab) $(tokens_list/sum(tokens_list))(token)")
    println("Profile size: $(cp/1000)k($(round(cp/length(sG)*100))%) @freq=$(S[sG[cp][1]]); [min($cp1, $cp2)]")
    sum_ngrams(sG), sG[1:cp]
end

function build_ngram_profile(lang; ngram=7, ratio=0.9, minfreq=10, maxsize=100000, blacklist=["wikipedia", "tatoeba"])
    D1 = TatoebaDataset("corpus/tatoeba", "tatoeba_train.txt", langs=[lang])
    D2 = WikiDataSet("corpus/wikipedia/train", langs=[lang])
    println("# ", lang)
    norm_ngrams_dict(count_dataset_all_ngrams.([D1, D2], ngram, blacklist=blacklist), ratio, minfreq, maxsize)
end

function build_ngram_profiles(langs, path; ngram=7, ratio=0.9, minfreq=10, maxsize=100000, kwargs...)
    mkpath(path)
    for lang in langs
        @time h, D = build_ngram_profile(lang, ngram=ngram, ratio=ratio, minfreq=minfreq, maxsize=maxsize; kwargs...)
        dump_ngram_table(h, D, joinpath(path, "$lang.txt"))
        flush(stdout)
    end
end
