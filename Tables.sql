#Create a new table with the sum of visitos every year in every region/country
CREATE TABLE yearly_visitors_by_region AS
SELECT 
    Year,
    Region,
    SUM(Total) AS Total,
    SUM(Tourist) AS Tourist,
    SUM(Business) AS Business,
    SUM(Others) AS Others,
    SUM(Short_Excursion) AS Short_Excursion
FROM cleaned_visitors_by_region
GROUP BY Year, Region
ORDER BY Year, Region;

#Create a new table with the region/country names as entries in every row instead of at the top of every column
CREATE TABLE yearly_spending AS
SELECT Year, 'Australia' AS Region, `Australia` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'Canada' AS Region, `Canada` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'China' AS Region, `China` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'France' AS Region, `France` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'Germany' AS Region, `Germany` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'India' AS Region, `India` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'Indonesia' AS Region, `Indonesia` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'Italy' AS Region, `Italy` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'Malaysia' AS Region, `Malaysia` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'Philippines' AS Region, `Philippines` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'Russia' AS Region, `Russia` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'Singapore' AS Region, `Singapore` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'Spain' AS Region, `Spain` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'Taiwan' AS Region, `Taiwan` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'United Kingdom' AS Region, `United Kingdom` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'United States' AS Region, `United States` AS Spending FROM country_spending
UNION ALL
SELECT Year, 'Vietnam' AS Region, `Vietnam` AS Spending FROM country_spending;

#Change the name given in yearly_spending
UPDATE yearly_spending
SET Region = 'U.S.A.'
WHERE Region = 'United States';

#Combine both tables to have one table with all the data needed
CREATE TABLE yearly_visitors_with_spending AS
SELECT 
    v.Year,
    v.Region,
    v.Total,
    v.Tourist,
    v.Business,
    v.Others,
    v.Short_Excursion,
    s.Spending
FROM yearly_visitors_by_region v
JOIN yearly_spending s
    ON v.Year = s.Year AND v.Region = s.Region;

#Create a new table with the total spending and create a new column for the year over year growth rate and set all as NULL
CREATE TABLE yearly_spending_summary AS
SELECT 
    curr.Year,
    curr.Region,
    (curr.Total * curr.Spending) AS TotalSpending,
    NULL AS YOY_Growth
FROM yearly_visitors_with_spending AS curr;

#Allow to store decimals instead of INT
ALTER TABLE yearly_spending_summary
MODIFY COLUMN YOY_Growth DECIMAL(6,2);

#Update the YOY_Growth column
UPDATE yearly_spending_summary AS curr
JOIN yearly_spending_summary AS prev
  ON curr.Region = prev.Region AND curr.Year = prev.Year + 1
SET curr.YOY_Growth = 
  ROUND( (curr.TotalSpending - prev.TotalSpending) / prev.TotalSpending * 100, 2 );



    




