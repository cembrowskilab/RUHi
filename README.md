
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ![](https://emojis.slackmojis.com/emojis/images/1563480763/5999/meow_party.gif?1563480763) RUHi 

#### R-based Utilities for HiPlex

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/RUHi)](https://CRAN.R-project.org/package=RUHi)
<!-- badges: end -->

The goal of RUHi is to analyze and visualize mFISH\! Stay tuned for
exciting features such as *integration with scRNA-seq data*\!

## Installation

You can install RUHi from this github repo with:

``` r
#for the last released version:
devtools::install_github("cembrowskilab/RUHi")

#for the current developers version:
devtools::install_github("kaitsull/RUHi")
```

Once installed, load the package normally:

``` r
library(RUHi)
```  

## Test Code

``` r
# TEST OUT THE PACKAGE PLS
# Kaitlin 2021

#run this code line if you don't have devtools!
install.packages('devtools')

#install the package from my github

#NOTE: you might be prompted to...
#1. update packages -> just enter an empty line to skip
#2. install a package -> enter 'yes' when asked about binaries vs source
devtools::install_github("kaitsull/RUHi")


#load package
library(RUHi)

#set the wd to your file
setwd("SET IT HERE")

#check out what this function does via:
#   ?ruMake   (in the console)

mydata <- ruMake(getwd())

#this code might be buggy depending on what version of
#the registration or quantification used - check out the gene names
#generated via the following line:
head(mydata)

#check out what this function does via:
#   ?goFISH   (in the console)
#PLZ NOTE: the dancing cat means its loading - it can be slow at first!
goFISH(mydata)
```  
  
    
 ## Function List

Currently the package has 2 functions:

### `ruMAKE`

  - takes quantified tables from FIJI and combines them into a table for
    analysis

### `goFISH`

  - launches the gone mFISHing shiny app (**NOTE**: must use table
    generated via ruMake)

##### Plus original functions by Mark Cembrowski:

`loadData`, `plotCluster`, `plotGene`, `plotViolin`

You can also access function documentation via:

``` r
help(goFISH())

#or

?goFISH()
```   
