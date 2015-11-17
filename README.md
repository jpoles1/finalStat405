#Repository for STAT 405 Final Project Code
##Database
We have finally gotten our database up and running. It includes 3 tables:
- Members (members): A list of the members of congress, sourced from the NY Times Congress API
  - Contains metadata such as name, party, state
  - Values like Total votes, seniority, total votes, missed votes
  - Also contains a value for the percentage of votes with party majority
  - Social media accounts, websites
- Senate Roll Call Votes (senateRollCalls)
- Individual Votes (votes)
-   - Metadata like roll-call vote number (rollNumber), Name, State, Party
  - Timescale data: congress number, session, year
  - vote (yea, nay, not voting)
