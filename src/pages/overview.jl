# provides layout of the overview page

using Dash
import PlotlyJS
import JSON
import Dates



include("../app.jl")
include("../functions.jl")
include("../styles.jl")
# PlotlyJS.use_style!(current_theme["plot_style"])  # deprecated



# --------------------------------------------------------------------
# options for dropdown 

interval_options = [
    (label="Yearly", value="Year"),
    (label="Monthly", value="YearMonth"),
    (label="Weekly", value="YearWeek"),
    (label="Daily", value="Date"),
    # (label="Hourly", value="Hour"),  # todo: make sure that all hours are in expense and income sub-dataframe
    (label="By Weekday", value="Weekday"),
    (label="By Calendar Month", value="CalendarMonth"),
    (label="By Calendar Week", value="CalendarWeek")
]



# --------------------------------------------------------------------
# layout div

function getOverview()
    overview = html_div(
        [

            # filter row
            html_div(
                [

                    html_div([], className="col-1"),  # blank cols left
                    html_div(
                        [
                            html_div(
                                [
                                    "Select a date range:",
                                    dcc_datepickerrange(
                                        id = "date_range_picker",
                                        start_date = clean_data.Date[begin],
                                        end_date = clean_data.Date[end],
                                        min_date_allowed = clean_data.Date[begin],
                                        max_date_allowed = clean_data.Date[end],
                                        first_day_of_week = 1,
                                        display_format = "DD MMM YYYY"
                                    )
                                ],
                                style = Dict(
                                    "width" => "70%"
                                )
                            )
                        ],
                        className = "col-10"
                    ),
                    html_div([], className="col-1")

                ],
                className = "row sticky-top",  # to stick on the top when scrolling down
                style = Dict("backgroundColor" => current_theme["accent"])
            ),



            # hidden divs, to store processed data in browser of user
            html_div(
                # children=JSON.json(clean_data),
                id="date_range_json_data",
                style=Dict("display"=>"None")
            ),


            # overview graph, parallel_categories plott
            html_div(
                [
                    html_div([dcc_graph(id="parallel_categories")], className="col-10"),
                ],
                className="row"
            ),
        ]
    )

end