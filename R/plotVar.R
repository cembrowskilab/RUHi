#' mFISH PCA Variance Plot
#' @author Kaitlin Sullivan
#'
#' @description Plot the proportion of variance or standard deviation of each principle component to determine the number of PCs to be used in subsequent analysis. Use this function after `ruProcess` and before `ruUMAP`.
#'
#' @param mFISH An mFISH object that has undergone processing via `ruProcess()`.
#' @param metric A PCA metric to plot. Options are: "variance", "cumulative", or "stdev". This corresponds to the proportion of variance, cumulativie proportion, or standard deviation of a given PC.
#' @param include.auto A logical indicator to include a vertical assymptote at the number of PCs auto-selected. Note: you can change number of PCs used in dim reduction and clustering in `ruUMAP`.
#'
#' @return An elbow plot for the mFISH principle components.
#'
#' @import dplyr
#' @importFrom stats prcomp
#'
#' @export
plotVar <- function(mFISH, metric="variance", include.auto=T){
  #get values
  sum <- mFISH@attributes$pcaSum

  #create plots by metric
  if(metric=="variance"){
    p <- ggplot(sum, aes(x=`Principle Component`,
                    y=`Proportion of Variance`))+
      geom_point()+
      theme_classic()
  }
  if(metric=="cumulative"){
    p <- ggplot(sum, aes(x=`Principle Component`,
                         y=`Cumulative Proportion`))+
      geom_point()+
      theme_classic()
  }
  if(metric=="stdev"){
    p <- ggplot(sum, aes(x=`Principle Component`,
                         y=`Standard deviation`))+
      geom_point()+
      theme_classic()
  }

  #filter for PCs providing most variance
  if(include.auto){
    if(sum$`Cumulative Proportion`[1]+sum$`Cumulative Proportion`[2]>0.95){
      df <- sum[1:2,]
    }else{
      df <- dplyr::filter(sum, `Cumulative Proportion`<=0.95)
    }
    #save autoselected pcs
    npcs <- nrow(df)
    #add to plot
    p <- p + geom_vline(xintercept=npcs, colour="red")
  }
  p
}
