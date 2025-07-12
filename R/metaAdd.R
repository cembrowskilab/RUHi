#' mFISH Add Metadata
#' @author Margarita Kapustina
#'
#' @description Add metadata to an existing mFISH object. (Note: new metadata must contain cell IDs.)
#'
#' @param mfish_object mFISH object
#' @param metadata_to_add New metadata as a dataframe (must contain cell IDs in an 'id' column).
#' @param metadata_variables_to_add Specify variable (column name) to add to mFISH object as new metadata.
#'
#' @return mFISH object with updated metadata.
#'
#' @export

metaAdd <- function(mfish_object,
                    metadata_to_add,
                    metadata_variables_to_add) {

  # Ensure 'id' in the new metadata corresponds to row names in the mFISH object's metaData
  if (!"id" %in% colnames(metadata_to_add)) {
    stop("The metadata_to_add must contain an 'id' column.")
  }

  # Merge the new metadata into the mFISH object's metaData
  merged_metadata <- merge(
    mfish_object@metaData,     # Existing metadata in the mFISH object
    metadata_to_add,           # New metadata to add
    by.x = "id",               # Use 'id' in mFISH metaData
    by.y = "id",               # Use 'id' in the new metadata
    all.x = TRUE               # Keep all rows from the mFISH object's metaData
  )

  # Restore row names in the merged metadata
  rownames(merged_metadata) <- merged_metadata$Row.names
  merged_metadata$Row.names <- NULL

  # Flag to track if warnings were issued
  warnings_occurred <- FALSE

  # Add specified variables to the mFISH object metaData
  for (var in metadata_variables_to_add) {
    if (!var %in% colnames(merged_metadata)) {
      warning(paste("Variable", var, "not found in metadata_variables_to_add. Skipping.\nIf updating an existing metadata variable, please first run \n mfishobj@metaData$variable = NULL"))
      warnings_occurred <- TRUE
    } else {
      mfish_object@metaData[[var]] <- merged_metadata[[var]]
    }
  }
  # Only print the success message if no warnings occurred
  if (!warnings_occurred) {
    message("New metadata added to mFISH object!")
  }
  return(mfish_object)
}
