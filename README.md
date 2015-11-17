#Repository for STAT 405 Final Project Code
##Database
We have finally gotten our database up and running. It includes 3 tables:
- Members (members): A list of the members of congress, sourced from the NY Times Congress API
  - Contains metadata such as name, party, state
  - Values like Total votes, seniority, total votes, missed votes
  - Also contains a value for the percentage of votes with party majority
  - Social media accounts, websites
- Senate Roll Call Votes (senateRollCalls): Data sourced from XML files on roll call votes provided by the <a href="http://www.senate.gov/legislative/votes.htm" target="_blank">US Senate</a>
  - Used to fetch individual votes later.
  - Lots of columns, some useful like tallies of votes, others less so.
- Individual Votes (votes): Using XML data from previous tables, fetched individual roll-call vote JSON data from <a href="https://www.govtrack.us/data/congress/" target="_blank">govtrack.us</a>
  - Metadata like roll-call vote number (rollNumber), Name, State, Party
  - Timescale data: congress number, session, year
  - vote (yea, nay, not voting)
