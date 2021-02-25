using Dash, DashHtmlComponents, DashCoreComponents




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
        return _404
    end
end





run_server(app, "0.0.0.0", debug=true)