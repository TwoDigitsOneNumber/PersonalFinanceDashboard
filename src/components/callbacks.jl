using Dash, DashHtmlComponents, DashCoreComponents
using Statistics



# ====================================================================
# general callbacks (callbacks used on multiple pages)



# callback that subsets the clean_data to the specified date range
callback!(
    app,
    Output("date_range_json_data", "children"),
    Input("date_range_picker", "start_date"),
    Input("date_range_picker", "end_date")
) do start_date, end_date
    # subset clean_data to only contain data in the specified range

    end_date = Dates.Date(end_date, Dates.DateFormat("yyyy-mm-dd"))
    start_date = Dates.Date(start_date, Dates.DateFormat("yyyy-mm-dd"))

    date_range_data = clean_data[(clean_data.Date .>= start_date) .& (clean_data.Date .<= end_date), :]

    return JSON.json(date_range_data)
end




# ====================================================================
# overview callbacks


# --------------------------------------------------------------------
# Data Preparation / User Input Callbacks


# callback that aggregates data based on interval
callback!(
    app,
    Output("aggregated_json_data", "children"),
    Input("interval_picker", "value"),
    Input("date_range_json_data", "children")
) do interval, json_data

    # parse and convert relevant column types
    date_range_data = DataFrames.DataFrame(JSON.parse(json_data, null=missing))
    agg_data = convertColumnTypes(date_range_data, interval)

    agg_data = DataFrames.combine(
        DataFrames.groupby(agg_data, ["Flag", "Category", interval]), 
        :Transaction=>sum
    )

    return JSON.json(Dict("agg_data"=>agg_data, "interval"=>interval))
end








# --------------------------------------------------------------------
# plot callbacks



# bar income expense chart
callback!(
    app,
    Output("bar_income_expense", "figure"),
    Input("aggregated_json_data", "children")
) do json_data

    agg_data, interval = unpackJSONData(json_data)
    agg_data = DataFrames.combine(DataFrames.groupby(agg_data, [interval, "Flag"]), :Transaction_sum=>sum)
    convertColumnTypes(agg_data, interval)

    return PlotlyJS.Plot(
        # data traces
        [
            # income
            PlotlyJS.bar(
                x = unique(agg_data[:, interval]), 
                y = agg_data[agg_data.Flag .== "Income", :].Transaction_sum_sum, 
                name = "Income"
            ),
            # expense
            PlotlyJS.bar(
                x = unique(agg_data[:, interval]), 
                y = agg_data[agg_data.Flag .== "Expense", :].Transaction_sum_sum, 
                name = "Expense"
            ),
            # savings rate
            PlotlyJS.scatter(
                x = unique(agg_data[:, interval]),
                y = (1 .- agg_data[agg_data.Flag .== "Expense", :].Transaction_sum_sum ./ agg_data[agg_data.Flag .== "Income", :].Transaction_sum_sum) .* 100, 
                name = "Savings Rate",
                yaxis = "y2"
            )
        ],
        PlotlyJS.Layout(
            title = "Total Income and Expenses",
            yaxis_title = "CHF",
            yaxis2_title = "Savings Rate (%)",
            yaxis2_side = "right",
            yaxis2_overlaying = "y"
        )
    )
end




