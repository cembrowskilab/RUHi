#' Calculate the distance along and away from a user-defined boundary using mFISH cell coordinates
#' @author Margarita Kapustina
#'
#' @description Compute distance along and the distance away from a user-defined boundary, using section-specific coordinate data computed with getCoords function. Useful to analyze cell distances away from white matteer, or neocortical layer edge.
#'
#' @param SectionName Name of your section (example: 'section7'), used for plotting titles and saving filenames
#' @param coord_data Coordinate section data extracted from mFISH object using getCoords().
#' @param highlight_cluster.1 Specify identity of first cluster to highlight when defining boundary, to use as a landmark if needed (example: highlight_cluster.1 = 1).
#' @param highlight_cluster.2 Specify identity of second cluster to highlight when defining boundary, to use as a landmark if needed (example: highlight_cluster.2 = 2).
#' @param highlight_colour Specify colour to highlight cells belonging to selected cluster in 'highlight_cluster.1'. Default colour is black
#'
#' @return A dataframe with cell ID, coordinates, cluster ID, distance along and distance away from your defined boundary. Distance metrics are available as raw (microns) and normalized (0-1) outputs.
#'
#' @import ggplot2
#'
#' @export

analyzeDistance <- function(SectionName,
                            coord_data,
                            highlight_cluster.1 = NULL,
                            highlight_cluster.2 = NULL,
                            highlight_colour = 'black') {

  # Convert x and y to numeric
  cell_data <- coord_data
  cell_data$x = as.numeric(cell_data$X)
  cell_data$y = as.numeric(cell_data$Y)

  # Plot out the cells in space
  ggplot2::ggplot(cell_data, ggplot2::aes(x = x, y = y, colour = cluster)) +
    ggplot2::geom_point() +
    ggplot2::coord_fixed()  # Set y-axis limits

  clusters <- factor(cell_data$cluster)
  colors <- rainbow(length(levels(clusters)))[clusters]  # Generate a color for each cluster

  # Optional: Highlight specified clusters in black if they are not NULL
  if (!is.null(highlight_cluster.1)) {
    colors[cell_data$cluster == highlight_cluster.1] <- highlight_colour
  }
  if (!is.null(highlight_cluster.2)) {
    colors[cell_data$cluster == highlight_cluster.2] <- highlight_colour
  }

  # Plot cell data with colored clusters
  par(pty="s")
  plot(cell_data$x, cell_data$y, type = "p",
       xlab = "x", ylab = "y", col = colors, pch = 19)

  message('Please click around 5-15 points to set major landmarks in plot screen...')
  message('Any highlighted clusters are coloured black.')
  message('When done hit ESC on keyboard.')

  # Prompt user to click points on the plot
  points <- locator()  # Hit ESC when done

  # Extract x and y coordinates of clicked points
  x_coords <- points$x
  y_coords <- points$y
  points <- as.data.frame(points)

  ######### Function to calculate the spline
  calculate_spline <- function(x1, y1, x2, y2, n_points = 100) {
    # Generate x values for the spline
    x_values <- seq(x1, x2, length.out = n_points)

    # Interpolate y values using a spline
    y_values <- spline(x = c(x1, x2), y = c(y1, y2), xout = x_values)$y

    return(data.frame(x = x_values, y = y_values))
  }

  # Initialize a list to store spline coordinates
  spline_segments <- list()

  # Iterate through points and calculate spline segments
  for (i in 1:(nrow(points) - 1)) {
    segment <- calculate_spline(points$x[i], points$y[i], points$x[i + 1], points$y[i + 1])
    spline_segments[[i]] <- segment
  }

  # Combine spline segments into a single DataFrame
  spline_data <- do.call(rbind, spline_segments)

  # Project the point onto the nearest spline segment and calculate signed distance
  project_point_onto_segment <- function(px, py, x1, y1, x2, y2) {
    dx <- x2 - x1
    dy <- y2 - y1
    # Calculate t, the projection factor of the point onto the line segment
    t <- ((px - x1) * dx + (py - y1) * dy) / (dx^2 + dy^2)
    t <- pmax(0, pmin(1, t))  # Clamp t to the segment bounds (0 <= t <= 1)

    # Calculate the projected point on the line segment
    projected_x <- x1 + t * dx
    projected_y <- y1 + t * dy

    # Calculate the signed perpendicular distance
    signed_distance <- ((x2 - x1)*(py - y1) - (y2 - y1)*(px - x1)) / sqrt((dx)^2 + (dy)^2)

    return(c(projected_x, projected_y, signed_distance))  # Return projected point and signed distance
  }

  # Initialize a vector to store signed distances
  distances <- numeric(nrow(cell_data))

  # Plot the cell data and spline
  par(pty="s")
  plot(cell_data$x, cell_data$y, type = "p", col = "red", pch = 16, xlab = "X", ylab = "Y",
       main = "Cell coordinates,\nestimated boundary\n and Distance to boundary")
  mtext("Please note: any new cell coordinates displayed are non-Slc17a7 expressing (cluster ID:NA)",
        side = 1, line = 3.5, cex = 0.9)
  points(spline_data$x, spline_data$y, col = "blue")

  for (i in 1:nrow(cell_data)) {
    nearest_index <- which.min((spline_data$x - cell_data$x[i])^2 + (spline_data$y - cell_data$y[i])^2)

    # Project cell points onto nearest spline segment
    if (nearest_index == 1) {
      projected <- project_point_onto_segment(cell_data$x[i], cell_data$y[i],
                                              spline_data$x[1], spline_data$y[1],
                                              spline_data$x[2], spline_data$y[2])
    } else if (nearest_index == nrow(spline_data)) {
      projected <- project_point_onto_segment(cell_data$x[i], cell_data$y[i],
                                              spline_data$x[nrow(spline_data) - 1], spline_data$y[nrow(spline_data) - 1],
                                              spline_data$x[nrow(spline_data)], spline_data$y[nrow(spline_data)])
    } else {
      projected <- project_point_onto_segment(cell_data$x[i], cell_data$y[i],
                                              spline_data$x[nearest_index - 1], spline_data$y[nearest_index - 1],
                                              spline_data$x[nearest_index], spline_data$y[nearest_index])
    }

    # Store the signed distance (third element)
    distances[i] <- projected[3]

    # Draw line from cell to the projected point on the spline
    segments(projected[1], projected[2], cell_data$x[i], cell_data$y[i], col = "green")  # Reversed the order of endpoints
  }

  # Add the signed distances as a new column in the cell_data dataframe
  #update dec 5 2024: flip the sign of the distances MK #og: cell_data$distance_to_spline <- distances
  cell_data$distance_to_spline <- -distances

  ## Normalize the signed distance to the spline
  cell_data$normalized_distance_to_spline <- (cell_data$distance_to_spline - min(cell_data$distance_to_spline)) /
    (max(cell_data$distance_to_spline) - min(cell_data$distance_to_spline))

  ## ggplot version to visualize the distances to spline (Non normalized)
  title <- paste0("Color-coded cells by distance to boundary: ", SectionName)
  p2 =  ggplot2::ggplot(cell_data, ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_point(ggplot2::aes(color = distance_to_spline), pch = 16) +
    ggplot2::scale_colour_gradient2(
      low = "red",      # For negative values
      mid = "white",    # For values close to zero
      high = "blue",    # For positive values
      midpoint = 0)+      # Center point for gradient
    ggplot2::labs(x = "X", y = "Y", title = title, color = "Distance to Boundary") +
    ggplot2::coord_fixed()

  # Save the plot
  filename <- paste0("distancetoBoundary_", SectionName, ".eps")
  ggplot2::ggsave(filename = filename, plot = p2)

  ############### Histogram of Distances to Spline
  title = paste0("Histogram of distances to the boundary: ", SectionName)
  p_hist2 <- ggplot2::ggplot(cell_data, ggplot2::aes(x = distance_to_spline)) +
    ggplot2::geom_histogram(color = "grey", fill = "gold", bins = 30) +
    ggplot2::labs(x = "Distance to Boundary", y = "Frequency", title = title)

  filename <- paste0("Histogram_distanceToBoundary_", SectionName, ".eps")
  ggplot2::ggsave(filename = filename, plot = p_hist2)

  ###############################

  # Initialize vector to store distances
  cell_data$distance_along_spline <- numeric(nrow(cell_data))

  # Iterate over each point in cell_data
  for (i in 1:nrow(cell_data)) {
    # Calculate distances to all points in spline_data
    distances <- sqrt((spline_data$x - cell_data$x[i])^2 + (spline_data$y - cell_data$y[i])^2)

    # Find index of nearest point
    nearest_index <- which.min(distances)

    # Calculate distance along spline to nearest point
    if (nearest_index == 1) {
      # If nearest point is the first point in spline_data, set distance to 0
      cell_data$distance_along_spline[i] <- 0
    } else {
      # Calculate distance as sum of distances between consecutive points along the spline up to the nearest point
      cell_data$distance_along_spline[i] <- sum(sqrt(diff(spline_data$x[1:nearest_index])^2 + diff(spline_data$y[1:nearest_index])^2))
    }
  }

  ##normalize the distance to spline stored in cell_data$distance_along_spline
  cell_data$normalized_distance_along_spline <- (cell_data$distance_along_spline - min(cell_data$distance_along_spline)) / (max(cell_data$distance_along_spline) - min(cell_data$distance_along_spline))

  # Plot histogram of distances along the spline for all cells
  # Create the ggplot histogram
  title = paste0("Histogram of distances along the boundary: ", SectionName)
  p_hist <- ggplot2::ggplot(cell_data, ggplot2::aes(x = distance_along_spline)) +
    ggplot2::geom_histogram(color = "grey", fill = "violet", bins = 30) +
    ggplot2::labs(x = "Distance along boundary", y = "Frequency", title = title)
  filename <- paste0("Histogram_distanceAlongBoundary_", SectionName, ".eps")
  ggplot2::ggsave(filename = filename, plot = p_hist)
  ###############################

  # Color-code the cells by their distance along the spline
  my_palette <- grDevices::colorRampPalette(c("red", "blue"))(nrow(cell_data))
  title <- paste0("Color-coded cells by distance along boundary: ", SectionName)
  p3 =  ggplot2::ggplot(cell_data, ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_point(ggplot2::aes(color = distance_along_spline), pch = 16) +
    ggplot2::scale_color_gradientn(colors = my_palette) +
    ggplot2::labs(x = "X", y = "Y", title = title, color = "Distance along Boundary")+
    ggplot2::coord_fixed()
  filename <- paste0("distanceAlongBoundary_", SectionName, ".eps")
  ggplot2::ggsave(filename = filename, plot = p3)

  #name dataframe with unique identifier, and name the object dynamically
  uniqueSection_name <- paste(SectionName, "data", sep = "")
  assign(uniqueSection_name, cell_data)
  ############
  message('Name this file as:')
  print(uniqueSection_name)
  # Update colnames in celldata
  colnames(cell_data)[colnames(cell_data) == "distance_to_spline"] <- "distance_to_boundary"
  colnames(cell_data)[colnames(cell_data) == "normalized_distance_to_spline"] <- "normalized_distance_to_boundary"
  colnames(cell_data)[colnames(cell_data) == "distance_along_spline"] <- "distance_along_boundary"
  colnames(cell_data)[colnames(cell_data) == "normalized_distance_along_spline"] <- "normalized_distance_along_boundary"
  # Return the modified cell_data dataframe
  return(cell_data)
}
