.enrichdot_default_palette <- "journal"

.enrichdot_palettes <- list(
  classic = list(
    p_adjust = c("#D73027", "#F7F7F7", "#4575B4"),
    p_adjust_values = c(0, 0.52, 1),
    score = c("#4575B4", "#F7F7F7", "#D73027"),
    score_values = c(0, 0.48, 1),
    accent = "#D73027"
  ),
  journal = list(
    p_adjust = c("#B2182B", "#DF7F7A", "#D8E1EA", "#2166AC"),
    p_adjust_values = c(0, 0.34, 0.66, 1),
    score = c("#2166AC", "#D8E1EA", "#DF7F7A", "#B2182B"),
    score_values = c(0, 0.34, 0.66, 1),
    accent = "#B2182B"
  ),
  presentation = list(
    p_adjust = c("#D7191C", "#FDAE61", "#ABD9E9", "#2C7BB6"),
    p_adjust_values = c(0, 0.35, 0.65, 1),
    score = c("#2C7BB6", "#ABD9E9", "#FDAE61", "#D7191C"),
    score_values = c(0, 0.35, 0.65, 1),
    accent = "#D7191C"
  )
)

.enrichdot_colorbar_guide <- function() {
  ggplot2::guide_colorbar(order = 1)
}

enrich_plot <- function(data,
                        term = "Description",
                        value = "p.adjust",
                        count = "Count",
                        ratio = "GeneRatio",
                        group = NULL,
                        top_n = 20,
                        order_by = c("ratio", "value"),
                        type = c("dot", "bar"),
                        layout = c("auto", "single", "compare", "facet"),
                        palette = "journal",
                        wrap_width = "auto",
                        title = NULL,
                        subtitle = NULL,
                        xlab = NULL,
                        base_size = 12,
                        font_family = "",
                        title_size = "auto",
                        subtitle_size = "auto",
                        axis_title_size = "auto",
                        axis_text_size = "auto",
                        label_size = "auto",
                        legend_title_size = "auto",
                        legend_text_size = "auto",
                        dot_min_size = "auto",
                        dot_max_size = "auto",
                        panel_background_color = "white",
                        plot_background_color = "white",
                        grid = c("both", "x", "none"),
                        grid_color = "#E4E7EB",
                        grid_linewidth = 0.32,
                        border_color = "#C8CDD2",
                        border_linewidth = 0.45) {
  type <- match.arg(type)
  order_by <- match.arg(order_by)
  layout <- match.arg(layout)
  grid <- match.arg(grid)
  palette <- resolve_palette_name(palette, "palette")
  pal <- enrich_palette(palette)
  plot_data <- prepare_enrich_data(
    data = data,
    term = term,
    value = value,
    count = count,
    ratio = ratio,
    group = group,
    top_n = top_n,
    wrap_width = wrap_width,
    display_order = if (identical(type, "dot")) order_by else "value"
  )
  label_size <- resolve_label_size(nrow(plot_data), label_size, base_size)
  text_sizes <- resolve_text_sizes(
    base_size = base_size,
    title_size = title_size,
    subtitle_size = subtitle_size,
    axis_title_size = axis_title_size,
    axis_text_size = axis_text_size,
    legend_title_size = legend_title_size,
    legend_text_size = legend_text_size
  )
  dot_size_range <- resolve_dot_size_range(plot_data$.count, dot_min_size, dot_max_size)

  if (type == "dot") {
    layout <- resolve_dot_layout(layout, group)
    p <- draw_enrich_dotplot(
      plot_data = plot_data,
      layout = layout,
      value = value,
      count = count,
      ratio = ratio,
      group = group,
      palette = pal,
      title = title,
      subtitle = subtitle,
      xlab = xlab,
      dot_size_range = dot_size_range
    )
  } else {
    p <- ggplot2::ggplot(
      plot_data,
      ggplot2::aes(x = .score, y = .term_label, fill = .score)
    ) +
      ggplot2::geom_col(width = 0.72, alpha = 0.96) +
      ggplot2::geom_text(
        ggplot2::aes(label = .count),
        hjust = -0.18,
        color = "#344054",
        size = 3.2
      ) +
      ggplot2::scale_fill_gradientn(
        colors = pal$score,
        values = pal$score_values %||% NULL,
        name = "-log10(adj. p)",
        guide = .enrichdot_colorbar_guide()
      ) +
      ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0, 0.16))) +
      ggplot2::labs(
        x = xlab %||% "-log10(adjusted p-value)",
        y = NULL,
        title = title,
        subtitle = subtitle
      )
  }

  if (type == "dot" && identical(layout, "facet")) {
    p <- p + ggplot2::facet_wrap(stats::as.formula("~ .group"), scales = "free_y")
  } else if (type != "dot" && !is.null(group)) {
    p <- p + ggplot2::facet_wrap(stats::as.formula("~ .group"), scales = "free_y")
  }

  out <- p + theme_enrich(
    base_size = base_size,
    font_family = font_family,
    title_size = text_sizes$title_size,
    subtitle_size = text_sizes$subtitle_size,
    axis_title_size = text_sizes$axis_title_size,
    axis_text_size = text_sizes$axis_text_size,
    label_size = label_size,
    legend_title_size = text_sizes$legend_title_size,
    legend_text_size = text_sizes$legend_text_size,
    panel_background_color = panel_background_color,
    plot_background_color = plot_background_color,
    grid = grid,
    grid_color = grid_color,
    grid_linewidth = grid_linewidth,
    border_color = border_color,
    border_linewidth = border_linewidth
  )
  message_resolved_enrich_params(
    plot = out,
    type = type,
    top_n = top_n,
    value = value,
    count = count,
    ratio = ratio,
    order_by = order_by,
    palette = palette,
    layout = layout,
    wrap_width = attr(plot_data, "wrap_width", exact = TRUE),
    label_size = label_size,
    text_sizes = text_sizes,
    dot_size_range = dot_size_range
  )
  attr(out, "enrichdot_palette") <- palette
  out
}

