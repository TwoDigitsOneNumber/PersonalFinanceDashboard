# this is the landing page
# it provides info about the app and how to use it

using Dash

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
                    html_div([], className="col-3"),
                    html_div(
                        [dcc_markdown(readme)], 
                        style = Dict("text-align"=>"left"),
                        className = "col-6"
                    ),
                    html_div([], className="col-3")
                ],
                className = "row"
            )
        ]
    )

end