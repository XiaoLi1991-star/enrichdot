test_that("enrich_plot returns ggplot objects", {
  enrichment <- data.frame(
    Description = c(
      "adaptive immune response and cytokine signaling",
      "mitochondrial respiratory chain complex assembly",
      "extracellular matrix organization"
    ),
    p.adjust = c(0.0008, 0.012, 0.032),
    Count = c(18, 12, 9),
    GeneRatio = c("18/240", "12/240", "9/240"),
    stringsAsFactors = FALSE
  )

  expect_message(
    plot <- enrich_plot(enrichment),
    "enrichdot resolved parameters"
  )
  expect_s3_class(plot, "ggplot")
  expect_null(attr(plot, "enrichdot_params", exact = TRUE))
  expect_s3_class(enrich_plot(enrichment, wrap_width = "auto", label_size = "auto"), "ggplot")
  expect_s3_class(enrich_plot(enrichment, wrap_width = 45, label_size = 11), "ggplot")
  expect_s3_class(enrich_plot(enrichment, dot_min_size = 2.5, dot_max_size = 8), "ggplot")
  expect_s3_class(enrich_plot(enrichment, dot_min_size = 8, dot_max_size = "auto"), "ggplot")
  expect_s3_class(enrich_plot(enrichment, dot_min_size = "auto", dot_max_size = 4), "ggplot")
  expect_s3_class(enrich_plot(enrichment, grid = "x", grid_linewidth = 0.2, border_linewidth = 0.35), "ggplot")
  expect_s3_class(enrich_plot(enrichment, type = "bar"), "ggplot")
  expect_error(enrich_plot(enrichment, wrap_width = "wide"), "positive integer")
  expect_error(enrich_plot(enrichment, wrap_width = 42.5), "positive integer")
  expect_error(enrich_plot(enrichment, top_n = 2.5), "positive integer")
  expect_error(enrich_plot(enrichment, order_by = "Count"), "'arg' should be one of")
  expect_error(enrich_plot(enrichment, dot_min_size = 0), "positive number")
  expect_error(enrich_plot(enrichment, dot_min_size = 9, dot_max_size = 3), "greater than or equal")
  expect_error(enrich_plot(enrichment, grid = "dense"), "'arg' should be one of")
})

test_that("top_n defaults to 20 rows per group", {
  expect_identical(formals(enrich_plot)$top_n, 20)
  expect_identical(formals(inspect_enrich_plot)$top_n, 20)
})

test_that("top_n selection uses value while dotplot display order is configurable", {
  enrichment <- data.frame(
    Description = c(
      "most significant low ratio",
      "second significant high ratio",
      "not selected highest ratio"
    ),
    p.adjust = c(0.001, 0.002, 0.5),
    Count = c(8, 16, 40),
    GeneRatio = c("8/200", "40/200", "90/200"),
    stringsAsFactors = FALSE
  )

  dot <- enrich_plot(enrichment, top_n = 2)
  expect_equal(
    as.character(dot$data$.term),
    c("second significant high ratio", "most significant low ratio")
  )
  expect_false("not selected highest ratio" %in% as.character(dot$data$.term))

  value_ordered <- enrich_plot(enrichment, top_n = 2, order_by = "value")
  expect_equal(
    as.character(value_ordered$data$.term),
    c("most significant low ratio", "second significant high ratio")
  )

  bar <- enrich_plot(enrichment, top_n = 2, type = "bar")
  expect_equal(
    as.character(bar$data$.term),
    c("most significant low ratio", "second significant high ratio")
  )
})

test_that("automatic dot sizes stay readable across term counts", {
  expect_equal(auto_dot_size_range(round(seq(8, 30, length.out = 8))), c(2.5, 8.4))
  expect_equal(auto_dot_size_range(round(seq(7, 30, length.out = 12))), c(2.5, 8.2))
  expect_equal(auto_dot_size_range(round(seq(5, 20, length.out = 20))), c(2.5, 8.2))
  expect_equal(auto_dot_size_range(round(seq(5, 32, length.out = 30))), c(2.25, 7.4))
  expect_equal(auto_dot_size_range(round(seq(4, 36, length.out = 45))), c(1.8, 6.15))
  expect_equal(
    auto_dot_size_range(c(1, 2, 3, 4, 5, 7, 9, 12, 16, 21, 27, 35, 48, 62, 80, 105, 132, 160, 190, 220)),
    c(2.3, 7.75)
  )
})

test_that("count legends prefer integer breaks for integer counts", {
  expect_equal(count_legend_breaks(c(14, 15, 16, 15)), c(14, 15, 16))
  expect_equal(count_legend_breaks(c(5, 8, 11, 15, 20)), c(5, 10, 15, 20))
  expect_equal(count_legend_breaks(c(1, 2, 5, 50, 220)), c(50, 100, 150, 200))
})

