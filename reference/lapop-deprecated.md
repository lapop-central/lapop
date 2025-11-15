# Deprecated functions in package lapop.

The functions listed below are deprecated and will be defunct in the
near future. When possible, alternative functions with similar
functionality are also mentioned. Help pages for deprecated functions
are available at `help("<function>-deprecated")`.

## Usage

``` r
lapop_db(
  data,
  ymin = 0,
  ymax = 100,
  lang = "en",
  main_title = "",
  source_info = "",
  subtitle = "",
  sort = "wave2",
  order = "hi-lo",
  color_scheme = c("#482677", "#3CBC70"),
  subtitle_h_just = 40,
  subtitle_v_just = -18
)

lapop_tsmulti(
  data,
  varlabel = data$varlabel,
  wave_var = as.character(data$wave),
  outcome_var = data$prop,
  label_var = data$proplabel,
  point_var = data$prop,
  ymin = 0,
  ymax = 100,
  main_title = "",
  source_info = "",
  subtitle = "",
  lang = "en",
  legend_h_just = 40,
  legend_v_just = -20,
  subtitle_h_just = 0,
  color_scheme = c("#7030A0", "#3CBC70", "#1F968B", "#95D840", "")
)

lapop_demog(
  data,
  lang = "en",
  main_title = "",
  subtitle = "",
  source_info = "",
  rev_values = FALSE,
  rev_variables = FALSE,
  subtitle_h_just = 0,
  ymin = 0,
  ymax = 100,
  x_lab_angle = 90,
  color_scheme = c("#7030A0", "#00ADA9", "#3CBC70", "#7EA03E", "#568424", "#ACB014")
)

lapop_sb(
  data,
  outcome_var = data$prop,
  prop_labels = data$proplabel,
  var_labels = data$varlabel,
  value_labels = data$vallabel,
  lang = "en",
  main_title = "",
  subtitle = "",
  source_info = "",
  rev_values = FALSE,
  rev_variables = FALSE,
  hide_small_values = TRUE,
  order_bars = FALSE,
  subtitle_h_just = 0,
  color_scheme = c("#2D708E", "#1F9689", "#00ADA9", "#21A356", "#568424", "#ACB014")
)
```

## Value

No return value, called for side effects

## `lapop_db`

For `lapop_db`, use
[`lapop_dumb`](https://lapop-central.github.io/lapop/reference/lapop_dumb.md).

## `lapop_tsmulti`

For `lapop _tsmulti`, use
[`lapop_mline`](https://lapop-central.github.io/lapop/reference/lapop_mline.md).

## `lapop_demog`

For `lapop_demog`, use
[`lapop_mover`](https://lapop-central.github.io/lapop/reference/lapop_mover.md).

## `lapop_sb`

For `lapop_sb`, use
[`lapop_stack`](https://lapop-central.github.io/lapop/reference/lapop_stack.md).
