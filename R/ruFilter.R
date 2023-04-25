#' mFISH Data Filtering
#' @author Kaitlin E Sullivan
#'
#' @description Filter data for a cell type of choice, plus exclude any non-expressing genes here. To be used after `ruMake` and before `ruProcess`.
#'
#' @param mFISH An mFISH object
#' @param threshold A numeric value to threshold the gene by
#' @param filter.by A gene or a vector of gene names to filter data by
#' @param exclude A gene or vector of gene names to exclude from analysis
#'
#' @import dplyr rlang
#'
#' @return An mFISH object with a populated filteredData section
#'
#' @export
ruFilter <- function(mFISH, threshold = 0.1, filter.by = NA, exclude = NA){
  #save raw data
  df <- mFISH@rawData

  if(!is.na(exclude[1])){
    print("Running gene exclusions...")
    l <- length(exclude)
    for(i in 1:l){
      #if(!(exclude %in% names(df))){
      #  warning(paste("Gene ", exclude[i], " has already been removed via filtering or does not exist in this object. This argument is for removing genes that are not included in the filtering process. Please also check spelling!",
      #                sep=""))
      #}
      #POTENTIAL ROADBLOCK???
      mFISH@metaData <- dplyr::mutate(mFISH@metaData,
                                      !!exclude[i] := log1p(df[[exclude[i]]]))
      df <- dplyr::select(df, -(!!rlang::sym(exclude[i])))
    }
  }

  #filter by list
    #only run if length > 1
    l <- length(filter.by)
    if(!is.na(filter.by[1])){
      #filter each gene and remove from dataframe
      for (i in 1:l) {
        print(paste("Filtering data by ", filter.by[i], " at threshold of ", threshold, "...", sep=""))
        #error if name does not exist
        if(!(filter.by[i] %in% names(df))){
          print(paste("WARNING: ", filter.by[i], " is not present in this current dataset. Please check spelling!",
                      sep=""))
        }
        df <- dplyr::filter(df, !!rlang::sym(filter.by[i])>threshold)
        #POTENTIAL ROADBLOCK???
        df <- dplyr::select(df, -(!!rlang::sym(filter.by[i])))
      }
    }

    #populate object with values
    #filtered
    mFISH@filteredData <- df
    #attributes
    my.attrib <- mFISH@attributes
    my.attrib$filter.by <- filter.by
    my.attrib$thresh <- threshold
    mFISH@attributes <- my.attrib
    #mFISH@attributes$filter.by <- filter.by
    #mFISH@attributes$thresh <- threshold

    #save filtered ids
    fils <- dplyr::select(mFISH@filteredData, id)
    fils <- dplyr::mutate(fils, fil = T)
    others <- dplyr::filter(mFISH@rawData, !(id %in% fils$id))
    others <- dplyr::select(others, id)
    others <- dplyr::mutate(others, fil = F)


    #bind
    b <- rbind(fils, others)
    print("Updating metadata...")
    b <- dplyr::arrange(b, id)
    md <- mFISH@metaData
    mFISH@metaData <- dplyr::mutate(md, fil = b$fil)

  #return mFISH object
  mFISH
}
