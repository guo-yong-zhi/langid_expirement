include("datasetloader.jl")
include("benchmark.jl")
using LanguageIdentification
import LanguageIdentification as LI
using BSON

WV = WikiDataSet("corpus/wikipedia/test", langs=LI.supported_languages())
TV = TatoebaDataset("corpus/tatoeba", "corpus/tatoeba_test_index.txt", langs=LI.supported_languages())
path = isempty(ARGS) ? "benchmarks/matrix" : ARGS[1]
mkpath(path)

function run_bmk(name_dataset, name_paramlist, ngram_list=1:7; path, kwargs...)
    dataname, dataset = name_dataset
    paramname, paramlist = name_paramlist
    ckpfn = "$path/bmkmats-$paramname-$dataname.bson"
    if isfile(ckpfn)
        BSON.@load ckpfn bmkmats
        println(length(bmkmats), " items in ", ckpfn)
    else
        bmkmats = []
        println("no checkpoint found.")
    end
    log_file = "$path/bmkmats-$paramname-$dataname.md"
    redirect_stdio(stdout=log_file) do
        langs = LI.supported_languages()
        last_vocsize = 0
        @time for n in ngram_list
            for pa in paramlist
                LI.initialize(;ngram=n, (paramname => pa,)..., kwargs...)
                vocsize = sum(last.(LI.vocabulary_sizes()))
                if vocsize == last_vocsize
                    continue
                end
                last_vocsize = vocsize
                println("# $n-grams $pa-$paramname (average vocabulary: $(vocsize/length(langs)))")
                r = benchmark((n, pa) => langid, dataset=dataset, languages=langs) |> only
                push!(bmkmats, r)
                showtable(["$n-grams $pa-$paramname" => last(r)], langs)
                BSON.@save ckpfn bmkmats
                flush(stdout)
            end
        end
    end
end

vocabulary_list = [100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000]
cutoff_list = [0.5, 0.6, 0.7, 0.75, 0.8, 0.825, 0.85, 0.875, 0.9, 0.95, 1.0]
run_bmk("wikipedia" => WV, :vocabulary => vocabulary_list; cutoff=2, path=path)
run_bmk("wikipedia" => WV, :cutoff => cutoff_list; vocabulary=1000000, path=path)
run_bmk("tatoeba" => TV, :vocabulary => vocabulary_list; cutoff=2, path=path)
run_bmk("tatoeba" => TV, :cutoff => cutoff_list; vocabulary=1000000, path=path)

mkpath(path*"/singlegram")
ngram_list = [n:n for n in 1:7]
run_bmk("wikipedia" => WV, :vocabulary => vocabulary_list, ngram_list; cutoff=2, path=path*"/singlegram")
run_bmk("wikipedia" => WV, :cutoff => cutoff_list, ngram_list; vocabulary=1000000, path=path*"/singlegram")
run_bmk("tatoeba" => TV, :vocabulary => vocabulary_list, ngram_list; cutoff=2, path=path*"/singlegram")
run_bmk("tatoeba" => TV, :cutoff => cutoff_list, ngram_list; vocabulary=1000000, path=path*"/singlegram")