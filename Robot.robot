*** Settings ***
Documentation  Database Testing in Robot Framework
Library        DatabaseLibrary

Suite Setup    Connect To Database Using Custom Params    pymssql     host=${DBHost}, user=${DBUser}, password=${DBPass}, database=${DBName}, port=${DBPort}
Suite Teardown    Disconnect From Database

*** Variables ***

${DBHost}   'EPUALVIW0BB5'
${DBUser}   'USR'
${DBPass}   'AR123'
${DBName}   'TRN'
${DBPort}   '1433'

*** Test Cases ***


Verify that Table is present
    [Documentation]
    ...  | *Expected result:*
    ...  | Table hr.Employees is present in TRN DB.
    Table Must Exist      Employees

Verify that the row count is 40
    [Documentation]
    ...  | *Expected result:*
    ...  | Count of rows is 40.
    Row Count Is Equal To X  SELECT * FROM hr.Employees  40

Verify that [hr].[countries] contain only expected values
    [Documentation]
    ...  | *Expected result:*
    ...  | Country_id in table [hr].[countries] is not Null
    Check If Not Exists In Database    SELECT * FROM [hr].[countries] where [country_id] not in ('AR', 'AU', 'BE', 'BR', 'CA', 'CH', 'CN', 'DE', 'DK', 'EG', 'FR', 'HK', 'IL', 'IN', 'IT', 'JP', 'KW', 'MX', 'NG', 'NL', 'SG', 'UK', 'US', 'ZM', 'ZW')

Verify that country_id in table [hr].[countries] is not Null
    [Documentation]
    ...  | *Expected result:*
    ...  | Country_id in table [hr].[countries] is not Null
    Check If Not Exists In Database   SELECT * FROM [hr].[countries] Where [country_id] is Null

Verify that count of department_id is less then 12
    [Documentation]
    ...  | *Expected result:*
    ...  | Table [hr].[departments] contains less then 12 rows
    Row Count Is Less Than X    SELECT [department_id] FROM [hr].[departments]   12

Verify that count of department_id is 0
    [Documentation]
    ...  | *Expected result:*
    ...  | Table [hr].[departments] contains less then 12 rows
    Row Count Is 0       SELECT [department_id] FROM [hr].[departments] Where [department_name] not in ('Administration', 'Marketing', 'Purchasing', 'Human Resources', 'Shipping', 'IT', 'Public Relations', 'Sales', 'Executive', 'Finance', 'Accounting')