<div id="main" class="col-md-9" role="main">

# Downloading AgERA5 data with ag5Tools

<div class="section level2">

## Overview

The Copernicus “Agrometeorological indicators from 1979 to present
derived from reanalysis” dataset (AgERA5) provides daily surface
meteorological data at 0.1° (\~11 km) resolution from 1979 to present.
The `ag5_download()` function gives programmatic access to this dataset
from R via the [Copernicus Climate Data Store (CDS)
API](https://cds.climate.copernicus.eu/datasets/sis-agrometeorological-indicators?tab=overview).

Each downloaded file covers one day and one variable, stored as a NetCDF
(`.nc`) file. Across a full year that means 365 (or 366) files per
variable, one per day.

</div>

<div class="section level2">

## Setup

<div class="section level3">

### 1. Register with the CDS

Create a free account at <https://cds.climate.copernicus.eu>.

</div>

<div class="section level3">

### 2. Get your API key

After logging in, your API key is shown on your profile page. Follow the
instructions at the [CDS API
Guide](https://cds.climate.copernicus.eu/how-to-api) to create a
`.cdsapirc` configuration file in your home directory containing your
key.

</div>

<div class="section level3">

### 3. Python and cdsapi

`ag5Tools` calls the CDS via the Python `cdsapi` library using the
`reticulate` package. If Python or `cdsapi` are not installed,
`ag5_download()` will install them automatically on first use.

</div>

</div>

<div class="section level2">

## Available variables

`ag5_download()` uses the **CDS API variable names** (snake_case). These
differ from the file names written to disk, which are used by
`ag5_extract()`. See `vignette("extracing_data")` for the mapping
between the two naming systems.

| Variable (CDS API name)                  | Description                                   |
|------------------------------------------|-----------------------------------------------|
| `2m_temperature`                         | 2 m air temperature (multiple statistics)     |
| `2m_dewpoint_temperature`                | 2 m dew point temperature                     |
| `2m_relative_humidity`                   | 2 m relative humidity (specific times of day) |
| `precipitation_flux`                     | Daily precipitation (mm/day)                  |
| `liquid_precipitation_duration_fraction` | Fraction of day with liquid precipitation     |
| `solid_precipitation_duration_fraction`  | Fraction of day with solid precipitation      |
| `solar_radiation_flux`                   | Daily solar radiation (J/m²/day)              |
| `vapour_pressure`                        | Daily mean vapour pressure                    |
| `10m_wind_speed`                         | 10 m wind speed                               |
| `cloud_cover`                            | Daily mean cloud cover                        |
| `snow_thickness`                         | Snow depth                                    |
| `snow_thickness_lwe`                     | Snow liquid water equivalent                  |

</div>

<div class="section level2">

## Statistics

Some variables are available with multiple daily statistics. Provide the
statistic name in the `statistic` argument.

**`2m_temperature`** — must specify one of:

| Statistic            | Description               |
|----------------------|---------------------------|
| `24_hour_maximum`    | Maximum over 24 hours     |
| `24_hour_mean`       | Mean over 24 hours        |
| `24_hour_minimum`    | Minimum over 24 hours     |
| `day_time_maximum`   | Maximum during daytime    |
| `day_time_mean`      | Mean during daytime       |
| `night_time_mean`    | Mean during night-time    |
| `night_time_minimum` | Minimum during night-time |

**`10m_wind_speed`**, **`vapour_pressure`**, **`cloud_cover`**,
**`2m_dewpoint_temperature`** — only `24_hour_mean` is available. The
`statistic` argument must be provided.

**`precipitation_flux`**, **`solar_radiation_flux`**,
**`snow_thickness`**, **`snow_thickness_lwe`**,
**`liquid_precipitation_duration_fraction`**,
**`solid_precipitation_duration_fraction`** — no `statistic` argument
needed.

**`2m_relative_humidity`** — no `statistic`, but requires a `time`
argument: `"06_00"`, `"09_00"`, `"12_00"`, `"15_00"`, or `"18_00"`.

</div>

<div class="section level2">

## Downloading data

<div class="section level3">

### A single day

<div id="cb1" class="sourceCode">

``` r
library(ag5Tools)

ag5_download(
  variable  = "2m_temperature",
  statistic = "24_hour_maximum",
  year      = 2015,
  month     = 6,
  day       = 15,
  path      = "C:/agera5_data"
)
```

</div>

</div>

<div class="section level3">

### All days in a month

Set `day = "all"` to download every day of the specified month.

<div id="cb2" class="sourceCode">

``` r
ag5_download(
  variable  = "precipitation_flux",
  year      = 2015,
  month     = 6,
  day       = "all",
  path      = "C:/agera5_data"
)
```

</div>

</div>

<div class="section level3">

### An entire year

Set both `month = "all"` and `day = "all"` to download a full year.

<div id="cb3" class="sourceCode">

``` r
ag5_download(
  variable  = "solar_radiation_flux",
  year      = 2020,
  month     = "all",
  day       = "all",
  path      = "C:/agera5_data"
)
```

</div>

</div>

<div class="section level3">

### Relative humidity (requires `time`)

<div id="cb4" class="sourceCode">

``` r
ag5_download(
  variable = "2m_relative_humidity",
  time     = "09_00",
  year     = 2015,
  month    = "all",
  day      = "all",
  path     = "C:/agera5_data"
)
```

</div>

</div>

</div>

<div class="section level2">

## Spatial subsetting with `area`

By default `ag5_download()` downloads the full global extent. Use the
`area` argument to restrict the download to a region of interest — this
substantially reduces file size and download time.

<div class="section level3">

### Bounding box

Provide a numeric vector `c(north, west, south, east)` in decimal
degrees.

<div id="cb5" class="sourceCode">

``` r
# East Africa bounding box
ag5_download(
  variable  = "2m_temperature",
  statistic = "24_hour_maximum",
  year      = 2015,
  month     = "all",
  day       = "all",
  area      = c(5, 28, -12, 42),
  path      = "C:/agera5_data"
)
```

</div>

</div>

<div class="section level3">

### Single point

Provide `c(lon, lat)`. A minimum 0.1° bounding box (one AgERA5 grid
cell) is derived automatically.

<div id="cb6" class="sourceCode">

``` r
ag5_download(
  variable  = "2m_temperature",
  statistic = "24_hour_maximum",
  year      = 2015,
  month     = "all",
  day       = "all",
  area      = c(36.68, -3.37),   # lon, lat — Arusha, Tanzania
  path      = "C:/agera5_data"
)
```

</div>

</div>

</div>

<div class="section level2">

## File organisation on disk

Downloaded files follow the naming convention used by the CDS and are
organised into sub-folders by variable and statistic automatically. For
example, daily maximum temperature files for 2015 will appear under a
path such as:

    C:/agera5_data/
      Temperature-Air-2m/
        Max-24h/
          AgERA5_Temperature-Air-2m_Max-24h_20150101.nc
          AgERA5_Temperature-Air-2m_Max-24h_20150102.nc
          ...

`ag5_extract()` searches the folder tree recursively, so you only need
to provide the root `path` when extracting.

</div>

</div>
