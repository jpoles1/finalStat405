#Libraries
require(RCurl)
require(jsonlite)
require(plyr)
require(RSQLite)
require(XML)
#Loading in API key from config
source("config.R")
source("fetchJSON.R")
source("fetchXML.R")
#Write to db
tableWriter = function(data, tablename){
  dbcon = dbConnect(SQLite(), dbname="data.sqlite")
  dbWriteTable(dbcon, tablename, data, overwrite=TRUE);
  dbDisconnect(dbcon);
}
#Fetch session data for determining which years align with a given congress session
sesh = read.delim("data/sessions.tsv")
range = 101:113
memberData = fetchAllMembers(range)
rollCallData = fetchSenateRollCalls(range, 1:2);
voteData = fetchVotes(rollCallData);