test_that("enrich_plot exposes typography and color controls", {
  enrichment <- data.frame(
    Description = c(
      "adaptive immune response and cytokine signaling",
      "mitochondrial respiratory chain complex assembly",
      "extracellular matrix organization"
    ),
    p.adjust = c(0.0008, 0.012, 0.032),
    Count = c(18, 12, 9),
    GeneRatio = c("18/240", "12/240", "9/240"),
    stringsAsFactors = FALSE
  )

  plot <- enrich_plot(
    enrichment,
    title = "Pathway enrichment",
    subtitle = "Agent-friendly typography controls",
    font_family = "serif",
    title_size = 14,
    subtitle_size = 10,
    axis_title_size = 11,
    axis_text_size = 9,
    label_size = 8.5,
    legend_title_size = 8.5,
    legend_text_size = 7.5,
    panel_background_color = "#FBFCFD",
    plot_background_color = "#FFFFFF",
    grid_color = "#D0D5DD",
    border_color = "#98A2B3"
  )

  expect_equal(plot$theme$text$family, "serif")
  expect_equal(plot$theme$plot.title$size, 14)
  expect_equal(plot$theme$plot.subtitle$size, 10)
  expect_equal(plot$theme$axis.title.x$size, 11)
  expect_equal(plot$theme$axis.text.x$size, 9)
  expect_equal(plot$theme$axis.text.y$size, 8.5)
  expect_equal(plot$theme$legend.title$size, 8.5)
  expect_equal(plot$theme$legend.text$size, 7.5)
  expect_equal(plot$theme$panel.background$fill, "#FBFCFD")
  expect_equal(plot$theme$plot.background$fill, "#FFFFFF")
  expect_equal(plot$theme$panel.grid.major$colour, "#D0D5DD")
  expect_equal(plot$theme$panel.border$colour, "#98A2B3")

  expect_error(enrich_plot(enrichment, title_size = 0), "positive number")
  expect_error(enrich_plot(enrichment, font_family = NA_character_), "single font family")
  expect_error(enrich_plot(enrichment, panel_background_color = "not-a-color"), "valid R color")
  expect_error(enrich_plot(enrichment, plot_background_color = "not-a-color"), "valid R color")
  expect_error(enrich_plot(enrichment, grid_color = "not-a-color"), "valid R color")
  expect_error(enrich_plot(enrichment, border_color = "not-a-color"), "valid R color")
  expect_s3_class(theme_enrich(font_family = "serif"), "theme")
})

test_that("enrich_plot rejects invalid numeric data", {
  enrichment <- data.frame(
    Description = c("adaptive immune response", "extracellular matrix organization"),
    p.adjust = c(0.001, 0.02),
    Count = c(18, 9),
    GeneRatio = c("18/240", "9/240"),
    stringsAsFactors = FALSE
  )

  negative_value <- enrichment
  negative_value$p.adjust[1] <- -0.01
  expect_error(enrich_plot(negative_value), "p-values or FDR values")

  too_large_value <- enrichment
  too_large_value$p.adjust[1] <- 1.2
  expect_error(enrich_plot(too_large_value), "p-values or FDR values")

  negative_count <- enrichment
  negative_count$Count[1] <- -1
  expect_error(enrich_plot(negative_count), "non-negative")

  negative_ratio <- enrichment
  negative_ratio$GeneRatio[1] <- "-1/240"
  expect_error(enrich_plot(negative_ratio), "non-negative")
})

test_that("enrich_plot handles grouped input", {
  enrichment <- data.frame(
    Description = rep(c("cell cycle", "T cell activation", "lipid metabolism"), 2),
    p.adjust = c(0.001, 0.004, 0.02, 0.003, 0.008, 0.04),
    Count = c(20, 14, 7, 18, 11, 6),
    GeneRatio = c("20/200", "14/200", "7/200", "18/180", "11/180", "6/180"),
    Cluster = rep(c("Up", "Down"), each = 3),
    stringsAsFactors = FALSE
  )

  expect_s3_class(enrich_plot(enrichment, group = "Cluster", top_n = 2), "ggplot")
  expect_s3_class(enrich_plot(enrichment, group = "Cluster", top_n = 2, layout = "facet"), "ggplot")
  expect_error(enrich_plot(enrichment, layout = "compare"), "requires `group`")
})

