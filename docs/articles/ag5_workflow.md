<div id="main" class="col-md-9" role="main">

# End-to-end workflow: from CDS to crop model

<div class="section level2">

## Overview

This article walks through the complete `ag5Tools` workflow:

1.  **Download** AgERA5 `.nc` files from the Copernicus Climate Data
    Store.
2.  **Extract** time series of specific variables for field trial
    locations.
3.  **Prepare** APSIM meteorological files for crop simulation.

The example uses the `arusha_df` dataset bundled with the package — 100
synthetic field trial plots in the Arusha region, Tanzania, each with
planting and harvest dates.

<div id="cb1" class="sourceCode">

``` r
library(ag5Tools)

data("arusha_df", package = "ag5Tools")
head(arusha_df)
#>        lon       lat start_date   end_date
#> 1 35.72636 -2.197162 1991-04-22 1991-08-20
#> 2 36.10249 -2.850983 1990-01-24 1990-05-24
#> 3 35.46292 -3.602582 1991-03-06 1991-07-04
#> 4 36.29166 -3.855945 1990-10-10 1991-02-07
#> 5 35.45254 -3.616361 1990-01-22 1990-05-22
#> 6 35.40131 -3.216106 1990-10-19 1991-02-16
```

</div>

The four columns are: `lon`, `lat` (decimal degrees, WGS84),
`start_date`, `end_date` (YYYY-MM-DD character strings). These match the
default argument names in `ag5_extract()`.

------------------------------------------------------------------------

</div>

<div class="section level2">

## Step 1: Download AgERA5 data

Before extracting, the corresponding AgERA5 files must be on disk.
Downloads are organised by variable and year; downloading a full year of
daily global data for one variable takes a few minutes depending on
connection speed.

The `area` argument limits the download to the bounding box of interest.
Here we use a rough bounding box covering the Arusha region.

<div id="cb2" class="sourceCode">

``` r
# Date range covered by arusha_df
range(as.Date(arusha_df$start_date))
range(as.Date(arusha_df$end_date))

# Download precipitation for the relevant period
ag5_download(
  variable = "precipitation_flux",
  year     = 2015,
  month    = "all",
  day      = "all",
  area     = c(-2, 35, -4, 38),   # c(north, west, south, east)
  path     = "C:/agera5_data"
)

# Download daily maximum temperature
ag5_download(
  variable  = "2m_temperature",
  statistic = "24_hour_maximum",
  year      = 2015,
  month     = "all",
  day       = "all",
  area      = c(-2, 35, -4, 38),
  path      = "C:/agera5_data"
)

# Download solar radiation
ag5_download(
  variable = "solar_radiation_flux",
  year     = 2015,
  month    = "all",
  day      = "all",
  area     = c(-2, 35, -4, 38),
  path     = "C:/agera5_data"
)
```

</div>

------------------------------------------------------------------------

</div>

<div class="section level2">

## Step 2: Extract data for field trial locations

`ag5_extract()` accepts a `data.frame` as `coords`. Each row defines a
location and date range; the function returns a list of named numeric
vectors — one per row.

<div class="section level3">

### Precipitation time series

<div id="cb3" class="sourceCode">

``` r
rainfall <- ag5_extract(
  coords   = arusha_df,
  variable = "Precipitation-Flux",
  path     = "C:/agera5_data"
)

# Each element is a named numeric vector covering that plot's date range
length(rainfall)      # 100
length(rainfall[[1]]) # number of days between start_date and end_date for plot 1
head(rainfall[[1]])
```

</div>

</div>

<div class="section level3">

### Maximum temperature time series

<div id="cb4" class="sourceCode">

``` r
maxt <- ag5_extract(
  coords    = arusha_df,
  variable  = "Temperature-Air-2m",
  statistic = "Max-24h",
  celsius   = TRUE,
  path      = "C:/agera5_data"
)
```

</div>

</div>

<div class="section level3">

### Single-point, single-date extraction

For a quick check, `coords` can be a numeric vector and `dates` a single
date string.

<div id="cb5" class="sourceCode">

``` r
ag5_extract(
  coords    = c(lon = 36.68, lat = -3.37),
  dates     = "2015-06-15",
  variable  = "Temperature-Air-2m",
  statistic = "Max-24h",
  celsius   = TRUE,
  path      = "C:/agera5_data"
)
```

</div>

</div>

<div class="section level3">

### Column name flexibility

If your `data.frame` uses different column names, pass them explicitly.

<div id="cb6" class="sourceCode">

