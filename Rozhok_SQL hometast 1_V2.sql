----V2

declare @str varchar(500) = '{"employee_id": "5181816516151", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "925155", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "815153", "department_id": "2", "class": "src\bin\comp\json"}, {"employee_id": "967", "department_id": "", "class": "src\bin\comp\json"}'
--select @str
;

WITH
	parsed_data ( [employee_id], [items], [department_id], [items_dep]
	) AS
	(

		select 
				left(stuff(@str,1,CHARINDEX('employee_id": "', @str+'employee_id": "')-1+15, ''), CHARINDEX('", "',stuff(@str,1,CHARINDEX('employee_id": "', @str+'employee_id": "')-1+15, ''))-1) as employee_id
				,STUFF(@str,1,CHARINDEX('employee_id": "', @str+'employee_id": "')-1+15,'') as items
				,LEFT(STUFF(@str,1,CHARINDEX('department_id": "', @str+'department_id": "')-1+17,''), CHARINDEX('", "', STUFF(@str,1,CHARINDEX('department_id": "', @str+'department_id": "')-1+17,'')) -1) as department_id
				,STUFF(@str,1,CHARINDEX('department_id": "', @str+'department_id": "')-1+17,'') as items_dep

		union all

		select 
				left(stuff(items,1,CHARINDEX('employee_id": "', items+'employee_id": "')-1+15, ''), CHARINDEX('", "',stuff(items,1,CHARINDEX('employee_id": "', items+'employee_id": "')-1+15, ''))-1)
				,STUFF([items],1,CHARINDEX('employee_id": "', [items]+'employee_id": "')-1+15,'')
				,LEFT(STUFF(items_dep,1,CHARINDEX('department_id": "', items_dep+'department_id": "')-1+17,''), CHARINDEX('", "', STUFF(items_dep,1,CHARINDEX('department_id": "', items_dep+'department_id": "')-1+17,''))-1 )
				,STUFF(items_dep,1,CHARINDEX('department_id": "', items_dep+'department_id": "')-1+17,'')
		from parsed_data
		where items > '' or items_dep > ''

	)
select
	[employee_id]
	,[department_id]
from parsed_data;