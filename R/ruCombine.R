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
ruCombine <- function (dfs) 
{
  if (length(dfs) > 1) {
    print("Combining tables...")
    cur <- dfs[[1]]
    print(paste("Table 1 - nrow =", nrow(cur)))
    for (i in 2:length(dfs)) {
      print(i)
      nxt <- dfs[[i]]
      print(paste("Table", i, "- nrow =", nrow(nxt)))
      cur <- rbind(cur, nxt)
    }
    cur <- dplyr::mutate(cur, id = 1:nrow(cur))
    print(paste("Combined length =", nrow(cur)))
    cur
  }
  else {
    warning("This function requires a list of data frames with length >= 2.")
  }
}
