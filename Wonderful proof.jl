### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 228247ee-91d4-4661-b4a0-047dc148aa01
using LanguageFinder

# ╔═╡ 26eb2fe3-54ae-4ba3-a1ff-3500ef9076b5
begin
"""
Wikipedia corpus builder is designed to harvest random Wikipedia pages in a given 
language code such as es for Spanish and train the ngram weights based on these pages. 
The full list of the available languages can be found in https://en.wikipedia.org/wiki/List_of_Wikipedias
## Example
```julia 
julia> train_wikipedia_text("es", 10, 15)
julia> 
    "Successfully trained on 10 es wikipedia pages."
```
"""

using HTTP
using StatsBase


#=
The dictionaries is stored within text files with custom format.
This function reads the custom text format and build a dictionary variable.
Retruns the dictionary read from the text file.
=#

function read_dictionary(InputFile::String)
    f = open(InputFile)
    raw_text = readlines(f)
    close(f)    
    dictionary = Dict()
    for i in raw_text
        push!(dictionary,split(i)[1] => split(i)[2]) end
    return dictionary
end

#=
The dictionaries are written with specific format for later use.
Specifically each line ad key + " " + value. This function writes
a defined dictionary to a text file.
Retruns nothing.
=#

function write_dictionary(InputFile::String, DICT::Dict)
    f = open(InputFile, "w")
    for (key, value) in DICT
        println(f, key, " ", value) end
    close(f)
end

#=
The Wikipedia page request function. Each Wikipedia subdomain has different random page url, instead of 
requesting that url, there is a known random page url text file stored and automatically updated when
a new language WP code is used. ("Wikipedia_Random.txt") 
HTTP library is used to get the webpage and the body text is pipelined to string.
Retruns the String type webpage body text.
=#

function get_random_wikipedia_page(LANG_CODE::String)
    url = ""
    random_urls = read_dictionary(joinpath(dirname(pathof(LanguageFinder)),"Wikipedia", "Wikipedia_Random.txt"))
    if(haskey(random_urls, LANG_CODE))
        url = "https://" * LANG_CODE * ".wikipedia.org" * random_urls[LANG_CODE]
    else
        homepage = HTTP.get("https://" * LANG_CODE * ".wikipedia.org" * "/wiki/")
        str = homepage.body |> String
        start_point = findfirst("n-randompage", str).stop+3
        text_rest = str[start_point:end]
        random_href = SubString(text_rest, findall("\"", text_rest)[1].start+1, findall("\"", text_rest)[2].start-1)
        push!(random_urls, LANG_CODE => random_href)
        write_dictionary(joinpath(dirname(pathof(LanguageFinder)), "Wikipedia", "Wikipedia_Random.txt"), random_urls)  
        url = "https://" * LANG_CODE * ".wikipedia.org" * random_urls[LANG_CODE] end
    r = HTTP.get(url)
	title = replace(r.request.target, r"/" => "_")
    return title, r.body |> String
end

#=
The raw HTML string is not parsed as a tree and with a lot of standartized HTML tags.
It is necessary to take the useful string in between these tags. The extract element function
checks crawls in the HTML raw string and extract strings.
Retruns an Array of useful strings.
=#

function extract_elements(HTML::AbstractString, ELEMENT::String)
    open_p = findall("<"*ELEMENT, HTML)
    close_p = findall("</"*ELEMENT, HTML)
    arr = []
    try
        for i in 1:length(open_p)
            temp_text = SubString(HTML, open_p[i].start, close_p[i].stop+1) 
            push!(arr, temp_text) end catch x end
    return arr
end

#=
The strings removed from the HTML tags are still contaminated with the inline annotations with 
(),[],{} and etc. The text or other information inside is often not useful to train ngrams. 
This function cleans these special set charaters and the information inside.
Retruns a cleared string.
=#

function clean_inside_tags(TEXT::AbstractString, SYMBOL_START::String, SYMBOL_STOP::String)
    open_symbol = findall(SYMBOL_START, TEXT)
    close_symbol = findall(SYMBOL_STOP, TEXT)
    arr = []
    if(length(open_symbol) > 0 && length(close_symbol) > 0 && length(open_symbol) == length(close_symbol))
        for i in 1:min(length(open_symbol), length(close_symbol))   
            temp_text = SubString(TEXT, open_symbol[i].start, close_symbol[i].stop)
            push!(arr, temp_text) end end
    for j in arr
        TEXT = replace(TEXT, j => "") end
    return TEXT
end

#=
This function combines the extracting and cleaning most prominent sets from a random Wikipedia
page. It extract the text within the <p> tags (Always the case in Wikipedia). Then, utilize the 
clean_inside_tags function to clear <>, (), [] and {}.
Returns a String with clean text.
=#

function clean_text_wiki(HTML::AbstractString)
    temp_text = ""
    for i in extract_elements(HTML, "p")
        temp_text *= clean_inside_tags(clean_inside_tags(clean_inside_tags(clean_inside_tags(i, "<", ">"), "[", "]"), "(", ")"), "{", "}") end
    return temp_text
