using Dash
using Statistics
using CategoricalArrays



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


# # ====================================================================
# # overview page callbacks


# # parallel_categories plot
# callback!(
#     app,
#     Output("parallel_categories", "figure"),
#     Input("date_range_json_data", "children")
# ) do json_data

#     # parse input json data
#     date_range_data = DataFrames.DataFrame(JSON.parse(json_data, null=missing))

#     # get income/expense categories for each income/expense transaction respectively
#     income_categories = date_range_data[.!ismissing.(date_range_data.Income), "Category"]
#     expense_categories = date_range_data[.!ismissing.(date_range_data.Expense), "Category"]

#     # get unique income/expense categories
#     unique_income_categories = sort!(unique(income_categories))
#     unique_expense_categories = sort!(unique(expense_categories))

#     # get the sum of the transactions for each income/expense category
#     income_sums = []
#     for cat in unique_income_categories
#         bool_mask = (date_range_data.Category .== cat) .& (date_range_data.Flag .== "Income")
#         cat_sum = round(sum(skipmissing(date_range_data[bool_mask, "Income"])), digits=2)
#         append!(income_sums, cat_sum)
#     end
#     expense_sums = []
#     for cat in unique_expense_categories
#         bool_mask = (date_range_data.Category .== cat) .& (date_range_data.Flag .== "Expense")
#         cat_sum = round(sum(skipmissing(date_range_data[bool_mask, "Expense"])), digits=2)
#         append!(expense_sums, cat_sum)
#     end


#     # compute savings = income - expense
#     savings = sum(income_sums) - sum(expense_sums)
    
#     # add savings to unique_expense_categories and expense_count
#     append!(unique_expense_categories, ["Savings"])
#     append!(expense_sums, savings)

#     println("unique_income_categories: ", unique_income_categories)
#     println("income_sums: ", income_sums)
#     println("unique_expense_categories: ", unique_expense_categories)
#     println("expense_sums: ", expense_sums)

#     # return the plot
#     return PlotlyJS.Plot(
#         [
#             PlotlyJS.parcats(
#                 dimensions = [
#                     Dict(
#                         "label" => "Incomes",
#                         "values" => unique_income_categories,
#                     ),
#                     Dict(
#                         "label" => "Balance",
#                         "values" => ["Total Balance"]
#                     ),
#                     Dict(
#                         "label" => "Expenses",
#                         "values" => unique_expense_categories,
#                     ),
#                 ]
#             )
#         ],
#         PlotlyJS.Layout(
#             title="Income and Expense Overview",
#             plot_bgcolor = current_theme["background"],
#             paper_bgcolor = current_theme["background"],
#             font_size = current_theme["font_size"],
#             titlefont_size = current_theme["titlefont_size"],
#             font_color = current_theme["font_color"]
#         )
#     )

#     # traces: income, budget (in the middle), expense

# end



