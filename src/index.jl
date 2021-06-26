using Dash, DashHtmlComponents, DashCoreComponents
import DataFrames
import CSV

include("app.jl")
include("components/callbacks.jl")
include("pages/404.jl")
include("pages/home.jl")
include("pages/overview.jl")
include("pages/transactions.jl")
include("styles.jl")
include("components/header.jl")
include("components/navbar.jl")
include("components/callbacks.jl")


# load clean_data or demo data if clean_data is not found
data_path = "../data/"
if isfile(data_path*"preprocessed_data.csv") 
    data_file = "preprocessed_data.csv"
else
    data_file = "artificial_demo_data.csv"
end
clean_data = DataFrames.DataFrame(CSV.File(data_path*data_file))
# make Year array categorical
clean_data[!, "Year"] = DataFrames.CategoricalArray(clean_data[!, "Year"])


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
    elseif pathname == "/overview"
        return getOverview()
    elseif pathname == "/transactions"
        return getTransactions()
    else
        return get404()  # catches invalid links; manual url changes revert to /home
    end
end



run_server(app, "0.0.0.0", debug=true)