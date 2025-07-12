#' mFISH Normalization and PCA
#' @author Kaitlin E Sullivan
#'
#' @description This function normalizes the **filtered** data and runs a PCA on it. To be used after `ruFilter` and before `ruUMAP`. See `plotVar` for info on selecting number of PCs.
#'
#' @param mFISH An mFISH object containing raw or filtered data
#' @param norm A string declaring "PAC" or "maxVal". Default is "PAC" as "maxval" is only useful in a handful of cases. See documentation.
#' @param remove.outliers A logical value for removing "outliers" (eg: autofluorescent cells positive for all genes)
#' @param outlier.thresh Low and high threshold for outliers. These numbers will change based on amount of genes and autofluorescence in your data.
#'
#' @return and mFISH object, normalized and containing a PCA (found in `obj@attributes$pca`)
#'
#' @import dplyr
#' @importFrom stats prcomp na.omit
#'
#' @export
#'
ruProcess <- function(mFISH, norm="PAC", remove.outliers=F, outlier.thresh=c(1,11)){
  #ensure the class of the object
  if(class(mFISH) != 'mFISH'){
    warning("This function only takes objects of class `mFISH`. You can generate this type of object using `ruMake()` or `ruCombine()`.")
  }

  #check for filtered data
  if(length(mFISH@filteredData)==0){
    mFISH@filteredData <- mFISH@rawData
  }

  #normalize the data
  df <- mFISH@filteredData

  #exclude id values from norm/pca
  ids <- dplyr::select(df, id)
  df <- dplyr::select(df, -id)

  #remove 0 value
  if(remove.outliers){
    print("Removing outliers...")
    #find cells with number of features outside of threshold
    df<-dplyr::mutate(df, nfts =rowSums(df>0))
    df <- dplyr::mutate(df, id=ids$id)
    ids <- dplyr::mutate(ids, nfts=df$nfts)

    #low/high
    df<-dplyr::filter(df, nfts>outlier.thresh[1])
    df<-dplyr::filter(df, nfts<outlier.thresh[2])

    #filter ids
    ids<-dplyr::filter(ids, id %in% df$id)

    #remove from table
    df<-dplyr::select(df, -c(nfts, id))
  }


  #normalize to PAC
  print("Normalizing the data...")
  if(norm=="maxVal"){
    # part 1: (new KS 2023 - for Shalini's autofluorescence)
    # this code takes the mean expression and
    # divides it by the max expression of that gene
    nms <- length(names(df))
    nmslist <- names(df)
    for(i in 1:nms){
      curmax <- max(df[,i])
      df <- dplyr::mutate(df, !!nmslist[i] := (!!rlang::sym(nmslist[i])/curmax)*100)
    }
  }
  if(norm=="PAC"){
    # part 2: original
    # expression per cell adds to equal 100
    #normalize to PAC
    df <- sweep(df, 1,apply(df, 1, sum), "/")
    df <- df*(100)
  }

  if(norm=="log"){
    # part 3: log
    # log normalize
    #normalize to PAC
    df <- log2(1+df)
  }

  #remove NAs
  df <- dplyr::mutate(df, id = ids$id)
  df <- stats::na.omit(df)
  ids <- dplyr::filter(ids, id %in% df$id)

  print("Running PCA...")
  #run a pca
  df <- dplyr::select(df, -id)
  pca <- stats::prcomp(df, center = T, scale = T)

  #save the data
  mFISH@filteredData <- dplyr::mutate(df, id=ids$id)
  mFISH@attributes$pca <- pca$x

  #save summary for elbow plotting
  sum <- summary(pca)
  sum <- as.data.frame(sum$importance)
  sum <- t(sum)
  sum <- as.data.frame(sum)
  #add PCs for plotting
  sum <- dplyr::mutate(sum,"Principle Component"= 1:nrow(sum))
  mFISH@attributes$pcaSum <- sum



  #update filtered ids
  fils <- dplyr::select(mFISH@filteredData, id)
  fils <- dplyr::mutate(fils, fil = T)
  others <- dplyr::filter(mFISH@rawData, !(id %in% fils$id))
  others <- dplyr::select(others, id)
  others <- dplyr::mutate(others, fil = F)


  #bind
  print("Updating metadata...")
  b <- rbind(fils, others)
  b <- dplyr::arrange(b, id)
  mFISH@metaData <- dplyr::mutate(mFISH@metaData, fil = b$fil)


  #save w ids
  df <- dplyr::mutate(df, id = ids$id)
  mFISH@filteredData <- df


  #filter for PCs providing most variance
    if(sum$`Cumulative Proportion`[1]+sum$`Cumulative Proportion`[2]>0.95){
      df <- sum[1:2,]
    }else{
      df <- dplyr::filter(sum, `Cumulative Proportion`<=0.95)
    }
    #save to attributes
    mFISH@attributes$npc <- nrow(df)

  #return object
  mFISH
}

