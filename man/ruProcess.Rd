% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ruProcess.R
\name{ruProcess}
\alias{ruProcess}
\title{mFISH Normalization and PCA}
\usage{
ruProcess(mFISH, norm = "PAC", remove.outliers = F, outlier.thresh = c(1, 11))
}
\arguments{
\item{mFISH}{An mFISH object containing raw or filtered data}

\item{norm}{A string declaring "log", "PAC", or "maxVal". Default is "PAC" but "log is also highly recommended. "maxval" is only useful in a handful of cases - namely with few marker genes. See documentation.}

\item{remove.outliers}{A logical value for removing "outliers" (eg: autofluorescent cells positive for all genes)}

\item{outlier.thresh}{Low and high threshold for outliers. These numbers will change based on amount of genes and autofluorescence in your data.}
}
\value{
and mFISH object, normalized and containing a PCA (found in \code{obj@attributes$pca})
}
\description{
This function normalizes the \strong{filtered} data and runs a PCA on it. To be used after \code{ruFilter} and before \code{ruUMAP}. See \code{plotVar} for info on selecting number of PCs.
}
\author{
Kaitlin E Sullivan
}
