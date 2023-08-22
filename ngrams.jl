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
function ngrams(text::AbstractString, n, counter=Dict{Vector{UInt8},Float64}())
    text = transcode(UInt8, string(text))
    for i in 1:length(text)-n+1
        p = text[i:i+n-1]
        counter[p] = get(counter, p, 0.0) + 1.0
    end
    counter
end
function merged_ngrams(text::AbstractString, n=5, counter=Dict{Vector{UInt8},Float64}())
    text = normalize_text(text)
    text = transcode(UInt8, string(text))
    for k in 1:n
        for i in 1:length(text)-k+1
            p = text[i:i+k-1]
            counter[p] = get(counter, p, 0.0) + 1.0
        end
    end
    counter
end


function dataset_ngrams(dataset, n)
    counters = [Dict{Vector{UInt8},Float64}() for i in 1:n]
    for (text, lang) in dataset
        text = normalize_text(text)
        for i in 1:n
            ngrams(text, i, counters[i])
        end
    end
    counters
end

function merged_dataset_ngrams(dataset, n)
    counter = Dict{Vector{UInt8},Float64}()
    for (text, lang) in dataset
        merged_ngrams(text, n, counter)
    end
    counter
end

function dump_ngrams(D, filename; head=nothing)
    open(filename, "w") do f
        if head !== nothing
            write(f, "total:")
            write(f, join(head, ","))
            write(f, "\n")
        end
        last_k = "###"
        last_v = 0.0
        for (k, v) in D
            @assert k isa Vector{UInt8}
            k = join(string.(k, base=16), "")
            kz = replace(k, last_k => "+")
            last_k = k
            write(f, kz)
            if last_v != v
                last_v = v
                write(f, ",")
                write(f, string(v))
            end
            write(f, "\n")
        end
    end
end

function load_ngrams(filename; head=true)
    open(filename) do f
        el = eachline(f)
        if head
            l1 = first(el)
            hd = parse.(Float64, split(split(l1, ":")[end], ","))
        end
        D = Vector{Pair{Vector{UInt8}, Float64}}()
        last_k = "###"
        last_v = 0.0
        for line in el
            kz_v = split(line, ",")
            if length(kz_v) == 1
                kz, v = kz_v[1], last_v
            else
                kz, v = kz_v
                v = parse(Float64, v)
                last_v = v
            end
            k = replace(kz, "+" => last_k)
            last_k = k
            @assert iseven(length(k))
            k = parse.(UInt8, Iterators.partition(string(k), 2), base=16)
            push!(D, k => v)
        end
        head ? (D, hd) : D
    end
end
