use master
go
declare @i int -- �������
declare @dbstr varchar(20) --�������ݿ�����
declare @tbstr varchar(100) -- ���������
declare @tbstr1 varchar(100) -- ���������
declare @enter char(10)	--�س�����
declare @otype1 varchar(10)
declare @otype2 varchar(10)
declare @otype3 varchar(10)
set @enter = CHAR(13)+CHAR(10) --�س�����
set @i = 0 --ѭ����ʶ
set @otype1 = 'delete'
set @otype2 = 'update'
set @otype3 = 'insert'
while 1=1 --while true
begin 
	set @dbstr = 'SHMonitor_Preplan'+CAST(@i as varchar(10))
	if (db_id(@dbstr) is null)	--�ж����ݿ��Ƿ����
		break
	else
	begin
		set @tbstr = '['+ @dbstr + '].[dbo].[��ʷ�鱨����Ϣ��]'
		if (OBJECT_ID(@tbstr,N'U') is null)	--�жϱ��Ƿ����
		begin
			exec('create table ' + @tbstr + '(
												[ID] [int] IDENTITY(1,1) NOT NULL,
												[����ʱ��] [datetime] NULL,
												[��������] [nvarchar](10) NULL,
												[�豸��ַ] [int] NULL,
												[�����б��] [int] NULL,
												[��������] [nvarchar](50) NULL,
												[ͣ��ʱ��] [int] NULL,
												[��/�����ٶ�] [int] NULL,
												[��/������ʽ] [nvarchar](50) NULL,
												[��˸����] [int] NULL,
												[��ʼx����] [int] NULL,
												[��ʼy����] [int] NULL,
												[����] [nvarchar](50) NULL,
												[����߶�] [int] NULL,
												[ǰ����ɫ] [nvarchar](50) NULL,
												[������ɫ] [nvarchar](50) NULL,
												[ͼƬ��] [int] NULL,
												[�б�����] [nvarchar](100) NULL,
												[TID] [int] NOT NULL
											) ON [PRIMARY]')  --��ִ̬�н������
		end	-- end if objectid
		set @tbstr1 = '['+ @dbstr + '].[dbo].[�鱨����Ϣ��]'
		PRINT('use '+@dbstr)  --��ӡ��ǰʹ�����ݿ�
		exec('
		use '+@dbstr+'
		exec(''create trigger tgr_�鱨����Ϣ��_DELETE
				on '+@tbstr1+'
				after delete
				as
				begin
					insert into '+@tbstr+'
					select getdate(),'''''+@otype1+''''',�豸��ַ,�����б��,��������,
					ͣ��ʱ��,[��/�����ٶ�],[��/������ʽ],��˸����,��ʼx����,��ʼy����,����,
					����߶�,ǰ����ɫ,������ɫ,ͼƬ��,�б�����,ID from Deleted
				end'')')--��̬Ƕ�׶�̬,��ִ̬�д���trigger delete
		exec('
		use '+@dbstr+'
		exec(''create trigger tgr_�鱨����Ϣ��_UPDATE
				on '+@tbstr1+'
				after update
				as
				begin
					insert into '+@tbstr+'
					select getdate(),'''''+@otype2+''''',�豸��ַ,�����б��,��������,
					ͣ��ʱ��,[��/�����ٶ�],[��/������ʽ],��˸����,��ʼx����,��ʼy����,����,
					����߶�,ǰ����ɫ,������ɫ,ͼƬ��,�б�����,ID from Deleted
				end'')')--��̬Ƕ�׶�̬,��ִ̬�д���trigger update
		exec('
		use '+@dbstr+'
		exec(''create trigger tgr_�鱨����Ϣ��_INSERT
				on '+@tbstr1+'
				after insert
				as
				begin
					insert into '+@tbstr+'
					select getdate(),'''''+@otype3+''''',�豸��ַ,�����б��,��������,
					ͣ��ʱ��,[��/�����ٶ�],[��/������ʽ],��˸����,��ʼx����,��ʼy����,����,
					����߶�,ǰ����ɫ,������ɫ,ͼƬ��,�б�����,ID from Inserted
				end'')')--��̬Ƕ�׶�̬,��ִ̬�д���trigger	insert
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
					select @datan=count(1) from [dbo].[��ʷ�鱨����Ϣ��] WHERE ����ʱ�� < @D
					SET	@tempD1 = @D
					while(@datan>1)
						begin
							DELETE FROM [dbo].[��ʷ�鱨����Ϣ��] WHERE ����ʱ�� < @tempD1
							select @datan=count(1) from [dbo].[��ʷ�鱨����Ϣ��] WHERE ����ʱ�� < @tempD1
							set @tempD1 = DATEADD(MONTH,-1,@tempD1)
						end		--end of while
				END		--end of begin'')')--��̬Ƕ�׶�̬,��ִ̬�д���trigger	insert
	end	--end if dbid
	
	set @i = @i+1
end	--end while