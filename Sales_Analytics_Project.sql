-- =========================================
-- SALES ANALYTICS PROJECT
-- =========================================
-- Q1. MANAGEMENT SUMMARY
-- Total Revenue
-- Total Orders
-- Total Customers
-- Average Order Value

Select Sum(Sales) As Total_Revenue,
Count(*) As Total_Orders,
Count(Distinct CustomerID) As Total_Customers,
Avg(Sales) As Average_Order_Value
From Orders;

-- =========================================
-- Q2. MONTHLY SALES TREND
-- =========================================

SELECT
    MONTH(OrderDate) AS Month,
    SUM(Sales) AS Total_Sales
FROM Orders
GROUP BY MONTH(OrderDate)
ORDER BY Month;

-- =========================================
-- Q3. REGION PERFORMANCE
-- =========================================

Select Region, Sum(Sales) As Regionwise_Sales
From Orders
Group by Region
Order by Regionwise_Sales Desc;

-- =========================================
-- Q4. CATEGORY PERFORMANCE
-- =========================================

Select Category, Sum(Sales) As Categorywise_Sales
From orders
Group by Category
Order by Categorywise_Sales Desc;

-- =========================================
-- Q5. PRODUCT PERFORMANCE
-- =========================================

Select Product, Sum(Sales) As Productwise_Sales
From Orders
Group by Product
Order by Productwise_Sales Desc;

-- =========================================
-- Q6. CUSTOMER PERFORMANCE
-- =========================================

Select c.customerID As CustomerID,
c.CustomerName As CustomerName,
Sum(o.Sales) As Customerwise_Sales
From Orders o
Join Customers c 
On o.CustomerID = c.CustomerID
Group By c.CustomerID, c.CustomerName
Order by Customerwise_Sales Desc;
 
-- =========================================
-- Q7. TOP PRODUCT BY CATEGORY
-- =========================================

With Product_Detail As (Select Category, Product, Sum(Sales) As Total_Sales
From Orders
Group by Category, Product),
Ranked_Product As (Select Category, Product, Total_Sales,
dense_rank() Over(Partition by Category Order by Total_Sales Desc) As Rnk
From Product_Detail)
Select Category, Product, Total_Sales
From Ranked_Product
Where Rnk = 1;

-- =========================================
-- Q8. TOP CUSTOMER BY REGION
-- =========================================

With Regionwise_Detail As (Select c.CustomerID, c.CustomerName, o.Region,
Sum(o.Sales) As Total_Sales
From Orders o 
Join Customers c 
On o.CustomerID = c.CustomerID
Group By c.CustomerID, c.CustomerName, o.Region),
Ranked_Region As (Select CustomerID, CustomerName, Region, Total_Sales,
dense_rank() Over(Partition By CustomerID Order By Total_Sales Desc) As Rnk
From Regionwise_Detail)
Select CustomerID, CustomerName, Region, Total_Sales
From Ranked_Region
Where Rnk = 1
Order by Total_Sales Desc;

-- =========================================
-- Q9. MONTH-OVER-MONTH GROWTH
-- =========================================

With Monthwise_Sales As (Select Month(OrderDate) As Month_No, 
Sum(Sales) As Total_Sales
From Orders 
Group by Month(OrderDate)),
Previous_Month_Sale As (Select Month_No, Total_Sales,
Lag(Total_Sales) over(Order By Month_No) As Previous_Month_Sales
From Monthwise_Sales)
Select Month_No, Total_Sales, Previous_Month_Sales,
((Total_Sales - Previous_Month_Sales)/Previous_Month_Sales) * 100 As MoM_Growth_Percentage
From Previous_Month_Sale;

-- =========================================
-- Q10. CUSTOMER SEGMENTATION
-- =========================================

With Segment As (Select C.CustomerID, c.CustomerName, sum(o.Sales) As Total_Sales
From Orders o 
Join Customers c 
On o.CustomerID = c.CustomerID
Group by o.CustomerID, c.CustomerID) 
Select CustomerID, CustomerName, Total_Sales,
Case
    When Total_Sales > 300000 then "High Value"
    When Total_Sales >= 210000 then "Medium Value"
    Else "Low Value"
    End As Segment
From Segment
Order by Total_Sales Desc;

