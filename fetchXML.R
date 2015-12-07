fetchXML = function(dataurl){
  rawtext = getURL(dataurl);
  data = xmlToList(rawtext)$votes;
  d = ldply(data, function(x) data.frame(x))
}
senateRollCall = function(congressNumber=113, sessionNumber=1){
  dataurl = sprintf("http://www.senate.gov/legislative/LIS/roll_call_lists/vote_menu_%s_%s.xml", congressNumber, sessionNumber)
  data = fetchXML(dataurl);
  print("Fetch succeeded")
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
  data = data[,2:16]
  colnames(data) = c("voteNumber", "date", "issueID", "issueURL", "question", "result", "yeas", "nays", "title", "questionType", "questionReference", "questionReferenceURL", "issueOther", "congressNumber", "session")
  tableWriter(data, "senateRollCalls")
  return(data);
}