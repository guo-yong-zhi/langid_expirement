include("datasetloader.jl")
include("benchmark.jl")
using LanguageIdentification
using BSON

WV = WikiDataSet("corpus/wikipedia/test", langs=LANGS)
TV = TatoebaDataset("corpus/tatoeba", "corpus/tatoeba_test_index.txt", langs=LANGS)

path = isempty(ARGS) ? "benchmarks/compare" : ARGS[1]
mkpath(path)

# import Pkg; Pkg.add(["LanguageFinder", "LanguageDetect", "Languages"])

import LanguageFinder: LanguageFind
LanguageFinder_detector(t) = LanguageFind(t, 0).lang

import LanguageDetect: detect
LanguageDetect_detector(t) = first(detect(t)).language

import Languages: LanguageDetector, isocode
_Languages_detector = LanguageDetector()
function Languages_detector(t)
    l = _Languages_detector(t) |> first
    if l === nothing
        return ""
    else
        return l |> isocode
    end
end
using Logging
Logging.disable_logging(Logging.Info)

log_file = "$path/compare.md"
redirect_stdio(stdout=log_file) do
    println("## dataset: tatoeba")
    TB = benchmark(
        "LanguageIdentification.jl"=>langid,
        "Languages.jl"=>Languages_detector,
        "LanguageDetect.jl"=>LanguageDetect_detector,
        "LanguageFinder.jl"=>LanguageFinder_detector,
        dataset=TV, languages=LANGS)
    BSON.@save "$path/compare_tatoeba.bson" TB
    println()
    showtable(TB, LANGS, average=false); println()
    showtable(TB[1:2], LANGS, threshold=0.); println()
    showtable(TB[1:3], LANGS, threshold=0.); println()
    showtable(TB, LANGS, threshold=0.); println()
    flush(stdout)

    println("## dataset: wikipedia")
    WB = benchmark(
        "LanguageIdentification.jl"=>langid,
        "Languages.jl"=>Languages_detector, 
        "LanguageDetect.jl"=>LanguageDetect_detector,
        "LanguageFinder.jl"=>LanguageFinder_detector,
        dataset=WV, languages=LANGS)
    BSON.@save "$path/compare_wikipedia.bson" WB
    println()
    showtable(WB, LANGS, average=false); println()
    showtable(WB[1:2], LANGS, threshold=0.); println()
    showtable(WB[1:3], LANGS, threshold=0.); println()
    showtable(WB, LANGS, threshold=0.); println()
    flush(stdout)
end
