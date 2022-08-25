<!-- README.md is generated from README.Rmd. Please edit that file -->

# RUHi ![](https://emojis.slackmojis.com/emojis/images/1563480763/5999/meow_party.gif?1563480763)

#### R-based Utilities for HiPlex

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/RUHi)](https://CRAN.R-project.org/package=RUHi)
<!-- badges: end -->

The goal of RUHi is to analyze and visualize mFISH! Stay tuned for
exciting features such as *integration with scRNA-seq data*!

## Table of Contents:

1.  [Installation](#installation)  
2.  [Tutorial](#tutorial)
3.  [Function List](#functions)

## Installation

This repo contains the most recent version of RUHi.  
You can install RUHi from this github repo with:

``` r
devtools::install_github("cembrowskilab/RUHi")
```

**IF YOU RECIEVE THIS ERROR:**  
``` r
Using github PAT from envvar GITHUB_PAT
Error: Failed to install 'unknown package' from GitHub:
  HTTP error 401.
  Bad credentials
```  
**USE:**  
``` r
Sys.unsetenv("GITHUB_PAT")
devtools::install_github("cembrowskilab/RUHi")
```
  
  
See [@kaitsull](https://github.com/kaitsull/RUHi)'s repo for the developer's version.

Once installed, load the package normally:

``` r
library(RUHi)
```

If you are updating to a newer version of the repo:

``` r
#remove old version
remove.packages(RUHi)  

#reinstall from here or from the kaitsull/RUHi github  
devtools::install_github("cembrowskilab/RUHi")  
```

## Tutorial

### 1. Setting up

We will be using a single section dataset from [our eLife
paper](https://elifesciences.org/articles/68967)  
Raw files used for this analysis are directly from FIJI Quantification
and can be found in [this
repo](https://github.com/kaitsull/RUHi/tree/master/inst/extdata).

``` r
# Kaitlin Sullivan 2022

#after following the installation instructions...
#load package
library(RUHi)
#> Registered S3 method overwritten by 'spatstat.geom':
#>   method     from
#>   print.boxx cli

#set the working directory using absolute path or here() function
#or simply provide full path in function

#check out what a function does via:
#   ?ruMake   (in the console)
```

### 2. Read and combine files

We will use `ruRead()` to read multiple FIJI Quantification files into a
single data frame. Then we can optionally use `ruCombine()` to
concatenate multiple data frames from seperate experiments.

``` r
####### STEP 1a: READING FILES FROM FIJI QUANTIFICATION #########
#here we are using an example dataset from our 2021 eLife paper - https://elifesciences.org/articles/68967

mydata <- ruRead("~/RUHi/inst/extdata", region = "intermediate", anum = "123456", section = "1")
#> [1] "The following files will be quantified:"
#>  [1] "R1_488_Cdh9.tif_registered.tif_rigid_and_nonlinear.tif_quantification.csv"   
#>  [2] "R1_550_Ctgf.tif_registered.tif_rigid_and_nonlinear.tif_quantification.csv"   
#>  [3] "R1_647_Slc17a6.tif_registered.tif_rigid_and_nonlinear.tif_quantification.csv"
#>  [4] "R1_750_Lxn.tif_registered.tif_rigid_and_nonlinear.tif_quantification.csv"    
#>  [5] "R2_488_Slc30a3.tif_registered.tif_rigid_and_nonlinear.tif_quantification.csv"
#>  [6] "R2_550_Gfra1.tif_registered.tif_rigid_and_nonlinear.tif_quantification.csv"  
#>  [7] "R2_647_Spon1.tif_registered.tif_rigid_and_nonlinear.tif_quantification.csv"  
#>  [8] "R2_750_Gnb4.tif_registered.tif_rigid_and_nonlinear.tif_quantification.csv"   
#>  [9] "R3_488_Nnat.tif_registered.tif_rigid_and_nonlinear.tif_quantification.csv"   
#> [10] "R3_550_Synpr.tif_registered.tif_rigid_and_nonlinear.tif_quantification.csv"  
#> [11] "R3_647_Pcp4.tif_registered.tif_rigid_and_nonlinear.tif_quantification.csv"   
#> [12] "R3_750_Slc17a7.tif_registered.tif_rigid_and_nonlinear.tif_quantification.csv"

#make sure all your genes are names correctly before continuing
#you should have columns named X,Y,id,region,section,anum and all of your genes
head(mydata)
#>         X     Y      Cdh9 Ctgf    Slc17a6       Lxn    Slc30a3     Gfra1
#> 1 637.872 6.908  1.867280    0  0.2326642 0.8173077  0.5831520 0.0000000
#> 2 648.738 3.233  3.167003    0  0.5762447 3.1670035  4.6052728 0.2881224
#> 3 683.589 4.922  3.603119    0  0.9213167 2.1788067  5.0274321 0.3349094
#> 4 725.680 3.766  8.688864    0 20.3719930 0.8985184 41.9436036 0.2987096
#> 5 732.072 6.676  2.607329    0 10.3302850 3.7658400 17.0887197 0.4829391
#> 6 798.757 3.855 11.003411    0  0.0000000 3.2553045  0.9298415 4.8038945
#>      Spon1      Gnb4      Nnat      Synpr        Pcp4   Slc17a7       region
#> 1 0.000000 0.5831520 0.1163321 0.00000000   0.0000000   0.00000 intermediate
#> 2 0.000000 1.4382693 0.0000000 0.00000000   2.8788811  11.51552 intermediate
#> 3 3.184799 1.5923993 0.4195846 0.08341139  23.2945270  36.19928 intermediate
#> 4 6.889438 0.2987096 0.0000000 0.00000000 110.5488291 126.72694 intermediate
#> 5 2.799962 0.7718887 0.6755722 0.67557215  49.1417696  52.23204 intermediate
#> 6 1.395622 0.0000000 0.4657801 0.00000000   0.9298415   0.00000 intermediate
#>     anum section id
#> 1 123456       1  1
#> 2 123456       1  2
#> 3 123456       1  3
#> 4 123456       1  4
#> 5 123456       1  5
#> 6 123456       1  6

#feel free to add extra metadata for your section at this point with dplyr::mutate()
```

``` r
####### STEP 2b: COMBINING MULTIPLE SECTIONS #######
#if you have multiple sections you can save multiple experiments as a data.frame using ruRead()
#to combine them use: 

combo <- ruCombine(c(data1, data2, data3))
```

### 3. Create an [mFISH Object](#mfish-objects)

``` r
######### STEP 3: CREATE YOUR OBJECT #########
#take your individual section or combined dataset and turn it into an mFISH object for analysis

myobj <- ruMake(mydata)
#> [1] "Creating object..."
```

### Run the Shiny App

``` r
######### STEP 4 VERSION A: "Auto-Analysis" SHINY APP ########
#for a quick analysis overview to get a feel for what variable values will work best, run the shiny app 
#you will have an option to save your object as a .RDS file, which you can later load into R and run further plotting, analysis, etc on

#you have optional time-saving arguments that can pre-select the filtering value and number of clusters prior to running the app

goFISH(myobj, filter.by = 'Slc17a7', k = 5)

#when you are happy with the way your analysis looks, press "Download Object"
#to read back in your saved .RDS file, simply use:
myobj <- readRDS(path/to/object)

#you can then skip straight to the plotting steps - or redo other steps if you want
```

### OR Manually Analyze

``` r
######### STEP 4 VERSION B: "Manual-Analysis" #########
#These steps happen automatically within the Shiny App
#doing them manually simply gives you more autonomy over the individual steps

### FILTERING
#here we filter for excitatory cells which are Slc17a7+
myobj <- ruFilter(myobj, filter.by = 'Slc17a7', threshold = 0.1)
#> [1] "Filtering data by Slc17a7 at threshold of 0.1..."
#> [1] "Updating metadata..."

### PREPROCESSING
#run normalization and PCA (with optional arg to remove autofluorescent cells)
myobj <- ruProcess(myobj)
#> [1] "Normalizing data..."
#> [1] "Running PCA..."
#> [1] "Updating metadata..."

### RUN UMAP
#populate attributes with UMAP for plotting
myobj <- ruUMAP(myobj)
#> Warning in if (suppressWarnings(is.na(mFISH@attributes$pca))) {: the condition
#> has length > 1 and only the first element will be used
#> [1] "Altering UMAP configurations..."
#> [1] "Running UMAP..."
#> [1] "Saving custom configuration..."

### CLUSTER 
#populate metaData with cluster column
myobj <- ruCluster(myobj, k = 5)
#> [1] "Clustering..."
```

#### Object storage

``` r
#you can continually re-run these functions until you get an analysis that you are happy with
#it is HIGHLY SUGGESTED you save your object, this way you can share your data and all of the parameters used to get there

#### SAVE VIA: saveRDS(path, myobj)
#### READ IN VIA: myobj <- readRDS(path)
```

### 5. Plotting

#### Geographic Space

``` r
######### STEP 4: PLOTTING #########

### GEOGRAPHIC SPACE with plotSpace()
#plot in space - automatically coloured by cluster
plotSpace(myobj)
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

``` r
#optional args to group by section, or other variable (eg cluster)
plotSpace(myobj, group.by = 'cluster')
```

<img src="man/figures/README-unnamed-chunk-6-2.png" width="100%" />

``` r
#plot in space but change to a gene or metadata value
plotSpace(myobj, colour.by = 'Ctgf', include.fil = F)
```

<img src="man/figures/README-unnamed-chunk-6-3.png" width="100%" />

``` r
#plot in space with separation by cluster (group.by is useful for viewing multiple sections as well)
plotSpace(myobj, group.by = 'cluster', colour.by = 'Ctgf')
```

<img src="man/figures/README-unnamed-chunk-6-4.png" width="100%" />

#### Dimensionally Reduced Space

``` r
### DIM REDUCED SPACE with plotDim()
#auto coloured by cluster
plotDim(myobj)
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />

``` r
#option to colour by gene/metadata 
plotDim(myobj, colour.by='Ctgf')
```

<img src="man/figures/README-unnamed-chunk-7-2.png" width="100%" />

#### Gene Expression Box Plots

``` r
### MARKER GENE BOX PLOTS

#Plot a gene's expression across clusters
geneBoxPlot(myobj, 'Ctgf')
```

<img src="man/figures/README-unnamed-chunk-8-1.png" width="100%" />

``` r
#Plot the gene expression profile of a specified cluster
clusterBoxPlot(myobj, clus='5')
```

<img src="man/figures/README-unnamed-chunk-8-2.png" width="100%" />

``` r
#or simply plot the gene expression for every cluster
clusterBoxPlot(myobj)
```

<img src="man/figures/README-unnamed-chunk-8-3.png" width="100%" />

## mFISH Objects

RUHi makes use of an `mFISH Object` that encapsulates the many stages of
one’s analysis for easy reproducibility.

The `mFISH Object` contains 4 main elements:  
- `@rawData`: *A data frame containing unfiltered non-normalized data*  
- `@filteredData`: *A data frame containing filtered and normalized
data*  
- `@metaData`: *A data frame containing metadata for each cell*  
- `@attributes`: *A list containing all of the analysis values utilized*

![](inst/extdata/mFISH.png)

Each core function within the package interacts with the elements of the
object so you don’t have to.  
However, if you wish to do more advanced analysis, you can access each
element by using the `@` accessor (eg: `object@metaData`). From there
you can subset like a regular `data.frame` or `list` with the `$`
accessor (eg: `object@attributes$pca`).

## Functions

Currently the package has **7 core functions**, **4 plotting
functions**, and a **Shiny App deployment function**:

## Core Functions

### `ruRead`

-   takes quantified tables from FIJI and combines them into a table for
    analysis
-   **NOTE:** if you do not specify region, section, anum, they will be
    filled with values `NA`. It is highly suggested to fill in these
    optional arguments with
    -   section = experiment number in quotations (eg: “4”)  
    -   region = region images (eg: “anterior”)  
    -   anum = animal number in quotations (eg: “123456”)

### `ruCombine`

-   takes multiple rounds from `ruRead()` and stitches them together
    with unique ids

### `ruMake`

-   creates an mFISH object from tables generated by `ruRead()` or
    `ruCombine()`
-   populates the `@rawData` and `@metaData` elements of the mFISH
    object  
-   **NOTE:** if you are reading in a pre-existing dataframe with gene
    expression data, these tables must include the metadata columns:
    X,Y,id,section,region,anum

### `ruFilter`

-   filter data by a gene at a certain threshold
    eg(`ruFilter(object, 'Slc17a7', 0.1)`)
-   populates the `@filteredData` element of the mFISH object

### `ruProcess`

-   normalize and run PCA
-   optional argument to remove outliers that are autofluorescent and
    therefore express every gene
    -   `remove.outliers = c(0,11)` would remove cells expressing no
        genes or expressing every gene (assuming 12 genes with one
        filtered out)  
-   alters the `@filteredData` element of the mFISH object

### `ruUMAP`

-   run a UMAP on the PCA (with option to select number of pcs and alter
    the hyperparameters of the UMAP)

### `ruCluster`

-   cluster the data via hierarchical clustering  
-   populates a cluster column within the `@metaData`

### `goFISH`

-   launches the gone mFISHing shiny app
-   App is best used for quickly looking through single sections as it
    gets slower computationally the larger your data is
-   (**NOTE**: must use object generated via ruMake)

## Plotting Functions

### `plotSpace`

-   plot an object in geographic space, coloured by any gene or metadata
    variable

### `plotDim`

-   plot an object in dimensionally reduced space, coloured by any gene
    or metadata variable

### `geneBoxPlot`

-   plot a boxplot of a given gene per cluster

### `clusterBoxPlot`

-   plot a boxplot of all the genes in a given cluster

##### Plus original functions by Mark Cembrowski:

`loadData`, `plotCluster`, `plotGene`, `plotViolin`

You can also access function documentation via:

``` r
help(goFISH())

#or

?goFISH()
```
