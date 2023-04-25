#' mFISH Plotting Cells in Native Tissue
#' @author Kaitlin E Sullivan
#'
#' @description Plot cells in their original X,Y coordinates. Colour according to gene expression or metadata.
#'
#' @param mFISH An mFISH object that has undergone all analysis steps.
#' @param colour.by A metadata variable to colour by
#' @param size Point size
#' @param cols Vector of colours
#' @param include.fil Logical allowing for filtered cells to appear in grey
#' @param group.by A variable to separate plots by (eg: section or anum to view individual slices or animals)
#'
#' @return A ggplot showing cells in native space!
#' @export
#'
#' @import ggplot2 dplyr
plotSpace <- function(mFISH, colour.by="cluster",
                      size = 0.9, cols=NA, include.fil=T, group.by=NA){

  #save object
  df <- mFISH@filteredData
  md <- mFISH@metaData
  mdf <- dplyr::filter(md, fil==T)
  df <- merge(df, md)
  # df <- dplyr::mutate(df, X=mdf$X, Y=mdf$Y, region=mdf$region,
  #                     section=mdf$section, anum=mdf$anum, cluster=mdf$cluster)
  #
  # others <- names(dplyr::select(df, -c(id,X,Y,section,region,anum,cluster)))
  # if(length(others)>0){
  #   for(i in length(others)){
  #     df <- dplyr::mutate(df, !!rlang::sym(others[i])=)
  #   }
  # }

  fil.df <- dplyr::filter(df, fil==T)
  bg <- mFISH@metaData



  #baseplot with bg cells
  if(include.fil){
    p <- ggplot2::ggplot(fil.df, aes_string(x="X", y="Y", colour=colour.by))+
      theme_classic()+
      geom_point(data = bg, colour='grey', size=size)+
      geom_point(size=size)
  }
  #without
  else{
    p <- ggplot2::ggplot(fil.df, aes_string(x="X", y="Y", colour=colour.by))+
      theme_classic()+
      geom_point(size=size)
  }

  #baseline colours
  if(class(df[[colour.by]])=='numeric'){
    p <- p + scale_colour_gradientn(colours=c("cyan", "red"))
  }

  #others
  if(!is.na(cols)){
    if(class(df[[colour.by]])=='numeric'){
      p <- p + scale_colour_gradientn(colours=cols)
    }
    else{
      p <- p + scale_colour_manual(values=cols)
    }
  }

  #facetwrap
  if(length(unique(md$section))>1){
    p <- p+facet_wrap(~section)
  }
  if(!is.na(group.by)){
    p <- p + facet_wrap(stats::as.formula(paste("~", group.by, sep = "")))
    #check if more than one section
    if(length(unique(md$section))>1){
      p <- p+facet_wrap(stats::as.formula(paste("~", c(group.by, "section"), sep = "")))
    }
  }


  #print plot
  p
}