inspect_enrich_plot <- function(data,
                                term = "Description",
                                value = "p.adjust",
                                count = "Count",
                                ratio = "GeneRatio",
                                group = NULL,
                                top_n = 20,
                                order_by = c("ratio", "value"),
                                layout = c("auto", "single", "compare", "facet"),
                                palette = "journal",
                                wrap_width = "auto",
                                label_size = "auto",
                                dot_min_size = "auto",
                                dot_max_size = "auto",
                                base_size = 12,
                                font_family = "",
                                title_size = "auto",
                                subtitle_size = "auto",
                                axis_title_size = "auto",
                                axis_text_size = "auto",
                                legend_title_size = "auto",
                                legend_text_size = "auto",
                                width = "auto",
                                height = "auto",
                                panel_width = "auto",
                                width_padding = 0.15,
                                panel_background_color = "white",
                                plot_background_color = "white",
                                grid = c("both", "x", "none"),
                                grid_color = "#E4E7EB",
                                grid_linewidth = 0.32,
                                border_color = "#C8CDD2",
                                border_linewidth = 0.45) {
  layout <- match.arg(layout)
  order_by <- match.arg(order_by)
  grid <- match.arg(grid)
  palette <- resolve_palette_name(palette, "palette")

  plot_data <- prepare_enrich_data(
    data = data,
    term = term,
    value = value,
    count = count,
    ratio = ratio,
    group = group,
    top_n = top_n,
    wrap_width = wrap_width,
    display_order = order_by
  )

  resolved_wrap_width <- attr(plot_data, "wrap_width", exact = TRUE)
  resolved_label_size <- resolve_label_size(nrow(plot_data), label_size, base_size)
  resolved_text_sizes <- resolve_text_sizes(
    base_size = base_size,
    title_size = title_size,
    subtitle_size = subtitle_size,
    axis_title_size = axis_title_size,
    axis_text_size = axis_text_size,
    legend_title_size = legend_title_size,
    legend_text_size = legend_text_size
  )
  resolved_dot_size_range <- resolve_dot_size_range(plot_data$.count, dot_min_size, dot_max_size)
  resolved_layout <- resolve_dot_layout(layout, group)

  plot <- enrich_plot(
    data = data,
    term = term,
    value = value,
    count = count,
    ratio = ratio,
    group = group,
    top_n = top_n,
    order_by = order_by,
    layout = layout,
    palette = palette,
    wrap_width = wrap_width,
    base_size = base_size,
    font_family = font_family,
    title_size = title_size,
    subtitle_size = subtitle_size,
    axis_title_size = axis_title_size,
    axis_text_size = axis_text_size,
    label_size = label_size,
    legend_title_size = legend_title_size,
    legend_text_size = legend_text_size,
    dot_min_size = dot_min_size,
    dot_max_size = dot_max_size,
    panel_background_color = panel_background_color,
    plot_background_color = plot_background_color,
    grid = grid,
    grid_color = grid_color,
    grid_linewidth = grid_linewidth,
    border_color = border_color,
    border_linewidth = border_linewidth
  )

  resolved_height <- resolve_output_height(plot, height)
  if (is.null(panel_width)) {
    resolved_panel_width <- NULL
    resolved_width <- resolve_output_width(width, NULL, fallback = 7.2, width_padding = width_padding)
  } else {
    resolved_panel_width <- resolve_panel_width(plot, panel_width)
    measured <- fixed_panel_grob(plot, panel_width = resolved_panel_width)
    resolved_width <- resolve_output_width(width, measured, fallback = 7.2, width_padding = width_padding)
  }

  labels <- unique(as.character(plot_data$.term_label))
  label_lines <- vapply(labels, function(label) length(strsplit(label, "\n", fixed = TRUE)[[1]]), integer(1))
  counts <- plot_data$.count[is.finite(plot_data$.count)]
  count_spread <- if (length(counts) > 1 && min(counts) > 0) max(counts) / min(counts) else 1

  notes <- character(0)
  if (nrow(plot_data) > 35) {
    notes <- c(notes, "many_terms: automatic height is increased; consider reducing `top_n` only if the figure is intended for slides.")
  }
  if (max(nchar(plot_data$.term, type = "chars", allowNA = FALSE)) > 80) {
    notes <- c(notes, "long_labels: automatic width and wrapping are used to protect the plot panel.")
  }
  if (count_spread > 8) {
    notes <- c(notes, "wide_count_spread: automatic dot size is capped so large bubbles do not dominate the panel.")
  }
  if (!identical(palette, .enrichdot_default_palette)) {
    notes <- c(notes, paste0("palette_override: using `", palette, "` instead of default `", .enrichdot_default_palette, "`."))
  }
  if (length(notes) == 0) {
    notes <- "ok: automatic settings should be readable for a journal-style dotplot."
  }

  structure(
    list(
      metrics = list(
        n_terms = nrow(plot_data),
        n_groups = length(unique(plot_data$.group)),
        max_label_length = max(nchar(plot_data$.term, type = "chars", allowNA = FALSE)),
        median_label_length = unname(stats::median(nchar(plot_data$.term, type = "chars", allowNA = FALSE))),
        max_label_lines = max(label_lines),
        count_min = min(plot_data$.count),
        count_max = max(plot_data$.count),
        count_spread = unname(count_spread),
        value_min = min(plot_data$.value),
        value_max = max(plot_data$.value)
      ),
      suggested_params = list(
        enrich_plot = list(
          palette = palette,
          font_family = font_family,
          title_size = resolved_text_sizes$title_size,
          subtitle_size = resolved_text_sizes$subtitle_size,
          axis_title_size = resolved_text_sizes$axis_title_size,
          axis_text_size = resolved_text_sizes$axis_text_size,
          order_by = order_by,
          wrap_width = resolved_wrap_width,
          label_size = resolved_label_size,
          legend_title_size = resolved_text_sizes$legend_title_size,
          legend_text_size = resolved_text_sizes$legend_text_size,
          dot_min_size = resolved_dot_size_range[1],
          dot_max_size = resolved_dot_size_range[2],
          panel_background_color = check_color_string(panel_background_color, "panel_background_color"),
          plot_background_color = check_color_string(plot_background_color, "plot_background_color"),
          grid = grid,
          grid_color = check_color_string(grid_color, "grid_color"),
          grid_linewidth = check_nonnegative_number(grid_linewidth, "grid_linewidth"),
          border_color = check_color_string(border_color, "border_color"),
          border_linewidth = check_nonnegative_number(border_linewidth, "border_linewidth")
        ),
        save_enrich = list(
          width = resolved_width,
          height = resolved_height,
          panel_width = resolved_panel_width
        )
      ),
      resolved = list(
        layout = resolved_layout,
        palette = palette,
        order_by = order_by,
        top_n = top_n
      ),
      notes = notes
    ),
    class = c("enrichdot_inspection", "list")
  )
}

