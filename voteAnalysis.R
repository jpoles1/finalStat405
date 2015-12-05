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
types <- queryDB("SELECT type, count(*) as ct, year
                  FROM senateRollCalls
                  GROUP BY type, year")
ggplot(types, aes(x = year, y=ct, fill = type))+
  geom_histogram(position="fill", stat="identity", width=1)