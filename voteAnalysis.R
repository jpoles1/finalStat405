#Functions to use in analzying the data
queryDB = function(query){
  dbcon = dbConnect(SQLite(), dbname="data.sqlite")
  res <- dbSendQuery(dbcon, query)
  data <- fetch(res, -1)
  dbClearResult(res)
  return(data)
}
