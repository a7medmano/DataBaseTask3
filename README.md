 SEARCH TASK


 1- Delete vs truncate
      DELETE   : removes rows one by one, supports WHERE, fully logged per row,
                 fires DELETE triggers, does not reset IDENTITY, can be
                 rolled back.
      TRUNCATE : removes ALL rows (no WHERE), deallocates data pages so it is
                 faster, fires no triggers, resets IDENTITY to its seed, cannot
                 be used on a table referenced by a foreign key.

 2- Transaction Log Backup
      A backup of the transaction log records (all changes since the last log
      backup). Needs the FULL or BULK_LOGGED recovery model and a prior full
      backup. It allows point-in-time restore and lets the inactive part of
      the log be reused.
      Example: BACKUP LOG companyDB2 TO DISK = 'C:\Backup\companyDB2_log.

 3- What is database Job (o)
      An automated task run by SQL Server Agent on a schedule (for example
      nightly backups, index rebuilds, cleanup). It has one or more steps
      (T-SQL, SSIS, PowerShell...) and a schedule.
