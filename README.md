# soccer Visual Analysis Tool (soccerVAT)

This application automatically generates data-oriented reports of football (soccer) matches, detailing the events of the selected match with the help of six different visual data segments, which are as follows:
1) Teamsheets,
2) Shots,
3) Passmap - home team,
4) Passmap - away team,
5) Progressive passes,
6) Action density.

Details that a coaching team at a professional football club generally wants such as teamsheets & starting formations, shot data & expected goals, pass networks, progressive pass maps & team action heatmaps, before diving into nuanced video analysis, are all incorporated in **_soccerVAT_**.

I have used event data from StatsBomb Open Data to build the app. Although **_soccerVAT_** uses data from the 2018 Men's World Cup, its codebase can be extended and tweaked to suit other datasets (from other providers), tournaments (other than those included in StatsBomb Open Data), etc.

## Use case

### _soccerVAT_ analyses the famous Portugal 3-3 Spain game from the 2018 FIFA World Cup (remember that Ronaldo freekick?!)

We select the match to detail and analyse from the dropdown menu. 

<img src="https://user-images.githubusercontent.com/37649445/117842743-da797500-b29b-11eb-99f5-285bdc8f6e49.png" alt="alt text" width="550" height="692">

Once we have selected the game (Portugal vs Spain), clicking the "GO" button takes us to all the plots and graphs on the right panel.

<img src="https://user-images.githubusercontent.com/37649445/117842945-05fc5f80-b29c-11eb-8e4e-04352e445749.png" alt="alt text" width="550" height="303">

The first tab shows us the tactical setups of both teams with information about the starting lineup and the formations. These seem to be basic information but having myself worked in an elite level professional club environment with experienced and successful European and South American coaching setups, I understand the value and emphasis coaches put on teamsheet information which is always the starting point for match analysis.

<img src="https://user-images.githubusercontent.com/37649445/117843549-88851f00-b29c-11eb-8b9e-05a6afe04387.png" alt="alt text" width="800" height="600">

The next tab shows the shots taken in the match (excluding own goals) mapped on a pitch, segmented by teams, with labels attached to the shots that ended up being goals. The size of each dot signifies the expected goals value of the shot it represents. Bigger the dot size, higher the goal probability of that shot. 

In general, expected goals models are heavily reliant on shot location hence the closer a shot is taken from goal, the higher its chances of becoming a goal. The shots visualisation in **_soccerVAT_** is not information heavy but has enough to hand the coaches a glimpse of a team's shot taking preferences.

<img src="https://user-images.githubusercontent.com/37649445/117850035-8c1ba480-b2a2-11eb-8e26-443fe266b181.png" alt="alt text" width="800" height="600">

The next two tabs demonstrate the passing networks of the teams in view. A pass network provides vital information about team-level passing structures and central players in a team's playing system. Although not a perfect illustration because pass networks take information about average positions of the players and, as a result, don't fully do justice to football (soccer) as a fluid sport with constantly moving parts, nonetheless they provide a good starting point for further analysis. 

The connecting lines and the dots act as networks of how a team played with the ball. The size of the lines indicates the level of chemistry (or interaction or passing frequency) between two players (example, Sergio Ramos to Gerard Pique for Spain), while the size of the dots indicate the level of involvement of a particular player (example, Bruno Fernandes' low involvement in Portugal's midfield can be seen from his little dot in the middle of Portugal's shape, indicating Spain's possession dominance, as expected).

<img src="https://user-images.githubusercontent.com/37649445/117850149-a8b7dc80-b2a2-11eb-8d38-e20e233e4b93.png" alt="alt text" width="800" height="600">

<img src="https://user-images.githubusercontent.com/37649445/117850184-b1101780-b2a2-11eb-8d3d-f1e0dc558688.png" alt="alt text" width="800" height="600">

Progressive passes and team action density are showcased in the next two tabs, highlighting how and from which areas teams progressed the ball towards goal by and the zones of threat (or joy!) for a particular team. These maps are particularly relevant for coaches as they paint a top view of a match, helping them visualise in their head and form important biases before heading to video viewing. 

Progressive passes are particularly important as the main objective of a defending team is to stop the supply of passes that end up in dangerous possessions. For example, in Portugal's progessive passes map, we can see a lot of those passes coming out of Portugal's own penalty box, suggesting the presence of an exit ball for their goalkeeper under pressure. To that end, coaches can prepare how to turn such a situation to their advantage and accordingly formulate a game plan.

<img src="https://user-images.githubusercontent.com/37649445/117855874-8f199380-b2a8-11eb-93c5-e647e33ebe70.png" alt="alt text" width="800" height="600">

<img src="https://user-images.githubusercontent.com/37649445/117855905-9640a180-b2a8-11eb-84b2-f112da25dd0e.png" alt="alt text" width="800" height="600">

That was a case study of analysing a particular match using **_soccerVAT_** and a dive into its various functionalities. _**soccerVAT**_ is my submission to 2021's RShiny Contest.

For further interaction regarding the code and the application's implementation, feel free to reach out to @abhibharali on Twitter.
