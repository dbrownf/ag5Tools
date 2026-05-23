#' Extract AgERA5 data formatted for APSIM
#'
#' @description Extracts all AgERA5 meteorological variables required by the APSIM crop model
#' for a single location and date range, applies the necessary unit conversions, computes the
#' site constants \code{tav} and \code{amp}, and optionally writes the result to a classic
#' APSIM \code{.met} file or an APSIM Next Generation \code{.csv} file.
#'
#' @param coords Numeric vector of length 2: \code{c(lon, lat)}.
#' @param start_date Character. Start date in \code{"YYYY-MM-DD"} format.
#' @param end_date Character. End date in \code{"YYYY-MM-DD"} format.
#' @param path Character. Path to the folder containing the downloaded AgERA5 \code{.nc} files.
#' @param variables Controls which variables are extracted. Three forms are accepted:
#' \itemize{
#'   \item \code{"all"} (default) — all supported variables: \code{maxt}, \code{mint},
#'     \code{rain}, \code{radn}, \code{wind}, \code{vp}, \code{rh}.
#'   \item \code{"required"} — only the four variables required by APSIM: \code{maxt},
#'     \code{mint}, \code{rain}, \code{radn}.
#'   \item A character vector of specific variable names drawn from the set above,
#'     e.g. \code{c("maxt", "mint", "rain", "radn", "wind")}.
#' }
#' @param filename Character or \code{NULL}. Output file path without extension. If \code{NULL}
#' (default) the function returns an annotated \code{data.frame} and prints the site constants
#' to the console. If provided, the file is written and the \code{data.frame} is returned
#' invisibly.
#' @param format Character. Output format: \code{"classic"} (default) writes a space-delimited
#' APSIM \code{.met} file; \code{"apsimng"} writes a \code{.csv} data file and a companion
#' \code{_constants.txt} file for APSIM Next Generation.
#' @param download Logical. If \code{TRUE}, checks which required AgERA5 files are missing from
#' \code{path} and downloads them via \code{ag5_download()} before extracting. The bounding box
#' is derived automatically from \code{coords}. Default is \code{FALSE}.
#' @param rh_time Character. Time of day for relative humidity extraction. One of \code{"06h"},
#' \code{"09h"} (default), \code{"12h"}, \code{"15h"}, \code{"18h"}. Only used when \code{rh}
#' is among the requested variables.
#'
#' @details
#' # APSIM variable mapping
#' \tabular{llll}{
#'   \strong{APSIM column} \tab \strong{AgERA5 variable} \tab \strong{Statistic} \tab \strong{Unit conversion} \cr
#'   maxt \tab Temperature-Air-2m \tab Max-24h \tab K to °C \cr
#'   mint \tab Temperature-Air-2m \tab Min-24h \tab K to °C \cr
#'   rain \tab Precipitation-Flux \tab — \tab none (mm/day) \cr
#'   radn \tab Solar-Radiation-Flux \tab — \tab J/m²/day ÷ 1e6 → MJ/m²/day \cr
#'   wind \tab Wind-Speed-10m \tab Mean \tab none (m/s) \cr
#'   vp   \tab Vapour-Pressure \tab Mean \tab none (hPa) \cr
#'   rh   \tab Relative-Humidity-2m \tab — \tab none (%) \cr
#' }
#'
#' # Site constants
#' \code{tav} (annual average temperature) and \code{amp} (half the range between the warmest
#' and coldest monthly mean temperatures) are computed from the extracted data and written to
#' the file header. When \code{filename = NULL} they are printed to the console and attached as
#' attributes to the returned \code{data.frame}.
#'
#' @return A \code{data.frame} with columns \code{year}, \code{day}, and one column per
#' requested variable. When \code{filename = NULL} the data.frame carries \code{tav},
#' \code{amp}, \code{latitude}, and \code{longitude} as attributes and is returned visibly.
#' When \code{filename} is provided the data.frame is returned invisibly.
#'
#' @examples
#' \dontrun{
#' # Return a data.frame (no file written)
#' met <- ag5_apsim(
#'   coords     = c(36.68, -3.37),
#'   start_date = "2015-01-01",
#'   end_date   = "2015-12-31",
#'   variables  = "required",
#'   path       = "C:/agera5/"
#' )
#'
#' # Write a classic APSIM .met file with all variables
#' ag5_apsim(
#'   coords     = c(36.68, -3.37),
#'   start_date = "2015-01-01",
#'   end_date   = "2015-12-31",
#'   path       = "C:/agera5/",
#'   filename   = "C:/apsim/arusha",
#'   format     = "classic"
#' )
#'
#' # Download missing files then write APSIM NG output
#' ag5_apsim(
#'   coords     = c(36.68, -3.37),
#'   start_date = "2015-01-01",
#'   end_date   = "2015-12-31",
#'   path       = "C:/agera5/",
#'   filename   = "C:/apsim/arusha",
#'   format     = "apsimng",
#'   download   = TRUE
#' )
#' }
#'
#' @seealso \code{\link{ag5_download}} to download AgERA5 files from the CDS,
#' \code{\link{ag5_extract}} to extract individual variables.
#'
#' @export
ag5_apsim <- function(coords,
                      start_date,
                      end_date,
                      path,
                      variables = "all",
                      filename  = NULL,
                      format    = c("classic", "apsimng"),
                      download  = FALSE,
                      rh_time   = "09h") {

  format <- match.arg(format)

  if (!is.numeric(coords) || length(coords) != 2)
    stop("coords must be a numeric vector of length 2: c(lon, lat)")

  all_vars      <- c("maxt", "mint", "rain", "radn", "wind", "vp", "rh")
  required_vars <- c("maxt", "mint", "rain", "radn")

  if (identical(variables, "all")) {
    vars <- all_vars
  } else if (identical(variables, "required")) {
    vars <- required_vars
  } else {
    invalid <- setdiff(variables, all_vars)
    if (length(invalid) > 0) {
      stop(paste0(
        "Invalid variable(s): ", paste(invalid, collapse = ", "),
        "\nValid options: ", paste(all_vars, collapse = ", ")
      ))
    }
    vars <- variables
  }

  if (!check_time(rh_time)) {
    stop("rh_time must be one of: '06h', '09h', '12h', '15h', '18h'")
  }

  # Specs keyed by APSIM variable name
  # extract: args for ag5_extract.numeric; download: args for ag5_download
  var_specs <- list(
    maxt = list(
      extract  = list(variable = "Temperature-Air-2m", statistic = "Max-24h",  time = NULL,    celsius = TRUE),
      download = list(variable = "2m_temperature",      statistic = "24_hour_maximum", time = NULL)
    ),
    mint = list(
      extract  = list(variable = "Temperature-Air-2m", statistic = "Min-24h",  time = NULL,    celsius = TRUE),
      download = list(variable = "2m_temperature",      statistic = "24_hour_minimum", time = NULL)
    ),
    rain = list(
      extract  = list(variable = "Precipitation-Flux",   statistic = NULL,       time = NULL,    celsius = FALSE),
      download = list(variable = "precipitation_flux",    statistic = NULL,       time = NULL)
    ),
    radn = list(
      extract  = list(variable = "Solar-Radiation-Flux", statistic = NULL,       time = NULL,    celsius = FALSE),
      download = list(variable = "solar_radiation_flux",  statistic = NULL,       time = NULL)
    ),
    wind = list(
      extract  = list(variable = "Wind-Speed-10m",  statistic = "Mean",      time = NULL,    celsius = FALSE),
      download = list(variable = "10m_wind_speed",   statistic = "24_hour_mean",    time = NULL)
    ),
    vp = list(
      extract  = list(variable = "Vapour-Pressure", statistic = "Mean",      time = NULL,    celsius = FALSE),
      download = list(variable = "vapour_pressure",  statistic = "24_hour_mean",    time = NULL)
    ),
    rh = list(
      extract  = list(variable = "Relative-Humidity-2m", statistic = NULL, time = rh_time, celsius = FALSE),
      download = list(variable = "2m_relative_humidity",  statistic = NULL,
                      time = gsub("h", "_00", rh_time))
    )
  )

  date_seq  <- seq(as.Date(start_date), as.Date(end_date), by = "day")
  year_vec  <- as.integer(format(date_seq, "%Y"))
  day_vec   <- as.integer(format(date_seq, "%j"))
  month_vec <- as.integer(format(date_seq, "%m"))

  # ── Optional download of missing files ────────────────────────────────────
  if (isTRUE(download)) {
    for (v in vars) {
      ex <- var_specs[[v]]$extract
      dl <- var_specs[[v]]$download

      missing_dates <- date_seq[vapply(date_seq, function(d) {
        tryCatch({
          get_file_path(d, ex$variable, ex$statistic, ex$time, path)
          FALSE
        }, error = function(e) TRUE)
      }, logical(1))]

      if (length(missing_dates) == 0) next

      md_year <- as.integer(format(missing_dates, "%Y"))
      md_month <- as.integer(format(missing_dates, "%m"))
      missing_ym <- unique(data.frame(year = md_year, month = md_month))

      for (i in seq_len(nrow(missing_ym))) {
        ym_days <- missing_dates[
          md_year == missing_ym$year[i] & md_month == missing_ym$month[i]
        ]
        ag5_download(
          variable  = dl$variable,
          statistic = dl$statistic,
          year      = missing_ym$year[i],
          month     = missing_ym$month[i],
          day       = as.integer(format(ym_days, "%d")),
          time      = dl$time,
          path      = path,
          area      = coords
        )
      }
    }
  }

  # ── Extract and convert ───────────────────────────────────────────────────
  extracted <- lapply(vars, function(v) {
    ex     <- var_specs[[v]]$extract
    result <- ag5_extract.numeric(
      coords    = coords,
      dates     = c(start_date, end_date),
      variable  = ex$variable,
      statistic = ex$statistic,
      time      = ex$time,
      celsius   = ex$celsius,
      path      = path
    )
    as.numeric(result)
  })
  names(extracted) <- vars

  if ("radn" %in% vars) extracted[["radn"]] <- extracted[["radn"]] / 1e6

  # ── Assemble data.frame in APSIM column order ─────────────────────────────
  col_order <- c("maxt", "mint", "rain", "radn", "wind", "vp", "rh")
  met_df <- data.frame(year = year_vec, day = day_vec)
  for (v in col_order[col_order %in% vars]) {
    met_df[[v]] <- extracted[[v]]
  }

  # ── Site constants ────────────────────────────────────────────────────────
  mean_temp     <- (met_df$maxt + met_df$mint) / 2
  tav           <- round(mean(mean_temp, na.rm = TRUE), 2)
  monthly_means <- tapply(mean_temp, month_vec, mean, na.rm = TRUE)
  amp           <- round((max(monthly_means) - min(monthly_means)) / 2, 2)
  lon           <- coords[1]
  lat           <- coords[2]

  # ── Output ────────────────────────────────────────────────────────────────
  if (!is.null(filename)) {
    if (format == "classic") {
      write_met_classic(met_df, filename, lat, lon, tav, amp)
    } else {
      write_met_apsimng(met_df, filename, lat, lon, tav, amp)
    }
    invisible(met_df)
  } else {
    message(sprintf(
      "Site constants:\n  latitude  = %s (degrees)\n  longitude = %s (degrees)\n  tav = %s (oC)\n  amp = %s (oC)",
      lat, lon, tav, amp
    ))
    attr(met_df, "latitude")  <- lat
    attr(met_df, "longitude") <- lon
    attr(met_df, "tav")       <- tav
    attr(met_df, "amp")       <- amp
    met_df
  }
}


