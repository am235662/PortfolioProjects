SELECT * FROM sql_project.insuranceclaims;

-- creating table--
CREATE TABLE sql_project.InsuranceClaims (
    Company VARCHAR(255),
    FileNo INT,
    Opened DATE,
    Closed DATE,
    Coverage VARCHAR(50),
    SubCoverage VARCHAR(50),
    Reason VARCHAR(255),
    SubReason VARCHAR(255),
    Disposition VARCHAR(255),
    Conclusion VARCHAR(255),
    Recovery DECIMAL(10, 2),
    ClaimStatus VARCHAR(50)
);

-- Modifying data type of Coverage and Sub Coverage columns --
ALTER TABLE sql_project.insuranceclaims
modify Coverage varchar(300);
ALTER TABLE sql_project.insuranceclaims
modify SubCoverage varchar(300);


-- Load CSV data into the table -- 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/InsuranceClaims.csv'
INTO TABLE sql_project.insuranceclaims
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
(@Company, @FileNo, @Opened, @Closed, @Coverage, @SubCoverage, @Reason, @SubReason, @Disposition, @Conclusion, @Recovery, @ClaimStatus)
SET
    Company = @Company,
    FileNo = @FileNo,
    Opened = CASE WHEN @Opened <> '' THEN STR_TO_DATE(@Opened, '%c/%e/%Y') ELSE NULL END,
    Closed = CASE WHEN @Closed <> '' THEN STR_TO_DATE(@Closed, '%c/%e/%Y') ELSE NULL END,
    Coverage = @Coverage,
    SubCoverage = @SubCoverage,
    Reason = @Reason,
    SubReason = @SubReason,
    Disposition = @Disposition,
    Conclusion = @Conclusion,
    Recovery = @Recovery,
    ClaimStatus = @ClaimStatus;

--------------------------------------------------------------------------------------
-- Retrieve all columns for the first 5 rows in the dataset.--
select * from sql_project.insuranceclaims
limit 100;
--------------------------------------------------------------------------------------
-- Count the total number of closed claims.--
SELECT COUNT(*)
FROM sql_project.insuranceclaims
WHERE ClaimStatus LIKE '%Closed%';

--------------------------------------------------------------------------------------
-- List unique coverage types present in the dataset. --
SELECT DISTINCT Coverage
FROM sql_project.insuranceclaims
where Coverage != "";

--------------------------------------------------------------------------------------
-- Calculate the average recovery amount for claims that were settled.--
select round(avg(Recovery),2) as `Average Recovery`
from sql_project.insuranceclaims;

--------------------------------------------------------------------------------------
-- Retrieve the count of distinct companies present in the dataset. --
select count(distinct Company)
from sql_project.insuranceclaims;

--------------------------------------------------------------------------------------
-- Display the top 5 reasons for claim denials. --
select Reason, count(SubReason) as Status
from sql_project.insuranceclaims
where SubReason like '%Denial%'
group by Reason
order by Status
limit 5;

--------------------------------------------------------------------------------------
--  Find the earliest and latest claim opened dates.--
select min(Opened)
from insuranceclaims;

--------------------------------------------------------------------------------------
-- Count the number of claims that have a non-zero recovery amount.--
select count(*) 
from insuranceclaims
where recovery != 0;

--------------------------------------------------------------------------------------
-- List the companies and their average claim settlement time (difference between Closed and Opened dates).--
select Company, ROUND(AVG(TIMESTAMPDIFF(Day, Opened, Closed)), 2) as `Average Settlement Date`
from insuranceclaims
group by Company
order by Company, `Average Settlement Date` Desc;

--------------------------------------------------------------------------------------
-- Calculate the percentage of claims that were satisfied ('Satisfied' in Conclusion) for each company.--
SELECT
    Company,
    ROUND(SUM(CASE WHEN Conclusion = 'Satisfied' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS SatisfiedPercentage
FROM insuranceclaims
GROUP BY Company
order by SatisfiedPercentage Desc;

--------------------------------------------------------------------------------------
-- Calculate the average recovery amount for each coverage type. --
select Coverage, Round( avg (Recovery), 2) as AverageRecovery
from insuranceclaims
group by Coverage
order by AverageRecovery Desc;

--------------------------------------------------------------------------------------
-- Identify the top 5 sub-reasons for claims with the highest recovery amounts.--
select SubReason, sum(Recovery) as HighestRecovery
from insuranceclaims
group by SubReason
order by HighestRecovery desc
limit 5;

-- Find the company with the highest number of duplicate coverage-related claims --
SELECT Company, COUNT(*) AS DuplicateCoverageClaims
FROM insuranceclaims
WHERE Coverage IS NOT NULL
GROUP BY Company
HAVING COUNT(*) > 1
ORDER BY DuplicateCoverageClaims DESC
LIMIT 1;

-- Calculate the average recovery amount for each company and coverage type combination. --
select Company, Coverage, round(avg(Recovery),2) as AverageRecovery
from insuranceclai	ms
where Coverage != "" and Coverage is not null
group by Company, Coverage
order by AverageRecovery desc;

-- Identify the coverage type that has the highest average recovery amount.--
select Coverage , round(avg(Recovery),2) as averageRecovery
from insuranceclaims
where Coverage != "" and Coverage is not null
group by Coverage
order by averageRecovery desc
limit 1;

-- Find the top 10 companies with the most denied claims. --
select Company, count(Case when Conclusion like '%Coverage Denied%' Then 1 else 0 End) as DenialClaims 
from insuranceclaims
group by Company
order by DenialClaims desc
limit 10;

-- Calculate the average claim settlement time for each reason, and order the results by time.--
select Reason,  round(avg(timestampdiff(Day, Opened, Closed)), 2) as `Average Settlement Date`
from insuranceclaims
group by Reason
order by `Average Settlement Date` desc; 

select Company, timestampdiff(day,Opened,Closed) as DateDiff
from insuranceclaims
where Closed is null;















