# ag5Tools 0.0.4

## New functions

- `ag5_apsim()`: extracts AgERA5 data for a location and date range and formats it for use in APSIM. Supports classic `.met` and APSIM Next Generation `.csv` output, variable selection (`"all"`, `"required"`, or a custom vector), optional auto-download of missing files, and returns an annotated `data.frame` when no filename is provided.

## Enhancements

- `ag5_download()`: the `area` parameter now accepts a length-2 vector `c(lon, lat)` in addition to a length-4 bounding box. A minimum 0.1-degree bounding box is derived automatically from the point coordinates.

# ag5Tools 0.0.3
- Add "area" parameter to ag5_download
- Fix problem with variable names and statistics

# ag5Tools 0.0.2

## Major changes

-   Add version parameter to function *ag5_download*, now required by AgERA5 database.

## Enhancements

-   Use parallelization to function *ag5_extract* to speed up files search

## Bug fixes

Correct parameter in help of function *ag5_extract* from 24_hour_minimum to Min-24h


# ag5Tools 0.0.1

-   First version on CRAN
