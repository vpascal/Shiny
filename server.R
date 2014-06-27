library(shiny)
library(dplyr)
library(ggvis)
library(reshape)
library(rgdal)
library(rgeos)
library(maptools)
gpclibPermit()

# Define server logic required to summarize and view the selected dataset
shinyServer(function(..., session) {
	
	map<-readShapeSpatial("MDA_Adm1", repair=T)
	proj4string(map) <- CRS("+proj=longlat +datum=NAD27")
	#   map$NAME_1 <- as.character(a$NAME_1)
	#   map$NAME_1[a$NAME_1 == "H??ncesti"] <- "Hincesti"
	
	
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
		scale_numeric("y", domain = c(0, 80))%>%
		bind_shiny("g")
	
})

