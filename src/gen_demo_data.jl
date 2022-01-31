using DataFrames
using Dates
using Random
using Distributions
using CSV


# date range
start_year = 2018
years = 4
date_range = Date(start_year, 1, 1):Day(1):Date(start_year+years, 12, 31)
nr_days_per_year = div(length(date_range), years)


# ------------------------------------------------------------
# helper functions


function increase_integers(array, lower, upper)
    max = maximum(array)
    mask = (array .<= upper) .& (array .>= lower)
    array[mask] = trunc.(Int, (array[mask] .- lower) .* (max - lower)/(upper - lower) .+ lower)
    return array
end


"""
Take a random sample from the dates in the date_range. Dates can be choosen multiple times.
"""
function sample_dates_and_times(date_range, n_samples, seed; increasing=false)
    n = length(date_range)
    
    # sample n_samples from the date_range
    Random.seed!(seed)
    sample_idx = rand(1:n, n_samples)

    # to get increasing number samples over time just increase some of the lower indices
    if increasing
        q1, q2, q3 = quantile(sample_idx, [.25, .5, .75])
        sample_idx = increase_integers(sample_idx, q2, q3)
        sample_idx = increase_integers(sample_idx, q1, q2)
        sample_idx = increase_integers(sample_idx, 0, q1)
    end

    # sample n_samples from the time_range
    Random.seed!(seed)
    sample_time = Time.(rand(0:23, n_samples), rand(0:59, n_samples))
    return date_range[sample_idx], sample_time
end


function regular_dates_and_times(date_range, days)
    n_months = div(length(date_range), days)
    first_date = date_range[1] + Day(days-2)
    monthly_dates = first_date:Day(days):date_range[end]
    return monthly_dates, repeat([Time(12)], n_months)
end


"""
Generate DataFrame with some data.

dates: array of Dates
times: array of Times
categories: string of category name
names: array of strings with transaction names, if 0, then names are missing
Expense: array of transaction amounts (floats, rounded to 2 decimal places)
Income: array of transaction amounts (floats, rounded to 2 decimal places)

Either income or expense must be 0 and the other must contain values.
"""
function build_df(dates, times, category, Names, Expense, Income)
    if Expense == 0
        transactions = Income
        transaction_name = "Income"
        other = "Expense"
    else
        transactions = Expense
        transaction_name = "Expense"
        other = "Income"
    end
    transactions = ["CHF $i" for i in transactions]

    if Names == 0
        Names = repeat([missing], length(dates))
    end

    df = DataFrame(
        "Date" => dates,
        "Time" => times,
        "Category" => repeat([category], length(dates)),
        "Name" => Names,
        "Notes" => repeat([missing], length(dates)),
        "$transaction_name" => transactions,
        "$other" => repeat([missing], length(dates))
    )
    return df
end


# -----------------------------------------------------------------------------
# create dataframe for each category (each row is a transaction)



# ===== Expenses =====


# ----- food -----
food_n = years*52  # number of transactions
food_dates, food_times = sample_dates_and_times(date_range, food_n, 1)  # random dates
# sample transaction amounts from exponential distribution
food_amounts = round.( 200 .* rand(Exponential(1), food_n), digits=2)

food_df = build_df(food_dates, food_times, "Food", 0, food_amounts, 0)


# ----- clothing -----
clothing_n = 32
clothing_dates, clothing_times = sample_dates_and_times(date_range, clothing_n, 2)
clothing_amounts = abs.(round.(rand(Normal(55, 20), clothing_n), digits=2))

clothing_df = build_df(clothing_dates, clothing_times, "Clothing", 0, clothing_amounts, 0)


# ----- public transport -----
public_transport_n = 50
public_transport_dates, public_transport_times = sample_dates_and_times(date_range, public_transport_n, 3)
public_transport_amounts = abs.(round.(rand(Normal(30, 25), public_transport_n), digits=2))

public_transport_df = build_df(public_transport_dates, public_transport_times, "Public Transport", 0, public_transport_amounts, 0)


# ----- rent -----
rent_n = div(length(date_range), 30)
rent_dates, rent_times = regular_dates_and_times(date_range, 30)
rent_amounts = repeat([1900], rent_n)

# increase rent after a "random" point
rent_amounts[43:rent_n] .+= 1400

rent_df = build_df(rent_dates, rent_times, "Rent", 0, rent_amounts, 0)


# ----- utilities -----
utilities_n = div(length(date_range), 30)
utilities_dates, utilities_times = regular_dates_and_times(date_range, 30)
utilities_amounts = abs.(round.(rand(Normal(500, 100), utilities_n), digits=2))

utilities_df = build_df(utilities_dates, utilities_times, "Utilities", 0, utilities_amounts, 0)


# ----- coffee -----
coffee_n = years*nr_days_per_year
coffee_dates, coffee_times = sample_dates_and_times(date_range, coffee_n, 4, increasing=true)
coffee_amounts = abs.(round.(rand(Normal(7, 2), coffee_n), digits=2))

