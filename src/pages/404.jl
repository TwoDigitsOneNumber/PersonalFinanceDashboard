# this page gets displayed when an invalid url is provided

using Dash, DashHtmlComponents, DashCoreComponents

include("../styles.jl")
include("../components/header.jl")
include("../components/navbar.jl")

_404 = html_div(
    [
        header,
        navbar,
        "404! The requested url is not available."
    ],
    className = "fill",
    style = Dict(
        "backgroundColor" => current_theme["background"],
        "color" => current_theme["text"],
        "text-align" => "center"
    )
)