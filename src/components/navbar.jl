using Dash

include("../styles.jl")


navbar = html_div(
    [

        html_div([], className="col-3"),  # black cols
        html_div(
            dcc_link("Home", href="/home"),
            className = "col-2",
            style = Dict("color" => current_theme["text"])
        ),
        # html_div(
        #     dcc_link("Overview", href="/overview"),
        #     className = "col-2",
        #     style = Dict("color" => current_theme["text"])
        # ),
        html_div(
            dcc_link("Aggregated", href="/aggregated"),
            className = "col-2",
            style = Dict("color" => current_theme["text"])
        ),
        html_div(
            dcc_link("Transactions", href="/transactions"),
            className = "col-2",
            style = Dict("color" => current_theme["text"])
        ),
        html_div([], className="col-3")  # black cols
    ],

    className = "row",
    style = Dict(
        "height" => "4%",
        "backgroundColor" => current_theme["background"]
    )
)