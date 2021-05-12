#Shiny Contest 2021 Submission
#by Abhijit Bharali
#twitter @abhibharali
#soccer Visual Analysis App (soccerVAT)





# Loading libraries............................................................................................................................................
library(shiny)
library(ggsoccer)
library(dplyr)
library(magrittr)
library(devtools)
library(readr)
library(shinythemes)
library(extrafont)
loadfonts(device = "postscript")
library(ggplot2)
library(ggrepel)





# Importing the data............................................................................................................................................
wcdata<-read_rds("wcdata.rds")
matches<-read_rds("matches.rds")





# Defining functions............................................................................................................................................
formation_data<-data.frame(
    position.id=c(1,2,3,4,5,6,7,9,10,11,8,12,13,14,15,16,17,18,19,20,21,25,22,23,24),
    location.x=c(10,20,20,20,20,20,26.3,26.3,26.3,26.3,26.3,32.6,32.6,32.6,32.6,32.6,
                 38.9,38.9,38.9,38.9,38.9,45.2,51.5,51.5,51.5),
    location.y=c(40,10,25,40,55,70,10,25,40,55,70,10,25,40,55,70,10,25,40,55,70,40,25,40,55)
)





formation_func<-function(df){
    formation_data<-data.frame(
        position.id=c(1,2,3,4,5,6,7,9,10,11,8,12,13,14,15,16,17,18,19,20,21,25,22,23,24),
        location.x=c(10,20,20,20,20,20,26.3,26.3,26.3,26.3,26.3,32.6,32.6,32.6,32.6,32.6,
                     38.9,38.9,38.9,38.9,38.9,45.2,51.5,51.5,51.5),
        location.y=c(40,10,25,40,55,70,10,25,40,55,70,10,25,40,55,70,10,25,40,55,70,40,25,40,55)
    )
    new_df<-left_join(df,formation_data,by="position.id")
    return(new_df)
}





dfForPassNet<-function(df){
    df1=df%>%group_by(player.name,pass.recipient.name)%>%dplyr::summarise(Passes=(n()))
    df1=na.omit(df1)
    pos=(df%>%group_by(player.name)%>%dplyr::summarise(xpos=mean(location.x),ypos=mean(location.y)))
    
    df1$playerx=df1$Passes
    df1$playery=df1$Passes
    df1$recipientx=df1$Passes
    df1$recipienty=df1$Passes
    
    for (i in 1:nrow(pos)) {
        for (j in 1:nrow(df1)) {
            if (df1$player.name[j]==pos$player.name[i]) {
                df1$playerx[j]=pos$xpos[i]
                df1$playery[j]=pos$ypos[i]
            }
        }
    }
    
    for (i in 1:nrow(pos)) {
        for (j in 1:nrow(df1)) {
            if (df1$pass.recipient.name[j]==pos$player.name[i]) {
                df1$recipientx[j]=pos$xpos[i]
                df1$recipienty[j]=pos$ypos[i]
            }
        }
    }
    
    d=df1
    return(d)
}





'%notin%'<-Negate('%in%')