enrich_palette <- function(name = "journal") {
  name <- resolve_palette_name(name, "name")
  palette <- .enrichdot_palettes[[name]]
  palette$name <- name
  palette
}

draw_enrich_dotplot <- function(plot_data,
                                layout,
                                value,
                                count,
                                ratio,
                                group,
                                palette,
                                title,
                                subtitle,
                                xlab,
                                dot_size_range) {
  base <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(y = .term_label, size = .count, color = .value)
  ) +
    ggplot2::geom_point(alpha = 0.92) +
    ggplot2::scale_color_gradientn(
      colors = palette$p_adjust,
      values = palette$p_adjust_values %||% NULL,
      name = value,
      guide = .enrichdot_colorbar_guide()
    ) +
    ggplot2::scale_size_continuous(
      range = dot_size_range,
      breaks = count_legend_breaks(plot_data$.count),
      name = count,
      guide = ggplot2::guide_legend(order = 2)
    ) +
    ggplot2::labs(y = NULL, title = title, subtitle = subtitle)

  if (identical(layout, "compare")) {
    return(base +
      ggplot2::aes(x = .group) +
      ggplot2::scale_x_discrete(expand = ggplot2::expansion(add = 0.55)) +
      ggplot2::labs(x = xlab %||% group))
  }

  x_breaks <- pretty(plot_data$.ratio, n = 3)
  base +
    ggplot2::aes(x = .ratio) +
    ggplot2::scale_x_continuous(
      breaks = x_breaks,
      expand = ggplot2::expansion(mult = c(0.10, 0.10))
    ) +
    ggplot2::labs(x = xlab %||% if (is.null(ratio)) count else ratio)
}

