# PersonalFinanceDashboard


## Instructions

__Before running__ the app on your local machine, make sure to instantiate the proper environment specified in the `Project.toml` file. You can do so as follows:
1. `cd` into the repository.
2. Start a julia REPL session by typing `julia` and press `Enter`.
3. Enter the package manager by typing `]` and run the following commands: 
```
activate .
instantiate
```


In order to __run__ the dashboard, run the following steps in order. If you wish to run it using artificial demo data, you can skip steps 1-3.
1. Export the __Transactions__ data from the Moneyboard mobile app as __csv__ and select the desired period.  
2. Name the csv file "Moneyboard.csv" and place it inside the "data" folder.  
3. In the terminal navigate to the root directory of the repository, then run the file `preprocess_data.sh`. This step will preprocess the data in a way such that the app can later handle it nicely. After this process is finished you will be able to see a file called "preprocessed_data.csv" inside the "data" folder.  
4. If you haven't already in step 3, then navigate to the root directory of the repository.  
5. Run the `run.sh` file in the terminal to start the application. If the process is successful, a message like `[ Info: Listening on: 0.0.0.0:8050` will appear in the terminal. Open your browser and enter `localhost:8050` into the address bar of firefox, or `0.0.0.0:8050` on other browsers. Initial loading of the pages might take some time, but subsequent actions (like adjusting filters or plots) will be a lot quicker.


## Navigation in the Dashboard

The dashboard is composed of three pages. `Home`, `Aggregated` and `Transactions`. 

- The `Home` page displays this README.
- The `Aggregated` page presents the data in aggregated form. The time period to be analyzed can be chosen in the top left of the page. The time frequency for aggregation can be chosen in the top right of the page. Selecting the frequencies "Yearly", "Monthly", "Weekly" or "Daily" aggregates the data for each period individually. Selecting any option prefixed with "By " aggregates the data for all periods, but does not treat the individual periods separately. For example, selecting "Monthly" selects every month (Jan. 2020, Feb. 2020, ..., Jan. 2021), note that "Jan. 2020" and "Jan. 2021" are separate from each other. Selecting "By Calendar Month" would aggregate all Januaries into one group.
- The `Transactions` page presents the data in its unaggregated form. The filter in the top right allows to choose from all categories of income or expense that can be found in the data.


## Interacting with Plots

__Every filter or selector (drop downs or calendar box) affects all plots below the filter, but not the ones above.__

Interactions with plots are relatively simple. Hovering over the plots reveals detailed information about all entities (lines, areas, bars, dots, etc.) contained in the plot. Many plots contain a legend in the top right which explains what the individual entities represent. __Clicking__ on an entity once will add/remove it from the display. Plots will always adapt to the entities displayed (i.e. probabilities of a pie chart will change, such that they always sum up to one; margins will adapt, such that the full area of the plot is used; etc.). __Quickly double clicking__ will isolate the clicked on entity, and only it will be shown. 

In the top right of most plots (above the legend) is a bar of tools to zoom in/out, pan and select certain elements. Pressing the "house"-icon will reset the axes to its original position.


## Design Choices

- The input specifying the date range has precedence over the input for the interval (i.e. "Yearly", "Monthly", ...). This means that for example if you choose \"2020-01-15\" and \"2020-08-15\" and \"Montly\", the first and last month will not cover the full data available if the appropriate start and end of the month would have been chosen. This has two advantages. First, the user has a way to clearly exclude certain days. Second, it keeps the code simple and intuitive.
- The dataframe that is subset to only include the specified date range is saved as a JSON string in the users browser. This dataframe is then parsed and aggregated to match the specified interval and saved again in the users browser. This allows for states to be shared across multiple plots without it affecting other users (more information [here](https://dash-julia.plotly.com/sharing-data-between-callbacks)). This has the downside that the writing and parsing of the dataframes takes some time, but it keeps the code easily extendable to add more plots, as it eliminates the need to repeatedly perform the same operations for every plot, and it also reduces the amount of grouping operations that need to be done.
- The whole project is designed to follow the Model-View-Controller (MVC) pattern of object oriented programming as much as possible/necessary. The individual html pages (src/pages) are the views. The `index.jl` file is the controller. The `callbacks.jl` file performs most of the heavy lifting upon calls by the controller, it is therefore the model.