# cumulative_income_expense graph
callback!(
    app,
    Output("cumulative_income_expense", "figure"),
    Input("aggregated_json_data", "children"),
    Input("date_range_json_data", "children")
) do agg_json_data, date_range_json_data
    
    agg_data, interval = unpackJSONData(agg_json_data)

    # if cumulative plot does not make sense show statistics on seasonality/cyclicality
    if (interval in ["Weekday", "CalendarMonth", "CalendarWeek"])
        # parse and convert relevant column types
        date_range_data = DataFrames.DataFrame(JSON.parse(date_range_json_data, null=missing))
        agg_data = convertColumnTypes(date_range_data, interval)

        # set correct aggregation column
        if interval == "Weekday"
            agg_by = "CalendarWeekday"
        elseif interval == "CalendarMonth"
            agg_by = "YearMonth"
        elseif interval == "CalendarWeek"
            agg_by = "YearWeek"
        end


        agg_data = DataFrames.combine(
            DataFrames.groupby(agg_data, ["Flag", agg_by, interval]), 
            :Transaction=>sum
        )

        means = DataFrames.combine(
            DataFrames.groupby(agg_data, ["Flag", interval]), 
            :Transaction_sum=>mean
        )
        stds = DataFrames.combine(
            DataFrames.groupby(agg_data, ["Flag", interval]), 
            :Transaction_sum=>std
        )

        return PlotlyJS.Plot(
            [
                PlotlyJS.scatter(
                    x = unique(agg_data[:, interval]),
                    y = means[means.Flag .== "Income", :].Transaction_sum_mean,
                    name = "Average Income"
                ),
                PlotlyJS.scatter(
                    x = unique(agg_data[:, interval]),
                    y = means[means.Flag .== "Expense", :].Transaction_sum_mean,
                    name = "Average Expense"
                ),
                PlotlyJS.scatter(
                    x = unique(agg_data[:, interval]),
                    y = stds[means.Flag .== "Income", :].Transaction_sum_std,
                    name = "Std. Dev. Income"
                ),
                PlotlyJS.scatter(
                    x = unique(agg_data[:, interval]),
                    y = stds[means.Flag .== "Expense", :].Transaction_sum_std,
                    name = "Std. Dev. Expense"
                )
            ],
            PlotlyJS.Layout(
                title = "Seasonality/Cyclicality",
                yaxis_title = "CHF"
            )
        )
    
    
    # show cumulative plot
    else
        agg_data = DataFrames.combine(DataFrames.groupby(agg_data, [interval, "Flag"]), :Transaction_sum=>sum)
        convertColumnTypes(agg_data, interval)

        return PlotlyJS.Plot(
            # traces
            [
                # income
                PlotlyJS.scatter(
                    x = unique(agg_data[:, interval]),
                    y = cumsum(agg_data[agg_data.Flag .== "Income", :].Transaction_sum_sum),
                    name = "Cumulative Income"
                ),
                # expense
                PlotlyJS.scatter(
                    x = unique(agg_data[:, interval]),
                    y = cumsum(agg_data[agg_data.Flag .== "Expense", :].Transaction_sum_sum),
                    name = "Cumulative Expense"
                ),
                # net income
                PlotlyJS.scatter(
                    x = unique(agg_data[:, interval]),
                    y = cumsum(agg_data[agg_data.Flag .== "Income", :].Transaction_sum_sum) - cumsum(agg_data[agg_data.Flag .== "Expense", :].Transaction_sum_sum),
                    name = "Cumulative Net Income"
                )
            ],
            PlotlyJS.Layout(
                title = "Cumulative Income and Expenses",
                yaxis_title = "CHF"
            )
        )
    end
end





callback!(
    app,
    Output("bar_category_chart", "figure"),
    Input("aggregated_json_data", "children"),
    Input("income_expense_overview_picker", "value")
) do json_data, inc_exp
    
    agg_data, interval = unpackJSONData(json_data)
    agg_data = DataFrames.dropmissing(agg_data[agg_data.Flag .== inc_exp, :], [:Category])
    agg_data = convertColumnTypes(agg_data, interval)

    bar_traces = [
        PlotlyJS.bar(
            x = unique(agg_data[:, interval]),
            y = agg_data[agg_data.Category .== category, "Transaction_sum"],
            name = category
        ) for category in unique(skipmissing(agg_data.Category))
    ]

    return PlotlyJS.Plot(
        bar_traces,
        PlotlyJS.Layout(
            title = "$inc_exp by Category over Time (absolute)",
            yaxis_title = "CHF"
        )
    )
end



# average income/expense per interval
callback!(
    app,
    Output("average_per_category", "children"),
    Input("aggregated_json_data", "children"),
    Input("income_expense_overview_picker", "value")
) do json_data, inc_exp

    agg_data, interval = unpackJSONData(json_data)
    agg_data = DataFrames.dropmissing(agg_data[agg_data.Flag .== inc_exp, :], [:Category])
    agg_data = convertColumnTypes(agg_data, interval)

    means = DataFrames.combine(DataFrames.groupby(agg_data, [:Category]), :Transaction_sum=>mean)
    cols = ["Category", "Transaction_sum_mean"]
    rows = 1:DataFrames.nrow(means)

    return html_div([
        html_h5("Average $inc_exp per Category", style=Dict("text-align"=>"center")),
        html_table(
            [
                html_thead([html_tr([html_th("Category"), html_th("Average $inc_exp")])]),
                html_tbody([
                    html_tr([
                        html_td(means[row, col]) for col in cols
                    ]) for row in rows
                ])
            ],
            className="center"
        )
    ])