resolve_dot_layout <- function(layout, group) {
  if (identical(layout, "auto")) {
    return(if (is.null(group)) "single" else "compare")
  }
  if (identical(layout, "facet") && is.null(group)) {
    return("single")
  }
  if (identical(layout, "compare") && is.null(group)) {
    stop("`layout = \"compare\"` requires `group` to be supplied.", call. = FALSE)
  }
  layout
}

theme_enrich <- function(base_size = 12,
                         font_family = "",
                         legend_position = "right",
                         title_size = "auto",
                         subtitle_size = "auto",
                         axis_title_size = "auto",
                         axis_text_size = "auto",
                         label_size = NULL,
                         legend_title_size = "auto",
                         legend_text_size = "auto",
                         panel_background_color = "white",
                         plot_background_color = "white",
                         grid = c("both", "x", "none"),
                         grid_color = "#E4E7EB",
                         grid_linewidth = 0.32,
                         border_color = "#C8CDD2",
                         border_linewidth = 0.45) {
  grid <- match.arg(grid)
  font_family <- check_font_family(font_family, "font_family")
  grid_linewidth <- check_nonnegative_number(grid_linewidth, "grid_linewidth")
  border_linewidth <- check_nonnegative_number(border_linewidth, "border_linewidth")
  panel_background_color <- check_color_string(panel_background_color, "panel_background_color")
  plot_background_color <- check_color_string(plot_background_color, "plot_background_color")
  grid_color <- check_color_string(grid_color, "grid_color")
  border_color <- check_color_string(border_color, "border_color")
  text_sizes <- resolve_text_sizes(
    base_size = base_size,
    title_size = title_size,
    subtitle_size = subtitle_size,
    axis_title_size = axis_title_size,
    axis_text_size = axis_text_size,
    legend_title_size = legend_title_size,
    legend_text_size = legend_text_size
  )
  axis_y_text <- ggplot2::element_text(color = "#1F2937", lineheight = 0.95)
  if (!is.null(label_size)) {
    label_size <- if (is_auto(label_size)) base_size * 0.82 else label_size
    axis_y_text <- ggplot2::element_text(
      color = "#1F2937",
      lineheight = 0.95,
      size = check_positive_number(label_size, "label_size")
    )
  }

  ggplot2::theme_minimal(base_size = base_size, base_family = font_family) +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = panel_background_color, color = NA),
      plot.background = ggplot2::element_rect(fill = plot_background_color, color = NA),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = if (identical(grid, "both")) {
        ggplot2::element_line(color = grid_color, linewidth = grid_linewidth)
      } else {
        ggplot2::element_blank()
      },
      panel.grid.major.x = if (identical(grid, "x")) {
        ggplot2::element_line(color = grid_color, linewidth = grid_linewidth)
      } else {
        NULL
      },
      panel.grid.major.y = if (identical(grid, "x")) {
        ggplot2::element_blank()
      } else {
        NULL
      },
      panel.border = ggplot2::element_rect(fill = NA, color = border_color, linewidth = border_linewidth),
      axis.text.y = axis_y_text,
      axis.text.x = ggplot2::element_text(color = "#344054", size = text_sizes$axis_text_size),
      axis.title.x = ggplot2::element_text(color = "#202A36", face = "bold", size = text_sizes$axis_title_size),
      plot.title = ggplot2::element_text(color = "#17202B", face = "bold", size = text_sizes$title_size),
      plot.subtitle = ggplot2::element_text(color = "#667085", size = text_sizes$subtitle_size, margin = ggplot2::margin(t = 3, b = 8)),
      plot.caption = ggplot2::element_text(color = "#667085"),
      plot.margin = ggplot2::margin(12, 24, 12, 18),
      strip.text = ggplot2::element_text(color = "#202A36", face = "bold", size = text_sizes$axis_title_size),
      strip.background = ggplot2::element_rect(fill = "#F2F4F7", color = NA),
      legend.position = legend_position,
      legend.background = ggplot2::element_rect(fill = plot_background_color, color = NA),
      legend.key = ggplot2::element_rect(fill = plot_background_color, color = NA),
      legend.title = ggplot2::element_text(color = "#202A36", face = "bold", size = text_sizes$legend_title_size),
      legend.text = ggplot2::element_text(color = "#475467", size = text_sizes$legend_text_size)
    )
}

