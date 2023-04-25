#' mFISH UMAP Plot
#' @author Kaitlin E Sullivan
#'
#' @description Plot UMAP dimensionality reduction and colour by gene expression or metadata.
#'
#' @param mFISH An mFISH object that has undergone all analysis steps
#' @param colour.by A metadata variable to colour by (auto-coloured by cluster).
#' @param size Point size
#' @param cols Vector of colours
#'
#' @return A ggplot showing UMAP space coloured by metadata.
#' @export
#'
#' @import ggplot2 dplyr
plotDim <- function(mFISH, colour.by="cluster", size = 0.9, cols=NA){

  #save umap object
  df <- mFISH@attributes$umap
  met <- dplyr::filter(mFISH@metaData, fil==T)
  data <- mFISH@filteredData
  uplot <- dplyr::mutate(met, UMAP_1 = df$UMAP_1, UMAP_2=df$UMAP_2)
  uplot <- merge(uplot, data)

  #baseplot
  p <- ggplot2::ggplot(uplot, aes_string(x="UMAP_1", y="UMAP_2", colour=colour.by))+
    theme_classic()+
    geom_point(size=size)

  #baseline colours
  if(class(uplot[[colour.by]])=='numeric'){
    p <- p + scale_colour_gradientn(colours=c("cyan", "red"))
  }

  #print(class(uplot[[colour.by]]))
  #others
  if(!is.na(cols)){
    if(class(df[[colour.by]])=='numeric'){
      p <- p + scale_colour_gradientn(colours=cols)
    }
    else{
      p <- p + scale_colour_manual(values=cols)
    }
  }

  #print plot
  p
}
