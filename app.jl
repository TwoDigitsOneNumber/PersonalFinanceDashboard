# this script starts the app
using ArgParse


# define command line arguments
function parse_commandline()
    s = ArgParseSettings()
    
    @add_arg_table! s begin

        "--file_name"
        help = "input file name of the preprocessed csv file (incl. file extension). Type \"demo\" to use the demo file."
        arg_type = String
        default = "demo"

        "--debug"
        help = "debug mode (round circle with info in bottom ritht corner of the page)"
        arg_type = Bool
        default = false

        "PORT"
        help = "The port to run the server on"
        default = 8050

    end
    
    return parse_args(s)
end

# handle command line arguments
parsed_args = parse_commandline()
# ! make sure to unpack them correctly in src/index.jl
ARGS = [
    parsed_args["file_name"], 
    parsed_args["debug"],
    parsed_args["PORT"]
]

# start program
cd("./src/")
include("src/index.jl")