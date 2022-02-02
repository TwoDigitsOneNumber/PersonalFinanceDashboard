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


# remove all characters until "## Navigation in the Dashboard" from readme, i.e. remove the instructions and title section.
# (this is because if a viewer sees the dashboard online, i.e. this code runs, then they don't need the instructions anymore)
start = findfirst("## Navigation in the Dashboard", readme)
start = start[1] - 1
readme = readme[start:end]


# add welcome text to the demo
if ARGS[1] == "demo"
    demo_welcome_text = """
    ## Welcome to this Dashboard Demo\n
    This dashboard provides a usefull way to monitor ones personal finances. This demo version is intended to demonstrate the functionality and versatility of the dashboard. See the sections below for some tips on how to navigate the dashboard and how to interact with the plots. We display the full functionality of the dashboard on some artificial demo data. For users who are interested to try the dashboard with their own data (collected through the Moneyboard mobile app (not affiliated)), please clone/download the source code from this [GitHub repository](https://github.com/TwoDigitsOneNumber/PersonalFinanceDashboard).\n\n
    """
    readme = demo_welcome_text * readme
end


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