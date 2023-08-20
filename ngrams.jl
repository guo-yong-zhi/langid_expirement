function normalize_text(text; blacklist=["wikipedia", "tatoeba"])
    text = replace(text, r"https?://[-_.?&~;+=/#0-9A-Za-z]{1,2076}" => " ")
    text = replace(text, r"[-_.0-9A-Za-z]{1,64}@[-_0-9A-Za-z]{1,255}[-_.0-9A-Za-z]{1,255}" => " ")
    text = replace(text, r"[^\p{L}]" => " ")
    text = " $text "
    text = lowercase(text)
    for w in blacklist
        text = replace(text, w => " ")
    end
    text = replace(text, r"\s\s+" => " ")
end
function ngrams(text::AbstractString, n, counter=Dict{Vector{UInt8}, Float64}())
	text = transcode(UInt8, string(text))
	for i in 1:length(text)-n+1
        p = text[i:i+n-1]
        counter[p] = get(counter, p, 0.) + 1.
	end
    counter
end
function merged_ngrams(text::AbstractString, n=5, counter=Dict{Vector{UInt8}, Float64}())
    text = normalize_text(text)
	text = transcode(UInt8, string(text))
    for k in 1:n
        for i in 1:length(text)-k+1
            p = (text[i:i+k-1])
            counter[p] = get(counter, p, 0.) + 1.
        end
    end
    counter
end


function dataset_ngrams(dataset, n)
    counters = [Dict{Vector{UInt8}, Float64}() for i in 1:n]
    for (text,lang) in dataset
        text = normalize_text(text)
        for i in 1:n
            ngrams(text, i, counters[i])
        end
    end
    counters
end

function merged_dataset_ngrams(dataset, n)
    counter = Dict{Vector{UInt8}, Float64}()
    for (text,lang) in dataset
        merged_ngrams(text, n, counter)
    end
    counter
end

function Base.:*(n::Number, d::Dict)
    return typeof(d)((k, v*n) for (k, v) in d)
end

function Base.:+(d1::Dict, d2::Dict)
    mergewith(+, d1, d2)
end

function dump_ngrams(D, filename)
    open(filename, "w") do f
        for (k, v) in D
            @assert k isa Tuple{Vararg{UInt8}}
            write(f, join(string.(k, base=16), ""))
            write(f, ",")
            write(f, string(v))
            write(f, "\n")
        end
    end
end

function load_ngrams(filename)
    open(filename) do f
        D = []
        for line in eachline(f)
            k, v = split(line, ",")
            @assert iseven(length(k))
            k = parse.(UInt8, Iterators.partition(string(k), 2), base=16)
            push!(D, k => parse(Float64, v))
        end
        Dict(D)
    end
end
function dump_vocab(V, filename)
    open(filename, "w") do f
        for k in V
            @assert k isa Vector{UInt8}
            write(f, join(string.(k, base=16), ""))
            write(f, "\n")
        end
    end
end
function load_vocab(filename)
    open(filename) do f
        V = []
        for line in eachline(f)
            c = parse.(UInt8, Iterators.partition(string(line), 2), base=16)
            push!(V, c)
        end
        V
    end
end