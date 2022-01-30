import Colors
import PlotlyJS




# --------------------------------------------------------------------
# custom color selection


# dict with custom colors (cc)
cc = Dict()

# define custom colors (cc) to use
cc["green"] = "#"*Colors.hex(Colors.RGBA(0/255, 204/255, 150/255, 1), :RRGGBB)
cc["darkgreen"] = "#"*Colors.hex(Colors.RGBA(0/255, 128/255, 64/255, 1), :RRGGBB)

cc["lightteal"] = "#"*Colors.hex(Colors.RGBA(99/255, 149/255, 160/255, 1), :RRGGBB)
cc["darkteal"] = "#"*Colors.hex(Colors.RGBA(37/255, 101/255, 115/255, 1), :RRGGBB)

cc["lightblue"] = "#"*Colors.hex(Colors.RGBA(122/255, 191/255, 228/255, 1), :RRGGBB)
cc["blue"] = "#"*Colors.hex(Colors.RGBA(23/255, 190/255, 207/255, 1), :RRGGBB)  
# cc["darkblue"] = "#"*Colors.hex(Colors.RGBA(30/255, 107/255, 149/255, 1), :RRGGBB)
cc["darkblue"] = "#"*Colors.hex(Colors.RGBA(31/255, 119/255, 180/255, 1), :RRGGBB)  # dark blue
cc["darkdarkblue"] = "#"*Colors.hex(Colors.RGBA(5/255, 35/255, 60/255, 1), :RRGGBB)

cc["violet"] = "#"*Colors.hex(Colors.RGBA(171/255, 99/255, 250/255, 1), :RRGGBB)
cc["red"] = "#"*Colors.hex(Colors.RGBA(239/255, 85/255, 59/255, 1), :RRGGBB)
cc["orange"]  = "#"*Colors.hex(Colors.RGBA(255/255, 161/255, 90/255, 1), :RRGGBB)
cc["yellow"] = "#"*Colors.hex(Colors.RGBA(234/255, 234/255, 0/255, 1), :RRGGBB)

cc["brown"] = "#"*Colors.hex(Colors.RGBA(128/255, 64/255, 64/255, 1), :RRGGBB)

cc["black"] = "#"*Colors.hex(Colors.RGBA(0/255, 0/255, 0/255, 1), :RRGGBB)
cc["gray"] = "#"*Colors.hex(Colors.RGBA(65/255, 73/255, 75/255, 1), :RRGGBB)
cc["lightgray"] = "#"*Colors.hex(Colors.RGBA(140/255, 140/255, 140/255, 1), :RRGGBB)
cc["darkwhite"] = "#"*Colors.hex(Colors.RGBA(205/255, 205/255, 205/255, 1), :RRGGBB)
cc["white"] = "#"*Colors.hex(Colors.RGBA(255/255, 255/255, 255/255, 1), :RRGGBB)


# plotlyjs default colors
#     '#1f77b4',  // muted blue
#     '#ff7f0e',  // safety orange
#     '#2ca02c',  // cooked asparagus green
#     '#d62728',  // brick red
#     '#9467bd',  // muted purple
#     '#8c564b',  // chestnut brown
#     '#e377c2',  // raspberry yogurt pink
#     '#7f7f7f',  // middle gray
#     '#bcbd22',  // curry yellow-green
#     '#17becf'   // blue-teal



# pick colors to cycle through in plots with multiple colors
# mind the order!
# cc["cycler"] = [
#     cc["darkblue"],  # 1
#     cc["lightblue"],  # 2
#     cc["yellow"],  # 3
#     cc["orange"],  # 4
#     cc["red"],  # 5
#     cc["pink"],  # 6
#     cc["violet"],  # 7
#     cc["brown"],  # 8
#     cc["darkgreen"],  # 9
#     cc["green"]  # 10
# ]

# --------------------------------------------------------------------

grid_col = "#"*Colors.hex(Colors.RGBA(20/255, 76/255, 115/255, 1), :RRGGBB)

theme_dark = Dict(
    "background" => cc["darkdarkblue"],
    "accent" => cc["darkblue"],
    "grid_color" => grid_col,
    "font_color" => cc["white"],
    "text" => cc["white"],
    "titlefont_size" => 18,
    "font_size" => 12,
    "Income" => cc["green"],
    "Expense" => cc["red"],
    "cc" => cc
    # "cycler" => cc["cycler"]
)


current_theme = theme_dark