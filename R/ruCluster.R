#' Cluster an mFISH object
#'
#' @author Kaitlin Sullivan
#'
#' @param mFISH An mFISH object
#' @param k Number of clusters
#' @param dmetric Metric for creating distance matrix (see `dist()`)
#' @param p Power of the Minkowski distance (see `dist()`)
#'
#' @return A clustered mFISH object.
#' @export
#'
#' @import dplyr
#' @importFrom stats hclust cutree dist
#'
ruCluster <- function(mFISH, k, dmetric = "euclidean", p = 2){
  #save pca
  pca <- mFISH@attributes$pca
  #run clustering
  npc <- mFISH@attributes$npc
  hc <- stats::hclust(d = stats::dist(pca[,1:npc], method=dmetric, p=p),
                      method = 'ward.D2')
  #cut tree
  clus <- stats::cutree(hc, k=k)
  filt <- data.frame(cluster = as.factor(clus), id = mFISH@filteredData$id)

  #update object
  #save the id-cluster combo
  others <-  dplyr::filter(mFISH@rawData, !id %in% filt$id)
  others <- dplyr::mutate(others, cluster=NA)
  others <- dplyr::select(others, c(id, cluster))

  #order by id
  clustered <- rbind(filt, others)
  clustered <- dplyr::arrange(clustered, id)


  #add to metadata
  print('Clustering...')
  mFISH@metaData <- dplyr::mutate(mFISH@metaData, cluster = clustered$cluster)
  #add to attributes
  mFISH@attributes$hclust_k <- k
  mFISH@attributes$hclust_metric <- dmetric
  mFISH@attributes$hclust_p <- p
  mFISH@attributes$cluster <- as.factor(clus)

  #return object
  mFISH
}
