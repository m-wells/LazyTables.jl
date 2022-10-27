Base.summary(io::IO, x::LazyTable) = print(io, 
    "LazyTable with ",
    length(propertynames(x)),
    " columns with ",
    length(x),
    " rows:",
)

Base.show(io::IO, x::LazyRow) = Base.show(io, (values(x)...,))

function Base.show(io::IO, ::MIME"text/plain", x::LazyTable)
    K = propertynames(x)

    x_isempty = isempty(x)
    # if x_isempty pretty_table wouldn't show anything if we just passed x
    x_show = x_isempty ? NamedTuple{K}(Iterators.repeated([nothing], length(K))) : x

    pretty_table(io, x_show;
        #-----------------------------------------------------------------------------------
        display_size = begin
            nrows, ncols = displaysize(io)
            # want previous prompt still visible to emulate Julia AbstractVectors
            (nrows - 2, ncols)
        end,
        #-----------------------------------------------------------------------------------
        # get OutOfMemory error if I try and just set this with Dict(0 => [r"\\."])
        alignment_anchor_regex = begin
            dict = Dict{Int, Vector{Regex}}()
            prop = Base.Fix1(getproperty, x)
            for (i, k) in enumerate(K)
                if eltype(prop(k)) <: AbstractFloat
                    dict[i] = [r"\\."]
                end
            end
            dict
        end,
        #-----------------------------------------------------------------------------------
        # hide "nothing" when empty
        formatters = x_isempty ? ft_nonothing : nothing,
        #-----------------------------------------------------------------------------------
        # make header explicit incase x_isempty
        header = (
            SVector(K),
            SVector(ntuple(i -> eltype(getproperty(x, @inbounds K[i])), length(K))),
        ),
        #-----------------------------------------------------------------------------------
        # center headers
        header_alignment = :c,
        #-----------------------------------------------------------------------------------
        linebreaks = true,
        #-----------------------------------------------------------------------------------
        # don't insert extra white space
        newline_at_end = false,
        #-----------------------------------------------------------------------------------
        # in the off chance that the columns are not vectors, show the indices, this is
        # currently broken in TypedTables
        row_labels = if ndims(x) > 1
            # this is to get the indices aligned on the comma
            # (the regex anchor doesn't apply to the row labels)
            cinds = CartesianIndices(axes(x))
            nx = length(x)
            y = Matrix{String}(undef, nx, ndims(x))
            for i in 1:nx # should be safe since cinds and y are one based
                ind = cinds[i].I
                s = string(ind)
                s = replace(s, "("=>"", ")"=>"")
                y[i, :] = split(s, ',')
            end
            for i in 1:ndims(x)
                v = view(y, :, i)
                n = maximum(length, v)
                @. v = lpad(v, n)
            end
            collect(String, join(y[i, :], ',') for i in 1:length(x))
        else
            nothing
        end,
        #-----------------------------------------------------------------------------------
        # center row labels
        row_label_alignment = :c,
        #-----------------------------------------------------------------------------------
        row_label_column_title = "index",
        #-----------------------------------------------------------------------------------
        row_number_column_title = "row",
        #-----------------------------------------------------------------------------------
        # not needed with title = summary
        show_omitted_cell_summary = false,
        #-----------------------------------------------------------------------------------
        # this is not redundant as row_labels only shows when ndims(x) > 1
        show_row_number = true,
        #-----------------------------------------------------------------------------------
        # show eltype of columns
        show_subheader = false,
        #-----------------------------------------------------------------------------------
        # let the title be the summary
        title = sprint(summary, x),
        #-----------------------------------------------------------------------------------
        # mimic the way Julia shows arrays
        vcrop_mode = :middle,
        #-----------------------------------------------------------------------------------
        # some small touches to polish if off without going overboard
        # round off the sharp edges
        tf = tf_unicode_rounded,
        # make sure not to use "white" or "black" to set font color
        # that would make an assumption about the user's colorscheme
        border_crayon = crayon"!bold",
        text_crayon = crayon"!bold",
        header_crayon = crayon"!bold",
        row_label_crayon = crayon"!bold",
        row_label_header_crayon = crayon"!bold",
        row_number_header_crayon = crayon"!bold",
        title_crayon = crayon"!bold",
    )
end
