<div id="main" class="col-md-9" role="main">

# Downloads AgERA5 data from the Copernicus Climate Change Service - Copernicus Climate Data Store

<div class="ref-description section level2">

The data is downloaded from Copernicus Climate Change Service (C3S)
using the Copernicus Climate Data Store (CDSAPI) Python library
<https://github.com/ecmwf/cdsapi>

This function provides programmatic access to the AgERA5 dataset. For
more information about the data license, please visit:
<https://cds.climate.copernicus.eu/datasets/sis-agrometeorological-indicators?tab=overview>

To download the data you should have a valid CDS account, an CDS API
key. Please follow the instructions at:
<https://cds.climate.copernicus.eu/how-to-api> to create a file to store
your API key. You do not need to install Python or the cdsapi, Ag5Tools
will do it if required.

</div>

<div class="section level2">

## Usage

<div class="sourceCode">

``` r
ag5_download(
  variable,
  statistic = NULL,
  year,
  month,
  day,
  time = NULL,
  version = "1_1",
  path,
  area = NULL
)
```

</div>

</div>

<div class="section level2">

## Arguments

-   variable:

    character The variable to be downloaded. See details

-   statistic:

    character Only required for some variables. See details for options.

-   year:

    numeric (Integer) Year to download. Should be between 1979 - 2022

-   month:

    numeric Month to be requested. Use `month = "all"` download all the
    months for the requested year.

-   day:

    numeric Days of the month for the requested data. Use `day = "all"`
    to download all days from requested month

-   time:

    Character Only required for "2m_relative_humidity".

-   version:

    Character Version 1_1 is currently the default and recommended See
    details for available options.

-   path:

    Character Target folder in an local hardrive e.g. "C:/agera5". The
    folder should exist and the user should have write permission.

-   area:

    Controls the geographic extent of the download. Three forms are
    accepted:

    -   `NULL` (default) — downloads the full global extent.

    -   A numeric vector of length 4 `c(north, west, south, east)` —
        downloads the specified bounding box.

    -   A numeric vector of length 2 `c(lon, lat)` — interpreted as a
        single point; a minimum bounding box of 0.1 degrees (one AgERA5
        grid cell) is derived automatically.

</div>

<div class="section level2">

## Value

No return value, called for side effects.

</div>

<div class="section level2">

## AgERA5 variables available for download:

-   cloud_cover

-   liquid_precipitation_duration_fraction

-   snow_thickness_lwe

-   solar_radiation_flux

-   2m_temperature

-   2m_dewpoint_temperature

-   precipitation_flux

-   solid_precipitation_duration_fraction

-   snow_thickness

-   vapour_pressure

-   10m_wind_speed

-   2m_relative_humidity

</div>

<div class="section level2">

## Statistics for variable "2m_temperature"

Variable "2m_temperature" requires to indicate at least one of the
following options in `statistic`:

-   24_hour_maximum

-   24_hour_mean

-   24_hour_minimum

-   day_time_maximum

-   day_time_mean

-   night_time_mean

-   night_time_minimum

</div>

<div class="section level2">

## Parameter "time" for Variable "2m_relative_humidity"

Variable "2m_relative_humidity" requires to indicate one of the
following options in `time`:

-   06_00

-   09_00

-   12_00

-   15_00

-   18_00

</div>

<div class="section level2">

## Variables that require statistic

For the following variables, only "24_hour_mean" statistic is available,
but should be explicitly indicated.

-   cloud_cover

-   snow_thickness_lwe

-   2m_dewpoint_temperature

-   snow_thickness

-   vapour_pressure

-   10m_wind_speed

</div>

<div class="section level2">

## Note on variable and statistic naming

This function uses the **CDS API variable names** as expected by the
Copernicus Climate Data Store (e.g. `"2m_temperature"`,
`"24_hour_maximum"`, `"06_00"`). The files written to disk by the CDS
use a different naming convention, which is what `ag5_extract` and
`ag5_apsim` require (e.g. `"Temperature-Air-2m"`, `"Max-24h"`, `"06h"`).
The two systems reflect the upstream API and file formats respectively;
ag5Tools does not modify either.

<div class="section">

### Variable name mapping (CDS API → file / extract)

|                                        |                                       |
|----------------------------------------|---------------------------------------|
| **ag5_download**                       | **ag5_extract**                       |
| 2m_temperature                         | Temperature-Air-2m                    |
| precipitation_flux                     | Precipitation-Flux                    |
| solar_radiation_flux                   | Solar-Radiation-Flux                  |
| 10m_wind_speed                         | Wind-Speed-10m                        |
| vapour_pressure                        | Vapour-Pressure                       |
| 2m_relative_humidity                   | Relative-Humidity-2m                  |
| 2m_dewpoint_temperature                | Dew-Point_Temperature-2m              |
| cloud_cover                            | Cloud-Cover                           |
| snow_thickness                         | Snow-Thickness                        |
| snow_thickness_lwe                     | Snow-Thickness-LWE                    |
| liquid_precipitation_duration_fraction | Precipitation-Rain-Duration-Fraction  |
| solid_precipitation_duration_fraction  | Precipitation-Solid-Duration-Fraction |

</div>

<div class="section">

### Statistic name mapping for 2m_temperature (CDS API → file / extract)

|                    |                 |
|--------------------|-----------------|
| **ag5_download**   | **ag5_extract** |
| 24_hour_maximum    | Max-24h         |
| 24_hour_mean       | Mean-24h        |
| 24_hour_minimum    | Min-24h         |
| day_time_maximum   | Max-Day-Time    |
| day_time_mean      | Mean-Day-Time   |
| night_time_mean    | Mean-Night-Time |
| night_time_minimum | Min-Night-Time  |

</div>

<div class="section">

### Time name mapping for 2m_relative_humidity (CDS API → file / extract)

CDS API: `"06_00"`, `"09_00"`, `"12_00"`, `"15_00"`, `"18_00"`

ag5_extract / ag5_apsim: `"06h"`, `"09h"`, `"12h"`, `"15h"`, `"18h"`

</div>

</div>

<div class="section level2">

## See also

<div class="dont-index">

`ag5_extract` to extract data from downloaded files, `ag5_apsim` to
prepare APSIM-formatted meteorological files.

</div>

</div>

<div class="section level2">

## Examples

<div class="sourceCode">

``` r
if (FALSE) { # \dontrun{
# Download all daily 2m_temperature (night-time minimum) for 2015
ag5_download(variable = "2m_temperature",
            statistic = "night_time_minimum",
            day = "all",
            month = "all",
            year = 2015,
            path = "C:/custom_target_folder")

# Download precipitation for a single point location (automatic bounding box)
ag5_download(variable = "precipitation_flux",
            day = "all",
            month = "all",
            year = 2015,
            area = c(35.73, -2.20),
            path = "C:/custom_target_folder")
            } # }
```

</div>

</div>

</div>