save_enrich <- function(plot,
                        filename,
                        width = "auto",
                        height = "auto",
                        dpi = 320,
                        device = NULL,
                        panel_width = "auto",
                        auto_width = TRUE,
                        width_padding = 0.15,
                        ...) {
  height <- resolve_output_height(plot, height)

  if (!is.null(panel_width)) {
    panel_width <- resolve_panel_width(plot, panel_width)
    plot <- fixed_panel_grob(plot, panel_width = panel_width)
    auto_width <- check_scalar_logical(auto_width, "auto_width")
    if (is_auto(width) || isTRUE(auto_width)) {
      width <- resolve_output_width(
        width = width,
        grob = if (isTRUE(auto_width) || is_auto(width)) plot else NULL,
        fallback = 7.2,
        width_padding = width_padding
      )
    } else {
      width <- check_positive_number(width, "width")
    }
  } else {
    width <- resolve_output_width(
      width = width,
      grob = NULL,
      fallback = 7.2,
      width_padding = width_padding
    )
  }

  args <- list(
    filename = filename,
    plot = plot,
    width = width,
    height = height,
    dpi = dpi,
    bg = "white",
    ...
  )
  args$device <- device %||% default_save_device(filename)
  do.call(ggplot2::ggsave, args)
  invisible(filename)
}

message_resolved_enrich_params <- function(plot,
                                           type,
                                           top_n,
                                           value,
                                           count,
                                           ratio,
                                           order_by,
                                           palette,
                                           layout,
                                           wrap_width,
                                           label_size,
                                           text_sizes,
                                           dot_size_range) {
  save_params <- default_save_params(plot)
  lines <- c(
    "enrichdot resolved parameters",
    "enrich_plot:",
    paste0("  type: ", type),
    paste0("  top_n: ", format_resolved_value(top_n)),
    paste0("  value: ", value),
    paste0("  count: ", count),
    paste0("  ratio: ", format_resolved_value(ratio)),
    paste0("  order_by: ", order_by),
    paste0("  palette: ", palette),
    paste0("  layout: ", layout),
    paste0("  wrap_width: ", format_resolved_value(wrap_width)),
    paste0("  label_size: ", format_resolved_number(label_size)),
    paste0("  title_size: ", format_resolved_number(text_sizes$title_size)),
    paste0("  subtitle_size: ", format_resolved_number(text_sizes$subtitle_size)),
    paste0("  axis_title_size: ", format_resolved_number(text_sizes$axis_title_size)),
    paste0("  axis_text_size: ", format_resolved_number(text_sizes$axis_text_size)),
    paste0("  legend_title_size: ", format_resolved_number(text_sizes$legend_title_size)),
    paste0("  legend_text_size: ", format_resolved_number(text_sizes$legend_text_size)),
    paste0("  dot_min_size: ", format_resolved_number(dot_size_range[1])),
    paste0("  dot_max_size: ", format_resolved_number(dot_size_range[2])),
    "save_enrich auto defaults:",
    paste0("  width: ", format_resolved_number(save_params$width)),
    paste0("  height: ", format_resolved_number(save_params$height)),
    paste0("  panel_width: ", format_resolved_number(save_params$panel_width)),
    paste0("  width_padding: ", format_resolved_number(save_params$width_padding))
  )
  message(paste(lines, collapse = "\n"))
}

default_save_params <- function(plot, width_padding = 0.15) {
  panel_width <- resolve_panel_width(plot, "auto")
  grob <- fixed_panel_grob(plot, panel_width = panel_width)
  list(
    width = resolve_output_width(
      width = "auto",
      grob = grob,
      fallback = 7.2,
      width_padding = width_padding
    ),
    height = resolve_output_height(plot, "auto"),
    panel_width = panel_width,
    width_padding = width_padding
  )
}

format_resolved_value <- function(value) {
  if (is.null(value)) {
    return("NULL")
  }
  if (length(value) == 0 || all(is.na(value))) {
    return("NA")
  }
  if (is.numeric(value)) {
    return(paste(vapply(value, format_resolved_number, character(1)), collapse = ", "))
  }
  paste(as.character(value), collapse = ", ")
}

format_resolved_number <- function(value) {
  if (length(value) == 0 || is.na(value)) {
    return("NA")
  }
  if (!is.numeric(value)) {
    return(as.character(value)[1])
  }
  format(round(value[1], 3), trim = TRUE, nsmall = 0, scientific = FALSE)
}

fixed_panel_grob <- function(plot, panel_width) {
  grob <- with_measure_device(ggplot2::ggplotGrob(plot))
  panel_cols <- unique(grob$layout$l[grepl("^panel", grob$layout$name)])
  if (length(panel_cols) == 0) {
    stop("`plot` does not contain a ggplot panel.", call. = FALSE)
  }
  grob$widths[panel_cols] <- as_panel_width_unit(panel_width)
  grob
}

as_panel_width_unit <- function(panel_width) {
  if (inherits(panel_width, "unit")) {
    return(panel_width)
  }
  grid::unit(check_positive_number(panel_width, "panel_width"), "in")
}

measure_grob_width <- function(grob) {
  with_measure_device(grid::convertWidth(sum(grob$widths), "in", valueOnly = TRUE))
}

with_measure_device <- function(expr) {
  opened_device <- is.null(grDevices::dev.list())
  if (opened_device) {
    tmp <- tempfile(fileext = ".png")
    ragg::agg_png(tmp, width = 1200, height = 900, res = 100)
    on.exit({
      grDevices::dev.off()
      unlink(tmp)
    }, add = TRUE)
  }
  force(expr)
}