end

#=
The text is further processed by removing \n \r and \t character sequences. Any non-letter 
such as numbers, punctuation and etc. is removed. Lastly, all the spaces with more than 
single space is reduced to a single space. 
Returns a refined string ready to train.
=#

function process_text(TEXT::String)
    temp_text = replace(TEXT, r"[\n\r\t]" => " ")
    temp_text = replace(temp_text, r"[^\p{L}]" => " ")
    temp_text = replace(temp_text, r"\s\s+" => " ")
    return strip(lowercase(temp_text))
end

#=
Count letter map is used to build a unigram frequency dictionary.
The StatsBase countmap is used to extract the frequencies.
Returns a dictionary of counts
=#

function count_letter_map(TEXT::SubString)
    counts = Dict{Any,Int64}()
    counts = countmap(collect(TEXT))
    return counts
end

#=
A similar methodology can be followed for any ngram frequency.
count_n_grams iterates all the text and build a large array of
ngram characters then utilize StatsBase countmap.
Returns a dictionary of counts (ngrams).
=#

function count_n_grams(TEXT::SubString, n::Integer)
    arr = []
    collection = collect(TEXT)
    for i in 1:length(collection)-n+1
        temp_gram = ""
        for j in 1:n
            temp_gram *= collection[i+j-1] end
            push!(arr, temp_gram) end 
    counts = countmap(arr)
    return counts    
end

#=
The function is built for short hand to element-wise additon of 
dictionaries. 
Returns a dictionary where the same key values are combined. 
=#

function add_count_maps(DICT1::Dict, DICT2::Dict)
    return merge!(+, DICT1, DICT2)
end

#=
Read corpus is initially built to serve single purpose, it can read
a text file given a local path.
Returns the string contained in the text file.
=#

function read_corpus(PATH::String)
    s = ""
    open(PATH, "r") do f
        s=read(f, String) end
    return s
end

#=
The train corpus file takes an array as an input and ngram value to train.
The array input is useful to feed in multiple filepaths at once to train locally
with existing text files. It utilize previous functions.
Returns a sorted array of counts given an ngram value.
=#

function train_corpus(ARR::Array, n::Integer)
    map = Dict()
    map_c = Dict()
    for text in ARR
        input = read_corpus(text)
        if(n == 1) map = count_letter_map(process_text(input))
            else map = count_n_grams(process_text(input), n) end
        if(!isempty(map_c))
            map_c = add_count_maps(map, map_c)
        else
            map_c = map end end
    total_dict = sum(values(map_c))
    for (key,value) in map_c
        if(value < total_dict/10000)
            delete!(map_c, key) end end
    return sort(collect(map_c), by=x->x[2], rev=true)
end

#=
The train_wikipedia_text is the on demand spraping/training fuction.
It takes three parameters lang_code as WP of a Wikipedia page such as
es for Spanish or en for English. The pages is the number of pages to be
train on and lastly sleep time between each page request to not over burden
the Wikipedia servers; initially set to 10 seconds but 3 seconds is managable 
as well. 
It writes (or overwrites) the ngram text files used to detect the language.
Four ngram files are witten after training. Additionally a full corpus file
for later use is added under the corpus folder. 
Returns nothing.
=#

function train_wikipedia_text(lang_code::String, pages::Integer, sleep_time::Integer = 10)
    try HTTP.get("https://" * lang_code * ".wikipedia.org" * "/wiki/") catch x throw(ArgumentError("Invalid language code; check WP codes in https://en.wikipedia.org/wiki/List_of_Wikipedias")) end
    pages < 1 && throw(DomainError("pages must be integer and more than 0"))
    sleep_time < 0 && throw(DomainError("sleep time must be positive"))
    temp_text = ""
    counter = 0 
    try
        for i in 1:pages
            temp_text *= process_text(clean_text_wiki(get_random_wikipedia_page(lang_code))) * " "
            sleep(sleep_time)
            counter += 1 end
    finally
        f = open(joinpath(dirname(pathof(LanguageFinder)), "Wikipedia", "corpus", (lang_code*"_corpus.txt")), "a")
        print(f, temp_text)
        close(f)
        for j in 1:4
            temp_train = train_corpus([joinpath(dirname(pathof(LanguageFinder)),"Wikipedia", "corpus", (lang_code*"_corpus.txt"))], j)
            f = open(joinpath(dirname(pathof(LanguageFinder)), "Wikipedia", "ngrams", string(j), (lang_code *".txt")), "w")
            for (key, value) in temp_train
                println(f, key, ",", value) end
            close(f) end end
        counter == pages ? println("Successfully trained on ", counter, " ", lang_code, " wikipedia pages.") : println("Early termination due to error, trained on ", counter, " ", lang_code, " wikipedia pages.")
end
end

# ╔═╡ ef16d27a-1fcd-4d6f-8efa-faebc3c1ebbc

