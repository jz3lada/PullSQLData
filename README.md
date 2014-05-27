PullSQLData
===========

This is a stored procedure that allows to extract all data from a specific table, only works (for now) in SQL Server.
If you can make same for other SGBD please contact me.


How to use?
===========

1. Copy the code in the Query editor and press F5 for execute the code
2. Check the messages windows and make sure the query execute correctly, the expected message is "Command(s) completed successfully."
3. In a new querry windows write same this:

    > sp_PullSQLData  table_name
    
    run the code and the SP give you the code for migrate the data of the table

4. Copy the code
5. In a new querry windows paste the code and press F5

  5.1. You can filter the data for pull, add the sentence " where column_name = sentence " in the final of the code if you         want migrate especific data, maybe in a range of dates, etc, etc.

6. Finally you get the code for migrate your data


*Steps 1 and 2 only for the first time