# Internal: write classic APSIM .met file
write_met_classic <- function(df, filename, lat, lon, tav, amp) {

  if (!grepl("\\.met$", filename)) filename <- paste0(filename, ".met")

  units_map <- c(
    year = "()",
    day  = "()",
    radn = "(MJ/m2)",
    maxt = "(oC)",
    mint = "(oC)",
    rain = "(mm)",
    wind = "(m/s)",
    vp   = "(hPa)",
    rh   = "(%)"
  )

  cols  <- names(df)
  units <- units_map[cols]

  cat(
    sprintf("! Generated by ag5Tools\n"),
    sprintf("latitude = %s (degrees)\n",  lat),
    sprintf("longitude = %s (degrees)\n", lon),
    sprintf("tav = %s (oC)\n",            tav),
    sprintf("amp = %s (oC)\n",            amp),
    sprintf("\n"),
    file = filename,
    sep  = ""
  )

  cat(paste(cols,  collapse = " "), "\n", file = filename, append = TRUE, sep = "")
  cat(paste(units, collapse = " "), "\n", file = filename, append = TRUE, sep = "")

  write.table(df,
              file      = filename,
              append    = TRUE,
              col.names = FALSE,
              row.names = FALSE,
              quote     = FALSE,
              sep       = " ")
}


# Internal: write APSIM Next Generation .csv + constants file
write_met_apsimng <- function(df, filename, lat, lon, tav, amp) {

  csv_file   <- paste0(filename, ".csv")
  const_file <- paste0(filename, "_constants.txt")

  write.csv(df, file = csv_file, row.names = FALSE)

  cat(
    sprintf("latitude = %s (degrees)\n",  lat),
    sprintf("longitude = %s (degrees)\n", lon),
    sprintf("tav = %s (oC)\n",            tav),
    sprintf("amp = %s (oC)\n",            amp),
    file = const_file,
    sep  = ""
  )
}