# Define UI for application.......................................................................................................................................
ui <- fluidPage(
    # Themes, titles and headers
    column(12,titlePanel(strong(tags$p("soccer Visual Analysis Tool")),windowTitle="soccerVAT")),
    tags$head(tags$style(HTML('* {font-family: "Tahoma"};'))),
    theme = shinytheme("paper"),
    # Sidebar detailing
    sidebarLayout(
        sidebarPanel(
            width = 3,
            img(src="world_cup_img.png",height="20%",width="100%"),
            br(),
            br(),
            selectizeInput("b1","SELECT MATCH (or SEARCH):",
                           levels(factor(matches$matchup)),
                           options = list(maxItems = 1,placeholder="Search player")),
            uiOutput("secondSelection"),
            actionButton("do","GO"),
            br(),
            br(),
            "",tags$b("Soccer Visual Analysis Tool (soccerVAT)")," automatically generates data-oriented reports of football (soccer) matches, detailing the events of a match with the help of six different visual data segments.",
            br(),
            br(),
            "Details that a coaching team would generally want before diving into nuanced video analysis, such as teamsheets & starting formations, shot data & expected goals, pass networks, progressive pass maps & team action zones, are all incorporated in ",tags$b("soccerVAT."),
            br(),
            br(),
            "Free event data from StatsBomb Open Data have been used. This app uses the 2018 Men's World Cup data and can be extended and tweaked to suit other datasets, tournaments, etc.",
            br(),
            br(),
            img(src="SB_Regular.png",height="70%",width="100%"),
            br(),
            br(),
            "©Abhijit Bharali",
            
            
            
            
        
        # Main panel detailing
        mainPanel(
            width = 9,
            # Output: Tabset with 6 plots ----
            tabsetPanel(type = "tabs",
                        tabPanel("TEAMSHEETS", plotOutput("plot1",height = "700px",width = "1000px")),
                        tabPanel("SHOTS", plotOutput("plot2",height = "600px",width = "1000px")),
                        tabPanel("PASSMAP - HOME TEAM", plotOutput("plot3",height = "700px",width = "1000px")),
                        tabPanel("PASSMAP - AWAY TEAM", plotOutput("plot4",height = "700px",width = "1000px")),
                        tabPanel("PROGRESSIVE PASSES", plotOutput("plot5",height = "600px",width = "1000px")),
                        tabPanel("ACTION DENSITY", plotOutput("plot6",height = "600px",width = "1000px"))
            )
            
        )
    )
)
    
    
    
    

# Define server logic required to draw the plots...................................................................................................................
server <- function(input, output,session) {
    
    x<-eventReactive(input$do,{
        formation_func(as.data.frame(((wcdata%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))]))$tactics.lineup)[1]))
    }
    )
    
    
    y<-eventReactive(input$do,{
        formation_func(as.data.frame(((wcdata%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))]))$tactics.lineup)[2]))
    }
    )
    
    
    z<-eventReactive(input$do,{
        dfForPassNet(wcdata%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))],
                                     team.name==matches$home_team.home_team_name[(which(matches$matchup==input$b1))],
                                     type.name=="Pass",
                                     index<which((wcdata%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))],
                                                                  team.name==matches$home_team.home_team_name[(which(matches$matchup==input$b1))]))$type.name=="Substitution")[1]))
    }   
    )
    
    
    w<-eventReactive(input$do,{
        dfForPassNet(wcdata%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))],
                                     team.name==matches$away_team.away_team_name[(which(matches$matchup==input$b1))],
                                     type.name=="Pass",
                                     index<which((wcdata%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))],
                                                                  team.name==matches$away_team.away_team_name[(which(matches$matchup==input$b1))]))$type.name=="Substitution")[1]))
    }
    )
    
    
    
    
    
    output$plot1<-renderPlot(({
        ggplot()+
            annotate_pitch(dimensions = pitch_statsbomb,colour = "black",fill = "snow1")+
            theme_pitch(aspect_ratio = 0.6)+
            geom_point(data = x(),
                       aes(x=location.x,y=location.y),size=7,shape=19,colour="#F8766D")+
            geom_text(data = x(),
                      aes(x=location.x,y=location.y,label=jersey_number,family="Tahoma"),
                      colour="white")+
            geom_point(data = y(),
                       aes(x=120-location.x,y=80-location.y),size=7,shape=19,colour="#00BFC4")+
            geom_text(data = y(),
                      aes(x=120-location.x,y=80-location.y,label=jersey_number,family="Tahoma"),
                      colour="white")+
            theme(
                plot.background = element_rect(fill = "white"),
                panel.background = element_rect(fill = "white"),
                plot.title = element_text(hjust = 0.5,size = 20,face = "bold"),
                plot.subtitle = element_text(hjust = 0.5,colour = "grey45",size = 15),
                text = element_text(family = "Tahoma")
            )+
            labs(title = paste0((matches%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))]))$home_team.home_team_name," ",(matches%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))]))$home_score,"-",(matches%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))]))$away_score," ",(matches%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))]))$away_team.away_team_name),
                 subtitle = (matches%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))]))$competition_stage.name)+
            geom_label_repel(data = x(),
                             aes(x=location.x,y=location.y,label=player.name,family="Tahoma"),
                             size=3, alpha=0.9,colour="#F8766D",box.padding = unit(0.1,"cm"),
                             nudge_y = 3,label.padding=unit(0.1,"cm"),label.r=unit(0.1,"cm"),
                             label.size=unit(0.1,"cm"),point.padding = unit(0.1,"cm"),
                             direction = "y" ,force_pull = 2,force = 10,
                             arrow = arrow(angle = 30,length = unit(0.01,"cm"),ends = "last",
                                           type = "closed"))+
            geom_label_repel(data = y(),
                             aes(x=120-location.x,y=80-location.y,label=player.name,family="Tahoma"),
                             size=3, alpha=0.9,colour="#00BFC4",box.padding = unit(0.1,"cm"),
                             nudge_y = 3,label.padding=unit(0.1,"cm"),label.r=unit(0.1,"cm"),
                             label.size=unit(0.1,"cm"),point.padding = unit(0.1,"cm"),
                             direction = "y" ,force_pull = 2,force = 10,
                             arrow = arrow(angle = 30,length = unit(0.01,"cm"),ends = "last",
                                           type = "closed"))
        
    }),width = "auto",height = "auto",res = 84)
    
    
    
    
    
    output$plot2<-renderPlot(({
        ggplot()+
            annotate_pitch(dimensions = pitch_statsbomb,colour = "black",fill = "snow1")+
            theme_pitch(aspect_ratio = 1.33)+
            geom_point(data = wcdata%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))],
                                              type.name=="Shot",
                                              shot.outcome.name!="Goal",
                                              period!=5),
                       aes(x=120-location.x,y=location.y,size=2*shot.statsbomb_xg,colour=team.name),
                       show.legend = F,alpha=0.9)+
            geom_point(data = wcdata%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))],
                                              type.name=="Shot",
                                              shot.outcome.name!="Goal",
                                              period!=5),
                       aes(x=120-location.x,y=location.y,size=2*shot.statsbomb_xg),
                       show.legend = F,colour="black",shape=1)+
            geom_point(data = wcdata%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))],
                                              type.name=="Shot",
                                              shot.outcome.name=="Goal",
                                              period!=5),
                       aes(x=120-location.x,y=location.y,size=2*shot.statsbomb_xg),
                       show.legend = F,colour="yellow",shape=18,alpha=0.9)+
            geom_point(data = wcdata%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))],
                                              type.name=="Shot",
                                              shot.outcome.name=="Goal",
                                              period!=5),
                       aes(x=120-location.x,y=location.y,size=2*shot.statsbomb_xg),
                       show.legend = F,colour="black",shape=5,alpha=1)+
            geom_label_repel(data = wcdata%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))],
                                                    type.name=="Shot",
                                                    shot.outcome.name=="Goal",
                                                    period!=5),
                             aes(x=120-location.x,
                                 y=location.y,
                                 label=paste0(round(shot.statsbomb_xg,2)," xG"),
                                 family="Arial"),
                             size=3.5, alpha=0.7,colour="black",box.padding = unit(0.1,"cm"),
                             nudge_y = 3,label.padding=unit(0.1,"cm"),label.r=unit(0.1,"cm"),
                             label.size=unit(0.1,"cm"),point.padding = unit(0.1,"cm"))+
            coord_flip(xlim = c(120,0),
                       ylim = c(0,80))+
            facet_wrap(~team.name)+
            labs(caption = "labeled points = GOALS")+
            theme(
                plot.background = element_rect(fill = "white"),
                panel.background = element_rect(fill = "white"),
                strip.background = element_rect(fill="white"),
                strip.text = element_text(family = "Tahoma",size = 20),
                plot.title = element_text(hjust = 0.5,size = 20,face = "bold"),
                plot.subtitle = element_text(hjust = 0.5,colour = "grey45",size = 15),
                plot.caption = element_text(hjust = 0.5,size = 15,colour = "grey45"),
                text = element_text(family = "Tahoma")
            )
        
    }),width = "auto",height = "auto",res = 84)
    
    
    
    
    
    output$plot3<-renderPlot(({
        ggplot()+
            annotate_pitch(dimensions = pitch_statsbomb,colour = "black",fill = "snow1")+
            theme_pitch(aspect_ratio = 0.6)+
            geom_segment(data = z(),
                         aes(x=playerx,y=80-playery,xend=recipientx,yend=80-recipienty,
                             alpha=Passes),size=1,
                         show.legend = F,colour="#F8766D")+
            geom_point(data = z()%>%group_by(player.name)%>%dplyr::summarise(x=mean(playerx),y=mean(playery),nPass=n()),
                       aes(x=x,y=80-y,size=nPass),show.legend = F)+
            geom_label_repel(data = z()%>%group_by(player.name)%>%dplyr::summarise(x=mean(playerx),y=mean(playery),nPass=n()),
                             aes(x=x,y=80-y,label=player.name,family="Tahoma"),
                             size=4, alpha=0.7,colour="#F8766D",box.padding = unit(0.1,"cm"),
                             nudge_y = 3,label.padding=unit(0.1,"cm"),label.r=unit(0.1,"cm"),
                             label.size=unit(0.1,"cm"),point.padding = unit(0.1,"cm"))+
            labs(title = paste0((matches%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))]))$home_team.home_team_name),
                 subtitle = ("Passing Network (till 1st sub)"))+
            theme(
                plot.background = element_rect(fill = "white"),
                panel.background = element_rect(fill = "white"),
                plot.title = element_text(hjust = 0.5,face = "bold",size = 20),
                plot.subtitle = element_text(hjust = 0.5,colour = "grey45",size = 15),
                text = element_text(family = "Tahoma"),
                strip.text = element_blank()
            )+
            geom_segment(aes(x=0,y=-3,xend=30,yend=-3),size=1,lineend = "butt",
                         linejoin = "mitre",
                         arrow = arrow(type = "closed",length = unit(0.07,"inches")),
                         colour="#F8766D")
        
    }),width = "auto",height = "auto",res = 84)
    
    output$plot4<-renderPlot(({
        ggplot()+
            annotate_pitch(dimensions = pitch_statsbomb,colour = "black",fill = "snow1")+
            theme_pitch(aspect_ratio = 0.6)+
            geom_segment(data = w(),
                         aes(x=playerx,y=80-playery,xend=recipientx,yend=80-recipienty,
                             alpha=Passes),size=1,
                         show.legend = F,colour="#00BFC4")+
            geom_point(data = w()%>%group_by(player.name)%>%dplyr::summarise(x=mean(playerx),y=mean(playery),nPass=n()),
                       aes(x=x,y=80-y,size=nPass),show.legend = F)+
            geom_label_repel(data = w()%>%group_by(player.name)%>%dplyr::summarise(x=mean(playerx),y=mean(playery),nPass=n()),
                             aes(x=x,y=80-y,label=player.name,family="Tahoma"),
                             size=4, alpha=0.7,colour="#00BFC4",box.padding = unit(0.1,"cm"),
                             nudge_y = 3,label.padding=unit(0.1,"cm"),label.r=unit(0.1,"cm"),
                             label.size=unit(0.1,"cm"),point.padding = unit(0.1,"cm"))+
            labs(title = paste0((matches%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))]))$away_team.away_team_name),
                 subtitle = ("Passing Network (till 1st sub)"))+
            theme(
                plot.background = element_rect(fill = "white"),
                panel.background = element_rect(fill = "white"),
                plot.title = element_text(hjust = 0.5,face = "bold",size = 20),
                plot.subtitle = element_text(hjust = 0.5,colour = "grey45",size = 15),
                text = element_text(family = "Tahoma"),
                strip.text = element_blank()
            )+
            geom_segment(aes(x=0,y=-3,xend=30,yend=-3),size=1,lineend = "butt",
                         linejoin = "mitre",
                         arrow = arrow(type = "closed",length = unit(0.07,"inches")),
                         colour="#00BFC4")
        
    }),width = "auto",height = "auto",res = 84)
    
    
    
    
    output$plot5<-renderPlot(({
        ggplot()+
            annotate_pitch(dimensions = pitch_statsbomb,colour = "black",fill = "snow1")+
            theme_pitch(aspect_ratio = 1.33)+
            geom_segment(data = wcdata%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))],
                                                type.name=="Pass",
                                                ifelse(location.x<95,pass.end_location.x-location.x>25,pass.end_location.x-location.x>0),
                                                #pass.angle>0,
                                                pass.type.name%notin%c("Corner","Free Kick","Goal Kick","Interception","Kick Off","Recovery","Throw-in")),
                         aes(x=location.x,y=80-location.y,
                             xend=pass.end_location.x,yend=80-pass.end_location.y,
                             colour=team.name),show.legend = F,
                         size=0.3,lineend = "butt",
                         linejoin = "mitre",
                         arrow = arrow(type = "closed",length = unit(0.07,"inches")))+
            facet_wrap(~team.name)+
            coord_flip()+
            labs(caption = "Passes that moved the ball at least 25m towards goal")+
            theme(
                plot.background = element_rect(fill = "white"),
                panel.background = element_rect(fill = "white"),
                strip.background = element_rect(fill="white"),
                strip.text = element_text(family = "Tahoma",size = 20),
                plot.title = element_text(hjust = 0.5,size = 20,face = "bold"),
                plot.subtitle = element_text(hjust = 0.5,colour = "grey45",size = 15),
                plot.caption = element_text(hjust = 0.5,size = 15,colour = "grey45"),
                text = element_text(family = "Tahoma")
            )
        
    }),width = "auto",height = "auto",res = 84)
    
    
    
    
    
    output$plot6<-renderPlot(({
        ggplot()+
            annotate_pitch(dimensions = pitch_statsbomb,colour = "black",fill = "snow1")+
            theme_pitch(aspect_ratio = 1.33)+
            stat_density_2d(data = wcdata%>%filter(match_id==matches$match_id[(which(matches$matchup==input$b1))],
                                                   location.y<80,location.y>0),
                            aes(x=location.x,y=location.y,alpha=..level..,colour=team.name),
                            show.legend = F)+
            coord_flip()+
            facet_grid(~team.name)+
            theme(
                plot.background = element_rect(fill = "white"),
                panel.background = element_rect(fill = "white"),
                strip.background = element_rect(fill="white"),
                strip.text = element_text(family = "Tahoma",size = 20),
                plot.title = element_text(hjust = 0.5,size = 20,face = "bold"),
                plot.subtitle = element_text(hjust = 0.5,colour = "grey45",size = 15),
                plot.caption = element_text(hjust = 0.5,size = 15,colour = "grey45"),
                text = element_text(family = "Tahoma")
            )
        
    }),width = "auto",height = "auto",res = 84)

    
}
    
    
    
    

# Run the application 
shinyApp(ui = ui, server = server)
