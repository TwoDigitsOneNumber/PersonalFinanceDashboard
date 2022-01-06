import Colors
import PlotlyJS




# --------------------------------------------------------------------
# custom color selection


# dict with custom colors (cc)
cc = Dict()

# define custom colors (cc) to use
cc["blue"] = "#"*Colors.hex(Colors.RGBA(23/255, 190/255, 207/255, 1), :RRGGBB)  # light blue
cc["darkblue"] = "#"*Colors.hex(Colors.RGBA(31/255, 119/255, 180/255, 1), :RRGGBB)  # dark blue
cc["green"] = "#"*Colors.hex(Colors.RGBA(60/255, 143/255, 53/255, 1), :RRGGBB)
cc["orange"]  = "#"*Colors.hex(Colors.RGBA(222/255, 98/255, 17/255, 1), :RRGGBB)
# cc["gray"] = "#"*Colors.hex(Colors.RGBA(72/255, 72/255, 72/255, 1), :RRGGBB)
cc["gray"] = "#"*Colors.hex(Colors.RGBA(99/255, 149/255, 160/255, 1), :RRGGBB)
cc["darkwhite"] = "#"*Colors.hex(Colors.RGBA(205/255, 205/255, 205/255, 1), :RRGGBB)

# for cycler
cc["green"] = "#"*Colors.hex(Colors.RGBA(0/255, 221/255, 111/255, 1), :RRGGBB)
cc["lightblue"] = "#"*Colors.hex(Colors.RGBA(122/255, 191/255, 228/255, 1), :RRGGBB)
cc["pink"] = "#"*Colors.hex(Colors.RGBA(204/255, 0/255, 204/255, 1), :RRGGBB)
cc["red"] = "#"*Colors.hex(Colors.RGBA(255/255, 77/255, 77/255, 1), :RRGGBB)
cc["orange"] = "#"*Colors.hex(Colors.RGBA(255/255, 128/255, 0/255, 1), :RRGGBB)
cc["yellow"] = "#"*Colors.hex(Colors.RGBA(234/255, 234/255, 0/255, 1), :RRGGBB)
cc["darkblue"] = "#"*Colors.hex(Colors.RGBA(30/255, 107/255, 149/255, 1), :RRGGBB)
cc["gray"] = "#"*Colors.hex(Colors.RGBA(25/255, 25/255, 31/255, 1), :RRGGBB)
cc["violet"] = "#"*Colors.hex(Colors.RGBA(128/255, 0/255, 225/255, 1), :RRGGBB)
cc["brown"] = "#"*Colors.hex(Colors.RGBA(128/255, 64/255, 64/255, 1), :RRGGBB)
cc["darkgreen"] = "#"*Colors.hex(Colors.RGBA(0/255, 128/255, 64/255, 1), :RRGGBB)



# pick colors to cycle through in plots with multiple colors
# mind the order!
cc["cycler"] = [
    cc["darkblue"],
    cc["lightblue"],
    cc["yellow"],
    cc["orange"],
    cc["red"],
    cc["pink"],
    cc["violet"],
    cc["brown"],
    cc["darkgreen"],
    cc["green"]
]





# --------------------------------------------------------------------
# custom plot style  (deprecated)

# # define style to use for all plots
# fin_style = let
#     axis = PlotlyJS.attr(
#         color = cc["darkwhite"],
#         font_size = 12
#         # showgrid = true,
#         # gridcolor = cc["darkwhite"],
#     )

#     layout = PlotlyJS.Layout(
#         plot_bgcolor = cc["gray"],
#         paper_bgcolor = cc["gray"],
#         font_size = 12,
#         xaxis = axis,
#         yaxis = axis,
#         titlefont_size=18,
#         # legend_font_color = cc["darkwhite"],
#         font_color = cc["darkwhite"],
#         xaxis_automargin = true,
#         yaxis_automargin = true
#     )

#     colors = PlotlyJS.Cycler(cc["cycler"])

#     gta = PlotlyJS.attr(
#         marker_line_width=0.5, marker_line_color="#348ABD", marker_color=colors
#     )

#     # PlotlyJS.Style(layout=layout, global_trace=gta)
# end


# layout = (
#     plot_bgcolor = cc["gray"],
#     paper_bgcolor = cc["gray"],
#     font_size = 12,
#     titlefont_size = 18,
#     font_color = cc["darkwhite"]
#     # legend_font_color = cc["darkwhite"],
#     # xaxis_automargin = true,
#     # yaxis_automargin = true
# )


theme_dark = Dict(
    "background" => cc["gray"],
    "accent" => cc["darkblue"],
    "font_color" => cc["darkwhite"],
    "text" => cc["darkwhite"],
    "titlefont_size" => 18,
    "font_size" => 12,
    # "plot_style" => fin_style,  # deprecated
    "Income" => cc["green"],
    "Expense" => cc["orange"],
    "cycler" => cc["cycler"]
)

# theme_light = Dict(
#     "background" => cc["gray"],
#     "accent" => cc["darkblue"],
#     "text" => cc["darkwhite"]
# )

current_theme = theme_dark