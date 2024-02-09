
# IdfHydroPckg

**Hydrological Package for IDF (Intensity-Duration-Frequency) Analysis**

IdfHydroPckg is an R package designed for conducting Intensity-Duration-Frequency (IDF) analysis in hydrology. It provides functions for importing NetCDF files, calculating IDF models, and visualizing IDF curves.

## Data Download

You can download the required data for using this package from the following link: [Data Download Link](https://owncloud.cesnet.cz/index.php/s/HyKD3KXSOontoKX/download)).

Please ensure that you have the necessary data downloaded and saved in the appropriate directory before using the package functions.


## Installation

You can install the development version of IdfHydroPckg from GitHub using `devtools`:

```r
devtools::install_github("mohsen-amirian/IdfHydroPckg")
```
## Usage

```r
library(IdfHydroPckg)

# Example usage: Import NetCDF files
data <- importNetCDFFiles(path = "/path/to/nc/files")

# Example usage: Calculate IDF models
idf_data <- calculate_idf(data)

# Example usage: Plot IDF curves
plotIDFCurves(idf_data)
```

## Logger and Data Storage

This project includes a logger for recording important events and messages during execution. When cloning the project to your local system, data will be stored in the logs folder with a name based on the log_year_month_day structure. The logger is designed to assist in debugging and tracking the execution of functions within the package.