end




# pie_chart
callback!(
    app,
    Output("pie_chart", "figure"),
    Input("aggregated_json_data", "children"),
    Input("income_expense_overview_picker", "value")
) do json_data, inc_exp
 
    agg_data, interval = unpackJSONData(json_data)
    agg_data = DataFrames.dropmissing(agg_data[agg_data.Flag .== inc_exp, :], [:Category])
    agg_data = DataFrames.combine(
        DataFrames.groupby(agg_data, [:Category]),
        :Transaction_sum => sum
    )

    return PlotlyJS.Plot(
        # traces
        [
            PlotlyJS.pie(
                values = agg_data.Transaction_sum_sum,
                labels = agg_data.Category,
            )
        ],
        PlotlyJS.Layout(
            title="Total $inc_exp by Category"
        )
    )   

end





# filled_area_plot
callback!(
    app,
    Output("filled_area_plot", "figure"),
    Input("aggregated_json_data", "children"),
    Input("income_expense_overview_picker", "value")
) do json_data, inc_exp

    agg_data, interval = unpackJSONData(json_data)
    agg_data = DataFrames.dropmissing(agg_data[agg_data.Flag .== inc_exp, :], [:Category])
    if interval == "Weekday"
        DataFrames.sort!(agg_data, interval)
    end

    filled_area_traces = [
        PlotlyJS.scatter(
            x = unique(agg_data[:, interval]),
            y = agg_data[agg_data.Category .== category, "Transaction_sum"], 
            name = category, 
            stackgroup = "one", 
            groupnorm = "percent"
        ) for category in unique(skipmissing(agg_data.Category))
    ]

    return PlotlyJS.Plot(
        # traces
        filled_area_traces,
        PlotlyJS.Layout(
            title = "$inc_exp by Category over Time (in %)",
            yaxis_title = "%"
        )
    )
end





# callback weekday_heatmap
callback!(
    app,
    Output("weekday_heatmap", "figure"),
    Input("interval_picker", "value"),
    Input("date_range_json_data", "children"),
    Input("income_expense_overview_picker", "value")
) do interval, json_data, inc_exp

    # to make sure Weekday is not plotted against Weekday
    if interval == "Weekday"
        interval = "Year"
    end

    # parse and convert relevant column types
    date_range_data = DataFrames.DataFrame(JSON.parse(json_data, null=missing))
    agg_data = convertColumnTypes(date_range_data, interval)

    agg_data = DataFrames.combine(
        DataFrames.groupby(agg_data, ["Flag", "Weekday", interval]), 
        :Transaction=> sum
    )
    agg_data[!, "Weekday"] = DataFrames.CategoricalArray(agg_data[!, "Weekday"])
    # define levels for sorting weekdays
    DataFrames.levels!(agg_data[!, "Weekday"], ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])
    DataFrames.sort!(agg_data, ["Weekday"])

    return PlotlyJS.Plot(
        [
            PlotlyJS.heatmap(
                x = agg_data[agg_data.Flag .== inc_exp, interval],
                y = agg_data[agg_data.Flag .== inc_exp, "Weekday"],
                z = agg_data[agg_data.Flag .== inc_exp, "Transaction_sum"],
                colorscale = [[0, current_theme["background"]], [1, (inc_exp=="Income" ? "green" : "red")]]

            )
        ],
        PlotlyJS.Layout(
            title = "$inc_exp by Weekday"
        )
    )
end





# ====================================================================
# transactions callbacks


# --------------------------------------------------------------------
# Data Preparation / User Input Callbacks



# dropdown options for categories
callback!(
    app,
    Output("category_picker", "options"),
    Output("category_picker", "value"),
    Input("flag_picker", "value")
) do flag_choice

    # find all unique categories for flag (Income or Expense)
    category_options = [(label=i, value=i) for i in unique(clean_data[clean_data.Flag .== flag_choice, :].Category)]
    sort!(category_options)

    # add "all" option
    options = append!([(label="All", value="All")], category_options)
    return (options, options[1][2])