resolve_panel_width <- function(plot, panel_width) {
  if (is_auto(panel_width)) {
    return(auto_panel_width(plot))
  }
  if (inherits(panel_width, "unit")) {
    return(panel_width)
  }
  check_positive_number(panel_width, "panel_width")
}

auto_panel_width <- function(plot) {
  data <- plot$data
  n_groups <- if (is.data.frame(data) && ".group" %in% names(data)) {
    length(unique(data$.group))
  } else {
    1
  }

  if (uses_group_x(plot)) {
    return(max(2.2, min(5.2, 1.3 + 0.55 * n_groups)))
  }

  n_terms <- plot_term_count(plot)
  if (n_terms > 35) {
    2.0
  } else if (n_terms > 22) {
    2.15
  } else {
    2.35
  }
}

uses_group_x <- function(plot) {
  x_mapping <- plot$mapping$x
  if (is.null(x_mapping)) {
    return(FALSE)
  }
  ".group" %in% all.names(x_mapping)
}

resolve_output_width <- function(width, grob, fallback, width_padding) {
  width_padding <- check_nonnegative_number(width_padding, "width_padding")
  if (is_auto(width)) {
    if (!is.null(grob)) {
      return(max(fallback, measure_grob_width(grob) + width_padding))
    }
    return(fallback)
  }

  width <- check_positive_number(width, "width")
  if (!is.null(grob)) {
    return(max(width, measure_grob_width(grob) + width_padding))
  }
  width
}

resolve_output_height <- function(plot, height) {
  if (!is_auto(height)) {
    return(check_positive_number(height, "height"))
  }

  n_terms <- plot_term_count(plot)
  label_lines <- plot_label_line_count(plot)
  extra_lines <- max(0, label_lines - n_terms)
  height <- 1.75 + 0.22 * n_terms + 0.08 * extra_lines
  max(4.2, min(18, height))
}

plot_term_count <- function(plot) {
  data <- plot$data
  if (is.data.frame(data) && ".term_label" %in% names(data)) {
    return(length(unique(as.character(data$.term_label))))
  }
  15
}

plot_label_line_count <- function(plot) {
  data <- plot$data
  if (is.data.frame(data) && ".term_label" %in% names(data)) {
    labels <- unique(as.character(data$.term_label))
    return(sum(vapply(labels, function(label) length(strsplit(label, "\n", fixed = TRUE)[[1]]), integer(1))))
  }
  plot_term_count(plot)
}

prepare_enrich_data <- function(data,
                                term,
                                value,
                                count,
                                ratio,
                                group,
                                top_n,
                                wrap_width,
                                display_order = c("ratio", "value")) {
  display_order <- match.arg(display_order)
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }
  check_column(data, term, "term")
  check_column(data, value, "value")
  check_column(data, count, "count")
  if (!is.null(ratio)) {
    check_column(data, ratio, "ratio")
  }
  if (!is.null(group)) {
    check_column(data, group, "group")
  }

  out <- data.frame(
    .term = as.character(data[[term]]),
    .value = suppressWarnings(as.numeric(data[[value]])),
    .count = suppressWarnings(as.numeric(data[[count]])),
    .ratio = if (is.null(ratio)) suppressWarnings(as.numeric(data[[count]])) else parse_ratio(data[[ratio]]),
    .group = if (is.null(group)) "All" else as.character(data[[group]]),
    stringsAsFactors = FALSE
  )

  keep <- !is.na(out$.term) &
    out$.term != "" &
    is.finite(out$.value) &
    is.finite(out$.count) &
    is.finite(out$.ratio)
  out <- out[keep, , drop = FALSE]
  if (nrow(out) == 0) {
    stop("no plottable enrichment rows after removing missing values.", call. = FALSE)
  }
  if (any(out$.value < 0 | out$.value > 1)) {
    stop("`value` column must contain p-values or FDR values in [0, 1].", call. = FALSE)
  }
  if (any(out$.count < 0)) {
    stop("`count` column must contain non-negative values.", call. = FALSE)
  }
  if (any(out$.ratio < 0)) {
    stop("`ratio` column must contain non-negative values.", call. = FALSE)
  }

  out$.value <- pmax(out$.value, .Machine$double.xmin)
  out$.score <- -log10(out$.value)
  out <- select_top_terms(out, top_n)
  out <- order_display_terms(out, display_order)
  wrap_width <- resolve_wrap_width(out$.term, wrap_width)
  out$.term_label <- wrap_terms(out$.term, wrap_width)
  out$.term_label <- factor(out$.term_label, levels = rev(unique(out$.term_label)))
  out$.group <- factor(out$.group, levels = unique(out$.group))
  attr(out, "wrap_width") <- wrap_width
  out
}

