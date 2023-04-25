#' Create an mFISH object
#' @author Kaitlin E Sullivan
#'
#' @description Create an mFISH object from a data table created by the function `ruRead` and/or `ruCombine`. Run `ruFilter` next!
#'
#' @param df Dataframe from `ruRead` or `ruCombine`.
# @param filteredData Dataframe containing the filtered and normalized dataset with id number
#' @param metadata Dataframe containing metadata
# @param attributes List of attributes used in data analysis: `list(filter.by, thresh, umap_nn, umap_mindist, umap_metric, hclust_k, hclust_metric, hclust_p)`
#' @return An mFISH object.
#'
#' @import dplyr methods
#'
#' @export
#'

ruMake <- function(df, metadata=NULL) {
  print("Creating object...")

  #get class of input
  isDf <- class(df)
  df <- df

  #if data.frame - start from scratch
  if(isDf=='data.frame'){
    meta <- dplyr::select(df, c(X,Y,id,region,anum,section))
    df <- dplyr::select(df, -c(X,Y,region,anum,section))


    #include other metadata
    if(!is.null(metadata)){
      for(i in 1:length(names(metadata))){
        cur <- names(metadata[i])
        meta$cur <- metadata$cur
      }
    }


    #enter rawData and metaData
    #leave filterData and attributes for future functions
    hiPlex <- methods::new(Class='mFISH', rawData = df, filteredData = data.frame(),
                    metaData = meta,
                    attributes = list(filter.by=NA, thresh=NA, umap_nn=NA,
                                  umap_mindist=NA, umap_metric=NA, hclust_k=NA,
                                  hclust_metric=NA, hclust_p=NA, pca=NA, npc=NA))
    #return object
    hiPlex
  }
  else{
    #print error if not a dataframe
    print("Incorrect class. Should be a dataframe output from the function ruCombine() or ruRead().")
  }
}
