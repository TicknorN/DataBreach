##
# Graphs.R - Code to plot each of our graphs
##

getStateTotal <- function(state){ #Author: Shaun
  info <- getStateInfo(state)
  total <- nrow(info)
  return(total)
}

getSTYr <- function(state,yrs,cats,bp=FALSE){ #Author: Nigel
  num <- nrow(breachdata[which(as.character(breachdata$State)==state&breachdata$Year %in% yrs&breachdata$Category %in% cats),])
  if(bp){
    num <- (num/popdata$population[which(popdata$state==as.character(state))])[1]
  }
  return(num)
}

stateFromLower <-function(x) { #This was found online
  st.codes<-data.frame(
    state=as.factor(c("AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA",
                      "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME",
                      "MI", "MN", "MO", "MS",  "MT", "NC", "ND", "NE", "NH", "NJ", "NM",
                      "NV", "NY", "OH", "OK", "OR", "PA", "PR", "RI", "SC", "SD", "TN",
                      "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY")),
    full=as.factor(c("alaska","alabama","arkansas","arizona","california","colorado",
                     "connecticut","district of columbia","delaware","florida","georgia",
                     "hawaii","iowa","idaho","illinois","indiana","kansas","kentucky",
                     "louisiana","massachusetts","maryland","maine","michigan","minnesota",
                     "missouri","mississippi","montana","north carolina","north dakota",
                     "nebraska","new hampshire","new jersey","new mexico","nevada",
                     "new york","ohio","oklahoma","oregon","pennsylvania","puerto rico",
                     "rhode island","south carolina","south dakota","tennessee","texas",
                     "utah","virginia","vermont","washington","wisconsin",
                     "west virginia","wyoming"))
  )
  st.x<-data.frame(state=x)
  refac.x<-st.codes$full[match(st.x$state,st.codes$state)]
  return(refac.x) #Returns the state name of the ABB
}

#This is the opposite of %in%. Pulled from Online.
'%out%' <- function(x,y)!('%in%'(x,y))


getPopCats <- function(breachdata){ #Author: Nigel Ticknor
  states = c("AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA",
             "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME",
             "MI", "MN", "MO", "MS",  "MT", "NC", "ND", "NE", "NH", "NJ", "NM",
             "NV", "NY", "OH", "OK", "OR", "PA", "PR", "RI", "SC", "SD", "TN",
             "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY")
  test <- data.frame(state=character(0),category=character(0))
  for(s in unique(breachdata$State)){
    v <- 0
    m <- ''
    for(c in unique(breachdata$Category))
    {
      t <- getCatInState(c,s)
      if(t>v){
        v <- t
        m <- c
      }
    }
    test <- rbind(test,data.frame(state=s,category=m))
  }
  for(ss in states[which(states %out% test$state)]){
    test <- rbind(test,data.frame(state=ss,category='None'))
  }
  return(test) #Returns most popular category in each state
}

getCatInState <- function(cat,state) #Author: Nigel Ticknor
{
  length(which(breachdata$Category[which(breachdata$State==state)]==cat)) #Returns num(breaches) of Category cat in state
}

drawHeatMap <- function(yrs,cats,bp=FALSE){ #Author: Shaun; Modified for Shiny by: Nigel
  #Draws a heatmap of most breaches per state
  
  library(maps)
  library(ggplot2)
  library(ggthemes)
  
  #Generate data.frame
  statesa = c("AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA",
             "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME",
             "MI", "MN", "MO", "MS",  "MT", "NC", "ND", "NE", "NH", "NJ", "NM",
             "NV", "NY", "OH", "OK", "OR", "PA", "PR", "RI", "SC", "SD", "TN",
             "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY")
  stateTotals <-  data.frame(statesa)
  stateTotals$region<-stateFromLower(stateTotals$statesa)
  stateTotals$total <- sapply(stateTotals$statesa, getSTYr,yrs,cats,bp)
  us_state_map <- map_data('state')
  us_state_map <- merge(us_state_map, stateTotals, by='region', all=T)
  
  #Calculate max color value
  ct <- max(stateTotals$total[which(stateTotals$statesa %out% c('DC','US','AK','HI','PR'))])
  
  # Generate Map
  map <- (qplot(long, lat, data=us_state_map, geom="polygon", group=group, fill=total,asp=.1)
          + geom_path()
          + theme_bw()
          + labs(title="California Has Most Breaches",
                              subtitle = "Though East Coast holds most breaches per-capita", x="Longitude", y="Latitude", fill="Total Breaches")
          + scale_fill_gradient2(low = "white", high = "#0b8a00",limits=c(0,ct))
            +theme_solarized_2(base_size = 12, light = FALSE))
  
  return(map) #Returns the map

}



