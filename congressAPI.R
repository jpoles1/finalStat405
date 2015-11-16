#Libraries
require(RCurl)
require(jsonlite)
require(plyr)
require(RSQLite)
require(XML)
require(plyr)
#Loading in API key from config
source("config.R")
#Helper Functions
fetchJSON = function(url){
  i = 1;
  while(i<5){
    #Gotta setup try-catch with a delay, in case we hit the API Limit
    rawtext = getURL(url);
    if(validate(rawtext)){
      print("Fetch succeeded")
      return(fromJSON(rawtext))
    }
    else{
      print("Failed to fetch, trying again in 15 seconds.")
      Sys.sleep(15);
      i=i+1;
    }
  }
  stop("Could not fetch data, timed out.")
}
fetchCongressMembers = function(congressNumber=113, chamber="senate", searchparams=""){
  dataurl = sprintf("http://api.nytimes.com/svc/politics/%s/us/legislative/congress/%s/%s/members.json?%s&api-key=%s", version, congressNumber, chamber, searchparams, apikey)
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
  dataurl = sprintf("http://api.nytimes.com/svc/politics/%s/us/legislative/congress/%s/%s/bills/passed.json?%s&api-key=%s", version, congressNumber, chamber, searchparams, apikey)
  data = fetchJSON(dataurl)$results
  return(data) 
}
fetchVote = function(congressNumber=113, chamber="senate", sessionNumber = 1, roleNumber=1, searchparams=""){
  dataurl = sprintf("http://api.nytimes.com/svc/politics/%s/us/legislative/congress/%s/%s/sessions/votes%s/passed.json?%s&api-key=%s", version, congressNumber, chamber, sessionNumber, searchparams, apikey)
  data = fetchJSON(dataurl)$results
  return(data) 
}
fetchXML = function(dataurl){
  rawtext = getURL(dataurl);
  data = xmlToList(rawtext)$votes;
  d = ldply(data, function(x) data.frame(x))
}
senateRollCall = function(congressNumber=113, sessionNumber=1){
  dataurl = sprintf("http://www.senate.gov/legislative/LIS/roll_call_lists/vote_menu_%s_%s.xml", congressNumber, sessionNumber)
  data = fetchXML(dataurl);
  return(data);
}
fetchSenateRollCalls = function(congressRange, sessionRange){
  data = data.frame()
  for(num in congressRange){
    for(session in sessionRange){
      set = senateRollCall(num, session)
      set$congressNumber = num
      set$session = session
      data = rbind.fill(data, set)
    }
  }
  tableWriter(data, "senateRollCalls")
  return(data);
}
rollCallData = fetchSenateRollCalls(101:113, 1:2);
#memberData = fetchAllMembers(80:113)
#fetchBills(111)
