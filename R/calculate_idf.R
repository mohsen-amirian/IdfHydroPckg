library(HydroRPackage)
library(ncdf4); library(ncdf4.helpers)
library(terra); library(data.table)
library(lubridate);library(CoSMoS)
library(sf);library(curl)

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

#' Calculate Intensity-Duration-Frequency (IDF) models
#'
#' This function calculates IDF models based on the input data.
#'
#' @param data A data.table object containing imported data.
#' @return A data.table containing IDF models.
#'
#' @examples
#' \dontrun{
#'   # Assuming `importNetCDFFiles` is correctly implemented and tested
#'   data <- importNetCDFFiles(path = "/path/to/nc/files")
#'   calculateIDF(data)
#' }
calculateIDF <- function(data) {
  # Ensure data is a data.table
  if (!data.table::is.data.table(data)) {
    writeToLog("Input 'data' must be a data.table.")
    stop("Input 'data' must be a data.table.")
  }

  # Melt the data
  melted_data <- data.table::melt(data = data, id.vars = "time", variable.name = "cell_id")

  # Split the melted data
  split_data <- split(x = melted_data, f = melted_data$cell_id)

  # Function to calculate IDF
  idf <- function(x, return_periods = c(2, 5, 10, 25, 50, 100),
                  durations = c(1, 2, 5, 10, 24, 48),
                  aggregation_function = "mean", distribution = "gev", ...) {
    aggregated_values <- lapply(
      X = durations,
      FUN = function(d) {
        out <- x[, .(time = time,
                     value = do.call(what = paste0("froll", aggregation_function),
                                     args = list(x = value,
                                                 n = d,
                                                 align = "center",
                                                 fill = 0)))]
        out
      }
    )

    quantiles <- lapply(
      X = aggregated_values,
      FUN = function(a) {
        max_values <- a[, .(max_value = max(x = value, na.rm = TRUE)),
                        by = year(x = time)]

        fitted_parameters <- tryCatch(
          {
            fitDist(data = max_values$max_value,
                    dist = distribution,
                    n.points = 10,
                    norm = "N4",
                    constrain = FALSE)
          },
          error = function(e) {
            writeToLog("Error fitting distribution. Skipping.")
            writeToLog(e)
            warning("Error fitting distribution. Skipping.")
            return(NULL)
          }
        )

        if (is.null(fitted_parameters)) {
          return(NULL)
        }

        probabilities <- 1 - 1/return_periods
        quantile_values <- qgev(p = probabilities,
                                loc = fitted_parameters$loc,
                                scale = fitted_parameters$scale,
                                shape = fitted_parameters$shape)

        names(x = quantile_values) <- return_periods
        as.list(x = quantile_values)
      }
    )

    names(x = quantiles) <- durations
    all_quantiles <- rbindlist(l = quantiles, idcol = "duration")
    idf_quantiles <- melt(data = all_quantiles, id.vars = "duration", variable.name = "return_period")

    return(idf_quantiles)
  }

  # Calculate IDF for each subset
  idf_data <- lapply(X = split_data, FUN = idf)

  # Combine the list of data.tables into one data.table
  idf_data <- rbindlist(l = idf_data, idcol = "cell_id", fill = TRUE)

  return(idf_data)
}


# Export functions
#' @export
