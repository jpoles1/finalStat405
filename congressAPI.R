#Libraries
require(RCurl)
require(jsonlite)
require(plyr)
require(RSQLite)
require(XML)
require(plyr)
#Loading in API key from config
source("config.R")
source("senateRollCall.R")
#Fetch session data for determining which years align with a given congress session
sesh = read.delim("data/sessions.tsv")
#Helper Functions
fetchJSON = function(url){
  i = 1;
  while(i<5){
    #Gotta setup try-catch with a delay, in case we hit the API Limit
    rawtext = getURL(url);
    if(validate(rawtext)){
      print("Fetch succeeded")
      return(fromJSON(rawtext))
      Sys.sleep(1);
    }
    else{
      print(rawtext)
      print("Failed to fetch, trying again in 15 seconds.")
      Sys.sleep(15);
      i=i+1;
    }
  }
  stop("Could not fetch data, timed out.")
}
fetchCongressMembers = function(congressNumber=113, chamber="senate", searchparams=""){
  dataurl = sprintf("http://api.nytimes.com/svc/politics/%s/us/legislative/congress/%s/%s/members.json?%s&api-key=%s", apiversion, congressNumber, chamber, searchparams, apikey)
  data = fetchJSON(dataurl)$results$members[[1]]
  return(data)
}
tableWriter = function(data, tablename){
  dbcon = dbConnect(SQLite(), dbname="data.sqlite")
  dbWriteTable(dbcon, tablename, data, overwrite=TRUE);
  dbDisconnect(dbcon);
}
fetchAllMembers = function(congressRange, chamber="senate"){
  data = data.frame()
  for(num in congressRange){
    set = fetchCongressMembers(num)
    set$congressNumber = num
    data = rbind.fill(data, set)
  }
  tableWriter(data, "members")
  return(data)
}
fetchBills = function(congressNumber=113, chamber="senate", searchparams=""){
  dataurl = sprintf("http://api.nytimes.com/svc/politics/%s/us/legislative/congress/%s/%s/bills/passed.json?%s&api-key=%s", apiversion, congressNumber, chamber, searchparams, apikey)
  data = fetchJSON(dataurl)$results
  return(data) 
}
fetchVote = function(congressNumber=113, year = 2015, rollNumber=1, searchparams=""){
  dataurl = sprintf("https://www.govtrack.us/data/congress/%s/votes/%s/s%s/data.json", congressNumber, year, rollNumber)
  print(dataurl)
  data = fetchJSON(dataurl)
  return(data);
}
fetchVotes = function(rollCallData){
  rollCallColnames = c("congressNumber", "session", "vote_number")
  rollCalls = rollCallData[rollCallColnames]
  data = ddply(rollCalls, rollCallColnames, function(x){
    rollNumber = x$vote_number;
    rollNumber = gsub("0", "", as.character(rollNumber))
    year = sesh[sesh$congress==x$congressNumber,]$session[x$session]
    set = fetchVote(x$congressNumber, year, rollNumber)
    set = ldply(set$votes, function(x) data.frame(x))
    set$congressNumber = x$congressNumber;
    set$session = x$session;
    set$year = year;
    set$rollNumber = rollNumber;
    set
  });
  data = data[,1:12];
  try(tableWriter(data, "votes"));
  return(data)
}
range = 101:113
memberData = fetchAllMembers(range)
rollCallData = fetchSenateRollCalls(range, 1:2);
voteData = fetchVotes(rollCallData);
