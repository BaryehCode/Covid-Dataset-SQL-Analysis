--THE AIM OF THIS PROJECT IS TO GAIN A BETTER UNDERSTANDING ON THE COVID -19 SITUATION THROUGH DATA EXPLORATION AND ANALYSIS IN
--SQL SERVER. THE DATA WAS THEN BE PULLED INTO POWER BI WHERE VISUALIZATIONS WAS CREATED TO FURTHER UNDERSTAND TRENDS IN
--THE COVID PANDEMIC.

-----COVID DATASET ANALYSIS-------
-----COVID DATASET ANALYSIS-------
-----COVID DATASET ANALYSIS-------
--Data was imported from an excel file which was downloaded from <https://ourworldindata.org/covid-deaths> on 05/16/2021
--DATA SPANS 2020-01-01 THROUGH TO 2021-05-15
--Making Id the primary Key however it accepts NULL values so we need to change it into a columnwhich does not accept nulls b4
--we can then run a code to make the column the primary key

ALTER TABLE
  covid_data
ALTER COLUMN
  Id
    INT NOT NULL;

--Now let's make it the primary key

ALTER TABLE covid_data
ADD PRIMARY KEY (Id);

--1.	Checking the dataset

SELECT TOP 5 *
FROM covid_data

--ANSWER
Id	Continent	Location	Date	New_Cases	New_Deaths	ICU_Patients	Hospital_Patients	Weekly_ICU_Admissions	New_Tests	New_Vaccinations	Population	GDP_Per_Capita	C+ardiovasc_death_rate
1	Asia	Afghanistan	2020-02-24 00:00:00.000	1	NULL	NULL	NULL	NULL	NULL	NULL	38928341	1803.987	597.029
2	Asia	Afghanistan	2020-02-25 00:00:00.000	0	NULL	NULL	NULL	NULL	NULL	NULL	38928341	1803.987	597.029
3	Asia	Afghanistan	2020-02-26 00:00:00.000	0	NULL	NULL	NULL	NULL	NULL	NULL	38928341	1803.987	597.029
4	Asia	Afghanistan	2020-02-27 00:00:00.000	0	NULL	NULL	NULL	NULL	NULL	NULL	38928341	1803.987	597.029
5	Asia	Afghanistan	2020-02-28 00:00:00.000	0	NULL	NULL	NULL	NULL	NULL	NULL	38928341	1803.987	597.029


--2.	Checking Number of rows

SELECT COUNT(*)
FROM covid_data

84692

 
 --3.	CONVERTING Date column data type FROM DATETIME to DATE SINCE
 --I WILL NOT USE THE HOURS, MINS AND SECONDS IN MY ANALYSIS

ALTER TABLE COVID_DATA
ALTER COLUMN [Date] DATE

 --4.	CHECKING EARLIEST DATE AND No. OF RECORDS FOR THAT DATE

SELECT MIN([Date])
FROM covid_data
 
 
SELECT *
FROM covid_data
WHERE [Date] like '2020-01-01'

SELECT COUNT(*)
FROM covid_data
Where [Date] like '2020-01-01'

--5.	CHECKING LATEST DATE AND No. OF RECORDS FOR THAT DATE

SELECT MAX([Date])
FROM covid_data
 
 
SELECT *
FROM covid_data
WHERE [Date] like '2021-05-15'

--number of records for last day

SELECT COUNT(*)
FROM covid_data
WHERE [Date] like '2021-05-15'

194

--6.	CONTINENTS DATA IS COLLETED ON

 SELECT DISTINCT(Continent)
 FROM covid_data

 Continent
North America
Asia
Africa
Oceania
South America
Europe

--7.	TOTAL CASES PER CONTINENT

 SELECT Continent, SUM([New_Cases]) AS [Total Cases]
 FROM covid_data
 GROUP BY Continent
 ORDER BY [Total Cases] DESC
 
--As at 2021-05-15 Europe is leading in reported cases with 46,298,857
--followed closely by Asia. North America is the third on the list with
--38346978 reported cases. The continent withthe least amount of cases is oceania


--8.	TOTAL DEATHS PER CONTINENT

 SELECT Continent, SUM(CAST([New_Deaths] AS INT)) AS Deaths
 FROM covid_data
 GROUP BY Continent
 ORDER BY Deaths DESC

--As at 2021-05-15 Europe is leading in reported deaths with 1050725
--followed  by North America. South America is the third on the list with
--726114 reported cases. The continent withthe least amount of deaths is oceania