order_display_terms <- function(data, display_order) {
  if (identical(display_order, "ratio")) {
    return(data[order(data$.group, -data$.ratio, data$.value, -data$.count, data$.term), , drop = FALSE])
  }
  data[order(data$.group, data$.value, -data$.count, data$.term), , drop = FALSE]
}

select_top_terms <- function(data, top_n) {
  if (is.null(top_n)) {
    return(data)
  }
  top_n <- check_positive_integer(top_n, "top_n")

  pieces <- split(data, data$.group, drop = TRUE)
  selected <- lapply(pieces, function(piece) {
    piece <- piece[order(piece$.value, -piece$.count, piece$.term), , drop = FALSE]
    piece[seq_len(min(top_n, nrow(piece))), , drop = FALSE]
  })
  do.call(rbind, selected)
}

parse_ratio <- function(x) {
  if (is.numeric(x)) {
    return(as.numeric(x))
  }
  text <- trimws(as.character(x))
  parsed <- vapply(text, function(item) {
    if (grepl("/", item, fixed = TRUE)) {
      parts <- strsplit(item, "/", fixed = TRUE)[[1]]
      if (length(parts) == 2) {
        num <- suppressWarnings(as.numeric(parts[1]))
        den <- suppressWarnings(as.numeric(parts[2]))
        if (is.finite(num) && is.finite(den) && den != 0) {
          return(num / den)
        }
      }
    }
    suppressWarnings(as.numeric(item))
  }, numeric(1))
  parsed
}

wrap_terms <- function(x, width) {
  width <- as.integer(width)
  if (!is.finite(width) || width <= 0) {
    stop("`wrap_width` must be a positive integer.", call. = FALSE)
  }
  vapply(
    x,
    function(item) paste(strwrap(item, width = width), collapse = "\n"),
    character(1)
  )
}

resolve_wrap_width <- function(terms, wrap_width) {
  if (!is_auto(wrap_width)) {
    return(check_positive_integer(wrap_width, "wrap_width"))
  }

  n_terms <- length(terms)
  term_chars <- nchar(terms, type = "chars", allowNA = FALSE)
  median_chars <- stats::median(term_chars)
  max_chars <- max(term_chars)

  width <- if (n_terms <= 10) {
    64
  } else if (n_terms <= 18) {
    58
  } else if (n_terms <= 30) {
    52
  } else {
    46
  }

  if (median_chars > 44) {
    width <- width + 4
  }
  if (max_chars > 78) {
    width <- width + 6
  }

  as.integer(max(38, min(72, width)))
}

resolve_label_size <- function(n_terms, label_size, base_size) {
  if (!is_auto(label_size)) {
    return(check_positive_number(label_size, "label_size"))
  }

  label_size <- if (n_terms <= 10) {
    10.8
  } else if (n_terms <= 18) {
    9.8
  } else if (n_terms <= 30) {
    8.8
  } else {
    7.8
  }

  min(check_positive_number(base_size, "base_size") * 0.95, label_size)
}

resolve_text_sizes <- function(base_size,
                               title_size,
                               subtitle_size,
                               axis_title_size,
                               axis_text_size,
                               legend_title_size,
                               legend_text_size) {
  base_size <- check_positive_number(base_size, "base_size")
  list(
    title_size = resolve_single_text_size(title_size, base_size * 1.10, "title_size"),
    subtitle_size = resolve_single_text_size(subtitle_size, base_size * 0.86, "subtitle_size"),
    axis_title_size = resolve_single_text_size(axis_title_size, base_size * 0.92, "axis_title_size"),
    axis_text_size = resolve_single_text_size(axis_text_size, base_size * 0.82, "axis_text_size"),
    legend_title_size = resolve_single_text_size(legend_title_size, base_size * 0.88, "legend_title_size"),
    legend_text_size = resolve_single_text_size(legend_text_size, base_size * 0.80, "legend_text_size")
  )
}

resolve_single_text_size <- function(value, auto_value, name) {
  if (is_auto(value)) {
    return(unname(auto_value))
  }
  check_positive_number(value, name)
}

resolve_dot_size_range <- function(counts, dot_min_size, dot_max_size) {
  auto_range <- auto_dot_size_range(counts)
  min_is_auto <- is_auto(dot_min_size)
  max_is_auto <- is_auto(dot_max_size)

  dot_min_size <- if (min_is_auto) auto_range[1] else check_positive_number(dot_min_size, "dot_min_size")
  dot_max_size <- if (max_is_auto) auto_range[2] else check_positive_number(dot_max_size, "dot_max_size")

  if (min_is_auto && !max_is_auto) {
    dot_min_size <- min(dot_min_size, dot_max_size)
  }
  if (!min_is_auto && max_is_auto) {
    dot_max_size <- max(dot_max_size, dot_min_size)
  }
  if (dot_max_size < dot_min_size) {
    stop("`dot_max_size` must be greater than or equal to `dot_min_size`.", call. = FALSE)
  }

  c(dot_min_size, dot_max_size)
}

