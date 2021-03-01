# PersonalFinanceDashboard


todo: write instructions.


* place `Moneyboard.csv` file in /data/ folder and run `src/moneyboard.jl`
* else a demo file gets used
* run /src/index.jl file


todo: how to interact with plots
* click legend
* zoom in


The filters and selectors always affect all plots that are placed below the filter.

## Design Choices

* The input specifying the date range has precedence over the input for the interval (i.e. "Yearly", "Monthly", $\dots$). This means that for example if you choose \"2020-01-15\" and \"2020-08-15\" and \"Montly\", the first and last month will not cover the full data available if the appropriate start and end of the month would have been chosen. This has two advantages. First, the user has a way to clearly exclude certain days. Second, it keeps the code simple and intuitive.
* The dataframe that is subset to only include the specified date range is saved as a JSON string in the users browser. This dataframe is then parsed and aggregated to match the specified interval and saved again in the users browser. This allows for states to be shared across multiple plots without it affecting other users (more information [here](https://dash-julia.plotly.com/sharing-data-between-callbacks)). This has the downside that the writing and parsing of the dataframes takes some time, but it keeps the code easily extendable to add more plots, as it eliminates the need to repeatedly perform the same operations for every plot, and it also reduces the amount of grouping operations that need to be done.

* MVC pattern