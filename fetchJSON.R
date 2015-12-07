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
fetchVote = function(congressNumber=113, year = 2015, rollNumber=1, searchparams=""){
  dataurl = sprintf("https://www.govtrack.us/data/congress/%s/votes/%s/s%s/data.json", congressNumber, year, rollNumber)
  print(dataurl)
  data = fetchJSON(dataurl)
  return(data);
}
fetchVotes = function(rollCallData){
  rollCallColnames = c("congressNumber", "session", "voteNumber")
  rollCalls = rollCallData[rollCallColnames]
  data = ddply(rollCalls, rollCallColnames, function(x){
    rollNumber = x$voteNumber;
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
  nms = colnames(data)
  nms[2] = "vote"
  nms[3] = "displayName"
  nms[4] = "firstName"
  nms[6] = "lastName"
  colnames(data) = nms;
  try(tableWriter(data, "votes"));
  return(data)
}