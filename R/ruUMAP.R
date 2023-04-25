#' mFISH UMAP Dimensionality Reduction
#' @author Kaitlin E Sullivan
#'
#' @description Run UMAP dimensionality reduction on your mFISH object. To be used after `ruProcess` and before `ruCluster`.
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

ruUMAP <- function(mFISH, metric="manhattan", nn=15, min.dist=0.1, npc="auto"){
    #run on PCA
    df <- mFISH@attributes$pca

    #auto generate npcs
    if(npc == "auto"){
      sum <- mFISH@attributes$pcaSum
      if(sum$`Cumulative Proportion`[1]+sum$`Cumulative Proportion`[2]>0.95){
        pcs <- sum[1:2,]
      }else{
        pcs <- dplyr::filter(sum, `Cumulative Proportion`<=0.95)
      }
      #save autoselected pcs
      npc <- nrow(pcs)
    }

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


