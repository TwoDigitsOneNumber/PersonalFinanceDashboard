import Statistics
import DataFrames



function findUniqueChars(array::AbstractArray)
    unique_chars = []
    for entry in unique(array)  # iterate over unique entries in Array
        if isa(entry, AbstractString)  # typecheck: check if entry is AbstractString
            for char_idx in collect(eachindex(entry))  # iterate over characters and append unique ones
                if !(entry[char_idx] in unique_chars)
                    append!(unique_chars, entry[char_idx])
                end
            end
        end
    end
    return sort(unique_chars)
end



function findAndReplace!(df::DataFrames.DataFrame, column, find_::Regex, replace_::AbstractString)
    for row in eachrow(df)
        if isa(row[column], AbstractString)  # type check: replace only on string defined
            row[column] = replace(row[column], find_=>replace_)
        end
    end
end


function parseIgnoreMissing!(df::DataFrames.DataFrame, parse_to; cols=:)
    new_col = Array{Union{Missing, parse_to}}(missing, nrow(df))
    for (i, v) in enumerate(df[!, cols])
        if isa(v, AbstractString)
            new_col[i] = parse(parse_to, v)
        end
    end
    df[!, cols] = new_col
end


function cumsumIgnoreMissing(array::AbstractArray, type_)

    missing_cumsum = zeros(Union{Missing, type_}, length(array))
    sumcum_ = cumsum(skipmissing(array))
    
    count_missing = 0
    for (i, v) in enumerate(array)
        if ismissing(v) && (count_missing > 0)
            missing_cumsum[i] = missing_cumsum[i-1]
            count_missing += 1
        elseif ismissing(v)
            missing_cumsum[i] = missing
            count_missing += 1
        else
            missing_cumsum[i] = sumcum_[i - count_missing]
        end
    end
    
    return missing_cumsum
end


function convertColumnTypes(df::DataFrames.DataFrame, interval::AbstractString)

    # only select columns that are in the dataframe
    string_cols = []
    for col in ["Category", "Flag"]
        if col in DataFrames.names(df)
            append!(string_cols, [col])
        end
    end
        

    if (interval == "Hour") | (interval == "Year")
        df[!, interval] = [string(i) for i in df[!, interval]]
    elseif (interval == "Date")
        df[!, interval] = [Dates.Date(i) for i in df[!, interval]]
    elseif (interval == "Weekday")
        df[!, interval] = DataFrames.CategoricalArray(df[!, interval])
        # define levels for sorting weekdays
        DataFrames.levels!(df[!, interval], ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])
    else
        append!(string_cols, [interval])
    end


    for col in string_cols
        df[!,col] = convert(Array{Union{Missing, String}, 1}, df[!,col])
    end


    if "Transaction" in names(df)
        df.Transaction = convert(Array{Float64, 1}, df.Transaction)
    elseif "Transaction_sum" in names(df)
        df.Transaction_sum = convert(Array{Float64, 1}, df.Transaction_sum)
    end

    return df
end


function unpackJSONData(json_data::AbstractString)
    # json data and convert agg_data column types
    json = JSON.parse(json_data, null=missing)

    interval = json["interval"]
    agg_data = DataFrames.DataFrame(json["agg_data"])
    agg_data = convertColumnTypes(agg_data, interval)

    return (agg_data, interval)
end

