include("datasetloader.jl")
include("train.jl")
include("trainutils.jl")

@show Threads.nthreads()
using BSON
using SampledVectors

logdir = isempty(ARGS) ? "trainlogs" : ARGS[1]
@show logdir
ckpfn = "$logdir/model.bson"
if isfile(ckpfn)
    BSON.@load ckpfn M train_loss val_loss val_accuracy default_q_list cutoff_list
    println("Loaded checkpoint. Current iter: $(length(train_loss)).")
else
    const PACKAGE_PATH = "."
    M = Model(joinpath(PACKAGE_PATH, "profiles"))
    train_loss = SampledVector{Float64}(4096*4)
    val_loss = SampledVector{Tuple{Int, Float64}}(4096*4)
    val_accuracy = SampledVector{Tuple{Int, Float64}}(4096*4)
    default_q_list = SampledVector{Float64}(4096*4)
    cutoff_list = SampledVector{Tuple{Int, Float64}}(4096*4)
    println("Training from scratch.")
end

WDs = [WikiDataSet("corpus/wikipedia/test", langs=[l]) for l in M.languages]
TDs = [TatoebaDataset("corpus/tatoeba", "tatoeba_test.txt", langs=[l]) for l in M.languages]
datasets = [WDs; TDs]
val_set = BatchedLoader(WeightedLoader(datasets, weights=log.(length.(datasets))), 2)
val_set_b10 = BatchedLoader(WeightedLoader(datasets, weights=log.(length.(datasets))), 10)

WDs = [WikiDataSet("corpus/wikipedia/train", langs=[l]) for l in M.languages]
TDs = [TatoebaDataset("corpus/tatoeba", "tatoeba_test.txt", langs=[l], negative_index=true) for l in M.languages]
datasets = [WDs; TDs]
train_set = BatchedLoader(WeightedLoader(datasets, weights=log.(length.(datasets))), 2)

mkpath(logdir)
for i in 1:8400*2*60
    l, grad = loss_and_grad(M, first(train_set), rand([1:M.ngram; 3:M.ngram; 3:min(5, M.ngram)]))
    step!(M, grad, 1f0)
    push!(train_loss, l)
    push!(default_q_list, M.default_q)
    iters = length(train_loss)
    if iters % 10 == 0
        l_val = get_loss(M, first(val_set))
        push!(val_loss, (length(train_loss), l_val))
        acc_val = get_accuracy(M, first(val_set_b10))
        push!(val_accuracy, (length(train_loss), acc_val))
    end
    if iters % 50 == 0
        plot_series("train_loss" => train_loss, "val_loss" => val_loss, title="loss", path=logdir)
        plot_series("val_accuracy" => val_accuracy, title="accuracy", path=logdir)
        plot_series("default_q" => default_q_list, path=logdir)
    end
    if iters % 100 == 0
        random_cutoff(M)
        push!(cutoff_list, (length(train_loss), sum(M.cutoff_list)/length(M.cutoff_list)))
        plot_series("cutoff" => cutoff_list, path=logdir)
    end
    if iters % 2000 == 0
        @BSON.save ckpfn M train_loss val_loss val_accuracy default_q_list cutoff_list
    end
end
@BSON.save ckpfn M train_loss val_loss val_accuracy default_q_list cutoff_list
@show length(train_loss)
