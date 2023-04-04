#' Cluster Atlas
#'
#' @description A function that creates data-driven anatomical atlas parcellation by taking a binned dataframe from createAtlas() and clusters based on cellular phenotype and/or cellular density.
#'
#' @param bins A bin dataframe generated from: createAtlas()
#' @param k Number of clusters to create (via hierarchical clustering of binned windows)
#' @param density Density value to use as a cut-off. If left at 0, automatically chooses optimal cut-off value.
#' @param include.density If you wish to include cell body density as a value to cluster on, select TRUE.
#' @param normalize Set to true if you wish to normalize cell body density.
#'
#' @return A bin dataframe with a cluster column. Can be plotted using plotAtlas()
#' @export
#'
clusterAtlas <- function(bins, k, density = 0, include.density = F, normalize = F){
  mybins <- dplyr::filter(bins, Avg_Density>density)
  meta <- dplyr::select(mybins, c(cX,cY))
  mybins <- dplyr::select(mybins, -c(cX,cY))
  
  if(include.density){
    mybins <-dplyr::select(mybins, -as.formula(filter.by))
  }
  if(normalize){
    mybins <- sweep(mybins, 1,apply(mybins, 1, sum), "/")
  }
  
  hc <- hclust(d=dist(mybins), method = "ward.D2")
  
  clus <- cutree(hc, k=k)
  mybins <- mutate(mybins, cluster = as.factor(clus),
                   cX = meta$cX, cY = meta$cY)
  mybins
}