-- =========================================
-- Q11. CUSTOMER SEGMENT DISTRIBUTION
-- =========================================

With Segment As (Select C.CustomerID, c.CustomerName, sum(o.Sales) As Total_Sales
From Orders o 
Join Customers c 
On o.CustomerID = c.CustomerID
Group by o.CustomerID, c.CustomerID),
Count_Segment as (Select CustomerID, CustomerName, Total_Sales,
Case
    When Total_Sales > 300000 then "High Value"
    When Total_Sales >= 210000 then "Medium Value"
    Else "Low Value"
    End As Segment
From Segment)
Select Segment, Count(*) As Customers
From Count_Segment
Group by Segment 
Order by Count(*) Desc;

-- =========================================
-- Q12. SEGMENT-WISE REVENUE
-- =========================================

With Segment As (Select C.CustomerID, c.CustomerName, sum(o.Sales) As Total_Sales
From Orders o 
Join Customers c 
On o.CustomerID = c.CustomerID
Group by o.CustomerID, c.CustomerID),
Count_Segment as (Select CustomerID, CustomerName, Total_Sales,
Case
    When Total_Sales > 300000 then "High Value"
    When Total_Sales >= 210000 then "Medium Value"
    Else "Low Value"
    End As Segment
From Segment)
Select Segment, Sum(Total_Sales) As Revenue
From Count_Segment
Group By Segment
Order By Revenue Desc;

-- =========================================
-- Q13. SEGMENT-WISE REVENUE CONTRIBUTION
-- =========================================

With Segment As (Select C.CustomerID, c.CustomerName, sum(o.Sales) As Total_Sales
From Orders o 
Join Customers c 
On o.CustomerID = c.CustomerID
Group by o.CustomerID, c.CustomerID),
Count_Segment as (Select CustomerID, CustomerName, Total_Sales,
Case
    When Total_Sales > 300000 then "High Value"
    When Total_Sales >= 210000 then "Medium Value"
    Else "Low Value"
    End As Segment
From Segment),
SegmentRevenue As (Select Segment, Sum(Total_Sales) As Revenue
From Count_Segment
Group By Segment
),
TotalRevenue As (Select Sum(Revenue) As Total_Revenue
From SegmentRevenue)
Select Segment, Revenue, 
(Revenue/Total_Revenue) * 100 As Contribution
From  SegmentRevenue, TotalRevenue;

-- =========================================
-- Q14. CUSTOMER AVERAGE ORDER VALUE
-- =========================================

Select C.CustomerID, c.CustomerName, Count(*) Total_Orders,
Sum(o.Sales) As Total_Sales,
(Sum(o.Sales)/Count(*)) As Average_Order_Value
From Orders o 
Join Customers c 
On o.CustomerID = c.CustomerID
Group By c.CustomerID, c.CustomerName
Order By Average_Order_Value Desc;

-- =========================================
-- Q15. CUSTOMER PURCHASE FREQUENCY
-- =========================================

Select c.CustomerID, c.CustomerName, Count(*) As Total_Order,
 Count(Distinct Month(OrderDate)) As Active_Month,
(Count(*)/Count(Distinct Month(OrderDate))) As Order_Per_Month
From Orders o 
Join Customers c 
On o.CustomerID = c.CustomerID
Group By c.CustomerID, c.CustomerName;

-- =========================================
-- Q16. CUSTOMER MONTHLY SPENDING
-- =========================================

Select c.CustomerID, c.CustomerName, sum(o.Sales) As Total_Spending,
 Count(Distinct Month(OrderDate)) As Active_Month,
(Sum(o.Sales)/Count(Distinct Month(OrderDate))) As Spending_Per_Month
From Orders o 
Join Customers c 
On o.CustomerID = c.CustomerID
Group By c.CustomerID, c.CustomerName
Order by Spending_Per_Month Desc;

-- =========================================
-- Q17. CUSTOMER MONTHLY SPENDING RANK
-- =========================================

With CustomerData As (Select c.CustomerID, c.CustomerName, sum(o.Sales) As Total_Spending,
 Count(Distinct Month(OrderDate)) As Active_Month,
(Sum(o.Sales)/Count(Distinct Month(OrderDate))) As Spending_Per_Month
From Orders o 
Join Customers c 
On o.CustomerID = c.CustomerID
Group By c.CustomerID, c.CustomerName
Order by Spending_Per_Month Desc)
Select CustomerID, CustomerName, Spending_Per_Month,
dense_rank() Over(Order By Spending_Per_Month Desc) As Rnk
From CustomerData;

