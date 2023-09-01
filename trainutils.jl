
ENV["GKSwstype"]="nul"
using Plots
default(display_type=:inline)
gr()
function plot_series(names_values...; title=nothing, path=".")
    fig = plot()
    if title === nothing
        title = only(names_values)[1]
    end
    title!(fig, title)
    y_m = Inf
    y_M = -Inf
    colors = Plots.palette(:Dark2_5)
    for (i,(name, value)) in enumerate(names_values)
        isempty(value) && continue
        y = sampled(value)
        if !(eltype(y) <: Real)
            x = first.(y)
            y = last.(y)
        else
            x = collect(sampledindexes(value))
        end
        fig = plot!(x, y, label="", linecolor=alphacolor(colors[i], 0.2))
        ylims!(fig, quantile(y, (0.005, 0.995)))
        step = max(1, length(y) ÷ 50)
        y_ = mean.(Iterators.partition(y, step))
        x_ = x[1:step:end]
        fig = plot!(x_, y_, label=name, linecolor=colors[i], linewidth=2)
        m, M = extrema(y_)
        y_m = min(y_m, m)
        y_M = max(y_M, M)
    end
    savefig("$path/$(title).png")
    extr = (y_m, y_M)
    if sum(abs.(extr .- ylims(fig))) > only(diff(collect(extr)))
        title!(fig, "$title zoom")
        ylims!(fig, extr)
        savefig("$path/$(title)-zoom.png")
    end
end