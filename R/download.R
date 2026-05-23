#'Downloads AgERA5 data from the Copernicus Climate Change Service - Copernicus Climate Data Store
#'
#'@description The data is downloaded from Copernicus Climate Change Service (C3S) using the
#'Copernicus Climate Data Store (CDSAPI) Python library
#'<https://github.com/ecmwf/cdsapi>
#'
#'This function  provides programmatic access to the AgERA5 dataset.
#'For more information about the data license, please visit:
#'<https://cds.climate.copernicus.eu/datasets/sis-agrometeorological-indicators?tab=overview>
#'
#'To download the data you should have a valid CDS account,
#'an CDS API key. Please follow the instructions at: <https://cds.climate.copernicus.eu/how-to-api>
#'to create a file to store your API key. You do not need to install Python or the cdsapi, Ag5Tools
#'will do it if required.

#'@name ag5_download
#'@param variable character The variable to be downloaded. See details
#'@param statistic character Only required for some variables. See details for options.
#'@param year numeric (Integer) Year to download. Should be between 1979 - 2022
#'@param month numeric Month to be requested. Use \code{month = "all"}  download
#' all the months for the requested year.
#'@param day numeric Days of the month for the requested data.
#' Use \code{day = "all"}  to download all days from requested month
#'@param time Character Only required for "2m_relative_humidity".
#'@param version Character Version 1_1 is currently the default and recommended
#'See details for available options.
#'@param path Character Target folder in an local hardrive e.g. "C:/agera5".
#' The folder should exist and the user should have write permission.
#'@param area Controls the geographic extent of the download. Three forms are accepted:
#' \itemize{
#'   \item \code{NULL} (default) — downloads the full global extent.
#'   \item A numeric vector of length 4 \code{c(north, west, south, east)} — downloads the specified bounding box.
#'   \item A numeric vector of length 2 \code{c(lon, lat)} — interpreted as a single point;
#'     a minimum bounding box of 0.1 degrees (one AgERA5 grid cell) is derived automatically.
#' }
#'
#'@details
#'# AgERA5 variables available for download:
#'\itemize{
#'\item cloud_cover
#'\item liquid_precipitation_duration_fraction
#'\item snow_thickness_lwe
#'\item solar_radiation_flux
#'\item 2m_temperature
#'\item 2m_dewpoint_temperature
#'\item precipitation_flux
#'\item solid_precipitation_duration_fraction
#'\item snow_thickness
#'\item vapour_pressure
#'\item 10m_wind_speed
#'\item 2m_relative_humidity
#'}
#'
#'
#'# Statistics for variable "2m_temperature"
#'Variable "2m_temperature" requires to indicate at least one of the following
#'options in \code{statistic}:
#'\itemize{
#'\item 24_hour_maximum
#'\item 24_hour_mean
#'\item 24_hour_minimum
#'\item day_time_maximum
#'\item day_time_mean
#'\item night_time_mean
#'\item night_time_minimum
#'}
#'
#'# Parameter "time" for Variable "2m_relative_humidity"
#'Variable "2m_relative_humidity" requires to indicate one of the following
#'options in \code{time}:
#'\itemize{
#'\item 06_00
#'\item 09_00
#'\item 12_00
#'\item 15_00
#'\item 18_00
#'}
#'
#'# Variables that require statistic
#'For the following variables, only "24_hour_mean" statistic is available, but should
#'be explicitly indicated.
#'\itemize{
#'\item cloud_cover
#'\item snow_thickness_lwe
#'\item 2m_dewpoint_temperature
#'\item snow_thickness
#'\item vapour_pressure
#'\item 10m_wind_speed

