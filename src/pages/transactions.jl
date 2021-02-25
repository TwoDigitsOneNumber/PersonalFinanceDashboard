# this page allows for a detailed look at individual transactions

using Dash, DashHtmlComponents, DashCoreComponents
import PlotlyJS
import DataFrames
import CSV
import JSON
import Dates



include("../app.jl")
include("../functions.jl")
include("../styles.jl")
PlotlyJS.use_style!(current_theme["plot_style"])









# --------------------------------------------------------------------
# load clean data

clean_data = DataFrames.DataFrame(CSV.File("../data/clean_data.csv"))
# make Year array categorical
clean_data[!, "Year"] = DataFrames.CategoricalArray(clean_data[!, "Year"])



# --------------------------------------------------------------------
# layout div

function getTransactions()
    transactions = html_div(
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
                                    "Select Category to analyze:",
                                    dcc_dropdown(
                                        id = "flag_picker",
                                        options = [(label=i, value=i) for i in ["Income", "Expense"]],
                                        value = "Income",
                                        searchable = false
                                    ),
                                    dcc_dropdown(
                                        id = "category_picker",
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
                    html_div([], className="col-1")  # blank cols left
                ],
                className = "row sticky-top",
                style = Dict(
                    "backgroundColor" => current_theme["accent"]
                )
            ),

            # hidden divs, to store processed data in browser of user
            html_div(
                id="date_range_json_data",
                style=Dict("display"=>"None")
            ),
            html_div(
                id="json_category_data",
                style=Dict("display"=>"None")
            ),


            # graphs

            html_div(
                [
                    # histogram
                    html_div([dcc_graph(id="histogram")], className="col-4"),
                    # transaction_time_plot
                    html_div([dcc_graph(id="transaction_time")], className="col-8")
                ],
                className = "row"
            )
        ]
    )


end