-- =========================================
-- Q18. REPEAT PURCHASE ANALYSIS
-- =========================================

Select c.CustomerID, c.CustomerName, o.Product, Count(*) As Purchase_Count
From Orders o 
Join Customers c 
On o.CustomerID = c.CustomerID
Group By c.CustomerID, c.CustomerName, o.Product
Having Count(*) > 1;

-- =========================================
-- Q19. REPEAT PURCHASE RATE
-- =========================================

With CustomerData as (Select c.CustomerID, c.CustomerName, o.Product, Count(*) As Purchase_Count
From Orders o 
Join Customers c 
On o.CustomerID = c.CustomerID
Group By c.CustomerID, c.CustomerName, o.Product
Having Count(*) > 1),
RepeatOrders As (Select CustomerID, CustomerName, Sum(Purchase_Count) As Repeat_Order
From CustomerData
Group By CustomerID, CustomerName),
TotalOrders As (Select CustomerID, Count(*) As Total_Order
From Orders
Group by CustomerID)
Select r.CustomerID, r.CustomerName, t.Total_Order, r.Repeat_Order,
(r.Repeat_Order/t.Total_Order) * 100 As Rate
From RepeatOrders r
Join TotalOrders t
On r.CustomerID = t.CustomerID;

-- =========================================
-- Q20. REPEAT REVENUE RATE
-- =========================================

With CustomerData as (Select c.CustomerID, c.CustomerName, o.Product, Count(*) As Purchase_Count,
Sum(o.Sales) As Total_Sales
From Orders o 
Join Customers c 
On o.CustomerID = c.CustomerID
Group By c.CustomerID, c.CustomerName, o.Product
Having Count(*) > 1),
RepeatOrders As (Select CustomerID, CustomerName, Sum(Total_sales) As Repeat_Sales
From CustomerData
Group By CustomerID, CustomerName),
TotalOrders As (Select CustomerID, Sum(Sales) As Total_Sales
From Orders
Group by CustomerID)
Select r.CustomerID, r.CustomerName, t.Total_Sales, r.Repeat_sales,
(r.Repeat_Sales/t.Total_Sales) * 100 As Repeat_Revenue_Rate
From RepeatOrders r
Join TotalOrders t
On r.CustomerID = t.CustomerID
Order by Repeat_Revenue_Rate Desc;

-- =========================================
-- Q21. CUSTOMER LOYALTY RANKING
-- =========================================

With CustomerData as (Select c.CustomerID, c.CustomerName, o.Product, Count(*) As Purchase_Count,
Sum(o.Sales) As Total_Sales
From Orders o 
Join Customers c 
On o.CustomerID = c.CustomerID
Group By c.CustomerID, c.CustomerName, o.Product
Having Count(*) > 1),
RepeatOrders As (Select CustomerID, CustomerName, Sum(Total_sales) As Repeat_Sales
From CustomerData
Group By CustomerID, CustomerName),
TotalOrders As (Select CustomerID, Sum(Sales) As Total_Sales
From Orders
Group by CustomerID),
Ranked As (Select r.CustomerID, r.CustomerName, t.Total_Sales, r.Repeat_sales,
(r.Repeat_Sales/t.Total_Sales) * 100 As Repeat_Revenue_Rate
From RepeatOrders r
Join TotalOrders t
On r.CustomerID = t.CustomerID)
Select CustomerID, CustomerName, Total_Sales, Repeat_Sales, Repeat_Revenue_Rate,
dense_rank() Over(Order by Repeat_Revenue_Rate Desc) as Rnk
From Ranked;

-- =========================================
-- Q22. PRODUCT REVENUE CONTRIBUTION
-- =========================================

With ProductSales As (Select Product, Sum(Sales) As Product_Sales
From Orders
Group by Product),
TotalSales As (Select Product, Product_Sales, Sum(Product_Sales) Over() As Total_Sales
From ProductSales)
Select Product, Product_Sales, 
(Product_Sales/Total_Sales) * 100 As Revenue_Contribution
From TotalSales 
Order By Revenue_Contribution Desc;