coffee_df = build_df(coffee_dates, coffee_times, "Coffee", 0, coffee_amounts, 0)



# ===== Incomes =====

# ----- salary -----
salary_n = div(length(date_range), 30)
salary_dates, salary_times = regular_dates_and_times(date_range, 30)  # get salary every 30 days
salary_amounts = repeat([2000], salary_n)

# increase salary twice at "random" points
salary_amounts[17:salary_n] .+= 1000
salary_amounts[29:salary_n] .+= 1000

salary_df = build_df(salary_dates, salary_times, "Salary", 0, 0, salary_amounts)


# ----- gifts -----
gifts_n = 2 * div(length(date_range), nr_days_per_year)
gifts_dates, gifts_times = regular_dates_and_times(date_range, div(nr_days_per_year, 2))  # get gifts every year
gifts_amounts = abs.(round.(rand(Normal(400, 200), gifts_n), digits=2))

gifts_df = build_df(gifts_dates, gifts_times, "Gifts", 0, 0, gifts_amounts)


# ----- dividends -----
dividends_n = div(length(date_range), 30)
dividends_dates, dividends_times = sample_dates_and_times(date_range, dividends_n, 5, increasing=true)  # get dividends every quarter
dividends_amounts = abs.(round.(rand(Normal(800, 100), dividends_n), digits=2))

dividends_df = build_df(dividends_dates, dividends_times, "Dividends", 0, 0, dividends_amounts)



# ===== single transactions =====

single_transact_1 = DataFrame(
    "Date" => [date_range[1]+Day(657)],
    "Time" => [Time(12)],
    "Category" => ["Other"],
    "Name" => ["Lottery Win"],
    "Notes" => [missing],
    "Expense" => [missing],
    "Income" => [10_000]
)

single_transact_2 = DataFrame(
    "Date" => [date_range[1]+Day(1020)],
    "Time" => [Time(12)],
    "Category" => ["Other"],
    "Name" => ["Promotion Bonus"],
    "Notes" => [missing],
    "Expense" => [missing],
    "Income" => [20_000]
)

single_transact_3 = DataFrame(
    "Date" => [date_range[1]+Day(1670)],
    "Time" => [Time(12)],
    "Category" => ["Technology"],
    "Name" => ["New Laptop"],
    "Notes" => [missing],
    "Expense" => [2_199],
    "Income" => [missing]
)

single_transact_4 = DataFrame(
    "Date" => [date_range[1]+Day(100)],
    "Time" => [Time(12)],
    "Category" => ["Holiday"],
    "Name" => ["Holiday Trip Ibiza"],
    "Notes" => [missing],
    "Expense" => [1800],
    "Income" => [missing]
)

single_transact_5 = DataFrame(
    "Date" => [date_range[1]+Day(nr_days_per_year+100)],
    "Time" => [Time(12)],
    "Category" => ["Holiday"],
    "Name" => ["Holiday Trip Canada"],
    "Notes" => [missing],
    "Expense" => [2799],
    "Income" => [missing]
)

single_transact_6 = DataFrame(
    "Date" => [date_range[1]+Day(nr_days_per_year*2+90)],
    "Time" => [Time(12)],
    "Category" => ["Technology"],
    "Name" => ["4K TV"],
    "Notes" => [missing],
    "Expense" => [1899],
    "Income" => [missing]
)

single_transact_7 = DataFrame(
    "Date" => [date_range[1]+Day(nr_days_per_year*2+100)],
    "Time" => [Time(12)],
    "Category" => ["Holiday"],
    "Name" => ["New Playstation"],
    "Notes" => [missing],
    "Expense" => [900],
    "Income" => [missing]
)

single_transact_8 = DataFrame(
    "Date" => [date_range[1]+Day(nr_days_per_year*2+100)],
    "Time" => [Time(12)],
    "Category" => ["Holiday"],
    "Name" => ["Indonesia"],
    "Notes" => [missing],
    "Expense" => [2990],
    "Income" => [missing]
)




# -----------------------------------------------------------------------------
# combine dataframe and save dataframe


# concatenate all dataframes together into one dataframe
df = vcat(
    food_df, clothing_df, public_transport_df, rent_df, utilities_df, coffee_df, 
    salary_df, gifts_df, dividends_df,
    single_transact_1, single_transact_2, single_transact_3, single_transact_4, 
    single_transact_5, single_transact_6, single_transact_7, single_transact_8
)

# sort dataframe by date (newest first)
sort!(df, :Date, rev=true)

# format date and time column (yy.mm.dd)
df.Time = [string(a)[1:5] for a in df.Time]  # "hh:mm"
df.Date = [string(a)[9:10]*"."*string(a)[6:7]*"."*string(a)[3:4] for a in df.Date]  # "yy.mm.dd"

# save dataframe
CSV.write("../data/demo_data.csv", df)
println("Data generation done!")