# ====================================================================
# aggregated page callbacks


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

    # avg_savings_rate = round(
    #     mean(
    #         (1 - sum(agg_data[agg_data.Flag .== "Expense", :].Transaction_sum_sum) / sum(agg_data[agg_data.Flag .== "Income", :].Transaction_sum_sum)) .* 100
    #     ),
    #     digits=2
    # )

    # compute arrays of incomes/expenses over time in aggregated form
    incomes = agg_data[agg_data.Flag .== "Income", :].Transaction_sum_sum
    expenses = agg_data[agg_data.Flag .== "Expense", :].Transaction_sum_sum

    # compute array of savings rate over time in aggregated form
    savings_rate = round.((1 .- expenses ./ incomes) .* 100, digits=2)
    # replace inf and -inf by missing
    savings_rate = replace(savings_rate, Inf=>missing, -Inf=>missing, NaN=>missing)

    savings_rate_color = current_theme["cc"]["violet"]

    return PlotlyJS.Plot(
        # data traces
        [
            # income
            PlotlyJS.bar(
                x = unique(agg_data[:, interval]), 
                y = incomes,
                name = "Income",
                marker_color = current_theme["Income"]
            ),
            # expense
            PlotlyJS.bar(
                x = unique(agg_data[:, interval]), 
                y = expenses,
                name = "Expense",
                marker_color = current_theme["Expense"]
            ),
            # savings rate
            PlotlyJS.scatter(
                x = unique(agg_data[:, interval]),
                y = savings_rate, 
                name = "Savings Rate",
                yaxis = "y2",
                marker_color = savings_rate_color,
                hovertemplate = "%{y:.2f}"
            )
            # average savings rate
            # PlotlyJS.scatter(
            #     x = unique(agg_data[:, interval]),
            #     y = repeat([avg_savings_rate], length(unique(agg_data[:, interval]))),
            #     name = "Average Savings Rate",
            #     yaxis = "y2"
            # )
        ],
        PlotlyJS.Layout(
            title = "Total Income and Expenses",
            yaxis_gridcolor = current_theme["grid_color"],
            yaxis_title = "CHF",
            yaxis2_title = "Savings Rate (%)",
            yaxis2_side = "right",
            yaxis2_overlaying = "y",
            yaxis2_color = savings_rate_color,
            yaxis2_gridcolor = savings_rate_color,
            yaxis2_zerolinecolor = savings_rate_color,
            plot_bgcolor = current_theme["background"],
            paper_bgcolor = current_theme["background"],
            font_size = current_theme["font_size"],
            titlefont_size = current_theme["titlefont_size"],
            font_color = current_theme["font_color"],
            hovermode = "x"
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

    # if cumulative plot does not make sense, then show statistics on seasonality/cyclicality
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

        time = unique(agg_data[:, interval])

        return PlotlyJS.Plot(
            [
                PlotlyJS.scatter(
                    x = time,
                    y = means[means.Flag .== "Income", :].Transaction_sum_mean,
                    name = "Average Income",
                    marker_color = current_theme["Income"]
                ),
                PlotlyJS.scatter(
                    x = time,
                    y = means[means.Flag .== "Expense", :].Transaction_sum_mean,
                    name = "Average Expense",
                    marker_color = current_theme["Expense"]
                ),
                PlotlyJS.scatter(
                    x = time,
                    y = stds[means.Flag .== "Income", :].Transaction_sum_std,
                    name = "Std. Dev. Income",
                    marker_color = current_theme["cc"]["lightblue"]
                ),
                PlotlyJS.scatter(
                    x = time,
                    y = stds[means.Flag .== "Expense", :].Transaction_sum_std,
                    name = "Std. Dev. Expense",
                    marker_color = current_theme["cc"]["darkblue"]
                )
            ],
            PlotlyJS.Layout(
                title = "Seasonality/Cyclicality",
                yaxis_title = "CHF",
                plot_bgcolor = current_theme["background"],
                paper_bgcolor = current_theme["background"],
                yaxis_gridcolor = current_theme["grid_color"],
                xaxis_gridcolor = current_theme["grid_color"],
                font_size = current_theme["font_size"],
                titlefont_size = current_theme["titlefont_size"],
                font_color = current_theme["font_color"],
                hovermode = "x unified"
            )
        )
    
    
    # show cumulative plot
    else
        agg_data = DataFrames.combine(DataFrames.groupby(agg_data, [interval, "Flag"]), :Transaction_sum=>sum)
        convertColumnTypes(agg_data, interval)

        time = unique(agg_data[:, interval])
        cum_income = cumsum(agg_data[agg_data.Flag .== "Income", :].Transaction_sum_sum)
        cum_expense =cumsum(agg_data[agg_data.Flag .== "Expense", :].Transaction_sum_sum) 
        cum_savings = cum_income - cum_expense
        cum_savings_rate = (1 .- cum_expense ./ cum_income) .* 100

        return PlotlyJS.Plot(
            # traces
            [
                # income
                PlotlyJS.scatter(
                    x = time,
                    y = cum_income,
                    name = "Cumulative Income",
                    marker_color = current_theme["Income"],
                    hovertemplate = "%{y:.2f} CHF"
                ),
                # expense
                PlotlyJS.scatter(
                    x = time,
                    y = cum_expense,
                    name = "Cumulative Expense",
                    marker_color = current_theme["Expense"],
                    hovertemplate = "%{y:.2f} CHF"
                ),
                # cumulative savings / net income
                PlotlyJS.scatter(
                    x = time,
                    y = cum_savings,
                    name = "Cumulative Savings",
                    marker_color = current_theme["cc"]["violet"],
                    hovertemplate = "%{y:.2f} CHF<br>(Cumulative Savings Rate: %{text} %)",
                    text = ["$(round(i, digits=2))" for i in cum_savings_rate],
                )
            ],
            PlotlyJS.Layout(
                title = "Cumulative Income and Expenses",
                yaxis_title = "CHF",
                plot_bgcolor = current_theme["background"],
                paper_bgcolor = current_theme["background"],
                yaxis_gridcolor = current_theme["grid_color"],
                xaxis_gridcolor = current_theme["grid_color"],
                font_size = current_theme["font_size"],
                titlefont_size = current_theme["titlefont_size"],
                font_color = current_theme["font_color"],
                hovermode = "x unified"
            )
        )
    end
end




# vertical bar chart of income/expense over time
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
            yaxis_title = "CHF",
            plot_bgcolor = current_theme["background"],
            paper_bgcolor = current_theme["background"],
            yaxis_gridcolor = current_theme["grid_color"],
            font_size = current_theme["font_size"],
            titlefont_size = current_theme["titlefont_size"],
            font_color = current_theme["font_color"],
            hovermode = "x"
        )
    )
