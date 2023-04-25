#' mFISH Dendrogram Plot
#' @author Kaitlin E Sullivan
#'
#' @description Plot and colour the dendrogram of one's hierarchical clustering. To be used after running `ruCluster` to guide one's choice of cluster number.
#'
#' @param mFISH An mFISH object that has been run through `ruCluster`.
#' @param k At default "current", it will colour the dendrogram by the selected number of clusters. Note: if you change the number of clusters, the original cluster colours will change!
#' @param polar A logical indicating whether the plot will have polar coordinates.
#'
#' @return Plots a dendrogram coloured by the chosen number of clusters.
#'
#' @import dplyr
#' @importFrom dendextend as.ggdend set
#' @importFrom stats hclust cutree dist
#'
#' @export
plotDendro <- function(mFISH, k="current", polar=F){
  #save values
  pca <- mFISH@attributes$pca
  npc <- mFISH@attributes$npc
  dmetric <- mFISH@attributes$hclust_metric
  p <- mFISH@attributes$hclust_p
  if(k=="current"){
    k <- mFISH@attributes$hclust_k
  }

  #run clustering
  hc <- stats::hclust(d = stats::dist(pca[,1:npc], method=dmetric, p=p),
                      method = 'ward.D2')

  print("Creating dendrogram...")
  #turn to dendrogram and plot
  d <- as.dendrogram(hc)
  d <- dendextend::set(d, "branches_k_color", k = k)
  print("Plotting...")
  print("Please wait, this may take a while...")
  d <- dendextend::as.ggdend(d)
  if(polar){
    ggplot2::ggplot(d, labels=FALSE)+
      theme_classic()+
      scale_y_reverse()+
      coord_polar(theta = "x")
  }else{
    ggplot2::ggplot(d, labels=FALSE)+
      theme_classic()+
      labs(x="Cell", y="Height")
  }
}
