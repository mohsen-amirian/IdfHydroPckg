library(HydroRPackage)
library(ncdf4); library(ncdf4.helpers)
library(terra); library(data.table)
library(lubridate);library(CoSMoS)
library(sf);library(curl)


#' @describeIn hydroPck_import_nc_files
#'   @param path Character string. The path to the directory containing NetCDF files.
#'   @param ids Numeric vector. The cell IDs to extract from each NetCDF file.
test_that("hydroPck_import_nc_files imports NetCDF files correctly", {
  # Use a temporary directory for testing
  temp_dir <- tempdir()

  # Mock the nc_open and related functions
  nc_open <- function(filename) {
    # Return a mock NetCDF object
    list(lon = c(0, 1), lat = c(0, 1), pr = matrix(1:4, nrow = 2, ncol = 2), time = 1:2)
  }
  nc_close <- function(nc) {
    # Do nothing for mock
  }

  nc.get.time.series <- function(f) {
    # Return a mock time vector
    f$time
  }

  # Call the function with a mock path
  result <- hydroPck_import_nc_files(path = temp_dir)

  # Perform assertions here (e.g., check if the resulting data.table matches expectations)
  expect_true(is.data.table(result))

  # Reset the mock functions
  unloadNamespace("IdfHydroPckg")
})


#' @describeIn hydroPck_calculate_idf
#'   @param data A data.table object containing imported data.
test_that("hydroPck_calculate_idf handles missing 'cell_id' correctly", {
  # Use a temporary directory for testing
  mock_data <- data.table(
    time = as.POSIXct(c(
      "1951-01-01 00:30:00", "1951-01-01 01:30:00", "1951-01-01 02:30:00",
      "1951-01-01 03:30:00", "1951-01-01 04:30:00", "1951-01-01 05:30:00",
      "1951-01-01 06:30:00", "1951-01-01 07:30:00", "1951-01-01 08:30:00",
      "1951-01-01 09:30:00"
    )),
    V1 = c(
      7.953370e-05, 1.356624e-04, 8.818065e-05, 3.993865e-05, 6.333713e-06,
      1.922358e-06, 1.791729e-06, 2.977827e-06, 7.625491e-06, 1.240480e-05
    ),
    V2 = c(
      1.265942e-05, 4.973588e-05, 2.043422e-05, 6.256427e-06, 4.994658e-07,
      1.434900e-08, 1.305186e-08, 1.245901e-08, 5.255420e-08, 6.725526e-08
    ),
    V3 = c(
      5.099834e-05, 9.354753e-05, 4.740013e-05, 1.312094e-05, 6.003063e-07,
      2.552802e-07, 4.179981e-07, 6.063094e-07, 1.587928e-06, 2.686359e-06
    ),
    V4 = c(
      1.339599e-04, 1.659433e-04, 8.543923e-05, 1.620368e-05, 8.859595e-07,
      1.180751e-06, 1.927696e-06, 2.842233e-06, 6.416995e-06, 1.333442e-05
    )
  )

  # Remove the 'cell_id' column from the data


  # Call the function with the modified data
  result <- hydroPck_calculate_idf(mock_data)

  # Perform assertions here (e.g., check if the resulting data.table matches expectations)
  expect_true(is.data.table(result))

  # Reset the mock functions (if any)
  unloadNamespace("IdfHydroPckg")
})

# Create a valid test for the function
#' @describeIn hydroPck_plot_idf_curves
#'   @param idf_data A data.table containing IDF models.
test_that("hydroPck_plot_idf_curves plots IDF curves correctly", {
  # Use a temporary directory for testing
  mock_data <- data.table(
    time = as.POSIXct(c(
      "1951-01-01 00:30:00", "1951-01-01 01:30:00", "1951-01-01 02:30:00",
      "1951-01-01 03:30:00", "1951-01-01 04:30:00", "1951-01-01 05:30:00",
      "1951-01-01 06:30:00", "1951-01-01 07:30:00", "1951-01-01 08:30:00",
      "1951-01-01 09:30:00"
    )),
    V1 = c(
      7.953370e-05, 1.356624e-04, 8.818065e-05, 3.993865e-05, 6.333713e-06,
      1.922358e-06, 1.791729e-06, 2.977827e-06, 7.625491e-06, 1.240480e-05
    ),
    V2 = c(
      1.265942e-05, 4.973588e-05, 2.043422e-05, 6.256427e-06, 4.994658e-07,
      1.434900e-08, 1.305186e-08, 1.245901e-08, 5.255420e-08, 6.725526e-08
    ),
    V3 = c(
      5.099834e-05, 9.354753e-05, 4.740013e-05, 1.312094e-05, 6.003063e-07,
      2.552802e-07, 4.179981e-07, 6.063094e-07, 1.587928e-06, 2.686359e-06
    ),
    V4 = c(
      1.339599e-04, 1.659433e-04, 8.543923e-05, 1.620368e-05, 8.859595e-07,
      1.180751e-06, 1.927696e-06, 2.842233e-06, 6.416995e-06, 1.333442e-05
    )
)
  idf_data <- hydroPck_calculate_idf(mock_data)

  # Call the function with the test data
  result <- hydroPck_plot_idf_curves(idf_data)

  # Perform assertions here (e.g., check if the resulting ggplot object matches expectations)
  expect_true(inherits(result, "gg"))

  # Reset the mock functions (if any)
  unloadNamespace("IdfHydroPckg")
})


