
#' Plot IDF Curves
#'
#' This function plots IDF curves.
#'
#' @param idf_data A data.table containing IDF models.
#' @return A ggplot object displaying IDF curves.
#'
#' @examples
#' \dontrun{
#'   # Assuming `hydroPck_calculate_idf` is correctly implemented and tested
#'   idf_data <- hydroPck_calculate_idf(data)
#'   plotIDFCurves(idf_data)
#' }
plotIDFCurves <- function(idf_data) {
  # Ensure idf_data is a data.table
  if (!data.table::is.data.table(idf_data)) {
    writeToLog("Input 'data' must be a data.table.")
    stop("Input 'idf_data' must be a data.table.")
  }

  # Plot IDF curves
  ggplot2::ggplot(data = idf_data,
                  aes(x = as.numeric(x = duration),
                      y = value,
                      colour = factor(return_period))) +
    ggplot2::geom_line() +
    ggplot2::geom_point() +
    ggplot2::scale_colour_manual(name = "Return\nperiod",
                                 values = c("yellow", "blue", "red",
                                            "green", "orange", "purple")) +
    ggplot2::labs(x = "Duration (hours)",
                  y = "Intensity (mm/h)",
                  title = "IDF curve") +
    ggplot2::theme_bw() +
    ggplot2::facet_wrap(facets = ~cell_id)
}

# Export functions
#' @export
