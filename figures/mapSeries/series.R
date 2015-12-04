stateMap = map_data("state")
congressRange = 101:113
#Votes With Party
for(congressNumber in congressRange){
  stateVote = queryDB(sprintf("SELECT state as stateAbrev, avg(votes_with_party_pct) as withParty FROM members WHERE congressNumber=%s GROUP BY state",congressNumber))
  stateVote$state = apply(stateVote, 1, FUN=function(x){stateAbrevToFull(x["stateAbrev"])})
  uniScale = seq(60, 100, by=5);
  ggplot()+
    geom_map(data=stateMap, map=stateMap, aes(x=long, y=lat, map_id=region), fill="#ffffff", color="grey10")+
    geom_map(data=stateVote, map=stateMap, aes(fill=withParty, map_id=state), color="grey10")+
    ggtitle(sprintf("Patterns in Voting With Party By State\nCongress Number: %s", congressNumber))+
    xlab("")+ylab("")+
    scale_x_continuous(breaks=NULL)+
    scale_y_continuous(breaks=NULL)+
    scale_fill_gradient(name="% Votes w/ Party", limits=c(0,100))
  ggsave(file=sprintf("../figures/mapSeries/%s.png", congressNumber), width= 6, height=4, dpi=200)
}
#Missed Votes
alldata = queryDB("SELECT state as stateAbrev, avg(missed_votes_pct) as missed, congressNumber FROM members  GROUP BY congressNumber, state ORDER BY congressNumber DESC, missed DESC")
upperbound = ceiling(mean(alldata$missed)+(2*sd(alldata$missed)))
for(congressNumber in congressRange){
  stateVote = queryDB(sprintf("SELECT state as stateAbrev, avg(missed_votes_pct) as missed FROM members WHERE congressNumber=%s GROUP BY state",congressNumber))
  stateVote$state = apply(stateVote, 1, FUN=function(x){stateAbrevToFull(x["stateAbrev"])})
  uniScale = seq(60, 100, by=5);
  ggplot()+
    geom_map(data=stateMap, map=stateMap, aes(x=long, y=lat, map_id=region), fill="#ffffff", color="grey10")+
    geom_map(data=stateVote, map=stateMap, aes(fill=missed, map_id=state), color="grey10")+
    ggtitle(sprintf("Avg. Percentage of Votes Missed by State Senators\nCongress Number: %s\n", congressNumber))+
    xlab("")+ylab("")+
    scale_x_continuous(breaks=NULL)+
    scale_y_continuous(breaks=NULL)+
    scale_fill_gradient(name="% Missed Votes", limits=c(0,upperbound), na.value="dark red")
  ggsave(file=sprintf("../figures/mapSeries/missed/%s.png", congressNumber), width= 10, height=6, dpi=200)
}

yearRange = 1989:2014
for (year in yearRange) {
  query <- sprintf("select type
            from senateRollCalls
            where year = %s", year)
  types <- queryDB(query, 'data.sqlite')
  pie <- ggplot(types,aes(x = factor(1), fill = type)) + geom_bar(width = 1) +
    coord_polar(theta = "y") + xlab("") + ylab("") + scale_x_discrete(breaks=NULL) +
    ggtitle(sprintf("Bill types\nYear: %s\n", year))+
    scale_y_continuous(breaks=NULL)
  ggsave(file=sprintf("../figures/mapSeries/billTypes/%s.png", year), width= 10, height=6, dpi=200)
}