end



# average income/expense per interval by category (table)
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
    means[!, "Transaction_sum_mean"] = round.(means[!, "Transaction_sum_mean"], digits=2)
    DataFrames.sort!(means, "Category")

    interval = readable_interval_names(interval)

    return html_div([
        html_h5("Average $inc_exp per $interval by Category", style=Dict("text-align"=>"center")),
        html_table(
            [
                html_thead([html_tr([html_th("Category"), html_th("Average $inc_exp")])]),
                html_tbody(
                    append!(
                        [
                            html_tr([
                                html_td("Total"), html_td(round(sum(means[:, "Transaction_sum_mean"]), digits=2))
                            ])

                        ],
                        [
                            html_tr([
                                html_td(means[row, col]) for col in cols
                            ]) for row in rows
                        ]
                    )
                )
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

    # repeat cycler colors enough for all transactions (else picks default colors, and ignores argument)
    # n = length(agg_data.Transaction_sum_sum)
    # k = length(current_theme[inc_exp])
    # if (k < n)
    #     colors = []
    #     for i in 1:(div(n, k)+1)
    #         append!(colors, current_theme["cycler"])
    #     end
    # else
    #     colors = current_theme["cycler"]
    # end
    # colors = colors[1:n]

    return PlotlyJS.Plot(
        # traces
        [
            PlotlyJS.pie(
                values = agg_data.Transaction_sum_sum,
                labels = agg_data.Category#,
                # marker_colors = colors
            )
        ],
        PlotlyJS.Layout(
            title="Total $inc_exp by Category",
            plot_bgcolor = current_theme["background"],
            paper_bgcolor = current_theme["background"],
            font_size = current_theme["font_size"],
            titlefont_size = current_theme["titlefont_size"],
            font_color = current_theme["font_color"]
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
            y = round.(agg_data[agg_data.Category .== category, "Transaction_sum"], digits=2),
            name = category, 
            stackgroup = "one", 
            groupnorm = "percent",
            hovertemplate = "%{y:.2f} %",
        ) for category in unique(skipmissing(agg_data.Category))
    ]

    return PlotlyJS.Plot(
        # traces
        filled_area_traces,
        PlotlyJS.Layout(
            title = "$inc_exp by Category over Time (in %)",
            yaxis_title = "%",
            plot_bgcolor = current_theme["background"],
            paper_bgcolor = current_theme["background"],
            yaxis_gridcolor = current_theme["grid_color"],
            xaxis_gridcolor = current_theme["grid_color"],
            font_size = current_theme["font_size"],
            titlefont_size = current_theme["titlefont_size"],
            font_color = current_theme["font_color"],
            hovermode = "x unified"  # show all values with the same x-axis value
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
    agg_data[!, "Weekday"] = CategoricalArray(agg_data[!, "Weekday"])
    # define levels for sorting weekdays
    levels!(agg_data[!, "Weekday"], ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])
    DataFrames.sort!(agg_data, ["Weekday"])

    interval_readable = readable_interval_names(interval)

    return PlotlyJS.Plot(
        [
            PlotlyJS.heatmap(
                x = agg_data[agg_data.Flag .== inc_exp, interval],
                y = agg_data[agg_data.Flag .== inc_exp, "Weekday"],
                z = agg_data[agg_data.Flag .== inc_exp, "Transaction_sum"],
                colorscale = [[0, current_theme["background"]], [1, current_theme[inc_exp]]],
                hovertemplate = "$interval_readable : %{x}<br>Weekday : %{y}<br>$inc_exp : %{z}<extra></extra>",
            )
        ],
        PlotlyJS.Layout(
            title = "$inc_exp by Weekday",
            plot_bgcolor = current_theme["background"],
            paper_bgcolor = current_theme["background"],
            yaxis_gridcolor = current_theme["grid_color"],
            xaxis_gridcolor = current_theme["grid_color"],
            font_size = current_theme["font_size"],
            titlefont_size = current_theme["titlefont_size"],
            font_color = current_theme["font_color"]
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
    Input("json_category_data", "children"),
    Input("flag_picker", "value")
) do json_data, flag

    category_data = DataFrames.DataFrame(JSON.parse(json_data, null=missing))

    return PlotlyJS.Plot(
        [
            PlotlyJS.histogram(
                x = category_data.Transaction,
                marker_color = current_theme[flag]
            )
        ],
        PlotlyJS.Layout(
            title = "Histogram",
            plot_bgcolor = current_theme["background"],
            paper_bgcolor = current_theme["background"],
            yaxis_gridcolor = current_theme["grid_color"],
            font_size = current_theme["font_size"],
            titlefont_size = current_theme["titlefont_size"],
            font_color = current_theme["font_color"]
        )
    )
end



# transactions over time scatter plot
callback!(
    app,
    Output("transaction_time_plot", "figure"),
    Input("json_category_data", "children"),
    Input("flag_picker", "value")
) do json_data, flag
    
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
                text = transaction_info,
                marker_color = current_theme[flag]
            )
        ],
        PlotlyJS.Layout(
            title = "Transactions over Time",
            hovermode = "closest",
            plot_bgcolor = current_theme["background"],
            paper_bgcolor = current_theme["background"],
            yaxis_gridcolor = current_theme["grid_color"],
            xaxis_gridcolor = current_theme["grid_color"],
            font_size = current_theme["font_size"],
            titlefont_size = current_theme["titlefont_size"],
            font_color = current_theme["font_color"]
        )
    )
end



# distribution statistics table
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
                            html_td([round(median(category_data.Transaction), digits=2)]),
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
                        ]),
                        html_tr([
                            html_td(["Total (sum)"]),
                            html_td([round(sum(category_data.Transaction), digits=2)])
                        ])
                    ])
                ],
                className="center"
            )
        ]
    )
end



# top transaction table
callback!(
    app,
    Output("top_transactions", "children"),
    Input("json_category_data", "children")
) do json_data

    # number of top transactions
    n = 15
    
    category_data = DataFrames.DataFrame(JSON.parse(json_data, null=missing))
    category_data = convertColumnTypes(category_data, "Date")

    replace!(category_data.Name, missing=>"")
    DataFrames.sort!(category_data, :Transaction, rev=true)

    # add position to dataframe to be displayed
    pos = 1:min(DataFrames.nrow(category_data), n)
    sub_df = category_data[pos, :]
    sub_df[:, "Position"] = pos
    cols = ["Position", "Transaction", "Date", "Category", "Name"]

    return html_div([
        html_h5("Top $n Transactions", style=Dict("text-align"=>"center")),
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



