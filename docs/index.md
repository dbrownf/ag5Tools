<div id="main" class="col-md-9" role="main">

# ag5Tools

<div class="section level1">

<div class="section level2">

## Toolbox for downloading and extracting data from the Copernicus AgERA5 dataset

</div>

<div class="section level2">

## Description

The R package *ag5Tools* is a toolbox to download and extract data from
the “Agrometeorological indicators from 1979 to present derived from
reanalysis” dataset (AgERA5).

A description of the dataset can found
[here](https://cds.climate.copernicus.eu/datasets/sis-agrometeorological-indicators?tab=overview)

The download function provides programmatic access to the Copernicus
Climate Data Store to download AgERA5 data.

A detailed description of the ag5Tools package can be found in the
companion paper: <https://doi.org/10.1016/j.softx.2022.101267>

</div>

<div class="section level2">

## Package Documentation

<div class="section level3">

### Main Functions

-   **ag5_download()**  
    Downloads AgERA5 data from the Copernicus Climate Data Store using
    the Python `cdsapi` library.  
    **Key arguments:**
    -   `variable`: Name of the variable to download (e.g.,
        `"2m_temperature"`, `"precipitation_flux"`).  
    -   `statistic`: Required for some variables (e.g.,
        `"24_hour_maximum"`).  
    -   `year`, `month`, `day`: Time period to download.  
    -   `area`: Geographic extent — `NULL` for global, `c(N, W, S, E)`
        for a bounding box, or `c(lon, lat)` for a single point (a
        minimum bounding box is derived automatically).  
    -   `path`: Target folder for downloaded files.  
    -   See the [reference
        manual](https://agrdatasci.github.io/ag5Tools/reference/ag5_download.html)
        for all options.
-   **ag5_extract()**  
    Extracts data from downloaded AgERA5 files for specific coordinates
    and dates.  
    **Key arguments:**
    -   `coords`: Numeric vector `c(lon, lat)` or a `data.frame` with
        location and date columns.  
    -   `variable`: Variable to extract (e.g.,
        `"Temperature-Air-2m"`).  
    -   `statistic`: Required for some variables (e.g., `"Max-24h"`).  
    -   `dates`: Single date or `c(start_date, end_date)` for a time
        series.  
    -   `path`: Folder containing AgERA5 `.nc` files.  
    -   `celsius`: Convert temperature from Kelvin to Celsius
        (logical).  
    -   See the [reference
        manual](https://agrdatasci.github.io/ag5Tools/reference/ag5_extract.html)
        for all options.
-   **ag5_apsim()**  
    Extracts all AgERA5 variables required by the
    [APSIM](https://www.apsim.info/) crop model for a single location
    and date range, applies unit conversions, computes site constants
    (`tav`, `amp`), and writes a ready-to-use meteorological file.  
    **Key arguments:**
    -   `coords`: Numeric vector `c(lon, lat)`.  
    -   `start_date`, `end_date`: Date range in `"YYYY-MM-DD"` format.  
    -   `variables`: `"all"` (default), `"required"` (maxt, mint, rain,
        radn only), or a character vector of specific variable names.  
    -   `filename`: Output file path without extension. If `NULL`,
        returns an annotated `data.frame`.  
    -   `format`: `"classic"` (space-delimited `.met`) or `"apsimng"`
        (`.csv` + `_constants.txt`).  
    -   `download`: If `TRUE`, missing AgERA5 files are downloaded
        automatically before extraction.  
    -   See the [reference
        manual](https://agrdatasci.github.io/ag5Tools/reference/ag5_apsim.html)
        for all options.

</div>

<div class="section level3">

### Available Variables

`ag5_download()` uses the CDS API variable names; `ag5_extract()` and
`ag5_apsim()` use the file names written to disk by the CDS. These
differ — see the table below.

| ag5_extract / ag5_apsim               | ag5_download                           | Description                                         |
|---------------------------------------|----------------------------------------|-----------------------------------------------------|
| Cloud-Cover                           | cloud_cover                            | Daily mean cloud cover                              |
| Precipitation-Flux                    | precipitation_flux                     | Daily precipitation (mm/day)                        |
| Precipitation-Rain-Duration-Fraction  | liquid_precipitation_duration_fraction | Fraction of day with liquid precipitation           |
| Precipitation-Solid-Duration-Fraction | solid_precipitation_duration_fraction  | Fraction of day with solid precipitation            |
| Snow-Thickness                        | snow_thickness                         | Snow depth                                          |
| Snow-Thickness-LWE                    | snow_thickness_lwe                     | Snow liquid water equivalent                        |
| Solar-Radiation-Flux                  | solar_radiation_flux                   | Daily solar radiation (J/m²/day)                    |
| Temperature-Air-2m                    | 2m_temperature                         | 2 m air temperature (multiple statistics available) |
| Dew-Point_Temperature-2m              | 2m_dewpoint_temperature                | 2 m dew point temperature                           |
| Vapour-Pressure                       | vapour_pressure                        | Daily mean vapour pressure                          |
| Wind-Speed-10m                        | 10m_wind_speed                         | 10 m wind speed                                     |
| Relative-Humidity-2m                  | 2m_relative_humidity                   | 2 m relative humidity (specific times of day)       |

For full details see the [package
documentation](https://agrdatasci.github.io/ag5Tools/reference/index.html).

</div>

</div>

<div class="section level2">

## Data license

The *ag5Tools* package does not distribute data, it only provides access
to the Climate Data Store through the Python cdsapi.

For specific details about the license agreement on downloading and
using Copernicus Products, please check the license
[here](https://cds.climate.copernicus.eu/datasets/sis-agrometeorological-indicators?tab=overview)

<div class="section level3">

### Installation

The stable version of *ag5Tools* can be installed from **CRAN** using

<div id="cb1" class="sourceCode">

``` r
install.packages("ag5Tools")
```

</div>

The development version could be installed using

<div id="cb2" class="sourceCode">

``` r
devtools::install_github("agrdatasci/ag5Tools", build_vignettes = TRUE)
```

</div>

</div>

<div class="section level3">

### Downloading AgERA5 data

<div class="section level4">

#### Install Python and the CDS API

Before using the *ag5Tools* package, you need to intall Python and the
CDS API, please see the detailsin the [CDSAPI
guide](https://cds.climate.copernicus.eu/how-to-api)

</div>

<div class="section level4">

#### Get your CDS API-Key

To download AgERA5 data you should first register at the Climate Data
Store and get your API key. Please follow the instructions detailed in
the [CDSAPI guide](https://cds.climate.copernicus.eu/how-to-api)

You need to create a file to store the API key. Please follow the
instructions detailed
[here](https://cds.climate.copernicus.eu/how-to-api)

</div>

<div class="section level4">

#### Examples

</div>

<div class="section level4">

#### Downloading data

The following example downloads daily ‘2m_temperature’ data for year
2015

<div id="cb3" class="sourceCode">

``` r
ag5_download(variable = "2m_temperature",
             statistic = "night_time_minimum",
             day = "all",
             month = "all",
             year = 2015,
             path = "C:/custom_target_folder"
             )
```

</div>

</div>

<div class="section level4">

#### Extracting data

To extract maximum day temperature (“Max-Day-Time”) of
“Temperature-Air-2m”:

<div id="cb4" class="sourceCode">

``` r
ag5_extract(coords = c(35.726364, -2.197162), 
            dates = "1995-01-23", 
            variable = "Temperature-Air-2m",
            statistic = "Max-Day-Time", 
            path = "C:/agera5_data")
```

</div>

</div>

<div class="section level4">

#### Preparing APSIM meteorological files

To extract all required variables for a location and write a classic
APSIM `.met` file:

<div id="cb5" class="sourceCode">

``` r
ag5_apsim(
  coords     = c(35.73, -2.20),
  start_date = "2015-01-01",
  end_date   = "2015-12-31",
  path       = "C:/agera5_data",
  filename   = "C:/apsim/site_2015",
  format     = "classic"
)
```

</div>

To get only the required APSIM variables as a `data.frame` without
writing a file:

<div id="cb6" class="sourceCode">

``` r
met <- ag5_apsim(
  coords     = c(35.73, -2.20),
  start_date = "2015-01-01",
  end_date   = "2015-12-31",
  variables  = "required",
  path       = "C:/agera5_data"
)
```

</div>

If the AgERA5 files have not been downloaded yet, set `download = TRUE`
to fetch them automatically:

<div id="cb7" class="sourceCode">

``` r
ag5_apsim(
  coords     = c(35.73, -2.20),
  start_date = "2015-01-01",
  end_date   = "2015-12-31",
  path       = "C:/agera5_data",
  filename   = "C:/apsim/site_2015",
  download   = TRUE
)
```

</div>

</div>

</div>

</div>

<div class="section level2">

## Acknowledgements

The *ag5Tools* package relies on the functionality available from other
open source packages.

-   The Python [*cdsapi*](https://pypi.org/project/cdsapi/)

-   The R package
    [*reticulate*](https://cran.r-project.org/package=reticulate) is
    used to access the Python CDS API functions from R.

-   The R package [*terra*](https://cran.r-project.org/package=terra) is
    used to extract data from nc files.

-   The R package [*fs*](https://cran.r-project.org/package=fs) is used
    for efficiently search and list files.

</div>

<div class="section level2">

## License

Please be aware that *ag5Tools* is released under MIT license, please
find details in the [MIT license
document](https://agrdatasci.github.io/ag5Tools/LICENSE.html)

</div>

<div class="section level2">

## Citation

To cite the *ag5Tools* in scientific publications please use:

Brown, D., de Sousa, K., & van Etten, J. (2023). ag5Tools: An R package
for downloading and extracting agrometeorological data from the AgERA5
database. SoftwareX, 21, 101267.
<https://doi.org/10.1016/j.softx.2022.101267>

</div>

<div class="section level2">

## Code of Conduct

Please note that the *ag5Tools* project is released with a [Contributor
Code of
Conduct](https://agrdatasci.github.io/ag5Tools/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.

</div>

</div>

</div>
