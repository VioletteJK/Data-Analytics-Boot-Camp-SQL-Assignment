# 📊 Sizwe Coffee SQL Analysis Project

Project Overview
This project analyses sales and operational data for Sizwe Coffee (Pty), a coffee roastery and wholesale supplier based in Isando, Johannesburg, with a second distribution centre in Epping, Cape Town. It roasts green beans and sells to about 1,400 business customers - grocery chains, restaurant groups, independent cafés, hotels and offices. It does not own retail stores.

The goal was to answer eight business questions posed by management to provide key insights for Nomsa and Bongani based on the following,

Task 1 - Channel performance
Nomsa needs the revenue split by channel for FY2024 and FY2025 side by side, with the growth rate between them. One row per channel, three figures on each. FY2024 is orders placed on or before 30 June 2024. FY2025 is everything after that.

Task 2 - Where the profit actually comes from
For each product line, return revenue, cost of goods, gross profit and gross margin percentage. Sort by gross profit. In one or two sentences under your query: which line earns the most profit, and is it the same line that earns the highest margin?

Task 3 - The collections problem
Nomsa suspects the business is being paid more slowly than it used to be, and wants to know where the problem sits. For each channel, return the number of invoices, how many have been settled, how many are still open, the average number of days taken to settle, and the total value still outstanding. In two or three sentences: what does this tell you, and which channel would you investigate first?

Task 4 - The ten accounts that matter most
Bongani wants a one-page list of the ten largest customers by FY2025 revenue, showing the trading name, segment, province, the sales representative who owns the account, and the revenue. Not every customer has a sales representative. Make sure your query does not silently drop anyone.

Task 5 - A commercial gap
Trade promotions are how Sizwe supports its wholesale accounts. Bongani thinks some sizeable customers have been getting nothing. Return the fifteen highest-revenue Wholesale customers who have never received a trade promotion, with their segment and province. One sentence: what would you recommend doing about the top three?

Task 6 - Are the sales representatives hitting target?
Each sales representative carries a monthly revenue target. Return every sales representative with their territory, their monthly target, their actual FY2025 monthly average, and that average as a percentage of target. Sort by percentage of target, best first. Every sales representative must appear, including any who generated no revenue.

Task 7 - The shape of the year
Return monthly revenue across the full two years, with the percentage change on the previous month and a rolling three-month average alongside it. In two sentences: is there a seasonal pattern, and when is Sizwe's quietest month?

Task 8 - Why has the margin moved?
Gross margin fell from 34.7% in FY2024 to 33.0% in FY2025, while revenue grew nearly 9%. Nobody can explain it. For each product line, return revenue and gross margin for each financial year, plus that line's share of total revenue in that year. Then answer, in a short paragraph: what caused the margin decline? Your answer must point at specific
numbers in your result.

The Dataset
The analysis used the following Sizwe Coffee dataset:

Table 	Rows 	What it holds
customers 	1,400 	One row per customer - name, channel, segment, province, credit limit, assigned sales representative
products 	23 	One row per SKU - product line, pack size, list price, unit cost
sales_orders 	48,144 	One row per order - customer, order date, delivery date, channel, sales representative
sales_lines 	168,172 	One row per order line - SKU, units, unit price, discount, line revenue, cost of goods
ar_ledger 	48,144 	One row per customer invoice - amount, due date, amount settled, settlement date
reps 		18 	Sales representatives - territory, monthly target
rep_visits 	9,400 	Visits made by sales representatives to customers, with the outcome
trade_promotions 640 	Promotional support given to a customer on a SKU

Relationships between the table:
- sales_orders.customer_id →customers.customer_id
- sales_orders.order_id → sales_lines.order_id
- sales_lines.sku → products.sku
- sales_orders.rep_id and customers.rep_id → reps.rep_id
- ar_ledger.customer_id → customers.customer_id
- rep_visits.customer_id and trade_promotions.customer_id → customers.customer_id

Skills Demonstrated
SQL Technique	Task Used

Numeric SQL function (ROUND()),	clean data inside the query, without changing what is stored (Task 1- 8). 

Date Functions,	subtract and extracts parts of a date. Task 3, 6 and 7. 

Aggregation (SUM, AVG),	Calculating revenue, gross profit, gross margins, rolling averages. Task 1 – 8 for SUM, Task 3, 6 and 7. 

JOINS (inner join, left join),	Linking related tables. Task 1 - 8
CASE Statement	Conditional calculations. Task 1, 3, 4, and 6. 

CTEs,	Simplify complex queries and make them easier to read. Task 3, 4, 6 and 7
Window Function (LAG)	 Calculating the percentage change Task 7. 


How to Run
Database/Tool Used:
 Databricks platform using the databricks SQL,

Steps to Reproduce:
Load the provided Sizwe Coffee CSVs into the respective tables (customers, sales_reps, trade_promotions, etc) in databricks catalogue. Run each SQL query in sequence for the eight questions.

Key Insights
For Nomsa

Channel Growth Rate grew 8.5% and 8.4% from FY2024 to FY2025, respectively for both Wholesale and Subscription channels.

The collections problem: There are 3454 Wholesale and 44 Subscription invoices open proving that the business is being paid more slowly and this needs to be investigated.

Rolling Revenue Trend: Revenue is steadily increasing, but margin erosion is visible.

For Bongani

Promotion Gaps: 15 top wholesale customers with revenues over R1M each received no trade promotions — potential missed relationship opportunities.

The shape of the year: the seasonal pattern needs to be investigated, from August to December every financial year the is a drop in the monthly revenues with percentage change ranging from -13.1% to -2.5%.

📌 Conclusion:
The analysis shows that while revenue is growing, margin erosion is concentrated in key product lines. Trade promotion gaps for high-value wholesale customers need immediate attention and the percentage change need investigation to determine why only those months are affected.
