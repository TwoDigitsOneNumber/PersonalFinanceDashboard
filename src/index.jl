using Dash
import DataFrames
import CSV
using CategoricalArrays
using ArgParse

println("Starting program...")

include("app.jl")
include("components/callbacks.jl")
include("pages/404.jl")
include("pages/home.jl")
# include("pages/overview.jl")
include("pages/aggregated.jl")
include("pages/transactions.jl")
include("styles.jl")
include("components/header.jl")
include("components/navbar.jl")
include("components/callbacks.jl")


# define command line arguments
function parse_commandline()
    s = ArgParseSettings()
    
    @add_arg_table! s begin

        "--file_name"
        help = "input file name of the preprocessed csv file (incl. file extension). Type \"demo\" to use the demo file."
        arg_type = String
        required = true
    end
    
    return parse_args(s)
end

# handle command line arguments
file_name = parse_commandline()["file_name"]


# -----------------------------------------------------------------------------
# load data

# load clean_data or demo data if clean_data is not found
data_path = "../data/"

if file_name == "demo"
    path = data_path * "preprocessed_demo_data.csv"
else
    path = data_path * file_name
end

# load data
clean_data = DataFrames.DataFrame(CSV.File(path))

# make Year array categorical
clean_data[!, "Year"] = CategoricalArray(clean_data[!, "Year"])


# --------------------------------------------------------------------
# setup basic layout that contains layouts of individual pages

app.layout = html_div(
    [
        header,
        navbar,
        dcc_location(id="url", refresh=false, pathname="/home"),
        html_div(id="page_content")
    ],
    className = "container-fluid",
    style = Dict(
        "backgroundColor" => current_theme["background"], 
        "color" => current_theme["text"]
    )
)
    


# callback that changes layout based on url
callback!(
    app,
    Output("page_content", "children"),
    Input("url", "pathname")
) do pathname
    if (pathname == "/home") | (pathname == "/")
        return getHome()
    # elseif pathname == "/overview"
    #     return getOverview()
    elseif pathname == "/aggregated"
        return getAggregated()
    elseif pathname == "/transactions"
        return getTransactions()
    else
        return get404()  # catches invalid links; manual url changes revert to /home
    end
end


println("Starting server...")
if file_name == "demo"
    debug = false
else
    debug = true
end

run_server(app, "0.0.0.0", debug=debug)