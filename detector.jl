include("ngrams.jl")
include("datasetloader.jl")

const G = [lang => load_ngrams(joinpath("ngrams", lang * ".txt")) for lang in LANGS];

function norm_table!(t)
    D = last(t)
    vs = sum(values(D))
    for (k, v) in D
        D[k] /= vs
        D[k] = log(D[k])
    end
end
function likelihood(t, logt, default_logp=DEFAULT_LOGP)
    sc = 0.
    for (code, p) in t
        logq = get(logt, code, default_logp)
        sc += p * logq
    end
    sc
end
function detector_lh(text; ngram=5, languages=LANGS, logtable=LOG_T)
    t = merged_ngrams(text, ngram)
    lhs = likelihood.(Ref(t), logtable)
    languages[argmax(lhs)]
end
function detector_lh2(text; ngram=5, languages=LANGS, logtable=LOG_T2)
    t = merged_ngrams(text, ngram)
    lhs = likelihood.(Ref(t), logtable)
    languages[argmax(lhs)]
end
norm_table!.(G);
const LOG_T = last.(G);
const DEFAULT_LOGP = (minimum.(values.(last.((G))))|>minimum)
using Dictionaries
const LOG_T2 = Dictionary.(LOG_T)