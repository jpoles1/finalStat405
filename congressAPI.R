#Libraries
require(RCurl)
require(jsonlite)
require(plyr)
require(RSQLite)
require(XML)
#Loading in API key from config
source("config.R")
#Setup Database Connection
dbcon = dbConnect(SQLite(), dbname="data.sqlite")
dbWriteTable(dbcon, "members", data)
#
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
      print("Failed to fetch, trying again in 30 seconds.")
      Sys.sleep(30);
      i=i+1;
    }
  }
  stop("Could not fetch data, timed out.")
}
fetchCongressMembers = function(congressNumber=113, chamber="senate", searchparams=""){
  url = sprintf("http://api.nytimes.com/svc/politics/%s/us/legislative/congress/%s/%s/members.json?%s&api-key=%s", version, congressNumber, chamber, searchparams, apikey)
  data = fetchJSON(url)$results$members[[1]]
  return(data)
}
fetchAllMembers = function(congressRange, chamber="senate"){
  data = data.frame()
  for(num in congressRange){
    set = fetchCongressMembers(num)
    set$number = num
    data = rbind.fill(data, set)
  }
  return(data)
}
fetchBills = function(congressNumber=113, chamber="senate", searchparams=""){
  url = sprintf("http://api.nytimes.com/svc/politics/%s/us/legislative/congress/%s/%s/bills/passed.json?%s&api-key=%s", version, congressNumber, chamber, searchparams, apikey)
  data = fetchJSON(url)$results
  return(data) 
}
fetchVote = function(congressNumber=113, chamber="senate", sessionNumber = 1, roleNumber=1, searchparams=""){
  url = sprintf("http://api.nytimes.com/svc/politics/%s/us/legislative/congress/%s/%s/sessions/votes%s/passed.json?%s&api-key=%s", version, congressNumber, chamber, sessionNumber, searchparams, apikey)
  data = fetchJSON(url)$results
  return(data) 
}
fetchXML = function(url){
  rawtext = getURL(url);
  data = xmlToList(rawtext);
}
senateRollCall = function(congressNumber=113, sessionNumber=1){
  dataurl = sprintf("http://www.senate.gov/legislative/LIS/roll_call_lists/vote_menu_%s_%s.xml", congressNumber, sessionNumber)
  data = fetchXML(dataurl);
  return(data);
}
x = senateRollCall();
View(x)
memberData = fetchAllMembers(80:113)
fetchBills(111)
