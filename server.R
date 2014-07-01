library(shiny)
library(dplyr)
library(ggvis)
library(reshape)
library(rgdal)
library(rgeos)
library(maptools)
gpclibPermit()

load("C:/Users/Vladislav Pascal/Documents/a.RData")
# Define server logic required to summarize and view the selected dataset
shinyServer(function(..., session) {
	
	map<-readShapeSpatial("MDA_Adm1", repair=T)
	proj4string(map) <- CRS("+proj=longlat +datum=NAD27")
	#   map$NAME_1 <- as.character(a$NAME_1)
	#   map$NAME_1[a$NAME_1 == "H??ncesti"] <- "Hincesti"
	
	all_values <- function(x) {
	  if(is.null(x)) return(NULL)
	  paste0(names(x), ": ", format(x), collapse = "<br />")
	}
	
	options(stringsAsFactors = FALSE)
	data <- read.csv("report_2014-06-26.csv", sep="\t",header=TRUE)
	trim <- function (x) gsub("^\\s+|\\s+$+|\\?", "", x)
	
	replace<-function (x) gsub("unic", "unique", x)
	data<-as.data.frame(apply(data,MARGIN=2,FUN=trim))
	data<-as.data.frame(apply(data,MARGIN=2,FUN=replace))
	data<-data[which(data$Question !="Upload other documents" & data$Question !="Upload photos"),]
	data<-data[which(data$Name !="Biblioteca Publica de Drept" & data$Name !="Biblioteca Nationala a Republicii Moldova"),]
	data<-data[data$Raion != "Chisinau",]
	
	# users
	data$Question[data$Question=="Number of all new unique users to library"]<-"Number of all unique users to library"
	pattern <- grep("Number of all unique users to library", data$Question, useBytes = T)
	users<-data[pattern,]
	users$Answer<-as.numeric(users$Answer)
	users<-users%>% group_by(Date) %>% summarise(Answer = sum(Answer,na.rm = TRUE))
	users$Date<-as.Date(users$Date)
	
	# Gender
	pattern<-agrep("Total number of registered/unic users of each gender",x=data$Question,useBytes=T)
	gender<-data[pattern,]
	gender$Answer<-as.numeric(gender$Answer)
	gender<-gender%>% group_by(Date,Question) %>% summarise(Answer = sum(Answer,na.rm = TRUE))
	
	gender<-cast(gender, Date~Question)
	gender$Total<-gender[,2]+gender[,3]
	gender$Percent_Female<-gender[,2]/gender[,4]*100
	gender$Percent_Male<-gender[,3]/gender[,4]*100
	
  gender<-gender[,c("Date","Percent_Female","Percent_Male")] 
	gender<-as.data.frame(gender)
	gender<-melt(gender,"Date")
	gender$Date<-as.Date(gender$Date)   
	
	pattern<-agrep("year",x=data$Question,useBytes=T)
	data_age<-data[pattern,]
	data_age$Answer<-as.numeric(data_age$Answer)
	data_age<-cast(data_age,Date~Question, sum,na.rm=T)
	data_age$Total<-data_age[,2]+data_age[,3]+data_age[,4]+data_age[,5]
	data_age$Percent_0_16<-data_age[,2]/data_age$Total*100
	data_age$Percent_17_30<-data_age[,3]/data_age$Total*100
	data_age$Percent_31_57<-data_age[,4]/data_age$Total*100
	data_age$Percent_58_above<-data_age[,5]/data_age$Total*100
	data_age<-data_age[,c("Date","Percent_0_16","Percent_17_30","Percent_31_57","Percent_58_above")]
	names(data_age)<-c("Date","% 0-16","% 17-30","% 31-57","% 58-above")
	data_age<-as.data.frame(data_age)
	data_age<-melt(data_age,id=c("Date"))
	data_age$Date<-as.Date(data_age$Date)
  
	pattern<-grep("physical visits", data$Question,useBytes=T)
	visits<-data[pattern,]
	visits$Question[visits$Question=="Total number of physical visits in May"]<-"Total number of physical visits"
	visits$Question[visits$Question=="Total number of physical visits in June"]<-"Total number of physical visits"
	visits$Question[visits$Question=="Total number of physical visits during this month"]<-"Total number of physical visits"
	visits$Answer<-as.numeric(visits$Answer)
	visits<-cast(visits,Date~Question, sum,na.rm=T)
  names(visits)<-c("Date","Visits")
	visits$Date<-as.Date(visits$Date)
  
  
	area%>%
	  ggvis(x=~long,y=~lat, stroke := "white") %>%
	  group_by(group) %>%
	  layer_paths() %>%
	  layer_paths(fill=~Key) %>%
	  hide_axis("x")%>%
	  hide_axis("y") %>%
	  #layer_points() %>%
	  add_tooltip(all_values, "hover") %>%
	  set_options(width = 400, height = 500)%>%
  	bind_shiny("map")
	
  
  
	users%>%
		ggvis(x=~Date,y=~Answer) %>%
		layer_lines() %>%
		layer_points() %>%
		add_axis("x", title = "")%>%
		add_axis("y", title = "")%>%
		scale_numeric("y", domain = c(0, 15000))%>%
		bind_shiny("u")
	
	
	
	gender%>%
		ggvis(x=~Date,y=~value,stroke= ~variable) %>%
		layer_lines() %>%
		layer_points(fill= ~variable) %>%
		add_axis("x", title = "")%>%
		add_axis("y", title = "")%>%
	  bind_shiny("g")
  
  
	data_age%>%
	  ggvis(x=~Date,y=~value,stroke= ~variable) %>%
	  layer_lines() %>%
	  layer_points(fill=~variable) %>%
	  add_axis("x", title = "")%>%
	  add_axis("y", title = "")%>%
	  #add_tooltip(all_values, "hover")
	  scale_numeric("y", domain = c(0, 80))%>%
	  bind_shiny("a")
  
	visits%>%
	  ggvis(x=~Date,y=~Visits) %>%
	  layer_lines() %>%
	  layer_points() %>%
	  add_axis("x", title = "")%>%
	  add_axis("y", title = "")%>%
	  scale_numeric("y", domain = c(0, 100000))%>%
	  bind_shiny("v")
  
	
})

