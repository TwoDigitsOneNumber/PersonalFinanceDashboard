# this script cleans the data and saves it

# todo: make sure data folder is created if it doesn't exist already
# todo: take file name and path as argument to the script


using DataFrames
import CSV
import Dates
import PlotlyJS

# include custom functions
include("functions.jl")

# read dataframe
transactions = DataFrame(CSV.File("../data/Moneyboard.csv"; ignoreemptylines=true, comment="#"))




# --------------------------------------------------------------------
# clean dataset


# remove last row
transactions = transactions[1:end-1, :]

# convert columns Date and Time to type DateType and TimeType
transactions.Date = Dates.Date.(transactions.Date, "dd.mm.yy") + Dates.Year(2000)
transactions.Time = Dates.Time.(transactions.Time, "HH:MM")

# find all unique characters (especially non-ASCII characters)
findUniqueChars(transactions.Category)
findUniqueChars(transactions.Name)
findUniqueChars(transactions.Notes)
findUniqueChars(transactions.Expense)
findUniqueChars(transactions.Income)

# In columns Expense and Income
# remove all characters that are not digits or a decimal point
for col in [:Expense, :Income]
    findAndReplace!(transactions, col, r"CHF", "")  # remove CHF
    findAndReplace!(transactions, col, r"\u00A0", "")  # remove unicode space
    findAndReplace!(transactions, col, r"\u2019", "")  # remove unicode quote
end

# convert columns Expense and Income to type Float64
parseIgnoreMissing!(transactions, Float64, cols=:Expense)
parseIgnoreMissing!(transactions, Float64, cols=:Income)


# sort dataframe by date and time
sort!(transactions, [:Date, :Time])



# --------------------------------------------------------------------
# Feature Engineering


# add label indicating if transaction is income or expense
transactions.Flag = [ismissing(i) ? "Expense" : "Income" for i in transactions.Income]


# add full time series to make sure every day is included (even if there are no transactions)
date_range = transactions.Date[begin]:Dates.Day(1):transactions.Date[end]


# make sure all dates are in the dataset for all categories
allowmissing!(transactions, propertynames(transactions))
for col in ["Expense", "Income"]

    for cat in unique(skipmissing(transactions[transactions.Flag .== col, :].Category))
        # choose dates that are not in the transactions dataframe
        date_range_col = date_range[[t in transactions[(transactions.Flag .== col) .& (transactions.Category .== cat), :].Date ? false : true for t in date_range]]
        n =  length(date_range_col)

        dates_df = DataFrames.DataFrame(
            Date=date_range_col,
            Time=Array{Union{Missing, Dates.Time}, 1}(missing, n),
            Category=fill(cat, n),
            Name=Array{Union{Missing, String}, 1}(missing, n),
            Notes=Array{Union{Missing, String}, 1}(missing, n),
            Expense=Array{Union{Missing, Float64}, 1}(missing, n),
            Income=Array{Union{Missing, Float64}, 1}(missing, n),
            Flag=fill(col, n)
        )

        replace!(dates_df.Time, missing=>Dates.Time(0))

        # append new dataframe to transactions and sort in place
        DataFrames.append!(transactions, dates_df)
    end
end


# add columns for grouping by date and time
transactions.Year = [Dates.year(t) for t in transactions.Date]
transactions.YearMonth = [Dates.monthname(t) * " " * string(Dates.year(t)) for t in transactions.Date]
transactions.YearWeek = ["Week " * string(Dates.week(t)) * " " * string(Dates.year(t)) for t in transactions.Date]
transactions.Weekday = [Dates.dayname(t) for t in transactions.Date]
transactions.Hour = [Dates.hour(t) for t in transactions.Time]


# add column with all transactions
transactions.Transaction = replace(transactions.Income, missing=>0) + replace(transactions.Expense, missing=>0)


DataFrames.sort!(transactions, [:Date, :Time])



# --------------------------------------------------------------------
# save clean dataframe

CSV.write("../data/clean_data.csv", transactions)

