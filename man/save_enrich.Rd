\name{save_enrich}
\alias{save_enrich}
\title{Save an enrichment plot}
\description{
Save an enrichment plot with white background and sensible device defaults.
}
\usage{
save_enrich(plot, filename, width = "auto", height = "auto", dpi = 320,
  device = NULL, panel_width = "auto", auto_width = TRUE,
  width_padding = 0.15, ...)
}
\arguments{
\item{plot}{A \code{ggplot} object.}
\item{filename}{Output file path.}
\item{width, height}{Output size in inches, or \code{"auto"} to choose a
size from the plot content. Automatic height grows with the number of displayed
terms; automatic width grows with labels, legends, and the fixed panel width.}
\item{dpi}{Raster output resolution.}
\item{device}{Optional graphics device passed to \code{ggplot2::ggsave()}.}
\item{panel_width}{Fixed plot panel width in inches, \code{"auto"} for a
content-based default, or \code{NULL} to leave the panel under standard ggplot2
layout control. When supplied, the middle plotting area keeps this width even
when y-axis labels are long.}
\item{auto_width}{When \code{TRUE}, expand the output width as needed so fixed
panel width, labels, and legends fit without squeezing the plot panel. If
\code{FALSE}, a numeric \code{width} is used as-is; \code{width = "auto"} is
still resolved to a numeric width.}
\item{width_padding}{Extra width, in inches, added after automatic width
measurement.}
\item{...}{Additional arguments passed to \code{ggplot2::ggsave()}.}
}
\value{The output filename, invisibly.}