L = LanguageFinder.LanguageFind

# ╔═╡ 9386e82a-693b-435a-9b3b-e1ed29ccb3c8
t = get_random_wikipedia_page("zh")

# ╔═╡ 8ca915eb-a2f4-4f8c-86ef-65dddec9d9db
function html2text(content::AbstractString)
    patterns = [
        r"<[\s]*?script[^>]*?>[\s\S]*?<[\s]*?/[\s]*?script[\s]*?>" => " ",
        r"<[\s]*?style[^>]*?>[\s\S]*?<[\s]*?/[\s]*?style[\s]*?>" => " ",
        r"<!--[\s\S]*?-->" => " ",
        "<br>" => "\n",
        r"<[\s\S]*?>" => " ",
        "&nbsp;" => " ",
        "&quot;" => "\"",
        "&amp;" => "&",
        "&lt;" => "<",
        "&gt;" => ">",
        r"&#?\w{1,6};" => " ",
    ]
    for p in patterns
        content = replace(content, p)
    end
    content
end

# ╔═╡ 6d85aa37-3e13-4b1d-a2b1-0c0427554c89
function download_wikipedia_text(lang_code::String, pages::Integer=1, sleep_time::Integer = 10; path="corpus")
	lang_code = lowercase(lang_code)
    try HTTP.get("https://" * lang_code * ".wikipedia.org" * "/wiki/") catch x throw(ArgumentError("Invalid language code; check WP codes in https://en.wikipedia.org/wiki/List_of_Wikipedias")) end
    pages < 1 && throw(DomainError("pages must be integer and more than 0"))
    sleep_time < 0 && throw(DomainError("sleep time must be positive"))
	dirpath = joinpath(path, lang_code)
	mkpath(dirpath)
    try
        for i in 1:pages-length(readdir(dirpath))
            i != 1 && sleep(sleep_time)
            title, text = get_random_wikipedia_page(lang_code)
            text = clean_text_wiki(text)
            text = html2text(text)
            text = replace(text, r"\n\n+" => "\n")
			fn = joinpath(dirpath, title[1:min(200, end)]*".txt")
			println(abspath(fn))
			if ! isempty(text)
	            open(fn, "w") do f
	                write(f, text) 
	            end
			end
        end
	catch e
		throw(e)
    end
end

# ╔═╡ 4449cc0a-6a80-426f-a941-a8a12ab02c77
download_wikipedia_text("FR", 10, path=raw"C:\Users\momos\wikitexts")

# ╔═╡ b83a835f-0c73-4a98-80cd-06c65f6bff33
langs = ["ar", "cs", "da", "de", "el", "en", "es", "fa", "fi", "fr", "he", "hi", "hu", "it", "jp", "ko", "nl", "no", "pl", "pt", "ru", "sv", "tr", "uk", "zh"]



# ╔═╡ 9b32c7bf-53f1-4424-b6ae-ffe43a3c8aef
length(langs)

# ╔═╡ ad01e523-bf4e-49c6-b3fe-63967e3b0972
for lang in langs
	download_wikipedia_text(lang, 10, path=raw"C:\Users\momos\wikitexts")
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
LanguageFinder = "e8e009a8-4479-409b-a274-75b76d9b8a40"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
HTTP = "~0.9.17"
LanguageFinder = "~0.1.1"
StatsBase = "~0.33.21"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.1"
manifest_format = "2.0"
project_hash = "4eadf42c12678dd78f2364a8b298963ab524bcd2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "7a60c856b9fa189eb34f5f8a6f6b5529b7942957"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.2+0"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.LanguageFinder]]
deps = ["HTTP", "StatsBase"]
git-tree-sha1 = "bb3f83847b29961ae3b46e2a0e278824b9b70ef9"
uuid = "e8e009a8-4479-409b-a274-75b76d9b8a40"
version = "0.1.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "c3ce8e7420b3a6e071e0fe4745f5d4300e37b13f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.24"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OrderedCollections]]
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "c60ec5c62180f27efea3ba2908480f8055e17cee"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "45a7769a04a3cf80da1c1c7c60caf932e6f4c9f7"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.6.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═228247ee-91d4-4661-b4a0-047dc148aa01
# ╠═ef16d27a-1fcd-4d6f-8efa-faebc3c1ebbc
# ╟─26eb2fe3-54ae-4ba3-a1ff-3500ef9076b5
# ╠═9386e82a-693b-435a-9b3b-e1ed29ccb3c8
# ╠═8ca915eb-a2f4-4f8c-86ef-65dddec9d9db
# ╠═6d85aa37-3e13-4b1d-a2b1-0c0427554c89
# ╠═4449cc0a-6a80-426f-a941-a8a12ab02c77
# ╠═b83a835f-0c73-4a98-80cd-06c65f6bff33
# ╠═9b32c7bf-53f1-4424-b6ae-ffe43a3c8aef
# ╠═ad01e523-bf4e-49c6-b3fe-63967e3b0972
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
