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
function ngrams(text::AbstractString, n, counter=Dict{Vector{UInt8},Float32}())
    text = transcode(UInt8, string(text))
    for i in 1:length(text)-n+1
        p = text[i:i+n-1]
        counter[p] = get(counter, p, 0.0) + 1.0
    end
    counter
end
function merged_ngrams(text::AbstractString, n=5, counter=Dict{Vector{UInt8},Float32}())
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
    counters = [Dict{Vector{UInt8},Float32}() for i in 1:n]
    for (text, lang) in dataset
        text = normalize_text(text)
        for i in 1:n
            ngrams(text, i, counters[i])
        end
    end
    counters
end

function merged_dataset_ngrams(dataset, n)
    counter = Dict{Vector{UInt8},Float32}()
    for (text, lang) in dataset
        merged_ngrams(text, n, counter)
    end
    counter
end

function lcs(s1::AbstractString, s2::AbstractString)
    m, n = length(s1), length(s2)
    len, pos1, pos2 = 0, 0, 0
    dp = zeros(Int, m + 1, n + 1)
    for i in 1:m
        for j in 1:n
            if s1[i] == s2[j]
                dp[i+1, j+1] = dp[i, j] + 1
                if dp[i+1, j+1] > len
                    len = dp[i+1, j+1]
                    pos1 = i
                    pos2 = j
                end
            end
        end
    end
    return pos1-len+1:pos1, pos2-len+1:pos2
end
function lcs_zip(str, refer) # `str` and `refer` must not contain any uppercase letters
    rg1, rg2 = lcs(refer, str)
    if length(rg1) > 2 || (length(rg1) == 2 && rg1[1] == 1)
        b1, e1 = first(rg1), last(rg1)
        b2, e2 = first(rg2), last(rg2)
        l1 = e1 - b1 + 1
        if b1 <= 26 && l1 <= 26
            bc = b1 == 1 ? "" : 'A' + (b1 - 1)
            lc = 'A' + (l1 - 1)
            str = string(str[1:b2-1], bc, lc, str[e2+1:end])
        end
    end
    str
end
function lcs_unzip(str, refer)
    b2 = findfirst(r"[A-Z]", str)
    if b2 !== nothing
        b2 = first(b2)
        b1 = str[b2] - 'A' + 1
        e2 = b2 + 1
        if e2 > length(str) || !('A' <= str[e2] <= 'Z')
            e2 = b2
            l1 = b1
            b1 = 1
        else
            l1 = str[e2] - 'A' + 1
        end
        e1 = b1 + l1 - 1
        str = string(str[1:b2-1], refer[b1:e1], str[e2+1:end])
    end
    str
end

function dump_ngram_table(head::Vector{Float32}, D, filename)
    open(filename, "w") do f
        write(f, "total:")
        write(f, join(head, ","))
        write(f, "\n")
        last_k = ""
        last_v = 0.0
        last_vstr = string(last_v)
        for (k, v) in D
            @assert k isa Vector{UInt8}
            k = join(string.(k, base=16), "")
            kz = lcs_zip(k, last_k)
            last_k = k
            write(f, kz)
            if last_v != v
                last_v = v
                write(f, ",")
                vstr = string(v)
                vstrz = lcs_zip(vstr, last_vstr)
                last_vstr = vstr
                write(f, vstrz)
            end
            write(f, "\n")
        end
    end
end

function ngram_table(filename)
    el = eachline(filename)
    l1 = first(el)
    hd = parse.(Float32, split(split(l1, ":")[end], ",", keepempty=false))
    function producer(c::Channel)
        last_k = ""
        last_v = 0.0
        last_vstr = string(last_v)
        for line in el
            kz_v = split(line, ",")
            if length(kz_v) == 1
                kz, v = kz_v[1], last_v
            else
                kz, vstrz = kz_v
                vstr = lcs_unzip(vstrz, last_vstr)
                last_vstr = vstr
                v = parse(Float32, vstr)
                last_v = v
            end
            k = lcs_unzip(kz, last_k)
            last_k = k
            @assert iseven(length(k))
            k = parse.(UInt8, Iterators.partition(string(k), 2), base=16)
            put!(c, k => v)
        end
    end
    hd,  Channel(producer)
end

function load_ngram_table(filename)
    hd, tb = ngram_table(filename)
    hd, collect(tb)
end
