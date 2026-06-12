\name{enrich_plot}
\alias{enrich_plot}
\title{Draw a polished enrichment dotplot or barplot}
\description{
Draw a polished enrichment dotplot or barplot from an already prepared
enrichment result table. The function prints resolved automatic parameters
with \code{message()} so agent-assisted workflows can tune from the exact
values used in the first plot.
}
\usage{
enrich_plot(data, term = "Description", value = "p.adjust",
  count = "Count", ratio = "GeneRatio", group = NULL, top_n = 20,
  order_by = c("ratio", "value"), type = c("dot", "bar"),
  layout = c("auto", "single", "compare", "facet"),
  palette = "journal", wrap_width = "auto", title = NULL, subtitle = NULL,
  xlab = NULL, base_size = 12, font_family = "", title_size = "auto",
  subtitle_size = "auto",
  axis_title_size = "auto", axis_text_size = "auto",
  label_size = "auto", legend_title_size = "auto",
  legend_text_size = "auto", dot_min_size = "auto",
  dot_max_size = "auto", panel_background_color = "white",
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
\item{group}{Optional grouping column for faceted comparisons.}
\item{top_n}{Number of rows to keep per group. Rows are selected by the
\code{value} column, with smaller adjusted p-values/FDR values first. Use
\code{NULL} to keep all rows. Dotplots display the selected rows by
\code{ratio} from large to small, matching common \code{enrichplot::dotplot()}
ordering.}
\item{order_by}{Dotplot display ordering after \code{top_n} selection.
\code{"ratio"} (default) orders by the column mapped through \code{ratio},
typically \code{GeneRatio}, from large to small. \code{"value"} orders by the
column mapped through \code{value}, typically \code{p.adjust}, from small to
large. Barplots keep significance ordering.}
\item{type}{Plot type: \code{"dot"} or \code{"bar"}.}
\item{layout}{Dotplot layout. \code{"auto"} uses a single GeneRatio x-axis
when \code{group = NULL} and a compare-style group x-axis when \code{group}
is supplied. Use \code{"facet"} to keep a GeneRatio x-axis within each group.}
\item{palette}{Palette name passed to \code{enrich_palette()}. The default
\code{"journal"} keeps the common enrichment dotplot semantics with a more
publication-oriented muted red, salmon, blue-gray, and blue adjusted p-value
scale. The same default is used by \code{inspect_enrich_plot()} and
\code{enrich_palette()}.}
\item{wrap_width}{Character width for wrapping long term labels, or
\code{"auto"} to choose a width from the displayed terms and row count.}
\item{title, subtitle, xlab}{Optional plot labels.}
\item{base_size}{Base theme font size used when individual text sizes are
\code{"auto"}.}
\item{font_family}{Font family passed to the ggplot theme. The default
\code{""} uses the current graphics device default.}
\item{title_size, subtitle_size}{Plot title and subtitle font sizes, or
\code{"auto"} to derive polished defaults from \code{base_size}.}
\item{axis_title_size, axis_text_size}{X-axis title and tick-label font sizes,
or \code{"auto"} to derive polished defaults from \code{base_size}.}
\item{label_size}{Y-axis term label font size, or \code{"auto"} to choose a
readable size from the displayed row count. This is the main control for
pathway/term label readability.}
\item{legend_title_size, legend_text_size}{Legend title and legend-label font
sizes, or \code{"auto"} to derive polished defaults from \code{base_size}.}
\item{dot_min_size, dot_max_size}{Minimum and maximum dot display sizes for
the \code{Count} mapping, or \code{"auto"} to choose sizes from the displayed
row count and count spread. These tune how prominent bubbles appear without
changing what variable controls bubble size.}
\item{panel_background_color}{Color for the plotting panel background.}
\item{plot_background_color}{Color for the whole plot and legend background.}
\item{grid}{Panel grid density: \code{"both"} for x and y major grid lines,
\code{"x"} for vertical grid lines only, or \code{"none"} for no major grid.}
\item{grid_color, grid_linewidth}{Major grid line color and thickness.}
\item{border_color, border_linewidth}{Panel border color and thickness.}
}
\value{A \code{ggplot} object.}
