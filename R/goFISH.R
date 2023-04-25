#' Gone mFISHing
#' @author Kaitlin E Sullivan
#'
#' @description Launch a Shiny app for code-free analysis of mFISH data.
#'
#' @param mFISH An mFISH object
#' @param filter.by A vector of strings or single string value of a gene to filter the data by
#' @param k A numeric value denoting number of clusters to input
#'
#' @return Launch Gone mFISHing shiny app
#'
#' @import grDevices shiny Seurat shinyWidgets umap ggplot2 shinydashboard tidyr dplyr shinythemes shinybusy
#'
#' @export
goFISH <- function(mFISH, filter.by=NA, k=NA, norm="PAC"){
  #Kaitlin Sullivan November 2020
  #This shiny app allows the code-free scientist to browse and visualize analyzed
  #mFISH data in a user-friendly way


  #genes for filtering
  filgenes <- dplyr::select(mFISH@rawData, -id)
  filgenes <- names(filgenes)
  #inclusion of "none" variable - default - no fil
  filgenes <- c("None", filgenes)

  #raw data
  raw <- mFISH@rawData
  #meta data
  meta <- mFISH@metaData

  #remove warnings
  if(length(filter.by)==1){
    if(is.na(filter.by[1])){
      filter.by <- filgenes[1]
    }
  }

  if(is.na(k)){
    inclus <- 3
  }
  else{
    inclus <- k
  }



  #groupings
  grouping <- dplyr::select(mFISH@metaData, -c(X,Y,id))
  #throw error if numeric
  grouping <- names(grouping)
  if(length(grouping)==0){
    grouping <- c("None","cluster")
  }
  else{
    grouping <- c("None" ,grouping, "cluster")
  }

  ui <- shiny::fluidPage(
      #theme
      theme = shinythemes::shinytheme("cyborg"),
        #progress bar :meowparty:
        shinybusy::add_busy_gif(
          src = "https://emojis.slackmojis.com/emojis/images/1563480763/5999/meow_party.gif?1563480763",
          height = 200, width = 200,
          timeout = 10,
          position = "full-page"
          ),

            # Title of this page
            titlePanel("Gone mFISHing"),
      h5("1. Select analysis settings"),

########## BOTTOM BAR

            #Top bar with initial preprocessing

                  shiny::fluidRow(

                      #column 1 = filtering
                      shiny::column( width = 6,
                        wellPanel( style="padding: 5px;",
                        #sidebar heading number 2 with info on clustering
                        h6("Preprocess Data"),
                        ###INPUTS
                        #filter by gene
                        div(style="padding: 0px;",
                          selectInput(
                          "mg",
                          "Filter by:",
                          choices = filgenes,
                          selected = filter.by,
                          multiple = TRUE
                        )),

                        #threshold for filtering
                        div(style="padding: 0px;",
                          sliderInput(
                          "filter",
                          "Filter Threshold:",
                          value = 0.1,
                          min = 0,
                          max = 2,
                          step = 0.1
                        )),

                        #how many pcs?
                        div(style="padding: 0px;",
                            sliderInput(
                          "npcs",
                          "Number of Principle Components to use:",
                          min = 2,
                          max = length(filgenes)-1,
                          value = (length(filgenes)/2)-1,
                          step = 1
                        ))
                      ),
                      #row 3
                      checkboxInput(
                        "out",
                        "Remove outliers?",
                        value = F
                      )
                    ),

                    #column 3 = umap settings
                    column(width = 6,
                      wellPanel(style="padding: 5px;",
                      h6("Dimensionality Reduction"),
                      #metric
                      div(style="padding: 0px;",
                          selectInput(
                            "metric",
                            "UMAP Distance Metric:",
                            choices = c('manhattan', 'euclidean'),
                            selected = 'manhattan'
                      )),
                      #NN
                      div(style="padding: 0px;",
                        sliderInput(
                        "nn",
                        "UMAP Nearest Neighbours",
                        min = 4,
                        max = 40,
                        value = 15,
                        step = 1
                      )),

                      #mindist?
                      div(style="padding: 0px;",
                        sliderInput(
                        "mindist",
                        "UMAP Minimum Distance:",
                        min = 0.05,
                        max = 0.5,
                        value = 0.1,
                        step = 0.05
                      ))
                    )
                  )
                ),
                br(),
               fluidRow(
                 column(
                  5, br()
                 ),
                 column(
                   3,
                   shiny::downloadButton(
                     "obj",
                     "Download Object"
                   )
                 ),
                 column(
                   2, br()
                 )
                ),
#### RAW GENE OUTPUTS
                #Raw gene data
                shiny::fluidRow(
                  h5("2. Visualize raw gene expression"),
                  shiny::sidebarLayout(
                    #editing gene selection
                    shiny::sidebarPanel(
                      width = 2,
                      h6("Raw Expression"),
                      shiny::uiOutput("geneIn"),
                      br(),
                      shiny::checkboxInput("flipxS", "Flip X Axis",
                                           value = FALSE),
                      shiny::checkboxInput("flipyS", "Flip Y Axis",
                                           value = FALSE),
                      shiny::checkboxInput("rotateS", "Rotate 90 degrees",
                                           value = FALSE)
                    ),

                    #RAW DATA PANEL
                    shiny::mainPanel(
                      #shiny::fluidRow(
                        column(
                          width=4,
                          #h3("Native Tissue"), br(),
                          shiny::plotOutput("rawSpace"),
                          br(),
                          shiny::downloadButton(
                            "rs",
                            "Download EPS"
                          )
                        ),
                        column(
                          width=4,
                          #h3("UMAP Space"), br(),
                          shiny::plotOutput("rawUMAP"),
                          br(),
                          shiny::downloadButton(
                            "ru",
                            "Download EPS"
                          )
                        ),
                        column(
                          width=4,
                          #h3("Gene Boxplot"), br(),
                          shiny::plotOutput("rawBP"),
                          br(),
                          shiny::downloadButton(
                            "rbp",
                            "Download EPS"
                          )
                        )
                      )
                    )
                  ), br(),
#CLUSTERED DATA PANEL
                shiny::fluidRow(
                  h5("3. Visualize clustered data"),
                  shiny::sidebarLayout(
                    shiny::sidebarPanel(
                      width=2,
                      h6("Clustered Data"),
                      #nclus
                      sliderInput(
                        "nclus",
                        "Number of Clusters",
                        min = 1,
                        max = 15,
                        value = inclus,
                        step = 1
                      ), br(),
                      #NEW ADDITION
                      shiny::radioButtons("groups",
                                                "Group Plots by Metadata:",
                                                choices=grouping,
                                          selected = grouping[1])
                    ),
                    shiny::mainPanel(
                      #shiny::fluidRow(
                        column(
                          width=4,
                          #h3("Native Tissue"), br(),
                          shiny::plotOutput("clusSpace"),
                          br(),
                          shiny::downloadButton(
                            "cs",
                            "Download EPS"
                          )
                        ),
                        column(
                          width=4,
                          #h3("UMAP Space"), br(),
                          shiny::plotOutput("clusUMAP"),
                          br(),
                          shiny::downloadButton(
                            "cu",
                            "Download EPS"
                          )
                        ),
                        column(
                          width=4,
                          #h3("Cluster Boxplot"), br(),
                          shiny::plotOutput("clusBP"),
                          br(),
                          shiny::downloadButton(
                            "cbp",
                            "Download EPS"
                          )
                        )
                      )
                    )
                  )
                )


########## SERVER ###########
  ## Define server logic required to plot
  server <- function(input, output){


#REACTIVE MISC
#reactive gene name list
    mygenes <- shiny::reactive({
      mygenes <- filgenes[-1]
      if(input$mg[1] %in% mygenes){
        colNum <- match(input$mg, mygenes)
        mygenes <- mygenes[-colNum]
      }
      mygenes
    })

#select genes from user id dataset
    output$geneIn <- shiny::renderUI({
      shiny::selectInput('geneNames', 'Select A Gene...', mygenes())
    })

#reactive attributes list
     attribs <- shiny::reactive({
       attribs <- list(filter.by = input$mg, thresh = input$filter,
                      umap_nn = input$nn, umap_mindist = input$mindist,
                      umap_metric = input$metric, hclust_k = input$nclus,
                      hclust_metric = 'manhattan', pca = pca(),
                      npc = input$npcs, umap = mu(), cluster = mc())

       if(input$out){
         attribs$remove.outliers <- c(1, length(mygenes()))
       }

       attribs
     })

#reactive metadata for object building
     metaReact <- shiny::reactive({
       #add clusters
       cc <- clusDat()
       metaReact <- dplyr::mutate(meta, cluster = cc$cluster)

       #create the fil variable
       fils <- filIds()
       fils <- dplyr::mutate(fils, fil = T)
       others <- dplyr::filter(raw, !(id %in% fils$id))
       others <- dplyr::select(others, id)
       others <- dplyr::mutate(others, fil = F)

       #bind
       b <- rbind(fils, others)
       print("Updating metadata...")
       b <- dplyr::arrange(b, id)

       #add fil
       metaReact <- dplyr::mutate(meta, fil = b$fil)

       metaReact
     })


#####NEW: USER INPUT TO RUN
      ###DATA FILTERING
      #filtering user input
      mf <- shiny::reactive({
        print("begin filtering")

        mf <- raw

        #for loop filtering out all genes
        if(input$mg[1] != "None"){
          l <- length(input$mg)
          for(i in 1:l){
            mf <- dplyr::filter(mf, !!rlang::sym(input$mg[i]) > input$filter)
            mf <- dplyr::select(mf, -(!!rlang::sym(input$mg[i])))
          }
        }


        #mf <- RUHi::ruFilter(mfish, threshold=input$filter,
                             #filter.by = input$mg)
        print("filtering completed")
        mf
      })

      ###DATA PREPROCESSING
      #remove outliers
      mp <- shiny::reactive({
        print("begin preprocessing")
        #save dfs
        mp <- mf()
        ids <- mp$id
        mp <- dplyr::select(mp, -id)

        #normalize
        if(norm == "PAC"){
          mp <- sweep(mp, 1,apply(mp, 1, sum), "/")
          mp <- mp*(100)
        }
        if(norm !="PAC"){
          nms <- length(names(mp))
          nmslist <- names(mp)
          for(i in 1:nms){
            curmax <- max(mp[,i])
            mp <- dplyr::mutate(mp, !!nmslist[i] := (!!rlang::sym(nmslist[i])/curmax)*100)
          }
        }


        #remove nas
        mp <- dplyr::mutate(mp, id=ids)
        mp <- na.omit(mp)


        if(input$out){
          #resave ids
          ids <- mp$id
          mp <- dplyr::select(mp, -id)

          #find cells with number of features outside of threshold
          prepro <- dplyr::mutate(mp, nfts = rowSums(mp>0))

          #bring back the ids for filtering
          prepro <- dplyr::mutate(prepro, id=ids)

          #low/high
          prepro <- dplyr::filter(prepro, nfts>0)
          prepro <- dplyr::filter(prepro, nfts<length(mygenes()))

          #remove labs
          prepro <- dplyr::select(prepro, -nfts)
          mp <- prepro
        }
        print("preprocessing completed")

        #mp <- RUHi::ruProcess(prepro, remove.outliers = input$out,
                              #outlier.thresh = c(1, length(mygenes())))


        mp
      })

######DIM REDUCTION
      #RUN AND SAVE A PCA
      pca <- shiny::reactive({
        print("begin PCA")
        df <- dplyr::select(mp(), -id)
        p <- prcomp(df, center=T, scale=T)
        pca <- p$x
        print("PCA completed")

        pca
      })


      ###UMAP
      #run umap structure
      mu <- shiny::reactive({
        print("begin UMAP")
        df <- pca()
        df <- df[,1:input$npcs]

        config <- umap::umap.defaults
        config$n_neighbors <- input$nn
        config$min_dist <- input$mindist
        config$metric <- input$metric

        mu <- umap::umap(df, config = config)

        mu <- mu$layout

        #mu <- RUHi::ruUMAP(pca, metric = input$metric, nn = input$nn,
                           #min.dist = input$mindist, npc = input$npcs)
        print("UMAP completed")
        mu
      })

      ###DATA CLUSTERING
      #run hclust
      mc <- shiny::reactive({
        print("begin clustering")

        df <- pca()
        df <- df[,1:input$npcs]

        hc <- hclust(d=dist(df), method="ward.D2")
        clus <- cutree(hc, k=input$nclus)

        mc <- as.factor(clus)

        #mc <- RUHi::ruCluster(umap, k=input$nclus, npc = input$npcs)
        print("clustering completed")
        mc
      })

#########PLOT OUTPUT

      ###GRAPHING DATAFRAMES

      #SAVE FILTERED IDS
      filIds <- shiny::reactive({
        filIds <- dplyr::select(mp(), id)
        filIds
      })

      #SAVE FILTERED COORDS
      filCoord <- shiny::reactive(({
        df <- mp()
        filCoord <- dplyr::filter(meta, id %in% df$id)
        filCoord <- dplyr::mutate(filCoord, cluster = mc())

        filCoord
      }))

      #SAVE CLUSTERS FOR METADATA
      clusDat <- shiny::reactive({
        #save filtered data
        inid <- filIds()
        inid <- dplyr::mutate(inid, cluster=mc())
        #save full data
        outid <- dplyr::filter(meta, !id %in% inid$id)
        outid <- dplyr::mutate(outid, cluster=NA)
        outid <- dplyr::select(outid, c(id, cluster))

        #bind together
        clusDat <- rbind(inid, outid)
        clusDat <- dplyr::arrange(clusDat, id)

        #return
        clusDat
      })

      #SPATIAL COORDS FOR FILTERED DATA
      #wide
      gWide <- shiny::reactive({
        df <- mp()
        md <- filCoord()
        um <- mu()

        #add metadata to df
        df <- dplyr::mutate(mp(), UMAP_1 = um[,1],
                            UMAP_2 = um[,2], cluster = md$cluster,
                            X = md$X, Y = md$Y)

        #add other factorial gorupings
        # if(!is.na(grouping)){
        #   for(i in 1:length(grouping)){
        #     #save the index of column
        #     ci <- grep(grouping[i], colnames(meta))
        #     #save varaible
        #     df <- dplyr::mutate(df, !!grouping[i] := meta[,ci])
        #   }
        # }

        gWide <- df

        gWide

      })

      #long (for violins)
      gLong <- shiny::reactive({
        wide <- gWide()

        gLong <- tidyr::pivot_longer(wide, cols = mygenes(),
                                     names_to = "Gene",
                                     values_to = "Expression")

        gLong
      })


#SPATIAL
  #RAW GENE
    sgplot <- shiny::reactive({

      sgplot <- ggplot2::ggplot(gWide(), aes_string(x='X', y='Y', colour=input$geneNames))+
        geom_point(size=0.6)+
        Seurat::DarkTheme()+
        scale_colour_gradientn(colors=c("cyan", "red"))+
        labs(title=paste("Spatial Location of ", input$geneNames, " Expression",
                         sep=""),
             subtitle = 'Use: plotSpace() with colour.by="Gene"')

      #print(head(dplyr::select(gWide(), !!rlang::sym(input$geneIn))))


      if(input$flipxS){
        sgplot <- sgplot + scale_x_reverse()
      }
      if(input$flipyS){
        sgplot <- sgplot + scale_y_reverse()
      }
      if(input$rotateS){
        sgplot <- sgplot + coord_flip()
      }

      if(input$groups != "None"){
        sgplot <- sgplot + facet_wrap(stats::as.formula(paste("~", input$groups, sep = "")))
      }

      sgplot
    })

#:meowparty:
    output$rawSpace <- shiny::renderPlot({
      shinybusy::play_gif()
      rawSpace <- sgplot()
      shinybusy::update_busy_bar(100)
      shinybusy::stop_gif()
      rawSpace
    })

##CLUSTERED
    scplot <- shiny::reactive({

      scplot <- ggplot2::ggplot(gWide(), aes(x=X, y=Y, colour=cluster))+
        geom_point(data=meta, colour='grey', size=0.6)+
        geom_point(size=0.6)+
        Seurat::DarkTheme()+
        labs(title="Spatial Location of Clusters",
             subtitle = 'Use: plotSpace()')

      #debug
      if(input$groups != "None"){
        scplot <- scplot +
          facet_wrap(~input$groups)
      }

      if(input$flipxS){
        scplot <- scplot + scale_x_reverse()
      }
      if(input$flipyS){
        scplot <- scplot + scale_y_reverse()
      }
      if(input$rotateS){
        scplot <- scplot + coord_flip()
      }

      if(input$groups != "None"){
        scplot <- scplot + facet_wrap(stats::as.formula(paste("~", input$groups, sep = "")))
      }

      scplot
    })
#:meowparty:
    output$clusSpace <- shiny::renderPlot({
      shinybusy::play_gif()
      clusSpace <- scplot()
      shinybusy::update_busy_bar(100)
      shinybusy::stop_gif()
      clusSpace
    })

#DIM REDUCTION
    #RAW GENE
    rumap <- shiny::reactive({
      rumap <- ggplot2::ggplot(gWide(), aes_string(x='UMAP_1', y='UMAP_2', colour=input$geneNames))+
        geom_point(size=0.6)+
        Seurat::DarkTheme()+
        scale_colour_gradientn(colors=c("cyan", "red"))+
        labs(title=paste("UMAP with ", input$geneNames, " Expression",
                         sep=""),
             subtitle = 'Use: plotDim() with colour.by="Gene"')


      #rumap <- RUHi::plotDim(mc(), colour.by = input$geneIn)+
        #labs(title = paste(input$geneIn))
      rumap
    })

    #:meowparty:
    output$rawUMAP <- shiny::renderPlot({
      shinybusy::play_gif()
      rawUMAP <- rumap()
      shinybusy::update_busy_bar(100)
      shinybusy::stop_gif()
      rawUMAP
    })

  #CLUSTERED
    cumap <- shiny::reactive({
      cumap <- ggplot2::ggplot(gWide(), aes(x=UMAP_1, y=UMAP_2, colour=cluster))+
        geom_point(size=0.6)+
        Seurat::DarkTheme()+
        labs(title="UMAP with Clusters",
             subtitle = 'Use: plotDim()')
      cumap
    })

    #:meowparty:
    output$clusUMAP <- shiny::renderPlot({
      shinybusy::play_gif()
      clusUMAP <- cumap()
      shinybusy::update_busy_bar(100)
      shinybusy::stop_gif()
      clusUMAP
    })

  #BOX PLOTS
    #RAW GENE
    rawbox <- shiny::reactive({
      rawbox <- ggplot2::ggplot(gWide(), aes_string(x='cluster', y=input$geneNames, fill='cluster'))+
        geom_boxplot(outlier.shape = NA)+
        Seurat::DarkTheme()+
        labs(y="Expression", title = input$geneNames,
             subtitle = 'Use: geneBoxPlot()')
      rawbox
    })

    #:meowparty:
    output$rawBP <- shiny::renderPlot({
      shinybusy::play_gif()
      rawBP <- rawbox()
      shinybusy::update_busy_bar(100)
      shinybusy::stop_gif()
      rawBP
    })


    #CLUSTERED
    clusbox <- shiny::reactive({
      clusbox <- ggplot2::ggplot(gLong(), aes(x=Gene, y=Expression, fill=Gene))+
        geom_boxplot(outlier.shape = NA)+
        Seurat::DarkTheme()+
        facet_wrap(~cluster)+
        labs(title = 'Gene Expression per Cluster',
             subtitle = 'Use: clusterBoxPlot()')+
        scale_fill_manual(values = rainbow(n=length(mygenes())))+
        theme(axis.text.x=element_blank(),
              axis.ticks.x=element_blank())
      clusbox
    })

    #:meowparty:
    output$clusBP <- shiny::renderPlot({
      shinybusy::play_gif()
      clusBP <- clusbox()
      shinybusy::update_busy_bar(100)
      shinybusy::stop_gif()
      clusBP
    })




#####DOWNLOAD BUTTONS

    #OBJECT
    myObj <- shiny::reactive({
      myObj <- new(Class = "mFISH", rawData = raw, filteredData = mp(),
                   metaData = metaReact(), attributes = attribs())
      myObj
    })

    output$obj<-downloadHandler(
      filename = function() {
        paste('goFISH', '.rds', sep='')
      },
      content=function(file){
        saveRDS(myObj(), file)
      })

    # raw space plot
    output$rs<-downloadHandler(
      filename = function() {
        paste(input$geneNames ,'Spatial', '.eps', sep='')
      },
      content=function(file){
        ggsave(file, sgplot())
      },
      contentType = 'image/eps')

    # raw umap plot
    output$ru<-downloadHandler(
      filename = function() {
        paste(input$geneNames, 'UMAP', '.eps', sep='')
      },
      content=function(file){
        ggsave(file, rumap())
      },
      contentType = 'image/eps')

    # raw box blot
    output$rbp<-downloadHandler(
      filename = function() {
        paste(input$geneNames, 'BoxPlot', '.eps', sep='')
      },
      content=function(file){
        ggsave(file, rawbox())
      },
      contentType = 'image/eps')

    # cluster spatial
    output$cs<-downloadHandler(
      filename = function() {
        paste('clusterSpatial', '.eps', sep='')
      },
      content=function(file){
        ggsave(file, scplot())
      },
      contentType = 'image/eps')

    # cluster umap
    output$cu<-downloadHandler(
      filename = function() {
        paste('clusterUMAP', '.eps', sep='')
      },
      content=function(file){
        ggsave(file, cumap())
      },
      contentType = 'image/eps')

    # total cluster bp
    output$cbp<-downloadHandler(
      filename = function() {
        paste('clusterBoxPlot', '.eps', sep='')
      },
      content=function(file){
        ggsave(file, clusbox())
      },
      contentType = 'image/eps')

  }

  # Run the application
  shinyApp(ui = ui, server = server)

}

