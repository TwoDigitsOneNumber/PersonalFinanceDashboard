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
# keep this text brief, it should just HIGHLIGHT the most important aspects for people who land on this page. Provide pointers to sections of the README
if ARGS[1] == "demo"
    demo_welcome_text = """
    ## Welcome to this Dashboard Demo\n
    &#9888; __A quick note before you start using the app:__ Loading each page for the first time may take a while as the Julia programming language precompiles all plots. However, subsequent page updates and changes to the plots run relatively fast. In case the site stops responding, refresh the website, wait about a minute and refresh again. For more information about these issues see the section "Issues with Deployment on Heroku" below or on [GitHub](https://github.com/TwoDigitsOneNumber/PersonalFinanceDashboard)\n
    This dashboard app provides a useful way to monitor and analyze ones personal finances to gain insights into ones income streams and spending habits. This demo version is intended to demonstrate the functionality and versatility of the dashboard. If you would like some guidance on how to navigate the dashboard and how to interact with the plots, please see the sections below for some tips. I encurage the user to explore the dashboard and its features.\n\nI display the full functionality of the dashboard on some artificial demo data. For users who are interested to try or use the dashboard with their own personal data (collected through the Moneyboard mobile app (not affiliated)), please clone/download the source code from this [GitHub repository](https://github.com/TwoDigitsOneNumber/PersonalFinanceDashboard). On the repository page I provide instructions on how to run the dashboard on your personal machine.\n\n
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