drawCatMap <- function(yrs){ #Author: Shaun
  #Generate the table of categories/state
  PopCats <- getPopCats(breachdata[which(breachdata$Year %in% yrs),])
  PopCats$region<-stateFromLower(PopCats$state)
  us_state_map <- map_data('state')
  us_state_map <- merge(us_state_map, PopCats, by='region', all=T)
  
 #Draw the map
  map2 <- (qplot(long, lat, data=us_state_map, geom="polygon", group=group, fill=as.character(category))
          + geom_path()
          + theme_bw() 
          + labs(title="Breach Categories in the US", x="Longitude", y="Latitude", fill = "Category")
          + theme(legend.position="right", legend.direction="vertical")
          + theme_solarized_2(base_size = 12, light = FALSE))
          map2 <- map2 + scale_fill_manual(values = c("Banking/Credit/Financial" = "#523178", "Business" = "#0b8a00", "Educational" = "yellow","Medical/Healthcare"="red3","Government/Military"="blue","None"="grey"))


  return(map2) #Returns the category map
}


drawLoess <- function(){ #Author: Paul
  numandyear <- data.frame(sapply(2005:2016, function(x){ return(nrow(getbyYear(x)))}), 2005:2016)
  colnames(numandyear) <- c("NumberBreaches", "Years")
  lpt <- (ggplot(data = numandyear) + geom_smooth(mapping = aes(x=Years, y =NumberBreaches), col="#0b8a00")+ labs(x="Years", y="Number of Companies Breached", title="Number Of Data Breaches On A Steady Climb"))
  return(lpt) #Returns Loess graph
}
drawTree <- function(){ #Author: Nigel
  slices <- c(length(which(breachdata$Type == "Electronic")), length(which(breachdata$Type == "Paper Data")))
  percs <- c(slices[1]/sum(slices),slices[2]/sum(slices))
  lbls = c(paste("Electronic Data ",signif(percs[1],4)*100,'%'), paste("Paper Data ",signif(percs[2],4)*100,'%'))
  tc <- data.frame(Type=lbls,Size=slices,Color=c(1,2))
  treemap(tc,c('Type'),c('Size'),vColor = 'Color',type='manual',palette=c('#0b8a00','grey'),position.legend = 'none',title='Electronic Data Is 6x More Likely To Be Stolen',fontsize.labels = 16)
}

#For line graph of months
colors <- c(
  "black",
  "red",
  "blue",
  "#b28e00",
  "purple",
  "deeppink",
  "darkorange2",
  "darkmagenta",
  "saddlebrown",
  "springgreen",
  "dodgerblue",
  "#0b8a00")
genMonthsGraph <- function(year){ #Author: Paul
  datad <- getbyYear(year)
  datad$Number <- sapply(datad$Number, as.character)
  datad$Number <- sapply(datad$Number, as.numeric)
  shy <- sapply(1:12, function(x){ 
    return(length(which(datad$Month == x)))
  })
  if(year == 2005){
    plot(x = 1:12, y=shy, type="l", ylim=c(0, 150), col=colors[1], main="Breaches per Month", lwd=2, xlab="Months",ylab="Number of Breaches")
  }else{
    lines(x=1:12, y=shy, type="l", ylim=c(0, 150),col=colors[(year-2005)+1], lwd=2)
  }
}
drawMonths <- function(){ #Author: Paul
  options(warn=-1)
  sapply(2005:2016, genMonthsGraph)
  legend(x="topright", legend=c("2005","2006","2007", "2008", "2009", "2010","2011","2012","2013","2014","2015","2016"), lwd=1, lty=c(1,1),col=colors, y.intersp=.75)
} 
drawBar <- function(){ #Author: Shaun
  graph <- ggplot(breachdata, aes(Category, fill = Category))
  graph + geom_bar() + 
    scale_x_discrete(labels = c("Banking/Credit/Financial" = "Banking", "Government/Military" = "Government", "Medical/Healthcare" = "Medical")) +
    scale_fill_manual(values = c("Banking/Credit/Financial" = "#523178", "Business" = "#0b8a00", "Educational" = "yellow","Medical/Healthcare"="red3","Government/Military"="blue","None"="grey")) +
    guides(fill = FALSE) +
    labs(title = "Banks Rarely Breached",subtitle='But businesses and hospitals need to watch out', y = "Number of Breaches", x = "Category of Institution")
}
drawBar2 <- function(){
  graph <- ggplot(breachdata, aes(Category))
  graph + geom_bar(aes(fill = Type), position = "dodge") + 
    scale_x_discrete(labels = c("Banking/Credit/Financial" = "Banking", "Government/Military" = "Government", "Medical/Healthcare" = "Medical")) +
   scale_fill_manual(values = c('Electronic'='springgreen4','Paper Data' = 'orangered')) +
    labs(title = "Banks Rarely Breached",subtitle='But businesses and hospitals need to watch out', y = "Number of Breaches", x = "Category of Institution")
}
