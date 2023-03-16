--drop procedure Statistics_on_DB

create procedure Statistics_on_DB
@p_DatabaseName nvarchar(max),
@p_SchemaName nvarchar(max),
@p_TableName nvarchar(max)
as
begin


drop table if exists #v_TablesList
create table #v_TablesList (
							[Database_Name] varchar(max),
							[Schema_Name] varchar(max),
							[Table_Name] varchar(max), 
							[Column_Name] varchar(max),
							[Data_Type] varchar(max)
							);

declare @sql nvarchar(200)
   
set @sql='use'
select @sql = @sql + ' ' + @p_DatabaseName + ' SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME,  COLUMN_NAME, DATA_TYPE from INFORMATION_SCHEMA.COLUMNS'
insert into #v_TablesList Exec sp_executesql @sql

declare @v_Query nvarchar(MAX);

WITH
	tbl_list AS
	(
		select
			[Database_Name],
			[Schema_Name],
			[Table_Name],
			LEAD([Table_Name]) OVER (ORDER BY [Table_Name]) [lead_row],
			[Column_Name],
			[Data_Type]
		from #v_TablesList
		where 1 = 1
			AND [Schema_Name] IN (@p_SchemaName)
			AND [Table_Name] LIKE (@p_TableName)			
	)
	,query_not_agg AS
	(
		select case when [lead_row] IS NOT NULL then 
					'SELECT ''' + [Database_Name] + ''' [Database_Name],''' + [Schema_Name] + ''' [Schema_Name],''' + [Table_Name] + ''' [Table_Name],COUNT(*) [Table total row count],''' + [Column_Name] + ''' [Column_Name],
					''' + [Data_Type] + ''' [Data_Type],COUNT(DISTINCT(' + [Column_Name] + ')) [Count of DISTINCT values],(SELECT COUNT(*) FROM [' + [Database_Name] + '].[' + [Schema_Name] + '].[' + [Table_Name] + '] WHERE [' + [Column_Name] + '] IS NULL ) [Count of NULL values],
					(SELECT SUM(CASE WHEN ''' + [Data_Type] + ''' LIKE (''%char'') AND HASHBYTES(''SHA2_256'', CAST(' + [Column_Name] + ' AS varchar)) = HASHBYTES(''SHA2_256'', UPPER(CAST(' + [Column_Name] + ' AS varchar))) THEN 1 ELSE 0 END) FROM [' + [Database_Name] + '].[' + [Schema_Name] + '].[' + [Table_Name] + ']) AS [Count of Upper Case],
					(SELECT MIN(CAST(' + [Column_Name] + ' AS varchar)) FROM [' + [Database_Name] + '].[' + [Schema_Name] + '].[' + [Table_Name] + ']) [MIN_value]
					FROM [' + [Database_Name] + '].[' + [Schema_Name] + '].[' + [Table_Name] + '] UNION ALL '
				when [lead_row] IS NULL	then
					'SELECT ''' + [Database_Name] + ''' [Database_Name],''' + [Schema_Name] + ''' [Schema_Name],''' + [Table_Name] + ''' [Table_Name],COUNT(*) [Table total row count],
					''' + [Column_Name] + ''' [Column_Name],''' + [Data_Type] + ''' [Data_Type],COUNT(DISTINCT(' + [Column_Name] + ')) [Count of DISTINCT values],
					(SELECT COUNT(*) FROM [' + [Database_Name] + '].[' + [Schema_Name] + '].[' + [Table_Name] + '] WHERE [' + [Column_Name] + '] IS NULL ) [Count of NULL values],
					(SELECT SUM(CASE WHEN ''' + [Data_Type] + ''' LIKE (''%char'') AND HASHBYTES(''SHA2_256'', CAST(' + [Column_Name] + ' AS varchar)) = HASHBYTES(''SHA2_256'', UPPER(CAST(' + [Column_Name] + ' AS varchar))) THEN 1 ELSE 0 END) FROM [' + [Database_Name] + '].[' + [Schema_Name] + '].[' + [Table_Name] + ']) AS [Count of Upper Case],
					(SELECT MIN(CAST(' + [Column_Name] + ' AS varchar)) FROM [' + [Database_Name] + '].[' + [Schema_Name] + '].[' + [Table_Name] + ']) [MIN_value]
					FROM [' + [Database_Name] + '].[' + [Schema_Name] + '].[' + [Table_Name] + ']'
				else 'N/A'
			end [query_text]
		from tbl_list
	)
select 
	@v_Query = STRING_AGG(CAST([query_text] as nvarchar(MAX)), '')
from query_not_agg

EXEC SP_EXECUTESQL @v_Query;

end


EXEC Statistics_on_DB @p_DatabaseName = 'TRN', @p_SchemaName = 'hr', @p_TableName = '%'