auto_dot_size_range <- function(counts) {
  n_terms <- length(counts)
  counts <- counts[is.finite(counts)]
  spread <- if (length(counts) > 1 && min(counts) > 0) {
    max(counts) / min(counts)
  } else {
    1
  }

  max_size <- if (n_terms <= 10) {
    8.4
  } else if (n_terms <= 24) {
    8.2
  } else if (n_terms <= 35) {
    7.4
  } else if (n_terms <= 50) {
    6.4
  } else {
    5.8
  }

  if (spread < 1.6) {
    max_size <- max_size + 0.2
  } else if (spread > 12) {
    max_size <- max_size - 0.45
  } else if (spread > 8) {
    max_size <- max_size - 0.25
  }

  min_size <- if (n_terms <= 24) {
    2.5
  } else if (n_terms <= 35) {
    2.25
  } else if (n_terms <= 50) {
    2.0
  } else {
    1.8
  }
  if (spread < 1.6) {
    min_size <- min_size + 0.1
  } else if (spread > 8) {
    min_size <- max(1.8, min_size - 0.2)
  }

  c(min_size, max(4.8, max_size))
}

count_legend_breaks <- function(counts) {
  counts <- counts[is.finite(counts)]
  if (length(counts) == 0) {
    return(NULL)
  }
  if (min(counts) == max(counts)) {
    return(unique(counts)[1])
  }

  breaks <- pretty(counts, n = 4)
  breaks <- breaks[breaks >= min(counts) & breaks <= max(counts)]
  if (all(abs(counts - round(counts)) < sqrt(.Machine$double.eps))) {
    breaks <- unique(round(breaks))
    breaks <- breaks[breaks >= min(counts) & breaks <= max(counts)]
  }
  if (length(breaks) == 0) {
    breaks <- range(counts)
  }
  breaks
}

check_column <- function(data, column, label) {
  if (!is.character(column) || length(column) != 1 || is.na(column) || column == "") {
    stop("`", label, "` must be a column name.", call. = FALSE)
  }
  if (!column %in% names(data)) {
    stop("column not found for `", label, "`: ", column, call. = FALSE)
  }
}

check_scalar_string <- function(value, name) {
  if (!is.character(value) || length(value) != 1 || is.na(value) || value == "") {
    stop("`", name, "` must be a non-empty string.", call. = FALSE)
  }
  value
}

resolve_palette_name <- function(value, name) {
  value <- tolower(check_scalar_string(value, name))
  if (!value %in% names(.enrichdot_palettes)) {
    stop(
      "unknown `", name, "`: ", value,
      ". Use one of: ", paste(names(.enrichdot_palettes), collapse = ", "),
      call. = FALSE
    )
  }
  value
}

check_color_string <- function(value, name) {
  value <- check_scalar_string(value, name)
  tryCatch(
    {
      grDevices::col2rgb(value)
      value
    },
    error = function(e) {
      stop("`", name, "` must be a valid R color string.", call. = FALSE)
    }
  )
}

check_font_family <- function(value, name = "font_family") {
  if (!is.character(value) || length(value) != 1 || is.na(value)) {
    stop("`", name, "` must be a single font family string.", call. = FALSE)
  }
  value
}

is_auto <- function(value) {
  is.character(value) && length(value) == 1 && !is.na(value) && tolower(value) == "auto"
}

check_positive_number <- function(value, name) {
  if (!is.numeric(value) || length(value) != 1 || !is.finite(value) || value <= 0) {
    stop("`", name, "` must be a positive number.", call. = FALSE)
  }
  value
}

check_nonnegative_number <- function(value, name) {
  if (!is.numeric(value) || length(value) != 1 || !is.finite(value) || value < 0) {
    stop("`", name, "` must be a non-negative number.", call. = FALSE)
  }
  value
}

check_positive_integer <- function(value, name) {
  if (!is.numeric(value) || length(value) != 1 || !is.finite(value) || value <= 0 || value != floor(value)) {
    stop("`", name, "` must be a positive integer.", call. = FALSE)
  }
  as.integer(value)
}

check_scalar_logical <- function(value, name) {
  if (!is.logical(value) || length(value) != 1 || is.na(value)) {
    stop("`", name, "` must be TRUE or FALSE.", call. = FALSE)
  }
  value
}

default_save_device <- function(filename) {
  extension <- tolower(sub("^.*[.]([^.]*)$", "\\1", filename))
  if (identical(extension, filename)) {
    extension <- ""
  }
  switch(
    extension,
    png = ragg::agg_png,
    jpg = grDevices::jpeg,
    jpeg = grDevices::jpeg,
    tif = grDevices::tiff,
    tiff = grDevices::tiff,
    bmp = grDevices::bmp,
    pdf = grDevices::pdf,
    NULL
  )
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
