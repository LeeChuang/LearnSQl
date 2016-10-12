use master
go
declare @i int -- 定义变量
declare @dbstr varchar(20) --定义数据库名称
declare @tbstr varchar(100) -- 定义表名称
declare @tbstr1 varchar(100) -- 定义表名称
declare @enter char(10)	--回车换行
declare @otype1 varchar(10)
declare @otype2 varchar(10)
declare @otype3 varchar(10)
set @enter = CHAR(13)+CHAR(10) --回车换行
set @i = 0 --循环标识
set @otype1 = 'delete'
set @otype2 = 'update'
set @otype3 = 'insert'
while 1=1 --while true
begin 
	set @dbstr = 'SHMonitor_Preplan'+CAST(@i as varchar(10))
	if (db_id(@dbstr) is null)	--判断数据库是否存在
		break
	else
	begin
		set @tbstr = '['+ @dbstr + '].[dbo].[历史情报板信息表]'
		if (OBJECT_ID(@tbstr,N'U') is null)	--判断表是否存在
		begin
			exec('create table ' + @tbstr + '(
												[ID] [int] IDENTITY(1,1) NOT NULL,
												[更改时间] [datetime] NULL,
												[操作类型] [nvarchar](10) NULL,
												[设备地址] [int] NULL,
												[播放列表号] [int] NULL,
												[文字内容] [nvarchar](50) NULL,
												[停留时间] [int] NULL,
												[出/入屏速度] [int] NULL,
												[出/入屏方式] [nvarchar](50) NULL,
												[闪烁次数] [int] NULL,
												[起始x坐标] [int] NULL,
												[起始y坐标] [int] NULL,
												[字体] [nvarchar](50) NULL,
												[字体高度] [int] NULL,
												[前景颜色] [nvarchar](50) NULL,
												[背景颜色] [nvarchar](50) NULL,
												[图片号] [int] NULL,
												[列表名称] [nvarchar](100) NULL,
												[TID] [int] NOT NULL
											) ON [PRIMARY]')  --动态执行建表操作
		end	-- end if objectid
		set @tbstr1 = '['+ @dbstr + '].[dbo].[情报板信息表]'
		PRINT('use '+@dbstr)  --打印当前使用数据库
		exec('
		use '+@dbstr+'
		exec(''create trigger tgr_情报板信息表_DELETE
				on '+@tbstr1+'
				after delete
				as
				begin
					insert into '+@tbstr+'
					select getdate(),'''''+@otype1+''''',设备地址,播放列表号,文字内容,
					停留时间,[出/入屏速度],[出/入屏方式],闪烁次数,起始x坐标,起始y坐标,字体,
					字体高度,前景颜色,背景颜色,图片号,列表名称,ID from Deleted
				end'')')--动态嵌套动态,动态执行创建trigger delete
		exec('
		use '+@dbstr+'
		exec(''create trigger tgr_情报板信息表_UPDATE
				on '+@tbstr1+'
				after update
				as
				begin
					insert into '+@tbstr+'
					select getdate(),'''''+@otype2+''''',设备地址,播放列表号,文字内容,
					停留时间,[出/入屏速度],[出/入屏方式],闪烁次数,起始x坐标,起始y坐标,字体,
					字体高度,前景颜色,背景颜色,图片号,列表名称,ID from Deleted
				end'')')--动态嵌套动态,动态执行创建trigger update
		exec('
		use '+@dbstr+'
		exec(''create trigger tgr_情报板信息表_INSERT
				on '+@tbstr1+'
				after insert
				as
				begin
					insert into '+@tbstr+'
					select getdate(),'''''+@otype3+''''',设备地址,播放列表号,文字内容,
					停留时间,[出/入屏速度],[出/入屏方式],闪烁次数,起始x坐标,起始y坐标,字体,
					字体高度,前景颜色,背景颜色,图片号,列表名称,ID from Inserted
				end'')')--动态嵌套动态,动态执行创建trigger	insert
		exec('
		use '+@dbstr+'
		exec(''CREATE PROCEDURE [dbo].[DelHisOfInfor]
					-- Add the parameters for the stored procedure here
				AS
				BEGIN
					-- SET NOCOUNT ON added to prevent extra result sets from
					-- interfering with SELECT statements.
					declare @D SMALLDATETIME
					declare @tempD1 SMALLDATETIME
					declare @datan int
					
					SET @D = DATEADD(MONTH,-1,GETDATE())
					select @datan=count(1) from [dbo].[历史情报板信息表] WHERE 更改时间 < @D
					SET	@tempD1 = @D
					while(@datan>1)
						begin
							DELETE FROM [dbo].[历史情报板信息表] WHERE 更改时间 < @tempD1
							select @datan=count(1) from [dbo].[历史情报板信息表] WHERE 更改时间 < @tempD1
							set @tempD1 = DATEADD(MONTH,-1,@tempD1)
						end		--end of while
				END		--end of begin'')')--动态嵌套动态,动态执行创建trigger	insert
	end	--end if dbid
	
	set @i = @i+1
end	--end while