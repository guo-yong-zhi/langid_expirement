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
end

function Model(path)
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
    default_q = minimum(minimum.(values.(Qs)))
    Model(langs, langs_inds, Qs, default_q)
end

function loglikelihood(P, Q, default_q)
    sc = 0.0
    for (code, p) in P
        q = haskey(Q, code) ? Q[code] : default_q
        sc += p * log_sigmoid(q)
    end
    sc
end
function loss(lls, ys)
    m = maximum(lls)
    sum(ys .* (log.(sum(exp.(lls .- m))) .+ m .- lls)) # softmax & cross entropy
end
function get_loss(params, p::AbstractDict, ys::AbstractVector)
    lls = [loglikelihood(p, Q, params.default_q) for Q in params.Qs]
    loss(lls, ys)
end
function get_loss(params, batch::AbstractVector{<:AbstractDict}, ys::AbstractMatrix)
    sum(get_loss.(Ref(params), batch, eachcol(ys))) / size(ys, 2)
end
function loss_and_grad(params, p, ys)
    val, grad = withgradient(params) do params
        get_loss(params, p, ys)
    end
    val, grad[1]
end
function preprocess_data(x::AbstractString, y::AbstractString, ngram)
    yi = M.langs_inds[y]
    onehot = zeros(Float32, length(M.languages))
    onehot[yi] = 1.0
    p = count_all_ngrams(x, ngram) |> normalize!
    (p, onehot)
end
function preprocess_data(data::AbstractVector, ngram)
    xys = [preprocess_data(x, y, ngram) for (x, y) in data]
    xs = [xy[1] for xy in xys]
    ys = hcat((xy[2] for xy in xys)...)
    xs, ys
end
function loss_and_grad(model::Model, args...; kwargs...)
    x, y = preprocess_data(args...; kwargs...)
    params = (Qs=model.Qs, default_q=model.default_q)
    loss_and_grad(params, x, y)
end
function step!(model, grad, lr=1e-3)
    model.default_q -= lr * grad.default_q
    for (D1, D2) in zip(model.Qs, grad.Qs)
        mergewith!((v1, v2) -> v1 - lr * v2, D1, D2)
    end
end