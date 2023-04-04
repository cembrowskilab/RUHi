#' Run UMAP dimensionality reduction on mFISH object
#'
#' @author Kaitlin E Sullivan
#'
#' @param mFISH An mFISH object with preprocessing completed.
#' @param metric Distance metric for UMAP.
#' @param nn Nearest neighbours value for UMAP.
#' @param min.dist Minimum distance value for UMAP.
#' @param npc Number of principle components to use.
#'
#' @return An mFISH object with UMAP coordinates populated in the metadata slot.
#'
#' @import dplyr umap
#' @export
#'

ruUMAP <- function(mFISH, metric="manhattan", nn=15, min.dist=0.1, npc=1){
    #auto generate npcs
    if(npc <= 1){
      l <- length(names(mFISH@filteredData))
      npc <- (l/2)-1
    }

    #run on PCA
    df <- mFISH@attributes$pca

    #update umap configuration
    print("Altering UMAP configurations...")
    custom <- umap::umap.defaults
    custom$n_neighbors <- nn
    custom$metric <- metric
    custom$min_dist <- min.dist

    #run UMAP
    print("Running UMAP...")
    u <- umap::umap(df[,1:npc], config = custom)

    #save coordinates
    print("Saving custom configuration...")

    mFISH@attributes$umap_nn <- nn
    mFISH@attributes$umap_mindist <- min.dist
    mFISH@attributes$umap_metric <- metric
    mFISH@attributes$npc <- npc
    mFISH@attributes$umap <- data.frame(UMAP_1 = u$layout[,1], UMAP_2 = u$layout[,2])

    #return object
    mFISH

}
