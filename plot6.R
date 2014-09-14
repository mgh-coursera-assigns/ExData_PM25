
## Conditional sourcing of the loading of the data sets.
##  Assuming that these two files are loaded into NEI and SCC
if(!isTRUE(exists("NEI")) | !isTRUE(exists("SCC")) | !isTRUE(exists("yrsInDataSet")))
    source("loadDataSets.R")

## Plot for 6th Question
## Compare emissions from motor vehicle sources in Baltimore City with emissions from motor vehicle 
##  sources in Los Angeles County, California (fips == "06037"). 
##  Which city has seen greater changes over time in motor vehicle emissions?

##sccVehicles <- SCC[grep('vehicle', SCC$SCC.Level.Two, ignore.case=TRUE),]
##sccVehicles <- sccVehicles[sccVehicles$Data.Category == 'Onroad', ]
sccVehicles <- SCC[SCC$Data.Category == 'Onroad', ]

idx <- 1
vecYears <- numeric(length(yrsInDataSet) * 2)
vecSumEmissions <- numeric(length(yrsInDataSet) * 2)
vecCity <- numeric(length(yrsInDataSet) * 2)

for(y in yrsInDataSet) {
    if(y %in% yrsOfInterest) {
        emissions <- subset(NEI, year == y & fips == '24510' & SCC %in% sccVehicles$SCC, select = c('Emissions'))
        vecYears[idx] <- y
        vecSumEmissions[idx] <- sum(emissions)
        vecCity[idx] <- 'Baltimore, MD'
        idx <- idx + 1
        
        emissions <- subset(NEI, year == y & fips == '06037' & SCC %in% sccVehicles$SCC, select = c('Emissions'))
        vecYears[idx] <- y
        vecSumEmissions[idx] <- sum(emissions)
        vecCity[idx] <- 'Los Angeles County, CA'
        idx <- idx + 1
    }
} 

dfVehiclesByYr <-  data.frame(vecYears, vecSumEmissions, vecCity)
library(ggplot2)

plot <- qplot(dfVehiclesByYr$vecYears, 
              dfVehiclesByYr$vecSumEmissions, 
              data = dfVehiclesByYr, 
              color = dfVehiclesByYr$vecCity, 
              geom = c("point", "smooth")) +
    geom_smooth() + theme_bw() +
    geom_point(size=6, alpha = I(.5)) +
    labs(x = 'Year') +
    labs(y = expression(PM[2.5] * ' Emissions')) +
    labs(title=expression('Cumulative PM'[2.5] * ' Vehicular Emissions in Baltimore and Los Angeles County')) +
    theme(axis.title=element_text(face='italic', size='14', color='forestgreen'), 
          legend.position='top', 
          plot.title=element_text(face='bold', size='20', color='midnightblue'), 
          legend.title=element_blank())

print(plot)


###
### Los Angeles County has seen an increate in cumulative PM2.5 vehicular emissions over the time period