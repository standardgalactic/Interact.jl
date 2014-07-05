
using DataStructures
import Base.convert

export Label, Slider, ToggleButton, Button, Options, Checkbox,
       Textbox, Textarea, RadioButtons, Dropdown, Select

# A type for values with labels (e.g. radio button options)
typealias Label{T} OrderedDict{String, T}

convert{T}(::Type{Label{T}}, x::T) = Label(x)

########################## Slider ############################

type Slider{T<:Number} <: InputWidget{T}
    input::Input{T}
    label::String
    value::T
    range::Range{T}
end

Slider{T}(range::Range{T};
          value=first(range),
          input=Input(value),
          label="") =
              Slider(input, label, value, range)

######################### Checkbox ###########################

type Checkbox <: InputWidget{Bool}
    input::Input{Bool}
    label::String
    value::Bool
end

Checkbox(; input=Input(false), label="", value=false) =
    Checkbox(input, label, value)

###################### ToggleButton ########################

type ToggleButton <: InputWidget{Bool}
    input::Input{Bool}
    label::String
    value::Bool
end

ToggleButton(; input=Input(false), label="", value=false) =
    ToggleButton(input, label, value)

ToggleButton(label; kwargs...) =
    ToggleButton(label=label; kwargs...)

######################### Button ###########################

type Button <: InputWidget{Nothing}
    input::Input{Nothing}
    label::String
    value::Nothing
    Button(inp::Input{Nothing}, l::String) =
        new(inp, l, nothing)
end

Button(label; input=Input(nothing)) =
    Button(input, label)

######################## Textbox ###########################

type Textbox{T <: Union(Number, String)} <: InputWidget{T}
    input::Input{T}
    label::String
    range::Union(Nothing, Range)
    value::T
end

function empty(t::Type)
    if is(t, Number) zero(t)
    elseif is(t, String) ""
    end
end

function Textbox(; typ=String, label="",
                 value=empty(typ),
                 range=nothing,
                 input=Input(value))
    if isa(value, String) && !isa(range, Nothing)
        throw(ArgumentError(
               "You cannot set a range on a string textbox"
             ))
    end
    Textbox(input, label, range, value)
end

Textbox(val; kwargs...) =
    Textbox(value=val; kwargs...)

function parse{T<:Number}(val, w::Textbox{T})
    v = convert(T, val)
    if isa(w.range, Range)
        # force value to stay in range
        v = max(first(w.range),
                min(last(w.range), v))
    end
    v
end

######################### Textarea ###########################

type Textarea{String} <: InputWidget{String}
    input::Input{String}
    label::String
    value::String
end

Textarea(; label="",
         value="",
         input=Input(value)) =
    Textarea(input, label, value)

Textarea(val; kwargs...) =
    Textarea(value=val; kwargs...)

##################### SelectionWidgets ######################

type Options{view, T} <: InputWidget{T}
    input::Input{T}
    label::String
    value::T
    value_label::String
    options::Label{T}
    # TODO: existential checks
end

Options{T}(view::Symbol, options::Label{T};
        label = "",
        value_label=first(options)[1],
        value=options[value_label],
        input=Input(value)) =
            Options{view, T}(input, label, value, value_label, options)

function Options{T}(view::Symbol,
                    options::Vector{T};
                    kwargs...)
    opts = Label{T}()
    map(v->opts[string(v)] = v, options)
    Options(view, opts; kwargs...)
end

Dropdown(opts; kwargs...) =
    Options(:Dropdown, opts; kwargs...)

RadioButtons(opts; kwargs...) =
    Options(:RadioButtons, opts; kwargs...)

Select(opts; kwargs...) =
    Options(:Select, opts; kwargs...)