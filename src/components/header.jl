using Dash

include("../styles.jl")


header = html_div(
    [

        html_div([
            html_img(
                src = "assets/graph.png",
                height = "50px",
                width = "auto"
            )
            ],
            className = "col-2"
        ),

        html_div(  # page title
            html_h1(
                "Personal Finance Dashboard",
                style = Dict("textAlign" => "center")
            ),
            className = "col-8"
        ),
        html_div([], className="col-2"),  # blank cols right

    ],
    className = "row",
    style = Dict("height" => "4%", "backgroundColor" => current_theme["background"])
)