test_that("enrich_palette defaults match enrich_plot", {
  enrichment <- data.frame(
    Description = c("adaptive immune response", "extracellular matrix organization"),
    p.adjust = c(0.001, 0.02),
    Count = c(18, 9),
    GeneRatio = c("18/240", "9/240"),
    stringsAsFactors = FALSE
  )

  expect_identical(formals(enrich_plot)$palette, .enrichdot_default_palette)
  expect_identical(formals(inspect_enrich_plot)$palette, .enrichdot_default_palette)
  expect_identical(formals(enrich_palette)$name, .enrichdot_default_palette)
  expect_equal(enrich_palette(), enrich_palette("journal"))
  expect_equal(enrich_palette("Journal")$name, "journal")
  expect_equal(names(.enrichdot_palettes), c("classic", "journal", "presentation"))
  expect_equal(
    enrich_palette("classic"),
    list(
      p_adjust = c("#D73027", "#F7F7F7", "#4575B4"),
      p_adjust_values = c(0, 0.52, 1),
      score = c("#4575B4", "#F7F7F7", "#D73027"),
      score_values = c(0, 0.48, 1),
      accent = "#D73027",
      name = "classic"
    )
  )
  expect_equal(
    enrich_palette("journal"),
    list(
      p_adjust = c("#B2182B", "#DF7F7A", "#D8E1EA", "#2166AC"),
      p_adjust_values = c(0, 0.34, 0.66, 1),
      score = c("#2166AC", "#D8E1EA", "#DF7F7A", "#B2182B"),
      score_values = c(0, 0.34, 0.66, 1),
      accent = "#B2182B",
      name = "journal"
    )
  )
  expect_equal(
    enrich_palette("presentation"),
    list(
      p_adjust = c("#D7191C", "#FDAE61", "#ABD9E9", "#2C7BB6"),
      p_adjust_values = c(0, 0.35, 0.65, 1),
      score = c("#2C7BB6", "#ABD9E9", "#FDAE61", "#D7191C"),
      score_values = c(0, 0.35, 0.65, 1),
      accent = "#D7191C",
      name = "presentation"
    )
  )
  expect_equal(attr(enrich_plot(enrichment), "enrichdot_palette"), .enrichdot_default_palette)
  expect_equal(attr(enrich_plot(enrichment, palette = "classic"), "enrichdot_palette"), "classic")
  expect_error(enrich_palette("not-a-palette"), "unknown `name`")
  expect_error(enrich_palette("aurora"), "unknown `name`")
  expect_error(enrich_palette("sunrise"), "unknown `name`")
  expect_error(enrich_palette("forest"), "unknown `name`")
  expect_error(enrich_palette("slate"), "unknown `name`")
})

test_that("legends use default colorbar styling with color above count", {
  enrichment <- data.frame(
    Description = c("adaptive immune response", "extracellular matrix organization"),
    p.adjust = c(0.001, 0.02),
    Count = c(18, 9),
    GeneRatio = c("18/240", "9/240"),
    stringsAsFactors = FALSE
  )

  for (palette in names(.enrichdot_palettes)) {
    dot_plot <- enrich_plot(enrichment, palette = palette)
    dot_color_guide <- dot_plot$scales$get_scales("colour")$guide
    dot_size_guide <- dot_plot$scales$get_scales("size")$guide

    expect_s3_class(dot_color_guide, "GuideColourbar")
    expect_equal(dot_color_guide$params$order, 1)
    expect_null(dot_color_guide$params$theme$legend.key.height)
    expect_null(dot_color_guide$params$theme$legend.key.width)

    expect_s3_class(dot_size_guide, "GuideLegend")
    expect_equal(dot_size_guide$params$order, 2)
  }

  bar_color_guide <- enrich_plot(enrichment, type = "bar")$scales$get_scales("fill")$guide
  expect_s3_class(bar_color_guide, "GuideColourbar")
  expect_equal(bar_color_guide$params$order, 1)
  expect_null(bar_color_guide$params$theme$legend.key.height)
  expect_null(bar_color_guide$params$theme$legend.key.width)
})

test_that("save_enrich can keep a fixed plot panel width", {
  enrichment <- data.frame(
    Description = c(
      "very long biological process label that would normally squeeze the plot panel",
      "another long pathway name used to test fixed plotting area"
    ),
    p.adjust = c(0.001, 0.02),
    Count = c(18, 9),
    GeneRatio = c("18/240", "9/240"),
    stringsAsFactors = FALSE
  )

  plot <- enrich_plot(enrichment, wrap_width = 80, label_size = 10)
  filename <- tempfile(fileext = ".png")
  auto_filename <- tempfile(fileext = ".png")
  exact_filename <- tempfile(fileext = ".png")

  expect_identical(save_enrich(plot, auto_filename), auto_filename)
  expect_true(file.exists(auto_filename))
  expect_gt(file.info(auto_filename)$size, 0)
  expect_identical(
    save_enrich(plot, filename, panel_width = 2, height = 4),
    filename
  )
  expect_true(file.exists(filename))
  expect_gt(file.info(filename)$size, 0)
  expect_identical(
    save_enrich(plot, exact_filename, width = 6, height = 4, panel_width = 2, auto_width = FALSE),
    exact_filename
  )
  expect_true(file.exists(exact_filename))
  expect_gt(file.info(exact_filename)$size, 0)
  expect_error(save_enrich(plot, tempfile(fileext = ".png"), panel_width = 0), "positive number")
})