-- =========================================
-- Q23. CATEGORY REVENUE CONTRIBUTION
-- =========================================

With CategorySales As (Select Category, Sum(Sales) As Category_Sales
From Orders
Group by Category),
TotalSales As (Select Category, Category_Sales, Sum(Category_Sales) Over() As Total_Sales
From CategorySales)
Select Category, Category_Sales, 
(Category_Sales/Total_Sales) * 100 As Revenue_Contribution
From TotalSales 
Order By Revenue_Contribution Desc;

-- =========================================
-- Q24. REGION REVENUE CONTRIBUTION
-- =========================================

With RegionSales As (Select Region, Sum(Sales) As Region_Sales
From Orders
Group by Region),
TotalSales As (Select Region, Region_Sales, Sum(Region_Sales) Over() As Total_Sales
From RegionSales)
Select Region, Region_Sales, 
(Region_Sales/Total_Sales) * 100 As Revenue_Contribution
From TotalSales 
Order By Revenue_Contribution Desc;

-- =========================================
-- Q25. REGION-WISE AVERAGE ORDER VALUE
-- =========================================

Select Region, Sum(Sales) as Total_Sales, avg(Sales) as Average_Sales_Value
From Orders
Group By Region;

-- =========================================
-- Q26. REGION-WISE CUSTOMER COUNT
-- =========================================

Select Region, Sum(Sales) as Total_Sales, Count(Distinct CustomerID) as Unique_Costomers
From Orders
Group By Region
Order By Total_Sales Desc;

-- =========================================
-- Q27. REGION-WISE AVERAGE CUSTOMER SPENDING
-- =========================================

with CustomerRegionSales As (
Select Region, CustomerID,
Sum(Sales) As Customer_Spending
From Orders
Group By Region, CustomerID)
Select Region, 
Avg(Customer_Spending) As Avg_Customer_Spending
From CustomerRegionSales
Group By Region;

-- =========================================
-- Q28. TOP CUSTOMER BY REGION
-- =========================================

With CustomerInfo As (Select o.Region, c.CustomerID, c.CustomerName,
Sum(o.Sales) As Total_Spending
From Orders o
Join Customers c 
On o.CustomerID = c.CustomerID
group by c.CustomerID, c.CustomerName, o.Region),
Ranking As (Select Region, CustomerName, Total_Spending,
dense_rank() Over(Partition By Region Order By Total_Spending Desc) As Rnk
From CustomerInfo) 
Select Region, CustomerName, Total_Spending
From Ranking
Where Rnk = 1
Order By Total_Spending Desc;

-- =========================================
-- Q29. TOP CUSTOMER REVENUE CONTRIBUTION BY REGION
-- =========================================

With CustomerInfo As (Select o.Region, c.CustomerID, c.CustomerName,
Sum(o.Sales) As Total_Spending
From Orders o
Join Customers c 
On o.CustomerID = c.CustomerID
group by c.CustomerID, c.CustomerName, o.Region),
TopCustomer As (Select Region, CustomerName, Total_Spending,
dense_rank() Over(partition By Region Order By Total_Spending Desc) as Rnk,
Sum(Total_Spending) Over(Partition By Region) As Region_Total
From CustomerInfo)
Select Region, CustomerName, Total_Spending, Region_Total,
(Total_Spending/Region_total) * 100 As Contribution
From TopCustomer
Where Rnk = 1
Order By Contribution Desc;

-- =========================================
-- Q30. REGION PERFORMANCE + TOP CUSTOMER
-- =========================================

With CustomerInfo As (Select o.Region, c.CustomerID, c.CustomerName,
Sum(o.Sales) As Total_Spending
From Orders o
Join Customers c 
On o.CustomerID = c.CustomerID
group by c.CustomerID, c.CustomerName, o.Region),
TopCustomer As (Select Region, CustomerName, Total_Spending,
dense_rank() Over(partition By Region Order By Total_Spending Desc) as Rnk,
Sum(Total_Spending) Over(Partition By Region) As Region_Total
From CustomerInfo)
Select Region, CustomerName, Total_Spending, Region_Total,
(Total_Spending/Region_total) * 100 As Contribution,
dense_rank() Over(Order By Region_Total Desc) As Region_Rank
From TopCustomer
Where Rnk = 1
Order By Region_Rank;


