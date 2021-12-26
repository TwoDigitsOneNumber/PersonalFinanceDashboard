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
                        className = "col-5"
                    ),
                    html_div(
                        [
                            html_div(
                                [
                                    "Aggregate the data:",
                                    dcc_dropdown(
                                        id = "interval_picker",
                                        options = interval_options,
                                        value = interval_options[1][2],  # choose first value as default
                                        searchable = false
                                    )
                                ],
                                style = Dict(
                                    "width" => "70%",
                                    "margin-top" => "5px"
                                )
                            )
                        ],
                        className = "col-5"
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
            html_div(
                id="aggregated_json_data",
                style=Dict("display"=>"None")
            ),


            # summary/overview graphs
            html_div(
                [
                    html_div([dcc_graph(id="bar_income_expense")], className="col-6"),
                    html_div([dcc_graph(id="cumulative_income_expense")], className="col-6")
                ],
                className="row"
            ),


            # income/expense overview graphs

            # income/expense picker dropdown
            html_div(
                [
                    html_div([], className="col-1"),
                    html_div(
                        [
                            dcc_dropdown(
                                id = "income_expense_overview_picker",
                                options = [(label=i, value=i) for i in ["Income", "Expense"]],
                                value = "Income",
                                searchable = false
                            ),
                        ],
                        className="col-10",
                        style = Dict(
                            "width" => "70%"
                        )
                    ),
                    html_div([], className="col-1")
                ],
                className="row",
                style = Dict("backgroundColor"=>current_theme["accent"])
            ),


            html_div(
                [
                    html_div([dcc_graph(id="bar_category_chart")], className="col-8"),
                    html_div([dcc_graph(id="pie_chart")], className="col-4")
                ],
                className="row"
            ),


            # row with long column on the right
            html_div(
                [
                    html_div(
                        [
                            html_div([dcc_graph(id="filled_area_plot")], className="col-12"),
                            html_div([dcc_graph(id="weekday_heatmap")], className="col-12")
                        ],
                        className="col-8"
                    ),
                    html_div(
                        [
                            html_div(id="average_per_category")
                        ],
                        className="col-4"
                    )
                ],
                className="row"
            )
        ]
    )

end