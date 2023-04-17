import pypyodbc as odbc
import pytest
import sqlalchemy
from sqlalchemy import text
from sqlalchemy.engine import URL


def connection():
    DRIVER_NAME = 'SQL SERVER'
    SERVER_NAME = 'EPUALVIW0BB5'
    DATABASE_NAME = 'TRN'

    connection_string = f"""
        DRIVER={{{DRIVER_NAME}}};
        SERVER={{{SERVER_NAME}}};
        DATABASE={{{DATABASE_NAME}}};
        Trust_Connection=yes;
        uid=USR;
        pwd=AR123;
    """

    connection_url = URL.create("mssql+pyodbc", query={"odbc_connect": connection_string})
    engine = sqlalchemy.create_engine(connection_url, module=odbc)

    return engine.connect()


conn = connection()

hr_jobs_count = text('SELECT count([job_title]) FROM [hr].[jobs]')

hr_jobs_JobTitleWithMaxSalary = text('SELECT [job_title]'
                                     'FROM [TRN].[hr].[jobs] WHERE max_salary = '
                                     '(select max(max_salary) FROM'
                                     '[TRN].[hr].[jobs])')

hr_employee_FirstNameIsNotEmpty = text('SELECT count(*)'
                                       'FROM [TRN].[hr].[employees]'
                                       'WHERE [first_name] is null')

hr_employee_maxDepartmentID = text('SELECT max([department_id])'
                                   'FROM [TRN].[hr].[employees]'
                                   'having max([department_id]) = 11')

hr_countries_DuplicatesCountryName = text('SELECT count(*), [country_name]'
                                          'FROM [TRN].[hr].[countries]'
                                          'group by [country_name]'
                                          'having count(*) > 1')

hr_countries_LenOfCountryID = text('SELECT len(country_id)'
                                   'FROM [TRN].[hr].[countries]'
                                   'where len(country_id) > 2')


class TestDB:
    @pytest.mark.hr_jobs
    def test_count_of_jobs(self):
        res = conn.execute(hr_jobs_count)
        for row in res:
            assert row[0] == 19, f'Count of jobs is incorrect'

    def test_Job_Title_With_Max_Salary(self):
        res = conn.execute(hr_jobs_JobTitleWithMaxSalary)
        for row in res:
            assert row[0] == 'President', f'President doesnt have max salary'

    @pytest.mark.hr_employee
    def test_First_Name(self):
        res = conn.execute(hr_employee_FirstNameIsNotEmpty)
        for row in res:
            assert row[0] <= 1, f'First Name Id Is Empty'

    def test_max_department_ID(self):
        res = conn.execute(hr_employee_maxDepartmentID)
        for row in res:
            assert row[0] == 11, f'Department ID is populated incorrectly'

    @pytest.mark.hr_countries
    def test_Duplicates_CountryName(self):
        res = conn.execute(hr_countries_DuplicatesCountryName)
        for row in res:
            assert row[0] == 0, f'[hr].[countries] contains duplicated'

    def test_Length_Of_CountryID(self):
        res = conn.execute(hr_countries_LenOfCountryID)
        for row in res:
            assert row[0] == 0, f'Length of CountryID > 2'
