\name{theme_enrich}
\alias{theme_enrich}
\title{A refined enrichment plot theme}
\description{
Return the default theme used by \code{enrichdot} plots.
}
\usage{
theme_enrich(base_size = 12, font_family = "", legend_position = "right",
  title_size = "auto",
  subtitle_size = "auto", axis_title_size = "auto",
  axis_text_size = "auto", label_size = NULL,
  legend_title_size = "auto", legend_text_size = "auto",
  panel_background_color = "white", plot_background_color = "white",
  grid = c("both", "x", "none"), grid_color = "#E4E7EB",
  grid_linewidth = 0.32, border_color = "#C8CDD2",
  border_linewidth = 0.45)
}
\arguments{
\item{base_size}{Base font size.}
\item{font_family}{Font family passed to \code{ggplot2::theme_minimal()}.}
\item{legend_position}{Legend position passed to \code{ggplot2::theme()}.}
\item{title_size, subtitle_size}{Plot title and subtitle font sizes, or
\code{"auto"} to derive defaults from \code{base_size}.}
\item{axis_title_size, axis_text_size}{X-axis title and tick-label font sizes,
or \code{"auto"} to derive defaults from \code{base_size}.}
\item{label_size}{Optional y-axis term label font size. Leave \code{NULL}
to inherit the theme default.}
\item{legend_title_size, legend_text_size}{Legend title and legend-label font
sizes, or \code{"auto"} to derive defaults from \code{base_size}.}
\item{panel_background_color}{Color for the plotting panel background.}
\item{plot_background_color}{Color for the whole plot and legend background.}
\item{grid}{Panel grid density: \code{"both"} for x and y major grid lines,
\code{"x"} for vertical grid lines only, or \code{"none"} for no major grid.}
\item{grid_color, grid_linewidth}{Major grid line color and thickness.}
\item{border_color, border_linewidth}{Panel border color and thickness.}
}
\value{A \code{ggplot2} theme.}