``` r
my_trials <- data.frame(
  x         = arusha_df$lon,
  y         = arusha_df$lat,
  planting  = arusha_df$start_date,
  harvest   = arusha_df$end_date
)

rain2 <- ag5_extract(
  coords     = my_trials,
  lon        = "x",
  lat        = "y",
  start_date = "planting",
  end_date   = "harvest",
  variable   = "Precipitation-Flux",
  path       = "C:/agera5_data"
)
```

</div>

</div>

<div class="section level3">

### Parallel extraction for large datasets

For large `data.frame` inputs, enable parallel processing to speed
things up.

<div id="cb7" class="sourceCode">

``` r
rainfall_par <- ag5_extract(
  coords   = arusha_df,
  variable = "Precipitation-Flux",
  path     = "C:/agera5_data",
  parallel = TRUE,
  ncores   = 4
)
```

</div>

------------------------------------------------------------------------

</div>

</div>

<div class="section level2">

## Step 3: Summarise extracted data

Once extracted, the list of time series can be summarised into
trial-level statistics for analysis or modelling.

<div id="cb8" class="sourceCode">

``` r
# Total rainfall over each trial's growing season
total_rain <- sapply(rainfall, sum, na.rm = TRUE)
summary(total_rain)

# Days with rainfall > 1 mm
rainy_days <- sapply(rainfall, function(x) sum(x > 1, na.rm = TRUE))
summary(rainy_days)
```

</div>

------------------------------------------------------------------------

</div>

<div class="section level2">

## Step 4: Prepare APSIM meteorological files

For crop simulation with APSIM, use `ag5_apsim()`. It extracts all
required variables for a single location, applies unit conversions,
computes site constants, and writes a `.met` file in one call.

<div class="section level3">

### Classic APSIM .met file

<div id="cb9" class="sourceCode">

``` r
ag5_apsim(
  coords     = c(36.68, -3.37),
  start_date = "2010-01-01",
  end_date   = "2020-12-31",
  path       = "C:/agera5_data",
  filename   = "C:/apsim/arusha",
  format     = "classic"
)
```

</div>

</div>

<div class="section level3">

### APSIM Next Generation output

<div id="cb10" class="sourceCode">

``` r
ag5_apsim(
  coords     = c(36.68, -3.37),
  start_date = "2010-01-01",
  end_date   = "2020-12-31",
  path       = "C:/agera5_data",
  filename   = "C:/apsim/arusha",
  format     = "apsimng"
)
```

</div>

</div>

<div class="section level3">

### Download missing files on the fly

If AgERA5 files are missing for any date in the requested range,
`download = TRUE` fetches them automatically before extracting.

<div id="cb11" class="sourceCode">

``` r
ag5_apsim(
  coords     = c(36.68, -3.37),
  start_date = "2015-01-01",
  end_date   = "2015-12-31",
  path       = "C:/agera5_data",
  filename   = "C:/apsim/arusha_2015",
  download   = TRUE
)
```

</div>

</div>

<div class="section level3">

### Inspect site constants without writing a file

Leave `filename = NULL` to get the `data.frame` back with `tav` and
`amp` as attributes.

<div id="cb12" class="sourceCode">

``` r
met <- ag5_apsim(
  coords     = c(36.68, -3.37),
  start_date = "2015-01-01",
  end_date   = "2015-12-31",
  variables  = "required",
  path       = "C:/agera5_data"
)
#> Site constants:
#>   latitude  = -3.37 (degrees)
#>   longitude = 36.68 (degrees)
#>   tav = 20.34 (oC)
#>   amp = 1.72 (oC)

attr(met, "tav")
attr(met, "amp")
```

</div>

------------------------------------------------------------------------

</div>

</div>

<div class="section level2">

## Note on variable naming

`ag5_download()` uses **CDS API variable names** (snake_case:
`"2m_temperature"`, `"24_hour_maximum"`, `"06_00"`). `ag5_extract()`
uses the **file names written to disk by the CDS** (Title-Case-hyphen:
`"Temperature-Air-2m"`, `"Max-24h"`, `"06h"`). These are two different
naming systems reflecting the upstream API and file formats — they are
not errors.

`ag5_apsim()` handles this translation internally; you do not need to
manage the naming difference when using it.

</div>

<div class="section level2">

## See also

-   `vignette("ag5Tools")` — reference guide for `ag5_download()`
-   `vignette("extracing_data")` — detailed `ag5_extract()` usage
-   `vignette("ag5_apsim")` — full APSIM file format guide

</div>

</div>
