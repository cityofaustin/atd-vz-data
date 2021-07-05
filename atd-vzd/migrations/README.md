## VZD Migrations

Currently database changes are not automated or version controlled; this folder however allows us to track the changes to the initial state of the database in relation to the schema folder.

We are currently working to automate this process in a safe way and enable an efficient workflow for all developers; in the mean time, whenever an alteration is made to the database, please create a SQL folder and put it in this folder with the following naming convention:

###`migration_[affected-table-name]_[yyyy-mm-dd--hhmm].sql`

