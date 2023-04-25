#' mFISH Gene Box Plot
#' @author Kaitlin E Sullivan
#'
#' @description Create a boxplot denoting expression of a **single gene** across _all clusters_.
#'
#' @param mFISH An mFISH object
#' @param gene Gene name to plot
#' @param group Metadata variable to group data by (must be a factor)
#'
#' @return A box plot showing gene expression
#' @export
#'
#' @import ggplot2
#'
geneBoxPlot <- function(mFISH, gene, group = "cluster"){
  #save data
  df <- mFISH@filteredData
  md <- mFISH@metaData
  md <- dplyr::filter(md, fil == T)

  #add md
  l <- ncol(md)
  nm <- names(md)
  for(i in 1:l){
    cur <- nm[i]
    df <- dplyr::mutate(df, !!cur := md[,i])
  }

  #plot
  gp <- ggplot2::ggplot(df, aes_string(x=group, y=gene, fill=group))+
    geom_boxplot(outlier.shape = NA)+
    theme_classic()+
    labs(y="Expression", title = gene)

  gp
}