#'}
#'@return No return value, called for side effects.
#'
#'@details
#'# Note on variable and statistic naming
#'
#'This function uses the **CDS API variable names** as expected by the Copernicus
#'Climate Data Store (e.g. \code{"2m_temperature"}, \code{"24_hour_maximum"},
#'\code{"06_00"}). The files written to disk by the CDS use a different naming
#'convention, which is what \code{\link{ag5_extract}} and \code{\link{ag5_apsim}}
#'require (e.g. \code{"Temperature-Air-2m"}, \code{"Max-24h"}, \code{"06h"}).
#'The two systems reflect the upstream API and file formats respectively;
#'ag5Tools does not modify either.
#'
#'## Variable name mapping (CDS API → file / extract)
#'\tabular{ll}{
#'  \strong{ag5_download} \tab \strong{ag5_extract} \cr
#'  2m_temperature \tab Temperature-Air-2m \cr
#'  precipitation_flux \tab Precipitation-Flux \cr
#'  solar_radiation_flux \tab Solar-Radiation-Flux \cr
#'  10m_wind_speed \tab Wind-Speed-10m \cr
#'  vapour_pressure \tab Vapour-Pressure \cr
#'  2m_relative_humidity \tab Relative-Humidity-2m \cr
#'  2m_dewpoint_temperature \tab Dew-Point_Temperature-2m \cr
#'  cloud_cover \tab Cloud-Cover \cr
#'  snow_thickness \tab Snow-Thickness \cr
#'  snow_thickness_lwe \tab Snow-Thickness-LWE \cr
#'  liquid_precipitation_duration_fraction \tab Precipitation-Rain-Duration-Fraction \cr
#'  solid_precipitation_duration_fraction \tab Precipitation-Solid-Duration-Fraction \cr
#'}
#'
#'## Statistic name mapping for 2m_temperature (CDS API → file / extract)
#'\tabular{ll}{
#'  \strong{ag5_download} \tab \strong{ag5_extract} \cr
#'  24_hour_maximum \tab Max-24h \cr
#'  24_hour_mean \tab Mean-24h \cr
#'  24_hour_minimum \tab Min-24h \cr
#'  day_time_maximum \tab Max-Day-Time \cr
#'  day_time_mean \tab Mean-Day-Time \cr
#'  night_time_mean \tab Mean-Night-Time \cr
#'  night_time_minimum \tab Min-Night-Time \cr
#'}
#'
#'## Time name mapping for 2m_relative_humidity (CDS API → file / extract)
#'CDS API: \code{"06_00"}, \code{"09_00"}, \code{"12_00"}, \code{"15_00"}, \code{"18_00"}
#'
#'ag5_extract / ag5_apsim: \code{"06h"}, \code{"09h"}, \code{"12h"}, \code{"15h"}, \code{"18h"}
#'
#'@seealso \code{\link{ag5_extract}} to extract data from downloaded files,
#'\code{\link{ag5_apsim}} to prepare APSIM-formatted meteorological files.
#'
#'@examples
#'\dontrun{
#'# Download all daily 2m_temperature (night-time minimum) for 2015
#'ag5_download(variable = "2m_temperature",
#'             statistic = "night_time_minimum",
#'             day = "all",
#'             month = "all",
#'             year = 2015,
#'             path = "C:/custom_target_folder")
#'
#'# Download precipitation for a single point location (automatic bounding box)
#'ag5_download(variable = "precipitation_flux",
#'             day = "all",
#'             month = "all",
#'             year = 2015,
#'             area = c(35.73, -2.20),
#'             path = "C:/custom_target_folder")
#'             }
#'
#'@importFrom utils unzip

#'@export
ag5_download <- function(variable,
                         statistic = NULL,
                         year,
                         month,
                         day,
                         time = NULL,
                         version = "1_1",
                         path,
                         area = NULL){

  if (!is.null(area)) {
    if (length(area) == 2) {
      message("area interpreted as point c(lon, lat); using a 0.1 degree bounding box")
      area <- c(area[2] + 0.1, area[1] - 0.1, area[2] - 0.1, area[1] + 0.1)
    } else if (length(area) != 4) {
      stop("area must be NULL, a length-2 point c(lon, lat), or a length-4 bounding box c(N, W, S, E)")
    }
  }

  if(length(month) == 1 && month == "all"){
    month <- formatC(x = seq(1:12), width = 2, flag = 0)
  }

  if(is.numeric(month)){

    month <- formatC(x = month, width = 2, flag = 0)
  }


  if(length(day) == 1 && day == "all"){
    day <- formatC(x = seq(1:31), width = 2, flag = 0)
  }

  if(is.numeric(day) ){
    day <- formatC(x = day, width = 2, flag = 0)
  }

  if(length(year) > 1 | length(month) > 1){
    years <- year

    for(i in seq_along(years)){
      for(j in month){
        ag5_request(variable = variable,
                    statistic = statistic,
                    day = day,
                    month = j,
                    time = time,
                    year = years[i],
                    version = version,
                    area = area,
                    path = paste0(path,
                                  years[i]))
      }
    }
  }
  else{
    ag5_request(variable = variable,
                statistic = statistic,
                day = day,
                month = month,
                time = time,
                year = year,
                version = version,
                area = area,
                path = paste0(path,
                                 year))

  }
}


ag5_request <- function(variable,
                        statistic = NULL,
                        day,
                        month,
                        year,
                        time = NULL,
                        version = version,
                        area = area,
                        path){

  c <- cdsapi$Client()


  results <- c$retrieve('sis-agrometeorological-indicators',
                          list("variable" = variable,
                               "year" = as.integer(year),
                               "statistic" = statistic,
                               "month" = month,
                               "day" = day,
                               "time" = time,
                               "version" = version,
                               "area" = area))


  file_name_path <- paste(path,
                          "agera5_download",
                          sep = "/")


  #add zip extension
  file_name_path <- paste0(file_name_path, ".zip")

  if(!dir.exists(path)){
    dir.create(path)
  }

  results$download(file_name_path)

  print(paste("unzipping: ", file_name_path, " to: ", path))

  unzip(zipfile = file_name_path, exdir = path)

  file.remove(file_name_path)

  print("Download process completed")

}


