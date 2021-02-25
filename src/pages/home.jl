# this is the landing page
# it provides info about the app and how to use it

using Dash, DashHtmlComponents, DashCoreComponents

include("../styles.jl")
include("../components/header.jl")
include("../components/navbar.jl")

# open readme
io = open("../README.md", "r")
readme = read(io, String)
close(io)


function getHome()
    home = html_div(
        [
            header,
            navbar,
            html_div(
                [
                    html_div([], className="col-2"),
                    html_div(
                        [dcc_markdown(readme)], 
                        style = Dict("text-align"=>"left"),
                        className = "col-8"
                    ),
                    html_div([], className="col-2")
                ],
                className = "row"
            )
        ],
        className = "fill",
        style = Dict(
            "backgroundColor" => current_theme["background"],
            "color" => current_theme["text"],
            "text-align" => "center"
        )
    )

end