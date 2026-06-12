\name{inspect_enrich_plot}
\alias{inspect_enrich_plot}
\title{Inspect enrichment data and suggest plotting parameters}
\description{
Return a structured diagnostic summary for an enrichment result table. The
output is designed for agent-assisted tuning: it reports data metrics and the
same automatic plotting parameters that \code{enrich_plot()} and
\code{save_enrich()} would use.
}
\usage{
inspect_enrich_plot(data, term = "Description", value = "p.adjust",
  count = "Count", ratio = "GeneRatio", group = NULL, top_n = 20,
  order_by = c("ratio", "value"),
  layout = c("auto", "single", "compare", "facet"),
  palette = "journal", wrap_width = "auto", label_size = "auto",
  dot_min_size = "auto", dot_max_size = "auto", base_size = 12,
  font_family = "", title_size = "auto", subtitle_size = "auto",
  axis_title_size = "auto", axis_text_size = "auto",
  legend_title_size = "auto", legend_text_size = "auto",
  width = "auto", height = "auto", panel_width = "auto",
  width_padding = 0.15, panel_background_color = "white",
  plot_background_color = "white", grid = c("both", "x", "none"),
  grid_color = "#E4E7EB", grid_linewidth = 0.32,
  border_color = "#C8CDD2", border_linewidth = 0.45)
}
\arguments{
\item{data}{A data frame containing already prepared enrichment results.}
\item{term}{Column containing pathway or term names.}
\item{value}{Column containing adjusted p-values or FDR values in \code{[0, 1]}.}
\item{count}{Column containing gene counts.}
\item{ratio}{Column containing numeric ratios or strings such as \code{"12/300"}.}
\item{group}{Optional grouping column for comparisons.}
\item{top_n}{Number of rows to keep per group. Rows are selected by the
\code{value} column, with smaller adjusted p-values/FDR values first. Use
\code{NULL} to keep all rows. Dotplot diagnostics use \code{ratio} ordering
for the selected rows.}
\item{order_by}{Dotplot display ordering to inspect after \code{top_n}
selection. Use \code{"ratio"} for GeneRatio-style ordering or \code{"value"}
for adjusted p-value/FDR ordering.}
\item{layout}{Dotplot layout used for diagnostics.}
\item{palette}{Palette name passed to \code{enrich_palette()}.}
\item{wrap_width, label_size}{Label settings to inspect. Use \code{"auto"} to
return automatic suggestions.}
\item{dot_min_size, dot_max_size}{Dot size settings to inspect. Use
\code{"auto"} to return automatic suggestions.}
\item{base_size}{Base theme font size used when individual text sizes are
\code{"auto"}.}
\item{font_family}{Font family to inspect. The default \code{""} uses the
current graphics device default.}
\item{title_size, subtitle_size}{Plot title and subtitle font sizes to inspect,
or \code{"auto"} to return automatic suggestions.}
\item{axis_title_size, axis_text_size}{X-axis title and tick-label font sizes
to inspect, or \code{"auto"} to return automatic suggestions.}
\item{legend_title_size, legend_text_size}{Legend title and legend-label font
sizes to inspect, or \code{"auto"} to return automatic suggestions.}
\item{width, height, panel_width}{Output size settings to inspect. Use
\code{"auto"} for automatic suggestions. Set \code{panel_width = NULL} to
inspect standard ggplot2 layout without a fixed panel width.}
\item{width_padding}{Extra width, in inches, added after automatic width
measurement.}
\item{panel_background_color}{Color for the plotting panel background.}
\item{plot_background_color}{Color for the whole plot and legend background.}
\item{grid}{Panel grid density: \code{"both"}, \code{"x"}, or \code{"none"}.}
\item{grid_color, grid_linewidth}{Major grid line color and thickness.}
\item{border_color, border_linewidth}{Panel border color and thickness.}
}
\value{
A list with \code{metrics}, \code{suggested_params}, \code{resolved}, and
\code{notes}. The \code{suggested_params} element is split into
\code{enrich_plot} and \code{save_enrich} entries so an agent can map user
feedback directly to function arguments. The resolved palette is reported in
\code{suggested_params$enrich_plot$palette} and \code{resolved$palette}.
}