test_that("png output defaults to the ragg device", {
  expect_identical(default_save_device("plot.png"), ragg::agg_png)
  expect_identical(default_save_device("plot.PNG"), ragg::agg_png)
  expect_identical(default_save_device("plot.pdf"), grDevices::pdf)
})

test_that("inspect_enrich_plot returns agent-friendly diagnostics", {
  enrichment <- data.frame(
    Description = c(
      "very long biological process label that should trigger label diagnostics",
      "cellular response to interleukin-1",
      "MAP kinase phosphatase activity"
    ),
    p.adjust = c(0.001, 0.02, 0.04),
    Count = c(80, 12, 4),
    GeneRatio = c("80/400", "12/400", "4/400"),
    stringsAsFactors = FALSE
  )

  diagnosis <- inspect_enrich_plot(enrichment)

  expect_s3_class(diagnosis, "enrichdot_inspection")
  expect_named(diagnosis, c("metrics", "suggested_params", "resolved", "notes"))
  expect_equal(diagnosis$metrics$n_terms, 3)
  expect_true(diagnosis$metrics$max_label_length > 40)
  expect_named(
    diagnosis$suggested_params$enrich_plot,
    c(
      "palette", "font_family", "title_size", "subtitle_size", "axis_title_size",
      "axis_text_size", "order_by", "wrap_width", "label_size", "legend_title_size",
      "legend_text_size", "dot_min_size", "dot_max_size",
      "panel_background_color", "plot_background_color",
      "grid", "grid_color", "grid_linewidth", "border_color", "border_linewidth"
    )
  )
  expect_named(diagnosis$suggested_params$save_enrich, c("width", "height", "panel_width"))
  expect_equal(diagnosis$suggested_params$enrich_plot$palette, "journal")
  expect_equal(diagnosis$suggested_params$enrich_plot$order_by, "ratio")
  expect_equal(diagnosis$resolved$palette, "journal")
  expect_equal(diagnosis$resolved$order_by, "ratio")
  expect_true(is.numeric(diagnosis$suggested_params$save_enrich$width))
  expect_true(is.numeric(diagnosis$suggested_params$save_enrich$height))

  manual <- inspect_enrich_plot(
    enrichment,
    palette = "Classic",
    order_by = "value",
    wrap_width = 50,
    label_size = 9,
    font_family = "serif",
    title_size = 14,
    axis_text_size = 9,
    legend_text_size = 7.5,
    panel_background_color = "#FBFCFD",
    plot_background_color = "#FFFFFF",
    dot_min_size = 2.5,
    dot_max_size = 7,
    grid = "x",
    grid_color = "#D0D5DD",
    grid_linewidth = 0.2,
    border_color = "#98A2B3",
    border_linewidth = 0.35,
    width = 7,
    height = 5,
    panel_width = 2
  )

  expect_equal(manual$suggested_params$enrich_plot$wrap_width, 50)
  expect_equal(manual$suggested_params$enrich_plot$palette, "classic")
  expect_equal(manual$suggested_params$enrich_plot$order_by, "value")
  expect_equal(manual$suggested_params$enrich_plot$label_size, 9)
  expect_equal(manual$suggested_params$enrich_plot$font_family, "serif")
  expect_equal(manual$suggested_params$enrich_plot$title_size, 14)
  expect_equal(manual$suggested_params$enrich_plot$axis_text_size, 9)
  expect_equal(manual$suggested_params$enrich_plot$legend_text_size, 7.5)
  expect_equal(manual$suggested_params$enrich_plot$panel_background_color, "#FBFCFD")
  expect_equal(manual$suggested_params$enrich_plot$plot_background_color, "#FFFFFF")
  expect_equal(manual$suggested_params$enrich_plot$dot_max_size, 7)
  expect_equal(manual$suggested_params$enrich_plot$grid, "x")
  expect_equal(manual$suggested_params$enrich_plot$grid_color, "#D0D5DD")
  expect_equal(manual$suggested_params$enrich_plot$border_color, "#98A2B3")
  expect_equal(manual$resolved$palette, "classic")
  expect_true(any(grepl("palette_override", manual$notes)))
  expect_equal(manual$suggested_params$save_enrich$panel_width, 2)
})
