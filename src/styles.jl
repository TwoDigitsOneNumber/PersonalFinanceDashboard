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
cc["gray"] = "#"*Colors.hex(Colors.RGBA(25/255, 25/255, 31/255, 1), :RRGGBB)
cc["darkwhite"] = "#"*Colors.hex(Colors.RGBA(205/255, 205/255, 205/255, 1), :RRGGBB)



# --------------------------------------------------------------------
# custom plot style

# define style to use for all plots
fin_style = let
    axis = PlotlyJS.attr(
        color = cc["darkwhite"],
        font_size = 12
        # showgrid = true,
        # gridcolor = cc["darkwhite"],
    )

    layout = PlotlyJS.Layout(
        plot_bgcolor = cc["gray"],
        paper_bgcolor = cc["gray"],
        font_size = 12,
        xaxis = axis,
        yaxis=axis,
        titlefont_size=18,
        # legend_font_color = cc["darkwhite"],
        font_color = cc["darkwhite"],
        xaxis_automargin = true,
        yaxis_automargin = true
    )

    colors = PlotlyJS.Cycler([
        "#348ABD", "#E24A33", "#988ED5", "#777777", "#FBC15E",
        "#8EBA42", "#FFB5B8"
    ])

    # colors = PlotlyJS.Cycler([
    #     "#408E2F",  # green
    #     "#A43741",  # red
    #     "#AA5B39",  # orange
    #     "#AA7439",  # beige
    #     "#27586B",  # blue
    # ])

    gta = PlotlyJS.attr(
        marker_line_width=0.5, marker_line_color="#348ABD", marker_color=colors
    )

    PlotlyJS.Style(layout=layout, global_trace=gta)
end


theme_dark = Dict(
    "background" => cc["gray"],
    "accent" => cc["darkblue"],
    "text" => cc["darkwhite"],
    "plot_style" => fin_style
)

# theme_light = Dict(
#     "background" => cc["gray"],
#     "accent" => cc["darkblue"],
#     "text" => cc["darkwhite"]
# )

current_theme = theme_dark