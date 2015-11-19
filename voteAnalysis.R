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
#Scratch space
partyData = queryDB("SELECT party as Party, count(*) as ct FROM members WHERE party!='ID' GROUP BY party")
a = ggplot(partyData, aes(x=reorder(Party, ct), y=ct))+geom_bar(stat="identity", fill=c("green", "red", "blue"))+xlab("\nParty")+ylab("Number of Seats Held")+ggtitle("Number of Senate Seats Held By Each Party\nRange from 101st to 113th Congress.")
partyDataByYear = queryDB("SELECT party as Party, congressNumber, count(*) as ct FROM members WHERE party!='ID' GROUP BY party, congressNumber")
c = ggplot(partyDataByYear, aes(x=congressNumber, y=ct, fill=Party))+geom_histogram(position="fill", stat="identity", width=1)+xlab("Congress Number\n")+scale_x_continuous(breaks=101:113)+ylab("\nPercentage of Senate Seats")+ggtitle("Senate Seats Held Per Party By Year\n")