--8.	RECOVERY

 SELECT Continent, SUM([New_Cases]) AS [Total Cases], SUM(CAST([New_Deaths] AS INT)) AS Deaths, (SUM([New_Cases])) - (SUM(CAST([New_Deaths] AS INT))) AS [Cases minus Deaths]
 FROM covid_data
 WHERE [DATE] BETWEEN '2020-01-01' AND '2021-03-31' 
 GROUP BY Continent
 ORDER BY [Total Cases] DESC
 --Assuming it took on average one and a half months for those who died from the desease to succumb to it then the 
 --syntax above gives a rough estimate of people the number of those who have recovered from the desease.
 
 --9.	HIGHEST RRECORDED MORTALITY AND DATE IT OCCURED

 SELECT TOP 1 Location, MAX(CAST([New_Deaths] AS INT)), [Date]
 FROM covid_data
 GROUP BY [Location], [Date]
 ORDER BY MAX(CAST([New_Deaths] AS INT)) DESC

--United States	4475	2021-01-12

 --10.	HIGHEST RRECORDED CASES AND DATE

 SELECT TOP 1 Location, MAX([New_Cases]), [Date]
 FROM covid_data
 GROUP BY [Location], [Date]
 ORDER BY MAX([New_Cases]) DESC


--India	  414188	2021-05-06

--11.	CHECKING WHAT DATE(TIME) VACCINATIONS STARTED BEING RECORDED. DAYS WHERE THERE WERE NO RECORD OF VACCINATIONS
--ARE NULL

SELECT top 1*
FROM covid_data
WHERE New_Vaccinations IS  NOT NULL

--Vaccinations began being recorded from 2021-01-13

--LET'S VERIFY. SINCE THE Id OF THE RECORD FOR THE 2021-01-13 IS771, LET'S CHECK WHETHER THE New Vaccination
--FIELD FOR THE RECORD WITH Id OF 770 IS NULL

select *
from covid_data 
where Id like 770

--LETS CHECK OTHER RCORDS PRECEDDING THE RECORD WITH Id OF 770 FOR FURTHER VERIFICATION


SELECT DISTINCT New_Vaccinations
FROM covid_data
WHERE Id < 771

-- They are all NULL

--CHECKING VALUES IN New_Vaccinations column to make sure they are all nulls

SELECT Continent, Location, New_Cases, New_Deaths, New_Vaccinations
FROM covid_data
WHERE Id < 771

--11.	LET'S CHECK TOTAL VACCINATIONS TILL DATE

SELECT SUM(CAST(New_Vaccinations AS INT))
FROM covid_data

-- 1235580968 vaccinations as at 2021-05-15

-- NOW LETS DRILL DOWN TO THE USA SINCE THAT'S WHERE I LIVE

--12	SUMMARY

SELECT Location, SUM(New_Cases) as Cases,
SUM(CAST(New_Deaths AS INT)) as Deaths,
SUM(CAST([New_Tests] AS INT)) as Tests,
SUM(CAST([New_Vaccinations] AS INT)) as Vaccinations
FROM covid_data
WHERE Location LIKE 'United States'
GROUP BY Location
[Location]		[New_Cases]	[New_Deaths]	[New_Tests]	[New_Vaccinations]
United States	32923981	585708	429959899	258263484

--13.	 prevalence Rate in the United States (Number of cases/Total population)

--No. of Cases
SELECT SUM(New_Cases)
FROM covid_data
WHERE Location LIKE 'United States'

32923981

--Total Polupation in United States
SELECT DISTINCT Population
FROM covid_data
WHERE Location LIKE 'United States'

331002647

--prevalence Rate

SELECT	CONCAT(  (ROUND(((SUM(New_Cases)/ 331002647) * 100),2)), '%') as [Prevalence Rate]
FROM covid_data
WHERE Location LIKE 'United States'

9.95%

--MORTALITY RATE (Number of Deaths due to a disease divided by the population


--METHOD 1
SELECT 
SUM(CAST([New_Deaths] AS FLOAT))/SUM([Population])
FROM covid_data
WHERE Location LIKE 'United States'

3.68645088206802E-06

--METHOD 2

select (
(
SELECT SUM(CAST([New_Deaths] AS FLOAT))
FROM covid_data
WHERE Location LIKE 'United States'
)

/

(
SELECT SUM([Population])
FROM covid_data
WHERE Location LIKE 'United States'
)
) as [Mortality Rate]


-- 14.	U.S Population and vaccinations. however it is unclear whether the numbers for vaccinations count individual doses

SELECT ([Population]), SUM(CAST([New_Vaccinations] AS INT))
FROM covid_data
WHERE Location LIKE 'United States'
GROUP BY [Population]


SELECT TOP 5 *
FROM covid_data