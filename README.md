# Personal Finance Dashboard

This dashboard app provides a useful way to monitor and analyze ones personal finances to gain insights into ones income streams and spending habits. It works on transaction data collected through the [Moneyboard mobile app](https://www.moneyboardapp.com/), but is in no way affiliated with said app.


## Online Demo Version

The final version of this app is deployed to a Heroku server with some demo data in order to showcase the possibilities of a Dash app built in Julia. The demo can be accessed at [https://personal-finance-dash-board.herokuapp.com](https://personal-finance-dash-board.herokuapp.com). However, the app is intended to be run locally on your own hardware if you intend to analyze your own financial data. Data must be collected through the Moneyboard mobile app (not affiliated), see instructions below.

&#9888; __Please note__ that the app on Heroku will take a long time to start up and to load each page for the first time. You might need to load the page a second time if the website shows an `Application Error` message. For more details on why this issue occurs see "Deployment on Heroku" below.



## Instructions to Run the App Locally

__Before running__ the app on your local machine, make sure to instantiate the proper environment specified in the `Project.toml` file (Note, it is assumed that you have some version of the Julia programming language installed and know how to run files from the terminal). You can do so as follows:
1. Clone this repository.
2. `cd` into the repository.
3. Start a julia REPL session by typing `julia` and press `Enter`.
4. Enter the package manager by typing `]` and run the following commands: 
```
activate .
instantiate
```


In order to __run__ the dashboard, run the following steps in order. If you wish to run it using artificial demo data, you can skip steps 1-3. To use different ports or filenames (e.g. to keep multiple files for different accounts in the same data directory) you can run the file `app.jl` in the root directory. `app.jl` serves as the entry point to the app (run `julia app.jl --help` for information on the script arguments). However, for simplicity's sake I provided small bash scripts which take care of most things and only the steps below need to be followed.
1. On your mobile phone export the __Transactions__ data from the Moneyboard mobile app as __csv__ and select the desired period.  
2. Name the csv file "Moneyboard.csv" and place it inside the "data" folder of this cloned repository.
3. In the terminal navigate to the root directory of the repository, then run the file `preprocess_data.sh`. This step will preprocess the data in a way such that the app can later handle it nicely. After this process is finished you will be able to see a file called "preprocessed_data.csv" inside the "data" folder.  
4. If you haven't already in step 3, then navigate to the root directory of the repository.  
5. Run the `run.sh` file in the terminal to start the application. If the process is successful, a message like `[ Info: Listening on: 0.0.0.0:8050` will appear in the terminal. Open your browser and enter `0.0.0.0:8050` into your browser address bar. Initial loading of the pages might take some time, but subsequent actions (like adjusting filters or plots) will be a lot quicker.



## Navigation in the Dashboard

The dashboard is composed of three pages. `Home`, `Aggregated` and `Transactions`. 

- The `Home` page displays this README.
- The `Aggregated` page presents the data in aggregated form. The time period to be analyzed can be chosen in the top left of the page. The time frequency for aggregation can be chosen in the top right of the page. Selecting the frequencies "Yearly", "Monthly", "Weekly" or "Daily" aggregates the data for each period individually. Selecting any option prefixed with "By " aggregates the data for all periods, but does not treat the individual periods separately. For example, selecting "Monthly" selects every month (Jan. 2020, Feb. 2020, ..., Jan. 2021), note that "Jan. 2020" and "Jan. 2021" are separate from each other. Selecting "By Calendar Month" would aggregate all Januaries into one group, creating in total 12 groups.
- The `Transactions` page presents the data in its unaggregated form, i.e. each transaction individually. The filter in the top right allows to choose from all categories of income or expense that can be found in the data.


## Interacting with Plots

__Every filter or selector (drop downs or calendar box) affects all plots below the filter, but not the ones above.__

Interactions with plots are relatively simple. Hovering over the plots reveals detailed information about all entities (lines, areas, bars, dots, etc.) contained in the plot. Many plots contain a legend in the top right which explains what the individual entities represent. __Clicking__ on an entity once will add/remove it from the plot. Plots will always adapt to the entities displayed (i.e. probabilities of a pie chart will change, such that they always sum up to one; margins will adapt, such that the full area of the plot is used; etc.). __Quickly double clicking__ will isolate the clicked on entity such that only it will be shown. 

In the top right of most plots (above the legend) is a bar of tools to zoom in/out, pan and select certain elements. Pressing the &#127968;-icon will reset the axes to its original position.


## Quick Project Summary

This project began partly out of curiosity about my own spending habits and partly as an excuse to learn the Julia programming language. This is also the first time that I used Plotly and Dash.


### Design Decisions

Following is a short list of some of the most important design decisions made during this project:

- The input specifying the date range has precedence over the input for the interval (i.e. "Yearly", "Monthly", ...). This means that for example if you choose \"2020-01-15\" and \"2020-08-15\" and \"Monthly\", the first and last month will only cover the data available between those start and end dates, even if for example data from 2020-01-01 to 2020-01-14 also was available. This has two advantages: First, the user has a way to clearly exclude certain days. Second, it keeps the code simple and intuitive.
- The dataframe that is subset to only include the specified date range is saved as a JSON string in the users browser. This dataframe is then parsed and aggregated to match the specified interval and saved again in the users browser. This allows for states to be shared across multiple plots without it affecting other users (more information [here](https://dash-julia.plotly.com/sharing-data-between-callbacks)). This has the downside that the writing and parsing of the dataframes takes some time, but it keeps the code easily extendable to add more plots, as it eliminates the need to repeatedly perform the same operations for every plot, and it also reduces the amount of grouping operations that need to be done.
- The whole project is designed to follow the Model-View-Controller (MVC) pattern of object oriented programming as much as possible/necessary. The individual html pages (src/pages) are the views. The `index.jl` file is the controller. The `callbacks.jl` file performs most of the heavy lifting upon calls by the controller, it is therefore the model.


### Deployment on Heroku 


For demo purposes I deployed the dashboard app on a heroku server so that everyone can explore the app without any installation of Julia necessary. The app can be explored at [https://personal-finance-dash-board.herokuapp.com](https://personal-finance-dash-board.herokuapp.com). 

#### Issues with Deployment on Heroku
Unfortunately, towards the completion of this project (February 2022) when the only thing left was to deploy a demo version, I realized that Julia and Heroku don't get along very well. Or in other words: Julia is not well suited for web development (yet), in particular not with how Heroku handles it. This shows in:

- A long initial startup of the pages (as Julia precompiles packages and functions). However, subsequent changes to the plots (e.g. using the filters) run relatively fast. This is accentuated by the fact that Heroku shuts down apps after 30 minutes of inactivity for free web apps.
- A high memory usage, which causes the Heroku server to kill and restart the app from time to time upon heavy usage. 

These issues are also noted in [this GitHub repository](https://gist.github.com/fonsp/38965d7595a5d1060e27d6ca2084778d#precompilation) by a user named fonsp, who provides a julia buildpack which precompiles most of the code in the build step of deployment. This helped decreasing the load times of my app by a lot.

These issues are not unique to my dashboard and can also be observed in other Julia dashboards written with Dash and deployed on Heroku (e.g. see [https://juliadash.herokuapp.com/](https://juliadash.herokuapp.com/) which was used in this very helpful [tutorial](https://towardsdatascience.com/deploying-julia-projects-on-heroku-com-eb8da5248134)). However the issues might be pronounced in my app as I used a fairly large amount of plots.

### Conclusion

Nevertheless, I am really happy with what I achieved in a relatively short amount of time. Julia is a relatively easy language to pick up and quite powerful at the same time. 

[Dash.jl](https://github.com/plotly/dash.jl) which enabled the core functionality of the dashboard and [PlotlyJS.jl](https://github.com/JuliaPlots/PlotlyJS.jl) which allowed me to create interactive and heavily customizable plots are easy to work with and produce great looking results. For PlotlyJS.jl I also recommend looking at this [youtube video](https://www.youtube.com/watch?v=_qx-j3HGHkE) in addition to the docs. That way one can use the entire plotly.js library with all its features, to really customize plots to one's heart's content. Also the simplicity of deploying a Julia app on Heroku is amazing, and the ability to deploy small projects like this one for free is really great to see. 
