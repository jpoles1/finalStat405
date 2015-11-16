require(RCurl)
require(XML)
dataurl = "http://www.senate.gov/legislative/LIS/roll_call_lists/vote_menu_113_1.xml"
rawtext = getURL(dataurl);
data = xmlParse(rawtext);
data["//votes//vote"]
a <- xmlSApply(data["//votes"], function(x) xmlSApply(x, xmlValue))
ldply(data["//votes//vote"], function(x){
  
})