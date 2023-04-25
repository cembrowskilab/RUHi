#' mFISH Cluster Box Plot
#' @author Kaitlin E Sullivan
#'
#' @description Create a box plot denoting expression of **all genes** in _one or all clusters_.
#'
#' @param mFISH An mFISH object
#' @param clus Cluster name or number in quotations (or "all" for every cluster)
#' @param metadata Metadata variable to plot (must be numeric)
#'
#' @return A box plot showing gene expression per cluster
#' @export
#'
#' @import ggplot2 dplyr tidyr grDevices
clusterBoxPlot <- function(mFISH, clus = "all", metadata = "genes"){
  #save data
  fdf <- mFISH@filteredData
  md <- mFISH@metaData
  md <- dplyr::filter(md, fil == T)

  len <- length(names(fdf))-1

  #add md
  #add md
  l <- ncol(md)
  nm <- names(md)
  for(i in 1:l){
    cur <- nm[i]
    fdf <- dplyr::mutate(fdf, !!cur := md[,i])
  }

  df <- tidyr::pivot_longer(fdf, cols = -names(md),
                            names_to = "genes", values_to= "Expression")

  if(clus != "all"){
    df <- dplyr::filter(df, cluster==clus)
  }

  #plot
  gp <- ggplot(df, aes_string(x="genes", y="Expression", fill="genes"))+
    geom_boxplot(outlier.shape = NA)+
    theme_classic()+
    labs(y="Expression", x="")+
    facet_wrap(~cluster)+
    scale_fill_manual(values = rainbow(len))


  gp
}
