#Functions to use in analzying the data
queryDB = function(query, dbPath="data.sqlite"){
  dbcon = dbConnect(SQLite(), dbname=paste(projectRoot, dbPath, sep=""))
  res <- dbSendQuery(dbcon, query)
  data <- fetch(res, -1)
  dbClearResult(res)
  dbDisconnect(dbcon)
  return(data)
}
#Converts a given congress and session number to a year using the following table
sesh = read.delim(paste(projectRoot,"data/sessions.tsv", sep=""))
congressToYear = function(congressNumber, sessionNumber){
  sessionNumber = as.factor(sessionNumber)
  year = sesh[sesh$congress==congressNumber,]$session[sessionNumber]
  return(as.integer(as.character(year)))
}
stateTable = read.csv(paste(projectRoot,"data/stateTable.csv", sep=""))
stateAbrevToFull = function(abrev){
  return(tolower(stateTable[stateTable$abbreviation==abrev, "name"]))
}
#Scratch space
stateParty = queryDB("SELECT state as stateAbrev, party, count(*) as ct FROM members WHERE party IN ('D', 'R') GROUP BY party, state")
statePartyWide = dcast(stateParty, stateAbrev~party, value.var="ct")
statePartyWide[is.na(statePartyWide)]=0
statePartyWide$diff = statePartyWide$D-statePartyWide$R
statePartyWide$state = apply(statePartyWide, 1, FUN=function(x){stateAbrevToFull(x["stateAbrev"])})
stateMap = map_data("state")
ggplot(statePartyWide)+geom_map(data=stateMap, map=stateMap, aes(x=long, y=lat, map_id=region), fill="#ffffff", color="grey10")+geom_map(data=statePartyWide, map=stateMap, aes(fill=diff, map_id=state), color="grey10")+scale_fill_gradient(name="Party Difference\n(# Senators)", low="red", high="blue")+ggtitle("Difference In # of Senators From Major Parties Elected by State\n")
