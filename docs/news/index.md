<div id="main" class="col-md-9" role="main">

# Changelog

<div class="section level2">

## ag5Tools 0.0.4

<div class="section level3">

### New functions

-   `ag5_apsim()`: extracts AgERA5 data for a location and date range
    and formats it for use in APSIM. Supports classic `.met` and APSIM
    Next Generation `.csv` output, variable selection (`"all"`,
    `"required"`, or a custom vector), optional auto-download of missing
    files, and returns an annotated `data.frame` when no filename is
    provided.

</div>

<div class="section level3">

### Enhancements

-   `ag5_download()`: the `area` parameter now accepts a length-2 vector
    `c(lon, lat)` in addition to a length-4 bounding box. A minimum
    0.1-degree bounding box is derived automatically from the point
    coordinates.

</div>

</div>

<div class="section level2">

## ag5Tools 0.0.3

CRAN release: 2026-03-25

-   Add “area” parameter to ag5_download
-   Fix problem with variable names and statistics

</div>

<div class="section level2">

## ag5Tools 0.0.2

CRAN release: 2023-10-12

<div class="section level3">

### Major changes

-   Add version parameter to function *ag5_download*, now required by
    AgERA5 database.

</div>

<div class="section level3">

### Enhancements

-   Use parallelization to function *ag5_extract* to speed up files
    search

</div>

<div class="section level3">

### Bug fixes

Correct parameter in help of function *ag5_extract* from 24_hour_minimum
to Min-24h

</div>

</div>

<div class="section level2">

## ag5Tools 0.0.1

CRAN release: 2022-03-24

-   First version on CRAN

</div>

</div>
