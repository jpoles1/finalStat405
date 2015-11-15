#Libraries
require(RCurl)
require(jsonlite)
require(plyr)
require(RSQLite)
#Loading in API key from config
source("config.R")
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
  version = "v3"
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
data = fetchAllMembers(80:113)
db = dbConnect(SQLite(), dbname="data.sqlite")
dbWriteTable(db, "members", data)
#write.csv(data, "data/members.csv")