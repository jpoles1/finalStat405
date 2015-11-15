#Libraries
require(RCurl)
require(jsonlite)
#Loading in API key from config
source("config.R")
fetchJSON = function(url){
  i = 1;
  while(i<5 & i!=0){
    #Gotta setup try-catch with a delay, in case we hit the API Limit
    try(function(){
      fetched = fromJSON(getURL(url));
      i = 0;
      print("Fetch succeeded")
      return(fetched);
    })
    print("Failed to fetch, trying again in 30 seconds.")
    Sys.sleep(30);
  }
  if(i!=0){
    stop("Could not fetch data, timed out.")
  }
}
fetchCongressMembers = function(congressNumber=113, chamber="senate", searchparams=""){
  version = "v3"
  url =   sprintf("http://api.nytimes.com/svc/politics/%s/us/legislative/congress/%s/%s/members.json?%s&api-key=%s", version, congressNumber, chamber, searchparams, apikey)
  rawjson = 
  data = fetchJSON(url)$results$members[[1]]
  return(data)
}
fetchAllMembers = function(congressRange, chamber="senate"){
  data = data.frame()
  for(num in congressRange){
    set = fetchCongressMembers(num)
    set$number = num
    data = rbind(data, set)
  }
  return(data)
}
data = fetchAllMembers(100:113)