using Zygote
include("ngrams.jl")
function normalize!(P::Dict{Vector{UInt8}, Float32})
    vs = sum(values(P))
    map!(v -> v / vs, values(P))
    P
end
sigmoid(x) = 1 / (1 + exp(-x))
logit(x) = -log((1 / x) - 1)
log_sigmoid(x) = -log1p(exp(-x)) # -softplus(-x)

mutable struct Model
    languages::Vector{String}
    langs_inds::Dict{String, Int}
    Qs::Vector{Dict{Vector{UInt8}, Float32}}
    default_q::Float32
    cutoff_list::Vector{Float32}
    ngram::Int
end

function Model(path::AbstractString)
    langs = [f[1:end-4] for f in readdir(path) if endswith(f, ".txt")]
    langs_inds = Dict(lang => i for (i, lang) in enumerate(langs))
    Qs = Vector{Dict{Vector{UInt8}, Float32}}()
    for lang in langs
        h, D = load_ngram_table(joinpath(path, lang * ".txt"))
        D = Dict(D)
        normalize!(D)
        map!(logit, values(D))
        push!(Qs, D)
    end
    cutoff_list = minimum.(values.(Qs))
    Model(langs, langs_inds, Qs, -4.0, cutoff_list, 7)
end

function loglikelihood(P, Q, default_q, cutoff)
    sc = 0.0
    for (code, p) in P
        if haskey(Q, code)
            q = Q[code]
            if q >= cutoff
                logq = log_sigmoid(q)
            else
                logq = log_sigmoid(default_q) + log_sigmoid(cutoff)
            end
        else
            logq = log_sigmoid(default_q) + log_sigmoid(cutoff) 
        end
        sc += p * logq
    end
    sc
end
function accuracy(lls, ys)
    argmax(lls) == argmax(ys)
end
function get_accuracy(params, p_ys::Tuple{<:AbstractDict, <:AbstractVector})
    p, ys = p_ys
    lls = [loglikelihood(p, Q, params.default_q, c)
            for (c, Q) in zip(params.cutoff_list, params.Qs)]
    accuracy(lls, ys)
end
function get_accuracy(params, batch::AbstractVector{<:Tuple{<:AbstractDict, <:AbstractVector}})
    sum(get_accuracy.(Ref(params), batch)) / length(batch)
end
function get_accuracy(model, data)
    get_accuracy(model, preprocess_data(data, model.ngram, model.langs_inds))
end
function loss(lls, ys)
    m = maximum(lls)
    sum(ys .* (log.(sum(exp.(lls .- m))) .+ m .- lls)) # softmax & cross entropy
end
function get_loss(params, p_ys::Tuple{<:AbstractDict, <:AbstractVector})
    p, ys = p_ys
    lls = [loglikelihood(p, Q, params.default_q, c)
            for (c, Q) in zip(params.cutoff_list, params.Qs)]
    loss(lls, ys)
end
function get_loss(params, batch::AbstractVector{<:Tuple{<:AbstractDict, <:AbstractVector}})
    sum(get_loss.(Ref(params), batch)) / length(batch)
end
function get_loss(model, data)
    get_loss(model, preprocess_data(data, model.ngram, model.langs_inds))
end
function preprocess_data(x_y::Union{Tuple, Pair}, ngram, langs_inds::Dict{String, Int})
    x, y = x_y
    yi = langs_inds[y]
    onehot = fill(Float32(0.1/(length(langs_inds)-1)), length(langs_inds))
    onehot[yi] = 0.9
    p = count_all_ngrams(x, ngram) |> normalize!
    (p, onehot)
end
function preprocess_data(data::AbstractVector, ngram, langs_inds::Dict{String, Int})
    [preprocess_data(d, ngram, langs_inds) for d in data]
end
function loss_and_grad(params, params_aux, p_ys)
    val, grad = withgradient(params) do params
        get_loss(merge(params, params_aux), p_ys)
    end
    val, grad[1]
end
function loss_and_grad(model::Model, data, ngram)
    params = (Qs=model.Qs, default_q=model.default_q)
    params_aux = (cutoff_list=model.cutoff_list,)
    data = preprocess_data(data, ngram, model.langs_inds)
    loss_and_grad(params, params_aux, data)
end
function step!(model::Model, grad, lr::Float32=0.01f0)
    if grad.default_q !== nothing
        model.default_q -= lr * 0.001 * grad.default_q
    end
    for (D1, D2) in zip(model.Qs, grad.Qs)
        D2 !== nothing && mergewith!((v1, v2) -> v1 - lr * v2, D1, D2)
    end
end

function cutoff_value_by_size(tb, ngram, s)
    vs = [v for (k, v) in tb if length(k)<=ngram]
    s >= length(vs) ? minimum(vs) : partialsort(vs, s, rev=true)
end
function cutoff_value_by_ratio(tb, ngram, r)
    logits = [v for (k, v) in tb if length(k)<=ngram]
    probs = sigmoid.(logits)
    si = sortperm(probs, rev=true)
    logits = logits[si]
    probs = probs[si]
    cs = cumsum(probs)
    ind = findfirst(x -> x >= r * cs[end], cs)
    ind === nothing ? minimum(logits) : logits[ind]
end
function cutoff_value_by_size(m::Model, ngram, s)
    for (i, tb) in enumerate(m.Qs)
        m.cutoff_list[i] = cutoff_value_by_size(tb, ngram, s)
    end
    m.ngram = ngram
end
function cutoff_value_by_ratio(m::Model, ngram, r)
    for (i, tb) in enumerate(m.Qs)
        m.cutoff_list[i] = cutoff_value_by_ratio(tb, ngram, r)
    end
    m.ngram = ngram
end

function random_cutoff(m::Model)
    ngram = rand([1:7; 3:7; 3:5])
    if rand() < 1.5
        cutoff_value_by_size(m, ngram, rand([100:5000; 100:10000; 100:20000; 20000:10:100000]))
    else
        cutoff_value_by_ratio(m, ngram, rand(0.5:0.001:1.0))
    end
end
