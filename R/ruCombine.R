#' mFISH Data Pooling
#' @author Kaitlin E Sullivan
#'
#' @description Combine `ruRead` datatables from multiple mFISH images!
#'
#' @param dfs A list of dataframes (from `ruRead` using `list(df1,df2,df3)`)
#' @return A combined dataframe.
#'
#' @import dplyr
#'
#' @export
#' @import dplyr
ruCombine <- function(dfs) {
  #if the data is 2+ dataframes
  if(length(dfs)>1){
    print("Combining tables...")

    #save the last id number of first df
    cur <- dfs[1][[1]]
    cur <- dplyr::mutate(cur, id=1:nrow(cur))

    #subsequent
    nxt <- dfs[2][[1]]

    #last id #
    lst <- nrow(cur)

    #iterate through
    for(i in 1:length(dfs)-1){
      print(paste("Table: ", i+1, sep=""))

      #change id numbers for subsequent round
      nxt <- dfs[i+1][[1]]
      nxt <- dplyr::mutate(nxt, id=1:nrow(nxt),
                           id=id+lst)

      #bind tables
      cur <- rbind(cur, nxt)

      #update last number for ids
      lst <- nrow(cur)
    }
    #return table
    cur
  }
  else{
    warning("This function requires a vector of dataframes with length >= 2.")
  }
}
