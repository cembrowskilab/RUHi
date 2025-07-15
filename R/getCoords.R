#' Get cell coordinates, cluster id and metadata information from an mFISH object, and optionally rotate cell XY coordinates.
#' @author Margarita Kapustina
#'
#' @description Create a dataframe with cell ID, coordinates, cluster IDs and metadata information from an mFISH object for an individual slice. Use this function after clustering your mFISH object.
#'
#' @param original_mfish_obj mFISH object to extract section coordinate data from
#' @param section_id ID of section to extract coordinates and data from
#' @param rotate_coords Option to adjust the angle of your cell coordinates (TRUE, FALSE)
#' @param theta_deg Specify the degrees you wish to rotate your section by
#'
#' @return A dataframe with XY coordinates, cell id, cluster ID, and metadata (cell id, anum, etc.) for a single mFISH object section. If rotate_coords = T, the adjusted XY coordinates will be stored in your dataframe output.
#'
#' @import ggplot2
#'
#' @export

getCoords <- function(original_mfish_obj,
                      section_id,
                      rotate_coords = FALSE,
                      theta_deg = 0) {

  # Extract metaData from original_mfish_obj
  meta_data <- original_mfish_obj@metaData

  # Filter metaData for the given section_id
  filtered_meta <- meta_data[meta_data$section == section_id, ]

  # Identify the row indices in 'metaData' that match the section_id condition
  indices <- which(meta_data$section == section_id)

  # Use the indices to subset other relevant slots
  filtered_rawData <- original_mfish_obj@rawData[indices, ]
  filtered_filteredData <- original_mfish_obj@filteredData[indices, ]
  attributes_filteredData <- original_mfish_obj@attributes[indices]

  # Create a new S4 object with the filtered data
  filtered_section <- original_mfish_obj
  filtered_section@metaData <- filtered_meta
  filtered_section@rawData <- filtered_rawData
  filtered_section@filteredData <- filtered_filteredData
  filtered_section@attributes <- attributes_filteredData

  # Convert the filtered metaData to a data frame
  section_coords <- as.data.frame(filtered_section@metaData)
  section_coords$cluster <- as.factor(section_coords$cluster)

  # Rotate coordinates if requested
  if (rotate_coords) {
    if (theta_deg == 0) {
      message("Please update theta_deg argument to rotate coordinates.")
    } else {
      rotate_coords_fn <- function(coordsSection, theta_deg) {
        # Convert angle from degrees to radians
        theta_rad <- theta_deg * (pi / 180)

        # Apply rotation transformation
        newX <- coordsSection$X * cos(theta_rad) + coordsSection$Y * sin(theta_rad)
        newY <- -coordsSection$X * sin(theta_rad) + coordsSection$Y * cos(theta_rad)

        # Update coordinates in the data frame
        coordsSection$X <- newX
        coordsSection$Y <- newY

        return(coordsSection)
      }

      # Apply rotation function
      section_coords <- rotate_coords_fn(section_coords, theta_deg)

      # Message indicating coordinates were updated
      message("Coordinates have been updated and stored.")
    }
  } else {
    # Message when rotation is not applied
    message("Coordinates have been stored.")
  }

  # Plot the filtered and optionally rotated data
  p <- ggplot2::ggplot(section_coords,
                       ggplot2::aes(x = X, y = Y, color = cluster)) +
    ggplot2::geom_point(size = 2) +
    ggplot2::ggtitle(paste("Section", section_id, "Cluster coordinates")) +
    ggplot2::coord_fixed()
  print(p)

  # Message for naming convention
  message("Please name the dataframe as: coordsSection_", section_id)

  # Return the section_coords data frame
  return(section_coords)
}
