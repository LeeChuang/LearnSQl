--USE master
--GO
/****** Object:  Job [delHisOfInfor]    Script Date: 10/12/2016 13:59:35 ******/
declare @i int,@maxNum int,@dbstr varchar(20) --定义数据库名称
set @i=0

while 1=1
BEGIN
	set @dbstr = 'SHMonitor_Preplan'+CAST(@i as varchar(10))
	if (db_id(@dbstr) is null)	--判断数据库是否存在
		break
	else
		set @i=@i+1
END


set @maxNum = @i-1
set @i = 0
print (@maxNum)
declare @execstr varchar(max) ---


/****** Object:  JobCategory [Data Collector]    Script Date: 10/12/2016 13:59:35 ******/
set @execstr = '
USE [msdb]
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N''Data Collector'' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N''Data Collector''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N''delHisOfInfor'', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N''删除历史情报板信息表'', 
		@category_name=N''Data Collector'', 
		@owner_login_name=N''sa'', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback'
/****** Object:  Step [db0]    Script Date: 10/12/2016 13:59:35 ******/
	
declare @conTypeS varchar
declare @conTypeF varchar
set @conTypeS = '3'
set @conTypeF = '3'
while @i<=@maxNum
begin
	if @i=@maxNum
	begin
		set @conTypeS = '1'
		set @conTypeF = '2'
	end
	set @execstr = @execstr + '
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''db'+CAST(@i as varchar(10))+''', 
			@step_id='+CAST(@i+1 as varchar(10))+', 
			@cmdexec_success_code=0, 
			@on_success_action='+@conTypeS+', 
			@on_success_step_id=0, 
			@on_fail_action='+@conTypeF+', 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N''TSQL'', 
			@command=N''exec DelHisOfInfor'', 
			@database_name=N''SHMonitor_Preplan'+CAST(@i as varchar(10))+''', 
			@flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback'

	set @i=@i+1
end
/****** Object:  Step [db1]    Script Date: 10/12/2016 13:59:35 ******/
set @execstr = @execstr + '
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N''每月第一天删除历史情报板信息表'', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20161012, 
		@active_end_date=99991231, 
		@active_start_time=500, 
		@active_end_time=235959, 
		@schedule_uid=N''ef308066-a1ec-450c-93af-af97e1516a7a''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

'
--print(@execstr) --
exec(@execstr) ---

