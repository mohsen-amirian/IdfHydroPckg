
writeToLog <- function(log_message) {
  # Get the current date and time in the specified format
  log_timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  log_message <- paste0(log_timestamp, " ", log_message)

  # Define the log file name
  log_file_path <- paste0("logs/log_", format(Sys.Date(), "%Y-%m-%d"), ".log")

  # Open the log file in append mode
  base::sink(log_file_path, append = TRUE)

  # Print the timestamp and message to the log file
  base::cat(log_message, "\n")

  # Close the log file
  base::sink()

  # Capture and write warnings to the log file
  if (length(base::warnings()) > 0) {
    warning_message <- paste0("Warning: ", paste(base::warnings(), collapse = "\n"), "\n")
    base::sink(log_file_path, append = TRUE)
    base::cat(warning_message)
    base::sink()
  }
}

#' Import NetCDF (*.nc) files
#'
#' This function imports NetCDF (*.nc) files and returns a data.table containing the imported data.
#'
#' @param path Character string. The path to the directory containing NetCDF files.
#' @param ids Numeric vector. The cell IDs to extract from each NetCDF file. Default is c(296, 263, 264, 265, 295, 297, 327, 328, 329).
#' @return A data.table containing imported data.
#'
#' @examples
#' \dontrun{
#'   importNetCDFFiles(path = "/path/to/nc/files")
#'   importNetCDFFiles(path = "/path/to/nc/files", ids = c(1, 2, 3))
#' }
importNetCDFFiles <- function(path, ids = c(305, 293, 326, 278)) {
  # List NetCDF files in the specified path
  file_paths <- base::list.files(path = path,
                           recursive = TRUE,
                           pattern = ".nc",
                           full.names = TRUE)


  extracted_data <- base::lapply(
    X = file_paths,
    FUN = function(file_path) {
      e <- tryCatch(
        {
          nc <- ncdf4::nc_open(filename = file_path)

          longitude <- ncdf4::ncvar_get(nc = nc, varid = "lon")
          latitude <- ncdf4::ncvar_get(nc = nc, varid = "lat")
          precipitation <- ncdf4::ncvar_get(nc = nc, varid = "pr")
          time_series <- ncdf4.helpers::nc.get.time.series(f = nc)

          ncdf4::nc_close(nc = nc)

          raster_data <- terra::rast(x = precipitation, ext = base::c(range(longitude), range(latitude)))

          terra::crs(x = raster_data) <- "epsg:4326"

          xy_coords <- terra::xyFromCell(object = raster_data, cell = ids)
          values <- terra::t(x = terra::extract(x = raster_data, y = xy_coords))

          imported_data <- data.table::data.table(time = time_series, values)

        },
        error = function(e) {
          warning(base::paste("Error processing file:", file_path))
          writeToLog(base::paste("Error processing file:", file_path))
          return(NULL)
        }
      )

      if (base::inherits(x = e, what = "try-error")) {
        writeToLog(e)
        return(NULL)
      } else {
        return(imported_data)
      }
    }
  )

  # Combine the list of data.tables into one data.table
  extracted_data <- data.table::rbindlist(l = extracted_data, use.names = TRUE, fill = TRUE)
  writeToLog("Successfully imported data") # Just for testing logger

  return(extracted_data)
}


# Export functions
#' @export
