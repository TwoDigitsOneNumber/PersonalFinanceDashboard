# this is the landing page
# it provides info about the app and how to use it

using Dash, DashHtmlComponents, DashCoreComponents

include("../styles.jl")
include("../components/header.jl")
include("../components/navbar.jl")


# --------------------------------------------------------------------


# open readme to display readme on home page
io = open("../README.md", "r")
readme = read(io, String)
close(io)


function getHome()
    home = html_div(
        [
            html_div(
                [
                    # todo: limit max width of readme text
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
        ]
    )

end