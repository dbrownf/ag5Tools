<div id="main" class="col-md-9" role="main">

# AgERA5 covariates in PlackettLuce models

<div class="section level2">

## Overview

[PlackettLuce](https://cran.r-project.org/package=PlackettLuce) models
the probability of ranking outcomes and is widely used for
farmer-participatory variety trials using the
[tricot](https://tricot.bioversityinternational.org/) approach.
`pltree()` extends this by partitioning trial sites into groups with
distinct variety preferences, using environmental variables as splitting
covariates.

This article demonstrates how to:

1.  Derive location and date information from a tricot trial dataset.
2.  Extract AgERA5 growing-season weather covariates with
    `ag5_extract()`.
3.  Use those covariates in a `pltree()` model.

</div>

<div class="section level2">

## Packages

<div id="cb1" class="sourceCode">

``` r
library(ag5Tools)
library(PlackettLuce)
```

</div>

</div>

<div class="section level2">

## Trial data: `beans`

The `beans` dataset in `PlackettLuce` contains 842 tricot observations
from a bean variety trial in Nicaragua (2015–2016). Each row records
which of three randomly assigned varieties a farmer rated as best and
worst.

<div id="cb2" class="sourceCode">

``` r
library(PlackettLuce)
#> Warning: package 'PlackettLuce' was built under R version 4.5.3
data(beans)
str(beans[, c("variety_a", "variety_b", "variety_c",
              "best", "worst", "lon", "lat", "planting_date", "season")])
#> 'data.frame':    842 obs. of  9 variables:
#>  $ variety_a    : chr  "BRT 103-182" "INTA Rojo" "INTA Ferroso" "INTA Centro Sur" ...
#>  $ variety_b    : chr  "SJC 730-79" "INTA Centro Sur" "INTA Matagalpa" "INTA Rojo" ...
#>  $ variety_c    : chr  "PM2 Don Rey" "INTA Sequia" "BRT 103-182" "ALS 0532-6" ...
#>  $ best         : chr  "C" "B" "A" "B" ...
#>  $ worst        : chr  "A" "A" "C" "C" ...
#>  $ lon          : num  -85.7 -85.4 -85.4 -85.4 -85.4 ...
#>  $ lat          : num  13.1 13.3 13.3 13.3 13.3 ...
#>  $ planting_date: Date, format: "2015-12-18" "2015-12-18" ...
#>  $ season       : Factor w/ 5 levels "Po - 15","Ap - 15",..: 2 2 2 2 2 2 2 2 2 2 ...
```

</div>

The columns `lon`, `lat`, and `planting_date` give us everything needed
to pull growing-season weather from AgERA5 for each observation.

</div>

<div class="section level2">

## Step 1: Derive a date range for each observation

Bean trials in this dataset run approximately 90 days. We add an
`end_date` column from `planting_date + 90`.

<div id="cb3" class="sourceCode">

``` r
beans$end_date <- beans$planting_date + 90
range(beans$planting_date)
#> [1] "2015-09-10" "2017-01-10"
range(beans$end_date)
#> [1] "2015-12-09" "2017-04-10"
```

</div>

</div>

<div class="section level2">

## Step 2: Extract AgERA5 covariates

We extract two growing-season covariates:

-   **Total rainfall** — sum of daily `Precipitation-Flux` (mm) over the
    growing season.
-   **Mean maximum temperature** — mean of daily `Temperature-Air-2m`
    (Max-24h, °C).

The `ag5_extract()` function accepts a `data.frame` as `coords`. We need
to rename columns to match the expected default names (`lon`, `lat`,
`start_date`, `end_date`), or pass the column names explicitly.

<div id="cb4" class="sourceCode">

``` r
library(ag5Tools)

# Use explicit column names since beans uses 'planting_date' not 'start_date'
precip_list <- ag5_extract(
  coords     = beans,
  lon        = "lon",
  lat        = "lat",
  start_date = "planting_date",
  end_date   = "end_date",
  variable   = "Precipitation-Flux",
  path       = "C:/agera5_data"
)

maxt_list <- ag5_extract(
  coords     = beans,
  lon        = "lon",
  lat        = "lat",
  start_date = "planting_date",
  end_date   = "end_date",
  variable   = "Temperature-Air-2m",
  statistic  = "Max-24h",
  celsius    = TRUE,
  path       = "C:/agera5_data"
)

# Aggregate daily series to trial-level covariates
beans$total_rain <- sapply(precip_list, sum,  na.rm = TRUE)
beans$mean_maxt  <- sapply(maxt_list,  mean, na.rm = TRUE)
```

</div>

To download the AgERA5 files for Nicaragua before extracting:

<div id="cb5" class="sourceCode">

``` r
# Nicaragua bounding box: c(north, west, south, east)
ag5_download(
  variable  = "precipitation_flux",
  year      = c(2015, 2016),
  month     = "all",
  day       = "all",
  area      = c(15, -88, 11, -83),
  path      = "C:/agera5_data"
)

ag5_download(
  variable  = "2m_temperature",
  statistic = "24_hour_maximum",
  year      = c(2015, 2016),
  month     = "all",
  day       = "all",
  area      = c(15, -88, 11, -83),
  path      = "C:/agera5_data"
)
```

</div>

</div>

<div class="section level2">

## Step 3: Convert rankings to PlackettLuce format

`as.rankings()` converts the tricot best/worst choices into a complete
partial ranking matrix suitable for `PlackettLuce()` and `pltree()`.

<div id="cb6" class="sourceCode">

``` r
# Build a grouped_rankings object from the tricot best/worst format
R <- rank_tricot(data      = beans,
                 items     = c("variety_a", "variety_b", "variety_c"),
                 input     = c("best", "worst"),
                 group     = TRUE)
```

</div>

</div>

<div class="section level2">

## Step 4: Fit a PlackettLuce tree

`pltree()` uses the environmental covariates to partition the trial
sites. Terminal nodes with meaningfully different worth estimates
indicate that variety performance depends on growing conditions.

<div id="cb7" class="sourceCode">

``` r
pl_tree <- pltree(R ~ total_rain + mean_maxt,
                  data    = beans,
                  minsize = 50)

print(pl_tree)
plot(pl_tree)
```

</div>

</div>

<div class="section level2">

## Step 5: Inspect worth estimates by node

`itempar()` returns the worth (log-ability) of each variety within each
terminal node, revealing which varieties perform best under wetter or
hotter conditions.

<div id="cb8" class="sourceCode">

``` r
itempar(pl_tree)
```

</div>

</div>

<div class="section level2">

## Adding more covariates

The same workflow extends to any AgERA5 variable. Further covariates
commonly used in variety trial analyses:

| Covariate                      | AgERA5 variable        | Statistic | Aggregation         |
|--------------------------------|------------------------|-----------|---------------------|
| Growing-season solar radiation | `Solar-Radiation-Flux` | —         | sum ÷ 1e6 (MJ/m²)   |
| Heat stress days               | `Temperature-Air-2m`   | `Max-24h` | count days \> 35 °C |
| Drought stress days            | `Precipitation-Flux`   | —         | count days \< 1 mm  |
| Mean vapour pressure           | `Vapour-Pressure`      | `Mean`    | mean (hPa)          |

<div id="cb9" class="sourceCode">

``` r
radn_list <- ag5_extract(
  coords     = beans,
  lon        = "lon",
  lat        = "lat",
  start_date = "planting_date",
  end_date   = "end_date",
  variable   = "Solar-Radiation-Flux",
  path       = "C:/agera5_data"
)

beans$total_radn <- sapply(radn_list, sum, na.rm = TRUE) / 1e6  # MJ/m²

pl_tree2 <- pltree(R ~ total_rain + mean_maxt + total_radn,
                   data    = beans,
                   minsize = 50)
plot(pl_tree2)
```

</div>

</div>

<div class="section level2">

## See also

-   `vignette("extracing_data")` — detailed `ag5_extract()` usage
-   `vignette("ag5_workflow")` — complete download-to-extraction
    workflow
-   [PlackettLuce package
    documentation](https://cran.r-project.org/package=PlackettLuce)

</div>

</div>
