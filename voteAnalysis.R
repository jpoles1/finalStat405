#Functions to use in analzying the data
queryDB = function(query, dbPath="data.sqlite"){
  dbcon = dbConnect(SQLite(), dbname=paste(projectRoot, dbPath, sep=""))
  res <- dbSendQuery(dbcon, query)
  data <- fetch(res, -1)
  dbClearResult(res)
  return(data)
}
#Converts a given congress and session number to a year using the following table
sesh = read.delim(paste(projectRoot,"data/sessions.tsv", sep=""))
congressToYear = function(congressNumber, sessionNumber){
  sessionNumber = as.factor(sessionNumber)
  year = sesh[sesh$congress==congressNumber,]$session[sessionNumber]
  return(as.integer(as.character(year)))
}
stateTable = read.csv("data/stateTable.csv")
stateAbrevToFull = function(abrev){
  return(tolower(stateTable[stateTable$abbreviation==abrev, "name"]))
}
#Scratch space
stateMap = map_data("state")
congressRange = 101:113
for(congressNumber in congressRange){
  stateVote = queryDB(sprintf("SELECT state as stateAbrev, avg(votes_with_party_pct) as withParty FROM members WHERE congressNumber=%s GROUP BY state",congressNumber))
  stateVote$state = apply(stateVote, 1, FUN=function(x){stateAbrevToFull(x["stateAbrev"])})
  ggplot()+geom_map(data=stateMap, map=stateMap, aes(x=long, y=lat, map_id=region), fill="#ffffff", color="grey10")+geom_map(data=stateVote, map=stateMap, aes(fill=withParty, map_id=state), color="grey10")+ggtitle(sprintf("Votes With Party By State\nCongress Number: %s", congressNumber));
  ggsave(file=sprintf("figures/mapSeries/%s.png", congressNumber), width= 6, height=4)
}