end


# subset data according to category
callback!(
    app,
    Output("json_category_data", "children"),
    Input("flag_picker", "value"),
    Input("category_picker", "value"),
    Input("date_range_json_data", "children")
) do flag_choice, category_choice, json_data

    date_range_data = DataFrames.DataFrame(JSON.parse(json_data, null=missing))

    # to make sure that only the right flag gets used in case same category name exists for income and expense
    category_data = date_range_data[[i ? false : true for i in ismissing.(date_range_data[!, flag_choice])], ["Category", "Date", "Transaction", "Name"]]

    if category_choice == "All"
        return JSON.json(category_data)
    else
        return JSON.json(category_data[category_data.Category .== category_choice, :])
    end
end




# --------------------------------------------------------------------
# plots



# histogram
callback!(
    app,
    Output("histogram", "figure"),
    Input("json_category_data", "children")
) do json_data

    category_data = DataFrames.DataFrame(JSON.parse(json_data, null=missing))
    
    return PlotlyJS.Plot(
        [
            PlotlyJS.histogram(x = category_data.Transaction)
        ],
        PlotlyJS.Layout(
            title = "Histogram"
        )
    )
end



# transactions over time scatter plot
callback!(
    app,
    Output("transaction_time_plot", "figure"),
    Input("json_category_data", "children")
) do json_data
    
    category_data = DataFrames.DataFrame(JSON.parse(json_data, null=missing))
    category_data = convertColumnTypes(category_data, "Date")

    replace!(category_data.Name, missing=>"")
    
    transaction_info = ["$name ($cat)" for (name, cat) in zip(category_data.Name, category_data.Category)]

    return PlotlyJS.Plot(
        [
            PlotlyJS.scatter(
                x = category_data.Date,
                y = category_data.Transaction,
                mode = "markers",
                text = transaction_info
            )
        ],
        PlotlyJS.Layout(
            title = "Transactions over Time",
            hovermode = "closest"
        )
    )
end



# distribution statistics
callback!(
    app,
    Output("distribution_statistics", "children"),
    Input("json_category_data", "children")
) do json_data
    
    category_data = DataFrames.DataFrame(JSON.parse(json_data, null=missing))
    category_data = convertColumnTypes(category_data, "Date")

    return html_div(
        [
            html_h5("Distribution Statistics", style=Dict("text-align"=>"center")),
            html_table(
                [
                    html_tbody([
                        html_tr([
                            html_td(["Max"]),
                            html_td([maximum(category_data.Transaction)]),
                        ]),
                        html_tr([
                            html_td(["Mean"]),
                            html_td([round(mean(category_data.Transaction), digits=2)]),
                        ]),
                        html_tr([
                            html_td(["Median"]),
                            html_td([median(category_data.Transaction)]),
                        ]),
                        html_tr([
                            html_td(["Min"]),
                            html_td([minimum(category_data.Transaction)]),
                        ]),
                        html_tr([
                            html_td(["Standard Deviation"]),
                            html_td([round(std(category_data.Transaction), digits=2)])
                        ]),
                        html_tr([
                            html_td(["Number of Transactions"]),
                            html_td([length(category_data.Transaction)])
                        ])
                    ])
                ],
                className="center"
            )
        ]
    )
end



# top ten transaction table
callback!(
    app,
    Output("top_ten_transactions", "children"),
    Input("json_category_data", "children")
) do json_data
    
    category_data = DataFrames.DataFrame(JSON.parse(json_data, null=missing))
    category_data = convertColumnTypes(category_data, "Date")

    replace!(category_data.Name, missing=>"")
    DataFrames.sort!(category_data, :Transaction, rev=true)

    # add position to dataframe to be displayed
    pos = 1:min(DataFrames.nrow(category_data), 10)
    sub_df = category_data[pos, :]
    sub_df[:, "Position"] = pos
    cols = ["Position", "Transaction", "Date", "Category", "Name"]

    return html_div([
        html_h5("Top 10 Transactions", style=Dict("text-align"=>"center")),
        html_table(
            [
                html_thead(html_tr([html_th(col) for col in cols])),
                html_tbody([
                    html_tr([
                        html_td(sub_df[row, col]) for col in cols
                    ]) for row in pos
                ])
            ],
            className="center"
        )
    ])
end



