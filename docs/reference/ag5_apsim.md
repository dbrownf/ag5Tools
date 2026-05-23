<div id="main" class="col-md-9" role="main">

# Extract AgERA5 data formatted for APSIM

<div class="ref-description section level2">

Extracts all AgERA5 meteorological variables required by the APSIM crop
model for a single location and date range, applies the necessary unit
conversions, computes the site constants `tav` and `amp`, and optionally
writes the result to a classic APSIM `.met` file or an APSIM Next
Generation `.csv` file.

</div>

<div class="section level2">

## Usage

<div class="sourceCode">

``` r
ag5_apsim(
  coords,
  start_date,
  end_date,
  path,
  variables = "all",
  filename = NULL,
  format = c("classic", "apsimng"),
  download = FALSE,
  rh_time = "09h"
)
```

</div>

</div>

<div class="section level2">

## Arguments

-   coords:

    Numeric vector of length 2: `c(lon, lat)`.

-   start_date:

    Character. Start date in `"YYYY-MM-DD"` format.

-   end_date:

    Character. End date in `"YYYY-MM-DD"` format.

-   path:

    Character. Path to the folder containing the downloaded AgERA5 `.nc`
    files.

-   variables:

    Controls which variables are extracted. Three forms are accepted:

    -   `"all"` (default) — all supported variables: `maxt`, `mint`,
        `rain`, `radn`, `wind`, `vp`, `rh`.

    -   `"required"` — only the four variables required by APSIM:
        `maxt`, `mint`, `rain`, `radn`.

    -   A character vector of specific variable names drawn from the set
        above, e.g. `c("maxt", "mint", "rain", "radn", "wind")`.

-   filename:

    Character or `NULL`. Output file path without extension. If `NULL`
    (default) the function returns an annotated `data.frame` and prints
    the site constants to the console. If provided, the file is written
    and the `data.frame` is returned invisibly.

-   format:

    Character. Output format: `"classic"` (default) writes a
    space-delimited APSIM `.met` file; `"apsimng"` writes a `.csv` data
    file and a companion `_constants.txt` file for APSIM Next
    Generation.

-   download:

    Logical. If `TRUE`, checks which required AgERA5 files are missing
    from `path` and downloads them via `ag5_download()` before
    extracting. The bounding box is derived automatically from `coords`.
    Default is `FALSE`.

-   rh_time:

    Character. Time of day for relative humidity extraction. One of
    `"06h"`, `"09h"` (default), `"12h"`, `"15h"`, `"18h"`. Only used
    when `rh` is among the requested variables.

</div>

<div class="section level2">

## Value

A `data.frame` with columns `year`, `day`, and one column per requested
variable. When `filename = NULL` the data.frame carries `tav`, `amp`,
`latitude`, and `longitude` as attributes and is returned visibly. When
`filename` is provided the data.frame is returned invisibly.

</div>

<div class="section level2">

## APSIM variable mapping

|                  |                      |               |                            |
|------------------|----------------------|---------------|----------------------------|
| **APSIM column** | **AgERA5 variable**  | **Statistic** | **Unit conversion**        |
| maxt             | Temperature-Air-2m   | Max-24h       | K to °C                    |
| mint             | Temperature-Air-2m   | Min-24h       | K to °C                    |
| rain             | Precipitation-Flux   | —             | none (mm/day)              |
| radn             | Solar-Radiation-Flux | —             | J/m²/day ÷ 1e6 → MJ/m²/day |
| wind             | Wind-Speed-10m       | Mean          | none (m/s)                 |
| vp               | Vapour-Pressure      | Mean          | none (hPa)                 |
| rh               | Relative-Humidity-2m | —             | none (%)                   |

</div>

<div class="section level2">

## Site constants

`tav` (annual average temperature) and `amp` (half the range between the
warmest and coldest monthly mean temperatures) are computed from the
extracted data and written to the file header. When `filename = NULL`
they are printed to the console and attached as attributes to the
returned `data.frame`.

</div>

<div class="section level2">

## See also

<div class="dont-index">

`ag5_download` to download AgERA5 files from the CDS, `ag5_extract` to
extract individual variables.

</div>

</div>

<div class="section level2">

## Examples

<div class="sourceCode">

``` r
if (FALSE) { # \dontrun{
# Return a data.frame (no file written)
met <- ag5_apsim(
  coords     = c(36.68, -3.37),
  start_date = "2015-01-01",
  end_date   = "2015-12-31",
  variables  = "required",
  path       = "C:/agera5/"
)

# Write a classic APSIM .met file with all variables
ag5_apsim(
  coords     = c(36.68, -3.37),
  start_date = "2015-01-01",
  end_date   = "2015-12-31",
  path       = "C:/agera5/",
  filename   = "C:/apsim/arusha",
  format     = "classic"
)

# Download missing files then write APSIM NG output
ag5_apsim(
  coords     = c(36.68, -3.37),
  start_date = "2015-01-01",
  end_date   = "2015-12-31",
  path       = "C:/agera5/",
  filename   = "C:/apsim/arusha",
  format     = "apsimng",
  download   = TRUE
)
} # }
```

</div>

</div>

</div>
